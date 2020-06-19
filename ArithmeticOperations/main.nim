import os
import sequtils
import options


var source: seq[char] = newSeq[char]()
var sourceIndex: int = 0


type TokenKind = enum
  Punct      #記号
  Intliteral #整数トークン


type Token = ref object
  kind: TokenKind
  value: string


proc toString(str: seq[char]): string =
  result = newStringOfCap(len(str))
  for ch in str:
    add(result, ch)


proc getChar(): Option[char] =
  if sourceIndex == source.len:
    return none(char)

  var c: char = source[sourceIndex]
  sourceIndex+=1
  some(c)


proc ungetChar() =
  sourceIndex-=1


proc readNumber(c1: char): string =
  var number: seq[char] = @[c1]

  while true:
    var c: Option[char] = getChar()
    if c.isNone:
      break
    if '0' <= c.get() and c.get() <= '9':
      number.add(c.get())
    else:
      ungetChar()
      break

  number.toString



proc tokenize(): seq[Token] =
  var tokens = newSeq[Token]()
  echo "# Tokens : "

  while true:
    var c: Option[char] = getChar()
    if c.isNone:
      break

    case c.get()
    of ' ', '\t', '\n':
      continue
    of '0', '1', '2', '3', '4', '5', '6', '7', '8', '9':
      var intliteral = readNumber(c.get())
      var token = Token(kind: Intliteral, value: intliteral)
      tokens.add(token)
      echo token.value
    of ';', '+', '-', '*', '/':
      var s = $c.get()
      var token = Token(kind: Punct, value: s)
      tokens.add(token)
      echo token.value
    else:
      echo "tokenizer: Invalid char:" & c.get()

  tokens



proc main() =
  if paramCount() != 1:
    echo "引数の個数が正しくありません"
    quit(1)

  source = toSeq(commandLineParams()[0].items)

  var tokens = tokenize()

  echo "最後 ", tokens[0].value




when isMainModule:
  main()
