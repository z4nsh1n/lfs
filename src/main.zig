const std = @import("std");

// pub const std_options = struct {
//     pub const fmt_max_depth = 10;
// };
pub const std_options = std.Options{.fmt_max_depth = 10};

const Io = std.Io;

const lfs = @import("lfs");
const parser = @import("parser.zig");

pub fn main(init: std.process.Init) !void {
    // const source = try std.Io.Dir.cwd().readFileAlloc(init.io, "./test.txt", init.gpa, .unlimited);
    // const tokens = try lfs.lexer.tokenize(init.gpa, source);
    // defer init.gpa.free(source);
    // defer init.gpa.free(tokens);
    //
    // for (tokens) |t| {
    //     std.debug.print("{any}, \"{s}\"\n", .{t.type, t.value});
    // }
    var p:parser.Parser = .{};
    var read_buffer:[4096]u8 = undefined;
    var reader = Io.File.stdin().readerStreaming(init.io, &read_buffer);
    var interface = &reader.interface;
    
    while (true){
        std.debug.print("> ", .{});
        const line = interface.takeDelimiter('\n') catch |err| {
            switch (err) {
                error.StreamTooLong => {
                    try interface.discardAll(10);
                    std.debug.print("Line is to long\n", .{});
                    continue;
            },
                else => return err,
            }
        } orelse break;
        const ast = try p.produceAST(init.gpa, line);
        defer init.gpa.free(ast.body);
        std.debug.print("ast: {any}\n", .{ast});
    }
}
