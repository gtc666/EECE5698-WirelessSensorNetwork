##########AWK SCRIPT###############

BEGIN {
    start_time_cnt = 0;
    end_time_cnt = 0;
    delay_cnt = 0;
    avg_delay = 0;
    seq_no = 0;

    start_time[200000];
    end_time[200000];
}

{
    time = $2;
    seq_no = $6;
    packet_id = $12;


    # Check the start time based on "s" and "exp" symbols
    if (($1 == "s") && ($4 == "AGT") && ( $7 == "exp" )) {
        start_time[seq_no] = time;
        start_time_cnt += 1;
        #printf("Start time: %f. Sequence No: %d.\n", start_time[seq_no], seq_no);
    }
    # Check the end time based on "r" and "exp" symbols
    if (($1 == "r") && ($4 == "AGT") && ( $7 == "exp")) {
        end_time[seq_no] = time;
        end_time_cnt += 1;
        #printf("End time: %f. Sequence No: %d.\n", end_time[seq_no], seq_no);
    }

}

END {
    printf("Send count: %d. Receive count: %d.\n", start_time_cnt, end_time_cnt);
    for (i = 0; i < start_time_cnt; i ++) {
        if (end_time[i] != 0) {
            avg_delay += end_time[i] - start_time[i];
            printf("No: %d. End time: %f. Start time: %f. Difference: %f.\n", i, end_time[i], start_time[i], end_time[i] - start_time[i]);
            delay_cnt += 1;
        }
    }
    avg_delay = avg_delay / delay_cnt;
    printf("Received count: %d. Average delay for all pairs: %f.\n", delay_cnt, avg_delay);

    print avg_delay >> "delay.txt"
}



