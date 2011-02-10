Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:40982 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750893Ab1BJOyS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Feb 2011 09:54:18 -0500
Date: Thu, 10 Feb 2011 09:54:16 -0500
From: Jim Rees <rees@umich.edu>
To: linux-nfs@vger.kernel.org
Cc: peter honeyman <honey@citi.umich.edu>
Subject: Re: hung task in iozone test on nfs client
Message-ID: <20110210145416.GB9407@merit.edu>
References: <20110204213635.GB3632@merit.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110204213635.GB3632@merit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Jim Rees wrote:

  I have a report here of iozone hanging when run on nfs4 client against an
  EMC server.  We have reproduced this problem with a wide range of client
  kernel versions, from 2.6.33.3-85.fc13.x86_64 up to
  2.6.38-0.rc3.git2.1.pnfs_wave3_20110203.fc15.x86_64, and on both 4.0 and
  4.1.  It seems to happen only with heavy multi-threaded iozone testing with
  big files.

I have a bit more info on this now.  Version of iozone is v3.300, and this
is the command:

/opt/iozone/bin/iozone -r 2m -s 256m -w -W -c -t 12 -i 0 -+m /root/iozone_sw.4x3 -o -+n
cat /root/iozone_sw.4x3
r38-13-78 /ufs10/sw_1 /opt/iozone/bin/iozone
r38-14-79 /ufs10/sw_2 /opt/iozone/bin/iozone   
r38-15-80 /ufs10/sw_3 /opt/iozone/bin/iozone
r38-16-81 /ufs10/sw_4 /opt/iozone/bin/iozone       
r38-13-78 /ufs10/sw_5 /opt/iozone/bin/iozone
r38-14-79 /ufs10/sw_6 /opt/iozone/bin/iozone
r38-15-80 /ufs10/sw_7 /opt/iozone/bin/iozone
r38-16-81 /ufs10/sw_8 /opt/iozone/bin/iozone
r38-13-78 /ufs10/sw_9 /opt/iozone/bin/iozone
r38-14-79 /ufs10/sw_10 /opt/iozone/bin/iozone
r38-15-80 /ufs10/sw_11 /opt/iozone/bin/iozone
r38-16-81 /ufs10/sw_12 /opt/iozone/bin/iozone

The hang happens reliably, but might take anywhere from one to eight runs
before it happens.  There is no shortage of memory, the clients have about
1GB free out of 8GB.  Here's the stack trace and rpc debug:

Jan 31 15:57:17 r38-15-80 kernel: INFO: task iozone:3587 blocked for more than 120 seconds.
Jan 31 15:57:17 r38-15-80 kernel: "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Jan 31 15:57:17 r38-15-80 kernel: iozone        D 0000000000000000     0  3587      1 0x00000000
Jan 31 15:57:17 r38-15-80 kernel: ffff880245d53ae8 0000000000000082 0000000000000000 ffff880242560908
Jan 31 15:57:17 r38-15-80 kernel: ffff880242560908 ffff8801e9dd29b0 0000000000000000 ffff880245d53fd8
Jan 31 15:57:17 r38-15-80 kernel: ffff880245d53fd8 000000000000f9b0 00000000000157c0 ffff880245c73268
Jan 31 15:57:17 r38-15-80 kernel: Call Trace:
Jan 31 15:57:17 r38-15-80 kernel: [<ffffffff810c1314>] ? sync_page+0x0/0x45
Jan 31 15:57:17 r38-15-80 kernel: [<ffffffff814297bc>] io_schedule+0x6e/0xb0
Jan 31 15:57:17 r38-15-80 kernel: [<ffffffff810c1355>] sync_page+0x41/0x45
Jan 31 15:57:17 r38-15-80 kernel: [<ffffffff81429cf8>] __wait_on_bit+0x43/0x76
Jan 31 15:57:17 r38-15-80 kernel: [<ffffffff810c14ae>] wait_on_page_bit+0x6d/0x74
Jan 31 15:57:17 r38-15-80 kernel: [<ffffffff8106484b>] ? wake_bit_function+0x0/0x2e
Jan 31 15:57:17 r38-15-80 kernel: [<ffffffff810c94c0>] ? pagevec_lookup_tag+0x20/0x29
Jan 31 15:57:17 r38-15-80 kernel: [<ffffffff810c1751>] filemap_fdatawait_range+0x9f/0x173
Jan 31 15:57:17 r38-15-80 kernel: [<ffffffff810c18ce>] filemap_write_and_wait_range+0x3e/0x51        
Jan 31 15:57:17 r38-15-80 kernel: [<ffffffff8111fa53>] vfs_fsync_range+0x5a/0xad           
Jan 31 15:57:17 r38-15-80 kernel: [<ffffffff8111faf9>] generic_write_sync+0x53/0x55
Jan 31 15:57:17 r38-15-80 kernel: [<ffffffff810c1d4b>] generic_file_aio_write+0x86/0xa2
Jan 31 15:57:17 r38-15-80 kernel: [<ffffffffa0321bf8>] nfs_file_write+0xed/0x169 [nfs]
Jan 31 15:57:17 r38-15-80 kernel: [<ffffffff811017c5>] do_sync_write+0xbf/0xfc
Jan 31 15:57:17 r38-15-80 kernel: [<ffffffff810f4dc9>] ? __slab_free+0x28/0x22e
Jan 31 15:57:17 r38-15-80 kernel: [<ffffffff81204b7d>] ? might_fault+0x1c/0x1e
Jan 31 15:57:17 r38-15-80 kernel: [<ffffffff811be22b>] ? security_file_permission+0x11/0x13
Jan 31 15:57:17 r38-15-80 kernel: [<ffffffff81101d23>] vfs_write+0xa9/0x106
Jan 31 15:57:17 r38-15-80 kernel: [<ffffffff81101e36>] sys_write+0x45/0x69
Jan 31 15:57:17 r38-15-80 kernel: [<ffffffff81009b02>] system_call_fastpath+0x16/0x1b
Jan 31 15:59:17 r38-15-80 kernel: INFO: task iozone:3587 blocked for more than 120 seconds.
Jan 31 15:59:17 r38-15-80 kernel: "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.

