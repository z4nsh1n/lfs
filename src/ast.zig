const std = @import("std");

pub const NodeType = enum {
    Program,
    NumericLiteral,
    Identifier,
    BinaryExpr,
    // CallExpr,
    // UnaryEpx,
    // FunctionDecl,
};

pub const Stmt = union(enum) {
    program: Program,
    // expr: Expr,
    binary: BinaryExpr,
    identifier:Identifier,
    numeric_literal:NumericLiteral
};

// pub const Expr = union(enum) {
//     binary: BinaryExpr,
//     identifier:Identifier,
//     numeric_literal:NumericLiteral
//     // unary: Unary,
// };

pub const Program = struct {
    kind: NodeType = .Program,
    body: []Stmt,
};

pub const BinaryExpr = struct {
    kind: NodeType = .BinaryExpr,
    left: *BinaryExpr,
    right: *BinaryExpr,
    operator: []const u8,
};

pub const Identifier = struct {
    kind: NodeType = .Identifier,
    symbol: []const u8,
};

pub const NumericLiteral = struct {
    kind:NodeType = .NumericLiteral,
    value: f32 = 0.0,
};


