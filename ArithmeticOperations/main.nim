import os
import sequtils
import strutils
import options

var
  input: seq[char] = newSeq[char]()
  index: int = 0


type
  TokenKind = enum
    Symbol
    Number


  Token = object
    kind: TokenKind
    value: string


proc toString(str: seq[char]): string =
  result = newStringOfCap(len(str))
  for ch in str:
    add(result, ch)


proc getChar(): Option[char] =
  if index == input.len:
    return none(char)

  var c: char = input[index]
  inc(index)
  some(c)


proc ungetChar() =
  dec(index)


proc readNumber(c1: char): string =
  var number: seq[char] = @[c1]

  while true:
    var c: Option[char] = getChar()
    if c.isNone:
      break
    if '0' <= c.get and c.get <= '9':
      number.add(c.get)
    elif '.' == c.get:
      number.add(c.get)
    else:
      ungetChar()
      break

  number.toString


proc tokenize(): seq[Token] =
  var tokens = newSeq[Token]()

  while true:
    var c: Option[char] = getChar()
    if c.isNone:
      break

    case c.get
    of ' ', '\t', '\n':
      continue
    of '0', '1', '2', '3', '4', '5', '6', '7', '8', '9':
      var num = readNumber(c.get)
      var token = Token(kind: Number, value: num)
      tokens.add(token)
    of '+', '-', '*', '/', '(', ')':
      var s = $c.get
      var token = Token(kind: Symbol, value: s)
      tokens.add(token)
    else:
      echo "tokenizer: Invalid char:" & c.get

  tokens


# 操車場アルゴリズム
proc syaParse(tokens: seq[Token]): seq[string] =

  var stack: seq[string] = newSeq[string]()
  var queue: seq[string] = newSeq[string]()

  for v in tokens:
    if v.kind == Number:
      queue.add(v.value)
    else:
      case v.value
      of "+":
        if stack.len > 0:
          if stack[^1] == "*" or stack[^1] == "/":
            queue.add(stack.pop)
            if stack.len > 0:
              if stack[^1] == "+" or stack[^1] == "-":
                queue.add(stack.pop)
        stack.add(v.value)
      of "-":
        if stack.len > 0:
          if stack[^1] == "*" or stack[^1] == "/":
            queue.add(stack.pop)
            if stack.len > 0:
              if stack[^1] == "+" or stack[^1] == "-":
                queue.add(stack.pop)
        stack.add(v.value)
      of "*":
        stack.add(v.value)
      of "/":
        stack.add(v.value)
      of "(":
        stack.add(v.value)
      of ")":
        # ( が現れるまで繰り返しpopしてqueueにadd
        while true:
          if stack.len > 0:
            var p = stack.pop
            queue.add(p)
            if p == "(":
              break
          else:
            break

  while stack.len > 0:
    queue.add(stack.pop)

  result = queue.filterIt(it != "(")


proc rpn(s: seq[string]): float =

  var stack: seq[float] = newSeq[float]()

  for v in s:
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


proc main() =
  if paramCount() != 1:
    echo "引数の個数が正しくありません"
    quit(1)

  var original = commandLineParams()[0]

  input = toSeq(original.items)

  var tokens = tokenize()

  var rpnArr = syaParse(tokens)

  echo "入力：", original

  echo "出力：", rpnArr.join(" ")

  let ans = rpn(rpnArr)

  echo "回答：", ans



when isMainModule:
  main()
