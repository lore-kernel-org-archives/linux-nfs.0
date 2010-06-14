From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: pNFS timeouts
Date: Mon, 14 Jun 2010 11:02:40 -0400
Message-ID: <4C164490.6010903@panasas.com>
References: <20100614085157.GS17703@ics.muni.cz> <4C163892.20201@panasas.com> <20100614142332.GB17703@ics.muni.cz> <4C1640DF.5070506@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:16309 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752038Ab0FNPCl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Jun 2010 11:02:41 -0400
In-Reply-To: <4C1640DF.5070506@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun. 14, 2010, 10:46 -0400, Benny Halevy <bhalevy@panasas.com> wrote:
> On Jun. 14, 2010, 10:23 -0400, Lukas Hejtmanek <xhejtman@ics.muni.cz> wrote:
>> Hi,
>>
>> On Mon, Jun 14, 2010 at 10:11:30AM -0400, Benny Halevy wrote:
>>> I'm not sure if that explains the 15 seconds delay.
>>> I wonder if it could be related to the nfsv4 grace period.
>>> Does this happen if you wait for a couple minutes after
>>> the server restarts before starting the test?
>>
>> I repeated the test after approx. 6 hours the server was restarted and it is
>> the same, the delay still happens. 
>>
>> But it could be something related, it complains about lease renewal:
>>
>> Jun 14 16:17:00 undomiel1 kernel: [187434.936220] nfs4_renew_state: done
>> Jun 14 16:17:00 undomiel1 kernel: [187434.936492] nfs41_sequence_done: Error 0 free the slot
>> Jun 14 16:17:00 undomiel1 kernel: [187434.936500] nfs4_free_slot: free_slotid 0 highest_used_slotid -1
>> Jun 14 16:17:00 undomiel1 kernel: [187434.936507] nfs41_sequence_call_done rpc_cred ffff88003d7a0300
>> Jun 14 16:17:00 undomiel1 kernel: [187434.936514] <-- nfs41_sequence_call_done
>> Jun 14 16:17:00 undomiel1 kernel: [187434.936522] nfs4_schedule_state_renewal: requeueing work. Lease period = 60
>> Jun 14 16:17:00 undomiel1 kernel: [187434.936530] --> nfs_put_client({2})
>> Jun 14 16:17:16 undomiel1 kernel: [187450.536014] nfs4_renew_state: start
>> Jun 14 16:17:16 undomiel1 kernel: [187450.536045] nfs4_renew_state: failed to call renewd. Reason: lease not expired
>> Jun 14 16:17:16 undomiel1 kernel: [187450.536056] nfs4_schedule_state_renewal: requeueing work. Lease period = 38
> 
> This looks like a complaint but it's actually saying that the "failure"
> is due to the fact that everything is OK (lease not expired)
> 
> BTW, is this the same issue that Jiri reported?
> http://marc.info/?l=linux-nfs&m=127619696004097&w=2

looking at http://charon.styxx.cz/tmp/pnfs/pnfs_write_log.txt
There seem to 15 seconds form after getting an NFS4ERR_DELAY
from a DS write to the respective commit.

