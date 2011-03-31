Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:47565 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752464Ab1CaQw7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Mar 2011 12:52:59 -0400
Date: Thu, 31 Mar 2011 12:52:58 -0400
From: Jim Rees <rees@umich.edu>
To: linux-nfs@vger.kernel.org
Cc: peter honeyman <honey@citi.umich.edu>
Subject: client hang in lock_flocks()
Message-ID: <20110331165258.GA3048@merit.edu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I have reported here before on a NFS client hang that we see in
multi-threaded iozone testing on various kernel and NFS versions.  What
looks like the same bug has been reported against RHEL here:

https://bugzilla.redhat.com/show_bug.cgi?id=672305

After applying the suggested fix from that bug report I'm getting a
different hang, at least with Benny's pnfs-all-latest and NFS 4.1 (no
pnfs).  Does this ring a bell with anyone?

INFO: task iozone:2666 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
iozone          D ffff88024cdf1aa0     0  2666      1 0x00000080
ffff880246be7c50 0000000000000082 0000000000000000 0000000000000000
ffff880246be6010 ffff880246be7fd8 00000000000136c0 ffff88024cdf16f0
ffff88024cdf1aa8 ffff88024cdf1aa0 00000000000136c0 00000000000136c0
Call Trace:
[<ffffffff8113978a>] ? lock_flocks+0x10/0x12
[<ffffffff8143dc37>] rwsem_down_failed_common+0xd3/0x105
[<ffffffff8143dc90>] rwsem_down_read_failed+0x12/0x14
[<ffffffff81209f54>] call_rwsem_down_read_failed+0x14/0x30
[<ffffffff8143d377>] ? down_read+0x32/0x36
[<ffffffffa03dbd20>] nfs4_proc_lock+0x224/0x342 [nfs]
[<ffffffffa03c19af>] do_setlk+0x61/0xd5 [nfs]
[<ffffffffa03c1c4a>] nfs_lock+0x170/0x17f [nfs]
[<ffffffff8113af72>] vfs_lock_file+0x24/0x38
[<ffffffff8113b2b9>] fcntl_setlk+0x15e/0x2a6
[<ffffffff811056d7>] ? fsnotify_access+0x5d/0x65
[<ffffffff81112ad6>] sys_fcntl+0x30e/0x4af
[<ffffffff8143e890>] ? do_device_not_available+0x9/0xb
[<ffffffff8100aa52>] system_call_fastpath+0x16/0x1b
