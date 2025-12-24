let print_list print_elem lst =
  let rec aux = function
    (*If lst is empty*)
    | [] -> print_endline "]"
    (*If lst has exactly one element*)
    | x :: [] ->
        print_elem x;
        print_endline "]"
    (*If lst has more than one element*)
    | x :: xs ->
        print_elem x;
        print_string "; ";
        aux xs
  in
  print_string "[";
  aux lst

let rec quicksort lst =
  match lst with
  | [] -> []
  | pivot :: rest ->
      let smaller = List.filter (fun x -> x < pivot) rest in
      let larger = List.filter (fun x -> x >= pivot) rest in
      quicksort smaller @ [ pivot ] @ quicksort larger

let lst = [ 5; 3; 8; 1; 2; 7 ];;

let sorted_lst = quicksort lst in
print_list (fun x -> print_string (string_of_int x)) sorted_lst;

(*ocamlformat should be able to fix this indentation*)
      let str = " space indentation" in
   let x = -3 in
print_endline ("Diabolical " ^ string_of_int x ^ str)
