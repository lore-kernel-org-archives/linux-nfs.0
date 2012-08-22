Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 5350504D.static.ziggozakelijk.nl ([83.80.80.77]:21444 "EHLO
	ns2.tasking.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754269Ab2HVOLD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Aug 2012 10:11:03 -0400
Received: from leonino.tasking.nl (nl-fg300a-1-dmz.tasking.nl [172.16.1.8])
	by ns2.tasking.nl (8.14.5/8.14.5) with ESMTP id q7ME5xgl023275
	(version=TLSv1/SSLv3 cipher=DHE-DSS-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 22 Aug 2012 16:05:59 +0200 (MEST)
Received: from lahti.tasking.nl (lahti.tasking.nl [172.17.2.45])
	by leonino.tasking.nl (8.14.5/8.14.5) with ESMTP id q7ME5xnr000669
	for <linux-nfs@vger.kernel.org>; Wed, 22 Aug 2012 16:05:59 +0200 (MEST)
To: linux-nfs@vger.kernel.org
Mime-Version: 1.0
Reply-To: dick.streefland@altium.nl (Dick Streefland)
From: dick.streefland@altium.nl (Dick Streefland)
Subject: NFSv3 client hang on many simultanious reads
Content-Type: text/plain; charset=us-ascii
Message-ID: <4d25.5034e746.eefd1@altium.nl>
Date: Wed, 22 Aug 2012 14:05:58 -0000
From: rnews@altium.nl
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've encountered occasional NFS client lockups, and traced it down to
a situation where many simultanious processes are reading the same
directory tree. It is not very easy to reproduce, but when I run the
following script in an NFS-mounted directory containing a linux-3.5.2
kernel tree, I usually get a lockup after a few iterations:

#!/bin/sh
[ -d /tmp/linux-3.5.2 ] || cp -a linux-3.5.2 /tmp/
while true
do
	date
	for i in $(seq 30)
	do
		cp -au linux-3.5.2 /tmp/ &
		echo -n .
	done
	echo
	wait
done

When you run "top" in a separate window, you will initially see 30
"cp" processed competing for the CPU. After the lockup, the processes
disappear because their state becomes "D". Everything accessing the
mount points hangs at that moment. Killing all "cp" processes removes
the lockup. Mounts on other clients are unaffected.

The client kernel version is 3.4.7, but the problem also exists in 3.1
kernels. I cannot reproduce lockups with a 3.0 kernel. The server is
running Linux 3.1.4. The mount options from /proc/mounts are:

nfs-doc:/export/doc/ /doc nfs rw,relatime,vers=3,rsize=32768,wsize=32768,namlen=255,hard,proto=udp,timeo=11,retrans=3,sec=sys,mountaddr=172.17.8.66,mountvers=3,mountport=52214,mountproto=udp,local_lock=none,addr=172.17.8.66 0 0

The hanging processes are all sitting in "rpc_wait_bit_killable":

  PID S WCHAN                    COMMAND
25547 D rpc_wait_bit_killable    cp -au linux-3.5.2 /tmp/
25548 D rpc_wait_bit_killable    cp -au linux-3.5.2 /tmp/
25549 D rpc_wait_bit_killable    cp -au linux-3.5.2 /tmp/
25550 D rpc_wait_bit_killable    cp -au linux-3.5.2 /tmp/
25551 D rpc_wait_bit_killable    cp -au linux-3.5.2 /tmp/
25552 D rpc_wait_bit_killable    cp -au linux-3.5.2 /tmp/
25553 D rpc_wait_bit_killable    cp -au linux-3.5.2 /tmp/
25554 D rpc_wait_bit_killable    cp -au linux-3.5.2 /tmp/
25555 D rpc_wait_bit_killable    cp -au linux-3.5.2 /tmp/
25556 D rpc_wait_bit_killable    cp -au linux-3.5.2 /tmp/
25557 D rpc_wait_bit_killable    cp -au linux-3.5.2 /tmp/
25558 D rpc_wait_bit_killable    cp -au linux-3.5.2 /tmp/
25559 D rpc_wait_bit_killable    cp -au linux-3.5.2 /tmp/
25560 D rpc_wait_bit_killable    cp -au linux-3.5.2 /tmp/
25561 D rpc_wait_bit_killable    cp -au linux-3.5.2 /tmp/
25562 D rpc_wait_bit_killable    cp -au linux-3.5.2 /tmp/
25563 D rpc_wait_bit_killable    cp -au linux-3.5.2 /tmp/
25564 D rpc_wait_bit_killable    cp -au linux-3.5.2 /tmp/
25565 D rpc_wait_bit_killable    cp -au linux-3.5.2 /tmp/
25566 D rpc_wait_bit_killable    cp -au linux-3.5.2 /tmp/
25567 D rpc_wait_bit_killable    cp -au linux-3.5.2 /tmp/
25568 D rpc_wait_bit_killable    cp -au linux-3.5.2 /tmp/
25569 D rpc_wait_bit_killable    cp -au linux-3.5.2 /tmp/
25570 D rpc_wait_bit_killable    cp -au linux-3.5.2 /tmp/
25571 D rpc_wait_bit_killable    cp -au linux-3.5.2 /tmp/
25572 D rpc_wait_bit_killable    cp -au linux-3.5.2 /tmp/
25573 D rpc_wait_bit_killable    cp -au linux-3.5.2 /tmp/
25574 D rpc_wait_bit_killable    cp -au linux-3.5.2 /tmp/
25575 D rpc_wait_bit_killable    cp -au linux-3.5.2 /tmp/
25576 D rpc_wait_bit_killable    cp -au linux-3.5.2 /tmp/

One "cp" process has this stack frame:

Aug 22 15:01:40 ivalo kernel: cp              D ee9dbc04     0 25558  25315 0x00000000
Aug 22 15:01:40 ivalo kernel: ee9dbc5c 00000086 f7bfbef8 ee9dbc04 c1086c00 00000000 f7b8e280 c1c36280
Aug 22 15:01:40 ivalo kernel: f53dbcc0 00009be4 c1c36280 f7b8e280 f4dc26d0 ee9dbc10 cb104b78 00000001
Aug 22 15:01:40 ivalo kernel: cb1049c0 f469b22c 00000000 ee9dbc50 ee9dbc34 c1089907 00000001 ee9dbc40
Aug 22 15:01:40 ivalo kernel: Call Trace:
Aug 22 15:01:40 ivalo kernel: [<c1086c00>] ? __wake_up+0x40/0x50
Aug 22 15:01:40 ivalo kernel: [<c1089907>] ? get_parent_ip+0x27/0x40
Aug 22 15:01:40 ivalo kernel: [<c108995b>] ? sub_preempt_count.part.65+0x3b/0x80
Aug 22 15:01:40 ivalo kernel: [<c10899bf>] ? sub_preempt_count+0x1f/0x50
Aug 22 15:01:40 ivalo kernel: [<c1834f7d>] ? _raw_spin_unlock_irqrestore+0x1d/0x40
Aug 22 15:01:40 ivalo kernel: [<c183429e>] schedule+0x1e/0x50
Aug 22 15:01:40 ivalo kernel: [<c178efb9>] rpc_wait_bit_killable+0x19/0x30
Aug 22 15:01:40 ivalo kernel: [<c1832657>] __wait_on_bit+0x47/0x70
Aug 22 15:01:40 ivalo kernel: [<c178efa0>] ? rpc_release_task+0xb0/0xb0
Aug 22 15:01:40 ivalo kernel: [<c178efa0>] ? rpc_release_task+0xb0/0xb0
Aug 22 15:01:40 ivalo kernel: [<c18326dc>] out_of_line_wait_on_bit+0x5c/0x70
Aug 22 15:01:40 ivalo kernel: [<c107f740>] ? autoremove_wake_function+0x40/0x40
Aug 22 15:01:40 ivalo kernel: [<c178f78b>] __rpc_execute+0xdb/0x1a0
Aug 22 15:01:40 ivalo kernel: [<c178fa93>] rpc_execute+0x33/0x40
Aug 22 15:01:40 ivalo kernel: [<c1788824>] rpc_run_task+0x54/0x70
Aug 22 15:01:40 ivalo kernel: [<c1788917>] rpc_call_sync+0x37/0x60
Aug 22 15:01:40 ivalo kernel: [<c11d3e60>] nfs3_rpc_call.constprop.15+0x50/0x80
Aug 22 15:01:40 ivalo kernel: [<c11d4252>] nfs3_rpc+0x42/0x60
Aug 22 15:01:40 ivalo kernel: [<c11d447f>] nfs3_proc_getattr+0x3f/0x80
Aug 22 15:01:40 ivalo kernel: [<c11c5505>] __nfs_revalidate_inode+0x75/0x1f0
Aug 22 15:01:40 ivalo kernel: [<c11c570c>] ? nfs_revalidate_inode+0x1c/0x50
Aug 22 15:01:40 ivalo kernel: [<c11c00eb>] nfs_lookup_revalidate+0x1db/0x4a0
Aug 22 15:01:40 ivalo kernel: [<c11c1474>] ? nfs_permission+0x104/0x200
Aug 22 15:01:40 ivalo kernel: [<c1089907>] ? get_parent_ip+0x27/0x40
Aug 22 15:01:40 ivalo kernel: [<c108995b>] ? sub_preempt_count.part.65+0x3b/0x80
Aug 22 15:01:40 ivalo kernel: [<c10899bf>] ? sub_preempt_count+0x1f/0x50
Aug 22 15:01:40 ivalo kernel: [<c110b56d>] ? __d_lookup+0x8d/0x170
Aug 22 15:01:40 ivalo kernel: [<c1102266>] do_lookup+0x166/0x260
Aug 22 15:01:40 ivalo kernel: [<c1103ab5>] do_last.isra.43+0x115/0x5a0
Aug 22 15:01:40 ivalo kernel: [<c11040b5>] path_openat+0x95/0x320
Aug 22 15:01:40 ivalo kernel: [<c1100eb6>] ? getname_flags+0x26/0x120
Aug 22 15:01:40 ivalo kernel: [<c110442c>] do_filp_open+0x2c/0x80
Aug 22 15:01:40 ivalo kernel: [<c10899bf>] ? sub_preempt_count+0x1f/0x50
Aug 22 15:01:40 ivalo kernel: [<c1834f42>] ? _raw_spin_unlock+0x12/0x30
Aug 22 15:01:40 ivalo kernel: [<c110eef9>] ? alloc_fd+0xa9/0xf0
Aug 22 15:01:40 ivalo kernel: [<c1100f45>] ? getname_flags+0xb5/0x120
Aug 22 15:01:40 ivalo kernel: [<c10f6853>] do_sys_open+0xe3/0x1b0
Aug 22 15:01:40 ivalo kernel: [<c10f694d>] sys_open+0x2d/0x40
Aug 22 15:01:40 ivalo kernel: [<c1835b1c>] sysenter_do_call+0x12/0x2c
Aug 22 15:01:40 ivalo kernel: [<c1830000>] ? inet_sk_reselect_saddr+0x146/0x18a

All other "cp" processes have this stack frame:

Aug 22 15:01:40 ivalo kernel: cp              D cb0ec180     0 25559  25315 0x00000000
Aug 22 15:01:40 ivalo kernel: ee8a7c5c 00000082 cb0ec0c0 cb0ec180 f63c7c60 cb0ec300 f7b8e280 c1c36280
Aug 22 15:01:40 ivalo kernel: f53d8d80 00009be4 c1c36280 f7b8e280 f56f7020 f63c7c60 f7b8fd78 ee8a7c6c
Aug 22 15:01:40 ivalo kernel: cb0ec300 f469b22c 00000000 ee8a7c50 ee8a7c34 c1089907 00000001 ee8a7c40
Aug 22 15:01:40 ivalo kernel: Call Trace:
Aug 22 15:01:40 ivalo kernel: [<c1089907>] ? get_parent_ip+0x27/0x40
Aug 22 15:01:40 ivalo kernel: [<c108995b>] ? sub_preempt_count.part.65+0x3b/0x80
Aug 22 15:01:40 ivalo kernel: [<c10899bf>] ? sub_preempt_count+0x1f/0x50
Aug 22 15:01:40 ivalo kernel: [<c1834f7d>] ? _raw_spin_unlock_irqrestore+0x1d/0x40
Aug 22 15:01:40 ivalo kernel: [<c183429e>] schedule+0x1e/0x50
Aug 22 15:01:40 ivalo kernel: [<c178efb9>] rpc_wait_bit_killable+0x19/0x30
Aug 22 15:01:40 ivalo kernel: [<c1832657>] __wait_on_bit+0x47/0x70
Aug 22 15:01:40 ivalo kernel: [<c178efa0>] ? rpc_release_task+0xb0/0xb0
Aug 22 15:01:40 ivalo kernel: [<c178efa0>] ? rpc_release_task+0xb0/0xb0
Aug 22 15:01:40 ivalo kernel: [<c18326dc>] out_of_line_wait_on_bit+0x5c/0x70
Aug 22 15:01:40 ivalo kernel: [<c107f740>] ? autoremove_wake_function+0x40/0x40
Aug 22 15:01:40 ivalo kernel: [<c178f78b>] __rpc_execute+0xdb/0x1a0
Aug 22 15:01:40 ivalo kernel: [<c178fa93>] rpc_execute+0x33/0x40
Aug 22 15:01:40 ivalo kernel: [<c1788824>] rpc_run_task+0x54/0x70
Aug 22 15:01:40 ivalo kernel: [<c1788917>] rpc_call_sync+0x37/0x60
Aug 22 15:01:40 ivalo kernel: [<c11d3e60>] nfs3_rpc_call.constprop.15+0x50/0x80
Aug 22 15:01:40 ivalo kernel: [<c11d4252>] nfs3_rpc+0x42/0x60
Aug 22 15:01:40 ivalo kernel: [<c11d447f>] nfs3_proc_getattr+0x3f/0x80
Aug 22 15:01:40 ivalo kernel: [<c11c5505>] __nfs_revalidate_inode+0x75/0x1f0
Aug 22 15:01:40 ivalo kernel: [<c11c570c>] ? nfs_revalidate_inode+0x1c/0x50
Aug 22 15:01:40 ivalo kernel: [<c11c00eb>] nfs_lookup_revalidate+0x1db/0x4a0
Aug 22 15:01:40 ivalo kernel: [<c11c1474>] ? nfs_permission+0x104/0x200
Aug 22 15:01:40 ivalo kernel: [<c1089907>] ? get_parent_ip+0x27/0x40
Aug 22 15:01:40 ivalo kernel: [<c108995b>] ? sub_preempt_count.part.65+0x3b/0x80
Aug 22 15:01:40 ivalo kernel: [<c10899bf>] ? sub_preempt_count+0x1f/0x50
Aug 22 15:01:40 ivalo kernel: [<c110b56d>] ? __d_lookup+0x8d/0x170
Aug 22 15:01:40 ivalo kernel: [<c1102266>] do_lookup+0x166/0x260
Aug 22 15:01:40 ivalo kernel: [<c1103ab5>] do_last.isra.43+0x115/0x5a0
Aug 22 15:01:40 ivalo kernel: [<c11040b5>] path_openat+0x95/0x320
Aug 22 15:01:40 ivalo kernel: [<c1100eb6>] ? getname_flags+0x26/0x120
Aug 22 15:01:40 ivalo kernel: [<c110442c>] do_filp_open+0x2c/0x80
Aug 22 15:01:40 ivalo kernel: [<c10899bf>] ? sub_preempt_count+0x1f/0x50
Aug 22 15:01:40 ivalo kernel: [<c1834f42>] ? _raw_spin_unlock+0x12/0x30
Aug 22 15:01:40 ivalo kernel: [<c110eef9>] ? alloc_fd+0xa9/0xf0
Aug 22 15:01:40 ivalo kernel: [<c1100f45>] ? getname_flags+0xb5/0x120
Aug 22 15:01:40 ivalo kernel: [<c10f6853>] do_sys_open+0xe3/0x1b0
Aug 22 15:01:40 ivalo kernel: [<c10f694d>] sys_open+0x2d/0x40
Aug 22 15:01:40 ivalo kernel: [<c1835b1c>] sysenter_do_call+0x12/0x2c

-- 
Dick

