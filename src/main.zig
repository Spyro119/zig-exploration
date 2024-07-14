const std = @import("std");

const ProgramError = error{
    WrongAmountOfArguments,
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const buffer = try allocator.alloc(u8, 1024 * 3); // 3kb seems to be the sweet spot
    defer allocator.free(buffer);

    if (std.os.argv.len < 2) {
        std.log.err("Incorrect number of arguments: wanted 2, got {d}", .{std.os.argv.len});
        return ProgramError.WrongAmountOfArguments;
    }

    const file_path: []u8 = std.mem.sliceTo(std.os.argv[1], 1);
    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    var delimiter = [_]u8{'\n'};
    var line_count: u64 = 0;
    var buf_reader = std.io.bufferedReader(file.reader());
    std.debug.print("buffer len: {d}bytes\n", .{buffer.len});
    line_count = try read_file(&buf_reader, buffer, &delimiter);
    std.debug.print("Line count: {d}\n", .{line_count});
}

// Reads the file by buffer length and return its line count.
// Returns the line count (u64)
pub fn read_file(buffer_reader: anytype, buffer: []u8, delimiter: []u8) anyerror!u64 {
    var number_of_lines: u64 = 0;
    while (true) {
        const number_of_read_bytes = try buffer_reader.read(buffer);
        if (number_of_read_bytes == 0) {
            break;
        }

        number_of_lines += std.mem.count(u8, buffer[0..number_of_read_bytes], delimiter);
    }
    return number_of_lines;
}
