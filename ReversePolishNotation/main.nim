#[
逆ポーランド記法

1 + 2 * 3 = 7
1 2 3 * + 

(3 + 4) * (1 - 2) = -7
3 4 + 1 2 - *

( 1 + 2 ) * ( 3 - 4 ) / ( 5 + 6 ) = -0.2727272727272727
1 2 + 3 4 - * 5 6 + /

( 1 + 5 ) * ( 2 + 3 ) = 30
1 5 + 2 3 + *

5 + 4 * 3 + 2 / 6 = 17.333333333333332
5 4 3 * 2 6 / + + 

(1 + 4) * (3 + 7) / 5 = 10
1 4 + 3 7 + * 5 /

]#

import strutils

var stack = newSeq[float]()

proc rpn(s: string): float =
  for v in s.split:
    if v != "":
      try:
        stack.add(v.parseFloat)
      except:
        let n2 = stack.pop
        let n1 = stack.pop

        case v
        of "+":
          stack.add(n1+n2)
        of "-":
          stack.add(n1-n2)
        of "*":
          stack.add(n1*n2)
        of "/":
          stack.add(n1/n2)

  stack[0]

echo "逆ポーランド記法入力"
let input = readLine(stdin)
let ans = rpn(input)
echo "答え：" & $ans
