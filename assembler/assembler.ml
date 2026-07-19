open Str

type instrtype = Rtype|Mtype|Itype|Ltype|Stype|Btype|Jal|Jalr|Ecall

(* ( opcode,funct3,funct7 )*)
let table = [ 
  ("add", (0x33, 0x0, 0x00));
  ("sub", (0x33, 0x0, 0x20));
  ("sll", (0x33, 0x1, 0x00));
  ("slt", (0x33, 0x2, 0x00));
  ("sltu", (0x33, 0x3, 0x00));
  ("xor", (0x33, 0x4, 0x00));
  ("srl", (0x33, 0x5, 0x00));
  ("sra", (0x33, 0x5, 0x20));
  ("or", (0x33, 0x6, 0x00));
  ("and", (0x33, 0x7, 0x00));
  ("mul", (0x33, 0x0, 0x01));
  ("mulh", (0x33, 0x1, 0x01));
  ("mulhsu", (0x33, 0x2, 0x01));
  ("mulhu", (0x33, 0x3, 0x01));
  ("div", (0x33, 0x4, 0x01));
  ("divu", (0x33, 0x5, 0x01));
  ("rem", (0x33, 0x6, 0x01));
  ("remu", (0x33, 0x7, 0x01));
  ("addi", (0x13, 0x0, 0x00));
  ("slti", (0x13, 0x2, 0x00));
  ("sltiu", (0x13, 0x3, 0x00));
  ("xori", (0x13, 0x4, 0x00));
  ("ori", (0x13, 0x6, 0x00));
  ("andi", (0x13, 0x7, 0x00));
  ("slli", (0x13, 0x1, 0x00));
  ("srli", (0x13, 0x5, 0x00));
  ("srai", (0x13, 0x5, 0x20));
  ("lb", (0x03, 0x0, 0x00));
  ("lh", (0x03, 0x1, 0x00));
  ("lw", (0x03, 0x2, 0x00));
  ("lbu", (0x03, 0x4, 0x00));
  ("lhu", (0x03, 0x5, 0x00));
  ("sb", (0x23, 0x0, 0x00));
  ("sh", (0x23, 0x1, 0x00));
  ("sw", (0x23, 0x2, 0x00));
  ("beq", (0x63, 0x0, 0x00));
  ("bne", (0x63, 0x1, 0x00));
  ("blt", (0x63, 0x4, 0x00));
  ("bge", (0x63, 0x5, 0x00));
  ("bltu", (0x63, 0x6, 0x00));
  ("bgeu", (0x63, 0x7, 0x00));
  ("jal", (0x6F, 0x0, 0x00));  
  ("jalr", (0x67, 0x0, 0x00));  
  ("ecall", (0x73, 0x0, 0x00))
]

(* ABIs -> bit *)
let abis = [
  ("zero", 0); 
  ("ra", 1);
  ("sp", 2);
  ("gp", 3);
  ("tp", 4);
  ("t0", 5); (* temp regs *)
  ("t1", 6);
  ("t2", 7);
  ("s0", 8); (* callee saved regs*)
  ("fp", 8); (* frame pointer *)
  ("s1", 9);
  ("a0", 10); (* argument regs *)
  ("a1", 11);
  ("a2", 12);
  ("a3", 13);
  ("a4", 14);
  ("a5", 15);
  ("a6", 16);
  ("a7", 17);
  ("s2", 18);
  ("s3", 19);
  ("s4", 20);
  ("s5", 21);
  ("s6", 22);
  ("s7", 23);
  ("s8", 24);
  ("s9", 25);
  ("s10", 26);
  ("s11", 27);
  ("t3", 28);
  ("t4", 29);
  ("t5", 30);
  ("t6", 31);
]


let check instr = 
  match List.assoc_opt instr table with
  | Some (opcode, _, funct7) -> (match opcode with 
    | 0x33 -> if funct7=0x01 then Mtype else Rtype
    | 0x13 -> Itype
    | 0x03 -> Ltype
    | 0x23 -> Stype
    | 0x63 -> Btype
    | 0x6F -> Jal
    | 0x67 -> Jalr
    | 0x73 -> Ecall
    | _ -> failwith ("unknown opcode: " ^ instr)
  )
  | None -> failwith ("unknown opcode: " ^ instr)

(* encoders *)
(* for each line, nums represents bit shifts to get to proper format *)
let encodeRM instr rd rs1 rs2 = 
  let (opcode, funct3, funct7) = List.assoc instr table in 
  opcode lor (rd lsl 7) lor (funct3 lsl 12) lor (rs1 lsl 15) lor (rs2 lsl 20) lor (funct7 lsl 25)

let encodeIL instr rd rs1 imm = 
  let (opcode, funct3, funct7) = List.assoc instr table in 
  opcode lor (rd lsl 7) lor (funct3 lsl 12) lor (rs1 lsl 15) lor (imm lsl 20)

