Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kalahimbra.net ([138.201.151.60]:53724 "EHLO
        mail.kalahimbra.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750839AbdIWWGe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 23 Sep 2017 18:06:34 -0400
Received: from [192.168.178.46] (p5DC77C94.dip0.t-ipconnect.de [93.199.124.148])
        by mail.kalahimbra.net (Postfix) with ESMTPSA id 1FE3820237
        for <linux-nfs@vger.kernel.org>; Sat, 23 Sep 2017 23:59:37 +0200 (CEST)
From: =?UTF-8?B?QXJtaW4gR3LDtsOfbGluZ2Vy?=
        <armin.groesslinger@uni-passau.de>
Subject: NFS client hangs with NFSv4 and Kerberos
To: linux-nfs@vger.kernel.org
Message-ID: <d913624b-098c-a205-9c08-457a5341de42@uni-passau.de>
Date: Sun, 24 Sep 2017 00:00:22 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

we are experiencing issues with Linux as NFS client with NFSv4 and Kerberos.
Occasionally, processes get stuck in NFS operations and the kernel reports
a blocked task and claims that the NFS server is not responding. When this
happens, the hanging process and the kernel never recover from the situation.

After some experimenting, I could create a small test program which seems
to trigger this behavior; it can be found here:
https://www.infosun.fim.uni-passau.de/cl/staff/groesslinger/writesync.c

The test program only performs lseek(), write() and fsync() on a file
(given as command line argument) in an endless loop. For the hang to occur,
it seems to be important not to write linearly to the file (therefore the
lseek()s to write with different strides). Usually after a few thousand
iterations, the process hangs uninterruptibly and the kernel logs something
like

[ 1272.779598] nfs: server nexstaff not responding, still trying
[ 1330.122586] INFO: task writesync:1443 blocked for more than 120 seconds.
[ 1330.122905]       Not tainted 4.14.0-rc1 #1
[ 1330.123141] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 1330.123407] writesync       D    0  1443   1442 0x00000000
[ 1330.123413] Call Trace:
[ 1330.123436]  __schedule+0x3c2/0x8b0
[ 1330.123441]  schedule+0x36/0x80
[ 1330.123452]  io_schedule+0x16/0x40
[ 1330.123468]  wait_on_page_bit_common+0xf8/0x190
[ 1330.123473]  ? page_cache_tree_insert+0xb0/0xb0
[ 1330.123478]  __filemap_fdatawait_range+0x123/0x190
[ 1330.123484]  filemap_write_and_wait_range+0x4b/0x90
[ 1330.123515]  nfs_file_fsync+0x3b/0x1f0 [nfs]
[ 1330.123536]  vfs_fsync_range+0x4b/0xb0
[ 1330.123541]  do_fsync+0x3d/0x70
[ 1330.123546]  SyS_fsync+0x10/0x20
[ 1330.123552]  entry_SYSCALL_64_fastpath+0x1e/0xa9
[ 1330.123556] RIP: 0033:0x7fa8e61ff730
[ 1330.123558] RSP: 002b:00007ffe159f2a28 EFLAGS: 00000246 ORIG_RAX: 000000000000004a
[ 1330.123562] RAX: ffffffffffffffda RBX: 0000000000000005 RCX: 00007fa8e61ff730
[ 1330.123564] RDX: 0000000000000001 RSI: 00000000004008f0 RDI: 0000000000000003
[ 1330.123565] RBP: 00007ffe159f03a0 R08: 00007fa8e64c8770 R09: 00007fa8e66cb700
[ 1330.123567] R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000005
[ 1330.123568] R13: 0000000000000001 R14: 00007fa8e64c7540 R15: 0000000000000000

I have performed a few experiments to see under which configurations
these hangs occurs:

- Kernels 3.16.48, 4.9.51, 4.13.2, 4.14-rc1 all show this behavior.
  (I'm not aware of a kernel version which does not show this behavior.)

- The hangs seem to occur only when NFSv4 is used together with Kerberos
  (sec=krb5, krb5i or krb5p all show the hangs), but I do not observe
  these hangs with sec=sys.

- nfs_utils versions on the clients used were 1.2.8 (Ubuntu 16.04) and
  1.3.4 (Debian 9).

- It does not occur with NFSv3 or NFSv4.1 or NFSv4.2 (with or without Kerberos).

- I can reproduce the hangs with Nexenta and Debian 9 (Kernel 4.9) as NFS server.

- I could not reproduce the hangs with FreeBSD 11.1 as client.

Since our department's productive server (running Nexenta) does not offer
NFSv4.1/4.2, using one of these protocol versions, which do not seem to be
affected, is unfortunately not an option. Our users are affected by the kernel
hangs every few days. We first observed the hangs with programs using SQLite,
e.g., Firefox often triggers the hangs when writing its databases.
(I constructed the test program by looking at what operations SQLite
does on the databases when the hangs occur.)

I'll be happy to provide further information (kernel dumps or similar);
please instruct me how to gather the information needed. I'd also be
happy to try kernel patches if somebody can suggest a fix for the problem.

Best regards,
Armin Groesslinger