r38-14-79: [ 1999.076511] -pid- flgs status -client- --rqstp- -timeout ---ops--
r38-14-79: [ 1999.076540] 34414 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.076554] 34415 0001      0 ffff8802456c4a00 ffff880251e1d260    60000 ffffffffa03c9810 nfsv4 WRITE a:call_status q:xprt_pending
r38-14-79: [ 1999.076570] 34416 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.076585] 34417 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.076601] 34418 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.076615] 34419 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.076629] 34420 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.076643] 34421 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.076658] 34422 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.076672] 34423 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.076686] 34424 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.076699] 34425 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.076713] 34426 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.076727] 34427 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.076739] 34428 0001      0 ffff8802456c4a00 ffff880251e1d0d8    60000 ffffffffa03c9810 nfsv4 WRITE a:call_status q:xprt_pending
r38-14-79: [ 1999.076753] 34429 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.076766] 34430 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.076782] 34431 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:NFS client
r38-14-79: [ 1999.076796] 34432 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.076810] 34433 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.076824] 34434 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.076837] 34435 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:NFS client
r38-14-79: [ 1999.076851] 34436 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.076865] 34437 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.076878] 34438 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.076892] 34439 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.076906] 34440 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.076920] 34441 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.076934] 34442 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.076948] 34443 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.076960] 34444 0001      0 ffff8802456c4a00 ffff880251e1c000    60000 ffffffffa03c9810 nfsv4 WRITE a:call_status q:xprt_pending
r38-14-79: [ 1999.076971] 34445 0001      0 ffff8802456c4a00 ffff880251e1cc40    60000 ffffffffa03c9810 nfsv4 WRITE a:call_status q:xprt_pending
r38-14-79: [ 1999.076985] 34446 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.076999] 34447 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.077018] 34448 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.077032] 34449 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.077045] 34450 0001    -11 ffff8802456c4a00 ffff880251e1c930    60000 ffffffffa03c9810 nfsv4 WRITE a:call_transmit_status q:xprt_pending
r38-14-79: [ 1999.077059] 34451 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.077073] 34452 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:NFS client
r38-14-79: [ 1999.077086] 34453 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:NFS client
r38-14-79: [ 1999.077098] 34454 0001      0 ffff8802456c4a00 ffff880251e1d570    60000 ffffffffa03c9810 nfsv4 WRITE a:call_status q:xprt_pending
r38-14-79: [ 1999.077110] 34455 0001      0 ffff8802456c4a00 ffff880251e1d6f8    60000 ffffffffa03c9810 nfsv4 WRITE a:call_status q:xprt_pending
r38-14-79: [ 1999.077122] 34456 0001      0 ffff8802456c4a00 ffff880251e1c310    60000 ffffffffa03c9810 nfsv4 WRITE a:call_status q:xprt_pending
r38-14-79: [ 1999.077135] 34457 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.077147] 34458 0001    -11 ffff8802456c4a00 ffff880251e1c188        0 ffffffffa03c9810 nfsv4 WRITE a:call_status q:xprt_sending
r38-14-79: [ 1999.077161] 34459 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.077173] 34460 0001      0 ffff8802456c4a00 ffff880251e1cdc8    60000 ffffffffa03c9810 nfsv4 WRITE a:call_status q:xprt_pending
r38-14-79: [ 1999.077184] 34461 0001      0 ffff8802456c4a00 ffff880251e1cf50    60000 ffffffffa03c9810 nfsv4 WRITE a:call_status q:xprt_pending
r38-14-79: [ 1999.077198] 34462 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.077212] 34463 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.077223] 34464 0001      0 ffff8802456c4a00 ffff880251e1cab8    60000 ffffffffa03c9810 nfsv4 WRITE a:call_status q:xprt_pending
r38-14-79: [ 1999.077237] 34465 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.077283] 34466 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.077307] 34467 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.077332] 34468 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.077356] 34469 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.077380] 34470 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.077404] 34471 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.077426] 34472 0001    -11 ffff8802456c4a00 ffff880251e1d3e8        0 ffffffffa03c9810 nfsv4 WRITE a:call_status q:xprt_sending
r38-14-79: [ 1999.077473] 34473 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.077495] 34474 0001    -11 ffff8802456c4a00 ffff880251e1c498        0 ffffffffa03c9810 nfsv4 WRITE a:call_status q:xprt_sending
r38-14-79: [ 1999.077519] 34475 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.077541] 34476 0001      0 ffff8802456c4a00 ffff880251e1c7a8    60000 ffffffffa03c9810 nfsv4 WRITE a:call_status q:xprt_pending
r38-14-79: [ 1999.077587] 34477 0001      0 ffff8802456c4a00   (null)        0 ffffffffa03c9810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
r38-14-79: [ 1999.077633] 17107 0280      0 ffff880243a8f800 ffff880251e1c620    60000 ffffffffa03d3b80 nfsv4 SEQUENCE a:call_status q:xprt_pending
