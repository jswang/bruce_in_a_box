module helper_tasks();

//sort an array of 3 eleemnts. sorted[3] = biggest, sorted[0] = smallest
task sort;
input unsigned [22:0] in_unsorted_array_0;
input unsigned [22:0] in_unsorted_array_1;
input unsigned [22:0] in_unsorted_array_2;
input unsigned [22:0] in_unsorted_array_3;

input [1:0]           in_unsorted_array_name_0;
input [1:0]           in_unsorted_array_name_1;
input [1:0]           in_unsorted_array_name_2;
input [1:0]           in_unsorted_array_name_3;

output [1:0]          sorted_array_name_0;
output [1:0]          sorted_array_name_1;
output [1:0]          sorted_array_name_2;
output [1:0]          sorted_array_name_3;

reg [22:0] temp;
reg [1:0] temp_name;

reg unsigned [22:0] unsorted_array[0:3];
reg unsigned [1:0] unsorted_array_name[0:3];
begin
    integer i;
    integer n;
    integer newn;
    unsorted_array[0] = in_unsorted_array_0;
    unsorted_array[1] = in_unsorted_array_1;
    unsorted_array[2] = in_unsorted_array_2;
    unsorted_array[3] = in_unsorted_array_3;
    unsorted_array_name[0] = in_unsorted_array_name_0;
    unsorted_array_name[1] = in_unsorted_array_name_1;
    unsorted_array_name[2] = in_unsorted_array_name_2;
    unsorted_array_name[3] = in_unsorted_array_name_3;

    newn = 0;
    for (n = 0; n < 4; n = n + 1) begin
        for (i = 1; i < 3; i = i + 1) begin
            if (unsorted_array[i-1] > unsorted_array[i]) begin
                //swap actual values
                temp = unsorted_array[i]; 
                unsorted_array[i] = unsorted_array[i-1];
                unsorted_array[i-1] = temp;
                newn = i;

                //swap the names of the values
                temp_name = unsorted_array_name[i]; 
                unsorted_array_name[i] = unsorted_array_name[i-1];
                unsorted_array_name[i-1] = temp_name;
            end
        end
    end
    sorted_array_name_3 = unsorted_array_name[3];
    sorted_array_name_2 = unsorted_array_name[2];
    sorted_array_name_1 = unsorted_array_name[1];
    sorted_array_name_0 = unsorted_array_name[0];
end
endtask

endmodule