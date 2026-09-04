module ast

import compiler.core { Span }

pub const empty_node = Node(EmptyNode(0))

pub type Node = Stmt | Block | EmptyNode

pub type EmptyNode = u8

pub type Stmt = Decl | PrintStmt | IfStmt | ForStmt | Expr

pub type Decl = TypeDecl | VarDecl | ListDecl | ArrayDecl | EnumDecl | FuncDecl | StructDecl

pub type Expr = AssignExpr | BinaryExpr | UnaryExpr | LiteralExpr | ScanExpr

pub struct Block {
pub:
	stmts []Stmt
	span  Span
}

pub struct TypeDecl {
pub:
	expr Expr
	span Span
}

pub struct VarDecl {
pub:
	type string
	expr Expr
	span Span
}

pub struct ListDecl {
pub:
	item_type string
	expr      Expr
	span      Span
}

pub struct ArrayDecl {
pub:
	key_type   string
	value_type string
	expr       Expr
	span       Span
}

pub struct EnumDecl {
	span Span
}

pub struct FuncDecl {
	span Span
}

pub struct StructDecl {
	span Span
}

pub struct PrintStmt {
pub:
	expr Expr
	span Span
}

pub struct IfStmt {
pub:
	cond  Expr
	left  Block
	right &Block = unsafe { nil }
	span  Span
}

pub struct ForStmt {
pub:
	cond  Expr
	left  Block
	right &Block = unsafe { nil }
	span  Span
}

pub struct ScanExpr {
pub:
	prompt Expr
	span   Span
}

pub struct AssignExpr {
pub:
	left  Expr
	right Expr
	span  Span
}

pub struct BinaryExpr {
pub:
	left  Expr
	right Expr
	op    string
	span  Span
}

pub struct UnaryExpr {
pub:
	expr Expr
	op   string
	span Span
}

pub struct LiteralExpr {
pub:
	name  string
	value string
	span  Span
}
