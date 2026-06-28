open Str

let testinstruction = "add rd, rs1, rs2"
let linesplitter Str.split(Str.regexp "[ ,]+") 