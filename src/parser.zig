const std = @import("std");
const ast = @import("ast.zig");
const lexer = @import("lexer.zig");


pub const Parser = struct {
    tokens:[]lexer.Token = &[_]lexer.Token{},
    idx: usize = 0,

    fn parse_statement(self: Parser) !ast.Stmt {
        // in the future for, while etc.
        // return .{.expr = try self.parse_expr()};
        return try self.parse_expr();
    }
    fn parse_expr(self: Parser) !ast.Stmt {
        return self.parse_primary_expr();
    }

    fn parse_primary_expr(self:Parser) !ast.Stmt {
        const tk = self.tokens[self.idx];
        switch (tk.type) {
            lexer.TokenType.Number => {
                const float = try std.fmt.parseFloat(f32, tk.value);
                return .{.numeric_literal = .{.kind = .NumericLiteral, .value = float}};
            },
            lexer.TokenType.Identifier => return .{.identifier = .{ .kind = .Identifier, .symbol = tk.value }},
            // lexer.TokenType.Number => return .{.numeric_literal =  .{}},
            else => {
                @panic("Unknown token!!");
            }
        }
    }

    fn not_eof(self: Parser) bool {
        return self.tokens[self.idx].type != lexer.TokenType.EOF;

    }
    pub fn produceAST(self: *Parser, alloc: std.mem.Allocator, source_code: []const u8) !ast.Program {
        self.tokens = try lexer.tokenize(alloc, source_code);
        defer alloc.free(self.tokens);
        self.idx = 0;
        var program: ast.Program = .{
            .kind = .Program,
            .body = undefined, 
        };

        var body = try std.ArrayList(ast.Stmt).initCapacity(alloc, 128);
        // defer alloc.free(body);
        // self.idx = 0;
        while (self.not_eof()){
            try body.append(alloc, try self.parse_statement());
            self.idx += 1;
        }
        program.body = try body.toOwnedSlice(alloc);
        return program;
    }
};

test "Parser: parse identifier and numeric expression" {
    const t = std.testing;
    var parser:Parser = .{
    } ;
    const alloc = t.allocator;
    const prg = try parser.produceAST(alloc, "foo 1001");
    // const prg = try parser.produceAST(alloc, "foo");
    defer alloc.free(prg.body);
    // _ = prg;
    // std.debug.print("DEBUG!:{any}", .{prg});
    // const output:[]const ast.Stmt = &[_]ast.Stmt{
    //         .{ .expr = .{.identifier = .{ .symbol = "foo", .kind = .Identifier }}},
    //         .{ .expr = .{.numeric_literal = .{.kind = .NumericLiteral, .value=1001}}},
    // };
    var body  = [_]ast.Stmt{
       .{.identifier = .{.kind = .Identifier, .symbol = "foo"}},
       .{.numeric_literal = .{.kind = .NumericLiteral, .value = 1001}},
    };
    const output:ast.Program = .{
        .kind = .Program,
        .body = &body,
    };
    // const output:[]const ast.Stmt = &[_]ast.Stmt{
    //    .{.identifier = .{.kind = .Identifier, .symbol = "foo"}},
    //    .{.numeric_literal = .{.kind = .NumericLiteral, .value = 1001}},
    // };
    std.debug.print("{any}", .{prg});
    try t.expectEqualDeep(output, prg);
    // for (prg.body, output) |value, value2| {
    //     switch (value2) {
    //         .program =>  std.debug.print("{any}", .{value.program}),
    //         .expr => {
    //             std.debug.print("{any}", .{value.expr});
    //             try t.expectEqualDeep(value.expr, value2.expr );
    //         }
    //     }
    // }

}
