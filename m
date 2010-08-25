Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:52067 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752579Ab0HYQMe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Aug 2010 12:12:34 -0400
Received: by wwd20 with SMTP id 20so161738wwd.1
        for <linux-nfs@vger.kernel.org>; Wed, 25 Aug 2010 09:12:22 -0700 (PDT)
Date: Wed, 25 Aug 2010 11:12:01 -0500
Message-ID: <AANLkTikWR_YSnx=4=KAodATpX+xO9+hj-cf7_e158f4d@mail.gmail.com>
Subject: fsync/wb deadlocks in 2.6.32
From: davidr@ressman.org
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello all,

I have ~100 nfs clients running Ubuntu 10.04 LTS, and under moderate and
heavy v3 write loads, I will periodically get deadlocks in nfs_do_fsync().
Unfortunately, it's rare enough that I've not been able to come up with
a test case that works reliably. The usage pattern looks like this:

1. 8 jobs are started on each of 100 nodes (each node has 8 cores)
2. These jobs stat(), read() and close() unique files of size 10-20MB
   on the source NFS filesystem.
3. They open(), write(), and close() the files on the target NFS
   filesystem (not the same as the source filesystem). Occasionally, the
   clients will insert a mkdir() before the open().
4. Steps 2-3 are repeated for a total of ~20m files (as in, all clients copy a
   total of 20m files cumulatively)

After an hour or two, at least one of these nodes gives a series of these
messages:

[88792.122324] INFO: task awk:7184 blocked for more than 120 seconds.
[88792.122643] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[88792.122990] python2.6   D 0000000000000000     0  7184   7150 0x00000000
[88792.122992]  ffff8806313cfb78 0000000000000046 0000000000015bc0
0000000000015bc0
[88792.122995]  ffff8806267483c0 ffff8806313cffd8 0000000000015bc0
ffff880626748000
[88792.122997]  0000000000015bc0 ffff8806313cffd8 0000000000015bc0
ffff8806267483c0
[88792.122999] Call Trace:
[88792.123010]  [<ffffffffa02a82b0>] ?
nfs_wait_bit_uninterruptible+0x0/0x20 [nfs]
[88792.123014]  [<ffffffff8153ebb7>] io_schedule+0x47/0x70
[88792.123019]  [<ffffffffa02a82be>] nfs_wait_bit_uninterruptible+0xe/0x20 [nfs]
[88792.123021]  [<ffffffff8153f40f>] __wait_on_bit+0x5f/0x90
[88792.123027]  [<ffffffffa02a82b0>] ?
nfs_wait_bit_uninterruptible+0x0/0x20 [nfs]
[88792.123029]  [<ffffffff8153f4b8>] out_of_line_wait_on_bit+0x78/0x90
[88792.123033]  [<ffffffff81085360>] ? wake_bit_function+0x0/0x40
[88792.123038]  [<ffffffffa02a829f>] nfs_wait_on_request+0x2f/0x40 [nfs]
[88792.123044]  [<ffffffffa02ac6af>] nfs_wait_on_requests_locked+0x7f/0xd0 [nfs]
[88792.123051]  [<ffffffffa02adaee>] nfs_sync_mapping_wait+0x9e/0x1a0 [nfs]
[88792.123057]  [<ffffffffa02aded9>] nfs_write_mapping+0x79/0xb0 [nfs]
[88792.123061]  [<ffffffff81155d9f>] ? __d_free+0x3f/0x60
[88792.123063]  [<ffffffff8115e4c0>] ? mntput_no_expire+0x30/0x110
[88792.123069]  [<ffffffffa02adf47>] nfs_wb_all+0x17/0x20 [nfs]
[88792.123073]  [<ffffffffa029ceba>] nfs_do_fsync+0x2a/0x60 [nfs]
[88792.123077]  [<ffffffffa029d105>] nfs_file_flush+0x75/0xa0 [nfs]
[88792.123079]  [<ffffffff8114051c>] filp_close+0x3c/0x90
[88792.123082]  [<ffffffff81068d8f>] put_files_struct+0x7f/0xf0
[88792.123084]  [<ffffffff81068e54>] exit_files+0x54/0x70
[88792.123086]  [<ffffffff8106b3ab>] do_exit+0x14b/0x380
[88792.123088]  [<ffffffff8106b635>] do_group_exit+0x55/0xd0
[88792.123089]  [<ffffffff8106b6c7>] sys_exit_group+0x17/0x20
[88792.123092]  [<ffffffff810131b2>] system_call_fastpath+0x16/0x1b

At which point, all writing process on the client go into iowait and
never return until the client is rebooted. In any given 24 hour period,
usually no more than 5 of my clients will exhibit this problem, and
frequently it's only 1 or 2 (although not the same from test to test).

I tried Ubuntu kernels 2.6.32.24.25 and 2.6.32.24.41, and I tried a
stock kernel.org build of 2.6.32.18, none of which appear to have had
any noticable effect.

Here are the current mount options:
  async,nocto,proto=udp,auto,intr,noatime,nodiratime, \
  rsize=32768,rw,vers=3,wsize=32768

I've tried tcp/udp, cto/nocto (i.e., grasping at straws), and none of
those options appear to have any effect either.

As far as I can tell, the problem appears to be unrelated to the
NFS server. We've seen these hangs while writing to a RHEL server
(2.6.18-92.1.22.el5) as well as an F5 ARX NFS proxy.

If anyone has seen this before, knows what it is, or needs more info
from me, please let me know.

Thanks,

David
