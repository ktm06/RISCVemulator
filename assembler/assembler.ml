open Str

type instrtype = Rtype|Mtype|Itype|Ltype|Stype|Btype|Jal|Jalr

(* ( opcode,funct3,funct7 )*)
let table = [ 
  ("add",    (0x33, 0x0, 0x00));
  ("sub",    (0x33, 0x0, 0x20));
  ("sll",    (0x33, 0x1, 0x00));
  ("slt",    (0x33, 0x2, 0x00));
  ("sltu",   (0x33, 0x3, 0x00));
  ("xor",    (0x33, 0x4, 0x00));
  ("srl",    (0x33, 0x5, 0x00));
  ("sra",    (0x33, 0x5, 0x20));
  ("or",     (0x33, 0x6, 0x00));
  ("and",    (0x33, 0x7, 0x00));
  ("mul",    (0x33, 0x0, 0x01));
  ("mulh",   (0x33, 0x1, 0x01));
  ("mulhsu", (0x33, 0x2, 0x01));
  ("mulhu",  (0x33, 0x3, 0x01));
  ("div",    (0x33, 0x4, 0x01));
  ("divu",   (0x33, 0x5, 0x01));
  ("rem",    (0x33, 0x6, 0x01));
  ("remu",   (0x33, 0x7, 0x01));
  ("addi",   (0x13, 0x0, 0x00));
  ("slti",   (0x13, 0x2, 0x00));
  ("sltiu",  (0x13, 0x3, 0x00));
  ("xori",   (0x13, 0x4, 0x00));
  ("ori",    (0x13, 0x6, 0x00));
  ("andi",   (0x13, 0x7, 0x00));
  ("slli",   (0x13, 0x1, 0x00));
  ("srli",   (0x13, 0x5, 0x00));
  ("srai",   (0x13, 0x5, 0x20));
  ("lb",     (0x03, 0x0, 0x00));
  ("lh",     (0x03, 0x1, 0x00));
  ("lw",     (0x03, 0x2, 0x00));
  ("lbu",    (0x03, 0x4, 0x00));
  ("lhu",    (0x03, 0x5, 0x00));
  ("sb",     (0x23, 0x0, 0x00));
  ("sh",     (0x23, 0x1, 0x00));
  ("sw",     (0x23, 0x2, 0x00));
  ("beq",    (0x63, 0x0, 0x00));
  ("bne",    (0x63, 0x1, 0x00));
  ("blt",    (0x63, 0x4, 0x00));
  ("bge",    (0x63, 0x5, 0x00));
  ("bltu",   (0x63, 0x6, 0x00));
  ("bgeu",   (0x63, 0x7, 0x00));
  ("jal",    (0x6F, 0x0, 0x00));  
  ("jalr",   (0x67, 0x0, 0x00));  
]

let check instr = 
  let (opcode, _, funct7) = List.assoc instr table in match opcode with
  | 0x33 -> if funct7=0x01 then Mtype else Rtype
  | 0x13 -> Itype
  | 0x03 -> Ltype
  | 0x23 -> Stype
  | 0x63 -> Btype
  | 0x6F -> Jal
  | 0x67 -> Jalr
  | _ -> failwith ("unknown opcode: " ^ instr)

let encodeR instr rd rs1 rs2 = 
  let (opcode, funct3, funct7) = List.assoc instr table in opcode
  lor (rd lsl 7) lor (funct3 lsl 12) lor (rs1 lsl 15) lor (rs2 lsl 20) lor (funct7 lsl 25)




let contents = In_channel.with_open_text "test1.txt" In_channel.input_all

let testinstruction = "add rd, rs1, rs2"

let filesplitter input = String.split_on_char '\n' input

let commstrip input = List.map ( fun x -> match String.split_on_char '#' x with
  | [] -> ""
  | h :: _ -> h 
  ) input 

let linesplitter input = List.map ( fun x -> Str.split(Str.regexp "[ ,\r]+") x) input

let stripempty input = List.filter (fun x -> x <> []) input

let increment = ref 0

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

(*
let run2 input = List.iter ( fun x ->
  match x with 
  | [] -> ()
  | h :: t -> 
    begin 
    if (check h)=Rtype
      encodeR
      
      
    
  )
*) 


(* pipeline here *)
let parsed = contents |> filesplitter |> commstrip |> linesplitter |> stripempty 

let () = run1 parsed

let () = Hashtbl.iter (fun k v -> Printf.printf "%s -> %d\n" k v) symbols
