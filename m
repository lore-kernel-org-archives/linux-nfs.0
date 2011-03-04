Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59988 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758269Ab1CDQ2Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Mar 2011 11:28:16 -0500
Message-ID: <4D711318.7070909@RedHat.com>
Date: Fri, 04 Mar 2011 11:28:08 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: hung iozone client bug recap
References: <20110303222219.GA16426@merit.edu>
In-Reply-To: <20110303222219.GA16426@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

We are seeing this too with a straight Fedora 14 kernel.
    https://bugzilla.redhat.com/show_bug.cgi?id=669204
 
Unfortunately we are not able to reproduce it as easily as 
you are...

steved.

On 03/03/2011 05:22 PM, Jim Rees wrote:
> I've asked about this before but now I have some new information.
> 
> When I run a multithreaded iozone test against an EMC server, I reliably get
> a hung client.  We have reproduced this problem with a wide range of client
> kernel versions, from 2.6.33.3-85.fc13.x86_64 up to benny's pnfs-all-latest,
> and on both 4.0 and 4.1.
> 
> Trond thinks the server is failing to reply to some rpc, but looking at the
> trace I don't see it.  The hang happens about 39 seconds in. The trace is
> here:
> http://www.citi.umich.edu/projects/nfsv4/pnfs/block/80.pcap.gz
> 
> The iozone command is like this.  Note the -o option for O_SYNC, this seem
> to be important.  There are three threads on each of four client.
> iozone -r 2m -s 256m -w -W -c -t 12 -i 0 -+m ioz-4x3 -o -+n
> 
> The call trace is usually something like this:
> INFO: task iozone:3587 blocked for more than 120 seconds.
> [<ffffffff810c1314>] ? sync_page+0x0/0x45
> [<ffffffff814297bc>] io_schedule+0x6e/0xb0
> [<ffffffff810c1355>] sync_page+0x41/0x45
> [<ffffffff81429cf8>] __wait_on_bit+0x43/0x76
> [<ffffffff810c14ae>] wait_on_page_bit+0x6d/0x74
> [<ffffffff8106484b>] ? wake_bit_function+0x0/0x2e
> [<ffffffff810c94c0>] ? pagevec_lookup_tag+0x20/0x29
> [<ffffffff810c1751>] filemap_fdatawait_range+0x9f/0x173
> [<ffffffff810c18ce>] filemap_write_and_wait_range+0x3e/0x51
> [<ffffffff8111fa53>] vfs_fsync_range+0x5a/0xad
> [<ffffffff8111faf9>] generic_write_sync+0x53/0x55
> [<ffffffff810c1d4b>] generic_file_aio_write+0x86/0xa2
> [<ffffffffa0321bf8>] nfs_file_write+0xed/0x169 [nfs]
> [<ffffffff811017c5>] do_sync_write+0xbf/0xfc
> [<ffffffff810f4dc9>] ? __slab_free+0x28/0x22e
> [<ffffffff81204b7d>] ? might_fault+0x1c/0x1e
> [<ffffffff811be22b>] ? security_file_permission+0x11/0x13
> [<ffffffff81101d23>] vfs_write+0xa9/0x106
> [<ffffffff81101e36>] sys_write+0x45/0x69
> [<ffffffff81009b02>] system_call_fastpath+0x16/0x1b
> 
> Here's a sample rpc queue (not from the same run as the trace):
> echo 0 >/proc/sys/sunrpc/rpc_debug
> r38-13-78: [ 1999.083961] -pid- flgs status -client- --rqstp- -timeout ---ops--
> r38-13-78: [ 1999.083987] 34411 0001      0 ffff880247b2e800 ffff8802550e6930    60000 ffffffffa03c3810 nfsv4 WRITE a:call_status q:xprt_pending
> r38-13-78: [ 1999.084004] 34412 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084021] 34413 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084036] 34414 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084050] 34415 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084064] 34416 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084078] 34417 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:NFS client
> r38-13-78: [ 1999.084092] 34418 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084105] 34419 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:NFS client
> r38-13-78: [ 1999.084119] 34420 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084137] 34421 0001      0 ffff880247b2e800 ffff8802550e6dc8    60000 ffffffffa03c3810 nfsv4 WRITE a:call_status q:xprt_pending
> r38-13-78: [ 1999.084153] 34422 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084167] 34423 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084181] 34424 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084195] 34425 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084209] 34426 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084223] 34427 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084236] 34428 0001      0 ffff880247b2e800 ffff8802550e7260    60000 ffffffffa03c3810 nfsv4 WRITE a:call_status q:xprt_pending
> r38-13-78: [ 1999.084250] 34429 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084262] 34430 0001      0 ffff880247b2e800 ffff8802550e6498    60000 ffffffffa03c3810 nfsv4 WRITE a:call_status q:xprt_pending
> r38-13-78: [ 1999.084276] 34431 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084288] 34432 0001      0 ffff880247b2e800 ffff8802550e6620    60000 ffffffffa03c3810 nfsv4 WRITE a:call_status q:xprt_pending
> r38-13-78: [ 1999.084301] 34433 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084316] 34434 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084330] 34435 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084344] 34436 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:NFS client
> r38-13-78: [ 1999.084357] 34437 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084369] 34438 0001    -11 ffff880247b2e800 ffff8802550e6188    60000 ffffffffa03c3810 nfsv4 WRITE a:call_transmit_status q:xprt_pending
> r38-13-78: [ 1999.084402] 34439 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084419] 34440 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084433] 34441 0001      0 ffff880247b2e800 ffff8802550e6c40    60000 ffffffffa03c3810 nfsv4 WRITE a:call_status q:xprt_pending
> r38-13-78: [ 1999.084449] 34442 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:NFS client
> r38-13-78: [ 1999.084465] 34443 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:NFS client
> r38-13-78: [ 1999.084481] 34444 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084498] 34445 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:NFS client
> r38-13-78: [ 1999.084514] 34446 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084529] 34447 0001      0 ffff880247b2e800 ffff8802550e73e8    60000 ffffffffa03c3810 nfsv4 WRITE a:call_status q:xprt_pending
> r38-13-78: [ 1999.084545] 34448 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084561] 34449 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084577] 34450 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084592] 34451 0001      0 ffff880247b2e800 ffff8802550e70d8    60000 ffffffffa03c3810 nfsv4 WRITE a:call_status q:xprt_pending
> r38-13-78: [ 1999.084608] 34452 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:NFS client
> r38-13-78: [ 1999.084625] 34453 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084642] 34454 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084658] 34455 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084674] 34456 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084690] 34457 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:NFS client
> r38-13-78: [ 1999.084706] 34458 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084722] 34459 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084738] 34460 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084754] 34461 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084770] 34462 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084786] 34463 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:NFS client
> r38-13-78: [ 1999.084802] 34464 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084817] 34465 0001    -11 ffff880247b2e800 ffff8802550e6f50        0 ffffffffa03c3810 nfsv4 WRITE a:call_status q:xprt_sending
> r38-13-78: [ 1999.084833] 34466 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:NFS client
> r38-13-78: [ 1999.084848] 34467 0001      0 ffff880247b2e800 ffff8802550e7570    60000 ffffffffa03c3810 nfsv4 WRITE a:call_status q:xprt_pending
> r38-13-78: [ 1999.084864] 34468 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084878] 34469 0001    -11 ffff880247b2e800 ffff8802550e6310        0 ffffffffa03c3810 nfsv4 WRITE a:call_status q:xprt_sending
> r38-13-78: [ 1999.084894] 34470 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:NFS client
> r38-13-78: [ 1999.084910] 34471 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084925] 34472 0001      0 ffff880247b2e800 ffff8802550e76f8    60000 ffffffffa03c3810 nfsv4 WRITE a:call_status q:xprt_pending
> r38-13-78: [ 1999.084943] 34473 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084959] 34474 0001      0 ffff880247b2e800   (null)        0 ffffffffa03c3810 nfsv4 WRITE a:rpc_prepare_task q:ForeChannel Slot table
> r38-13-78: [ 1999.084974] 18306 0280      0 ffff880253a4a000 ffff8802550e6ab8    60000 ffffffffa03cdb80 nfsv4 SEQUENCE a:call_status q:xprt_pending
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