[69615.596004] --> _pnfs_try_to_write_data
[69615.596004] _pnfs_try_to_write_data: Utilizing pNFS I/O
[69615.596004] pnfs_writepages: Writing ino:3898308 8192@40960
[69615.596004] get_lock_alloc_layout Begin
[69615.596004] get_lock_alloc_layout Return ffff88003b058338
[69615.596004] pnfs_has_layout:Begin
[69615.596004] pnfs_has_layout:Return lseg ffff88003b987840 take_ref 1 ref 7 valid 1
[69615.596004] pnfs_update_layout: Using cached lseg ffff88003b987840 for 8192@40960 iomode 2)
[69615.596004] pnfs_update_layout end (err:0) state 0x0 lseg ffff88003b987840
[69615.596004] pnfs_writepages: Calling layout driver (how 0) write with 2 pages
[69615.596004] --> filelayout_write_pagelist ino 3898308 nr_pages 2 pgbase 0 req 8192@40960 sync 0
[69615.596004] nfs4_pnfs_dserver_get: offset=40960, count=8192, si=0, dsi=0, stripe_count=1, stripe_unit=8192 first_stripe_index 0
[69615.596004] nfs4_pnfs_dserver_get: dev_id=00000351 00000001, ip:port=147.251.11.45.8.1, ds_idx=0 stripe_idx=0, offset=40960, count=8192
[69615.596004] filelayout_write_pagelist ino 3898308 8192@40960 DS:93fb0b2d:2049 147.251.11.45.8.1
[69615.596004] --> pnfs4_proc_write_setup ds_nfs_client ffff88003b98f800
[69615.596004] NFS:     0 initiated write call (req 0:10/3898308, 8192 bytes @ offset 40960)
[69615.596004] --> nfs4_setup_sequence clp ffff88003b98f800 session ffff88003cd8bc00 sr_slotid 128
[69615.596004] --> nfs41_setup_sequence
[69615.596004] --> nfs4_find_slot used_slots=001f highest_used=4 max_slots=16
[69615.596004] <-- nfs4_find_slot used_slots=003f highest_used=5 slotid=5 
[69615.596004] <-- nfs41_setup_sequence slotid=5 seqid=5
[69615.596004] <-- nfs4_setup_sequence status=0
[69615.596004] encode_compound: tag=
[69615.596004] encode_sequence: sessionid=1276181646:3:3:0 seqid=5 slotid=5 max_slotid=5 cache_this=1
[69615.596004] pnfs_writepages End (trypnfs:0)
[69615.791232] pnfs_writeback_done: Begin (status -10008)
[69615.791238] put_lseg: lseg ffff88003b987840 ref 7 valid 1
[69615.794450] NFS:  6195 nfs_writeback_done (status -10008 count 8192)
[69615.794450] pnfs4_write_done DS write
[69615.794450] nfs41_sequence_done: Error 0 free the slot 
[69615.794450] nfs4_free_slot: free_slotid 0 highest_used_slotid 5
[69615.794450] <-- pnfs4_write_done status= -11
...
[69616.196974] pnfs_update_last_write: Wrote 8192@40960 bpos 0, epos: 49151
[69616.196979] pnfs_need_layoutcommit: has_layout=1 ctx=ffff88003b987640
[69616.196983] nfs_writeback_done DS write
[69616.196992] NFS:  6197 write (0:10/3898308 4096@16384) marked for commit
[69616.197000] NFS:  6197 write (0:10/3898308 4096@20480) marked for commit
[69616.197008] NFS:  6198 write (0:10/3898308 4096@24576) marked for commit
[69616.197015] NFS:  6198 write (0:10/3898308 4096@28672) marked for commit
[69616.197022] NFS:  6199 write (0:10/3898308 4096@32768) marked for commit
[69616.197029] NFS:  6199 write (0:10/3898308 4096@36864) marked for commit
[69616.197037] NFS:  6200 write (0:10/3898308 4096@40960) marked for commit
[69616.197044] NFS:  6200 write (0:10/3898308 4096@45056) marked for commit
[69616.197069] filelayout_write_call_done new off 49152 orig offset 49152
[69616.197078] pnfs_writeback_done: Begin (status 8192)
...
[69630.789213] _pnfs_try_to_commit: Utilizing pNFS I/O
[69630.789220] pnfs_commit: Begin
[69630.789226] get_lock_alloc_layout Begin
[69630.789241] get_lock_alloc_layout Return ffff88003b058338
[69630.789245] pnfs_has_layout:Begin
[69630.789249] pnfs_has_layout:Return lseg ffff88003b987840 take_ref 1 ref 2 valid 1
[69630.789254] pnfs_update_layout: Using cached lseg ffff88003b987840 for 189@0 iomode 2)
[69630.789260] pnfs_update_layout end (err:0) state 0x0 lseg ffff88003b987840
[69630.789264] pnfs_commit: Calling layout driver commit
[69630.789270] filelayout_commit data ffff88003cfe7a80 pnfs_client (null) nfslay ffff88003b987880 sync 1
[69630.789276] filelayout_commit stripesize 8192
[69630.789281] nfs4_pnfs_dserver_get: offset=0, count=4096, si=0, dsi=0, stripe_count=1, stripe_unit=8192 first_stripe_index 0
[69630.789289] nfs4_pnfs_dserver_get: dev_id=00000351 00000001, ip:port=147.251.11.45.8.1, ds_idx=0 stripe_idx=0, offset=0, count=4096
[69630.789297] filelayout_commit: Initiating commit: 78013@0 USE DS:
[69630.789301]         ip_addr 93fb0b2d
[69630.789305]         port 2049
[69630.789308]         client ffff88003b98f800
[69630.789311]         ref count 1
[69630.789314]         cl_exchange_flags 60001
[69630.789317]         ip:port 147.251.11.45.8.1
[69630.789322] --> pnfs4_proc_commit_setup ds_nfs_client ffff88003b98f800 commit_through_mds 0
[69630.789327] NFS:     0 initiated commit call
[69630.789341] --> nfs4_setup_sequence clp ffff88003b98f800 session ffff88003cd8bc00 sr_slotid 128
[69630.789347] --> nfs41_setup_sequence
[69630.789355] --> nfs4_find_slot used_slots=0000 highest_used=-1 max_slots=16
[69630.789365] <-- nfs4_find_slot used_slots=0001 highest_used=0 slotid=0 
[69630.789370] <-- nfs41_setup_sequence slotid=0 seqid=23
[69630.789374] <-- nfs4_setup_sequence status=0
[69630.789378] encode_compound: tag=
[69630.789382] encode_sequence: sessionid=1276181646:3:3:0 seqid=23 slotid=0 max_slotid=0 cache_this=1
[69630.789403] pnfs_commit End (trypnfs:0)
[69630.790916] pnfs_commit_done: Begin (status 0)
[69630.790924] put_lseg: lseg ffff88003b987840 ref 2 valid 1
[69630.790929] NFS:  6205 nfs_commit_done (status 0)
[69630.790935] --> pnfs4_commit_done task->tk_status 0
[69630.790940] pnfs4_commit_done DS commit
[69630.790944] nfs41_sequence_done: Error 0 free the slot 
[69630.790958] nfs4_free_slot: free_slotid 0 highest_used_slotid -1
[69630.790966] <-- pnfs4_commit_done
[69630.790975] NFS:       commit (0:10/3898308 4096@0) OK
[69630.790982] NFS:       commit (0:10/3898308 4096@4096) OK
[69630.790988] NFS:       commit (0:10/3898308 4096@8192) OK
[69630.790993] NFS:       commit (0:10/3898308 4096@12288) OK
[69630.790999] NFS:       commit (0:10/3898308 4096@16384) OK
[69630.791005] NFS:       commit (0:10/3898308 4096@20480) OK
[69630.791010] NFS:       commit (0:10/3898308 4096@24576) OK
[69630.791016] NFS:       commit (0:10/3898308 4096@28672) OK
[69630.791021] NFS:       commit (0:10/3898308 4096@32768) OK
[69630.791027] NFS:       commit (0:10/3898308 4096@36864) OK
[69630.791033] NFS:       commit (0:10/3898308 4096@40960) OK
[69630.791042] NFS:       commit (0:10/3898308 4096@45056) OK
[69630.791052] NFS:       commit (0:10/3898308 4096@49152) OK
[69630.791058] NFS:       commit (0:10/3898308 4096@53248) OK
[69630.791064] NFS:       commit (0:10/3898308 4096@57344) OK
[69630.791069] NFS:       commit (0:10/3898308 4096@61440) OK
[69630.791075] NFS:       commit (0:10/3898308 4096@65536) OK
[69630.791080] NFS:       commit (0:10/3898308 4096@69632) OK
[69630.791086] NFS:       commit (0:10/3898308 4096@73728) OK
[69630.791091] NFS:       commit (0:10/3898308 189@77824) OK


> 
> Benny
> 
>>
>> The full log can be found at:
>> http://undomiel.ics.muni.cz/tmp/nfs-log.txt
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
