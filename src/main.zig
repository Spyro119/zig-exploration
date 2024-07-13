const std = @import("std");

const ProgramError = error{
    WrongAmountOfArguments,
};

pub fn main() !void {
    var file_path: []u8 = undefined;

    if (std.os.argv.len < 2) {
        std.log.err("Incorrect number of arguments: wanted 2, got {d}", .{std.os.argv.len});
        return ProgramError.WrongAmountOfArguments;
    }
    file_path = std.mem.sliceTo(std.os.argv[1], 1);

    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();
    var line_count: u64 = 0;
    const delimiter = [_]u8{'\n'};

    var buf_reader = std.io.bufferedReader(file.reader());

    var buffer: [std.fs.MAX_PATH_BYTES]u8 = undefined;
    while (true) {
        const number_of_read_bytes = try buf_reader.read(&buffer);

        if (number_of_read_bytes == 0) {
            break; // No more data
        }
        const number_of_lines = std.mem.count(u8, buffer[0..number_of_read_bytes], &delimiter);
        line_count += number_of_lines;
    }
    std.debug.print("finished reading\n", .{});
    std.debug.print("Line count: {d}\n", .{line_count});
}

test "simple test" {}
