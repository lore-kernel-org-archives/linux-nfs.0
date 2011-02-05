Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17807 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752258Ab1BEAYS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Feb 2011 19:24:18 -0500
Subject: Re: hung task in iozone test on nfs client
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
In-Reply-To: <20110204213635.GB3632@merit.edu>
References: <20110204213635.GB3632@merit.edu>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 04 Feb 2011 19:24:15 -0500
Message-ID: <1296865456.2938.63.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-02-04 at 16:36 -0500, Jim Rees wrote: 
> I have a report here of iozone hanging when run on nfs4 client against an
> EMC server.  We have reproduced this problem with a wide range of client
> kernel versions, from 2.6.33.3-85.fc13.x86_64 up to
> 2.6.38-0.rc3.git2.1.pnfs_wave3_20110203.fc15.x86_64, and on both 4.0 and
> 4.1.  It seems to happen only with heavy multi-threaded iozone testing with
> big files.  The iozone is something like this:
> 
> iozone -r 2m -s 256m -w -W -c -t 12 -i 0 -o
> 
> The call trace is usually something like this:
> 
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
> I have a pcap file here but it's 8GB.  I am trying to distill it to the
> important parts.
> 
> Those of you who are familiar with the page cache, is there any obvious
> deadlock here that jumps out at you?

The above just tells you that something is waiting for the PG_writeback
lock (IOW: it is waiting for a writeback of the page to the server to
complete). It doesn't actually tell you why that page writeback is
failing to complete.

Can you send us the output of 'dmesg' after you do

   echo 0 >/proc/sys/sunrpc/rpc_debug

as root? The 'echo' command needs to be done during the hang.

Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