let encodeS instr rs1 rs2 offset =
  let (opcode, funct3, funct7) = List.assoc instr table in 
  opcode lor ((offset land 0x1F) lsl 7) lor (funct3 lsl 12) lor (rs1 lsl 15) lor (rs2 lsl 20) lor (((offset lsr 5) land 0x7F) lsl 25)

let encodeJAL instr offset rd = 
  let (opcode, funct3, funct7) = List.assoc instr table in
  opcode lor (rd lsl 7) lor (((offset lsr 12) land 0xFF) lsl 12) lor (((offset lsr 11) land 0x1) lsl 20) lor (((offset lsr 1) land 0x3FF) lsl 21) lor (((offset lsr 20) land 0x1) lsl 31)

let encodeB instr offset rs1 rs2 = 
  let (opcode, funct3, funct7) = List.assoc instr table in
  opcode lor (funct3 lsl 12) lor (rs1 lsl 15) lor (rs2 lsl 20) lor (((offset lsr 1) land 0xF) lsl 8) lor (((offset lsr 5) land 0x3F) lsl 25) lor (((offset lsr 11) land 0x1) lsl 7) lor (((offset lsr 12) land 0x1) lsl 31)


let regvert reg = match List.assoc_opt reg abis with
 | Some a -> a
 | None -> failwith("unknown reg: " ^ reg)

let infile = if String.length Sys.argv.(1) > 1 then Sys.argv.(1)  else "test1.txt"

let contents =  In_channel.with_open_text infile In_channel.input_all

let testinstruction = "add rd, rs1, rs2"

let filesplitter input = String.split_on_char '\n' input

let commstrip input = List.map ( fun x -> match String.split_on_char '#' x with
  | [] -> ""
  | h :: _ -> h 
  ) input 

let linesplitter input = List.map ( fun x -> Str.split(Str.regexp "[ ,\r]+") x) input

let stripempty input = List.filter (fun x -> x <> []) input

let increment = ref 0


(* pc jumps by 4 *)
let acc () = increment := !increment + 4

let symbols = Hashtbl.create 10

let insertsymbol input = Hashtbl.replace symbols input !increment

let run1 input = List.iter ( fun x -> 
  match x with
  | [] -> ()
  | h :: t -> 
    if String.contains h ':' then begin 
      insertsymbol (List.hd (String.split_on_char ':' h));
    if t <> [] then acc ()
    end else acc()
) input

(* increment for run2 *)
let addr = ref 0

let accaddr () = addr := !addr + 4

(* label to int conversion *)
let transfer input =
  match Hashtbl.find_opt symbols  input with
  | Some target -> target - !addr 
  | None -> int_of_string input

let run2 input = List.filter_map( fun x ->
  match x with 
  | [] -> None
  | h :: t -> if String.contains h ':' then None else begin
    let word = (match check h with
    | Rtype | Mtype -> 
      let rd = regvert (List.nth t 0) in
      let rs1 = regvert (List.nth t 1) in
      let rs2 = regvert (List.nth t 2) in
      encodeRM h rd rs1 rs2
    | Itype | Jalr ->
      let rd = regvert (List.nth t 0) in
      let rs1 = regvert (List.nth t 1) in
      let imm = int_of_string (List.nth t 2) in
      encodeIL h rd rs1 imm
    | Ltype -> (* format: instr rd, offset(rs2) so we must parse that but  *)
      let rd = regvert (List.nth t 0) in
      let a = String.split_on_char '(' (List.nth t 1) in
      let offset = int_of_string (List.hd a) in
      let rs1 = regvert (List.hd (String.split_on_char ')' (List.nth a 1))) in
      encodeIL h rd rs1 offset
    | Jal ->
      let rd = regvert (List.nth t 0) in
      let offset = transfer (List.nth t 1) in
      encodeJAL h offset rd
    | Btype ->
      let rs1 = regvert (List.nth t 0) in
      let rs2 = regvert (List.nth t 1) in 
      let offset = transfer (List.nth t 2) in
      encodeB h offset rs1 rs2
    | Stype ->
      let rs2 = regvert (List.nth t 0) in
      let a = String.split_on_char '(' (List.nth t 1) in
      let offset = int_of_string (List.hd a) in
      let rs1 = regvert (List.hd (String.split_on_char ')' (List.nth a 1))) in
      encodeS h rs2 rs1 offset
    | Ecall ->
      0x73)
    in accaddr();
    Some word
  end

    
  ) input

let outfile = if (String.length Sys.argv.(2) > 1) then Sys.argv.(2) else "results.bin"

let outbin filename words =
  let oc = open_out_bin filename in List.iter( fun word -> 
    output_byte oc (word land 0xFF);
    output_byte oc ((word lsr 8) land 0xFF);
    output_byte oc ((word lsr 16)land 0xFF);
    output_byte oc ((word lsr 24) land 0xFF)
    ) words;
    close_out oc

(* pipeline *)
let parsed = contents |> filesplitter |> commstrip |> linesplitter |> stripempty 

(* first run to get symbols*)
let () = run1 parsed

(* second run to encode *)
let encoded = run2 parsed

(* output *)
let () = outbin outfile encoded