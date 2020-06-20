import os
import sequtils
import strutils
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



var tokens: seq[Token] = newSeq[Token]()
var tokenIndex: int = 0


proc getToken(): Option[Token] =
  if tokenIndex == tokens.len:
    return none(Token)

  var token: Token = tokens[tokenIndex]
  tokenIndex+=1
  some(token)


type Expr = ref object
  kind: string     # "intliteral", "unary"
  intval: int      # for intliteral
  operator: string # "-", "+", ...
  operand: Expr    # for unary expr
  left: Expr       # for binary expr
  right: Expr      # for binary expr


proc parseUnaryExpr(): Expr =
  var token = getToken()
  case token.get().kind
  of Intliteral:
    var i: int = token.get().value.parseInt
    return Expr(kind: "intliteral", intval: i)
  of Punct:
    return Expr(
      kind: "unary",
      operator: token.get().value,
      operand: parseUnaryExpr()
    )


proc parse(): Expr =
  var expr = parseUnaryExpr()

  while true:
    var token = getToken()
    if token.isNone or token.get().value == ";":
      return expr

    case token.get().value
    of "+", "-", "*", "/":
      return Expr(
        kind: "binary",
        operator: token.get().value,
        left: expr,
        right: parseUnaryExpr(),
      )
    else:
      discard



proc generateExpr(expr: Expr) =
  case expr.kind
  of "intliteral":
    echo expr.intval
  of "unary":
    case expr.operator
    of "-":
      echo expr.operand.intval
    of "+":
      echo expr.operand.intval
    else:
      echo "generator: Unknown unary operator:", expr.operator

  of "binary":
    echo expr.left.intval
    echo expr.right.intval
    case expr.operator
    of "+":
      echo "  addq %%rcx, %%rax"
    of "-":
      echo "  subq %%rcx, %%rax"
    of "*":
      echo "  imulq %%rcx, %%rax"
    of "/":
      echo "  movq $0, %%rdx"
      echo "  idiv %%rcx"
    else:
      echo "generator: Unknown binary operator:", expr.operator

  else:
    echo "generator: Unknown expr.kind:", expr.kind


proc main() =
  if paramCount() != 1:
    echo "引数の個数が正しくありません"
    quit(1)

  source = toSeq(commandLineParams()[0].items)

  tokens = tokenize()
  var expr = parse()

  generateExpr(expr)

  echo expr[]
  echo expr.left[]
  echo expr.left.operand[]
  echo expr.right[]
  # writeLine(stdout,expr)




when isMainModule:
  main()
