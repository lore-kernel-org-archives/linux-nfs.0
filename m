From: Simon Kirby <sim@hostway.ca>
Subject: rpciod causes workqueue BUG()
Date: Tue, 14 Apr 2009 17:37:34 -0700
Message-ID: <20090415003734.GB17195@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from newpeace.netnation.com ([204.174.223.7]:42028 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751300AbZDOAv2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Apr 2009 20:51:28 -0400
Received: from sim by peace.netnation.com with local (Exim 4.63)
	(envelope-from <sim@netnation.com>)
	id 1Ltt8A-0007ji-T7
	for linux-nfs@vger.kernel.org; Tue, 14 Apr 2009 17:37:34 -0700
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

'lo!

We saw this in production on one of our shared hosting servers.  This is
the first time we've seen this particular issue, and it was in the middle
of the night when nothing special was happening (that we know of).

Linux 2.6.28.7 compiled from source (no patches), NFSv3 in this case,
with lockd fairly well-used.  There is a large number of NFS mounts to an
HA NFS server (same kernel version).

After this occurred, our health-checking systems showed that NFS-touching
processes seemed to be hanging.  Has this issue been seen before?

Simon-

...no prior kernel messages for over a day...
Apr 13 02:54:38 lsh1001 kernel: ------------[ cut here ]------------
Apr 13 02:54:38 lsh1001 kernel: kernel BUG at kernel/workqueue.c:292!
Apr 13 02:54:38 lsh1001 kernel: invalid opcode: 0000 [#1] SMP 
Apr 13 02:54:38 lsh1001 kernel: last sysfs file: /sys/block/sda/stat
Apr 13 02:54:38 lsh1001 kernel: CPU 0 
Apr 13 02:54:38 lsh1001 kernel: Modules linked in: nf_conntrack_ftp xt_state xt_owner xt_MARK nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 bnx2 zlib_inflate
Apr 13 02:54:38 lsh1001 kernel: Pid: 1317, comm: rpciod/0 Not tainted 2.6.28.7-hw #1
Apr 13 02:54:38 lsh1001 kernel: RIP: 0010:[<ffffffff80251014>]  [<ffffffff80251014>] run_workqueue+0xf4/0x150
Apr 13 02:54:38 lsh1001 kernel: RSP: 0018:ffff88012f3fbe80  EFLAGS: 00010286
Apr 13 02:54:38 lsh1001 kernel: RAX: 0000000000000000 RBX: ffff8801286f3c18 RCX: ffff88012f3fa000
Apr 13 02:54:38 lsh1001 kernel: RDX: ffff8801286f3c18 RSI: ffff88012f3fbec0 RDI: ffff88012f35d200
Apr 13 02:54:38 lsh1001 kernel: RBP: ffff88012f3fbeb0 R08: ffff88012f3fa000 R09: 0000000000000001
Apr 13 02:54:38 lsh1001 kernel: R10: 0000000000000001 R11: 0000000000000001 R12: ffff88012f35d200
Apr 13 02:54:38 lsh1001 kernel: R13: ffff8801286f3c10 R14: ffffffff806706a0 R15: ffff88012f35d208
Apr 13 02:54:38 lsh1001 kernel: FS:  0000000000000000(0000) GS:ffffffff8098a000(0000) knlGS:0000000000000000
Apr 13 02:54:38 lsh1001 kernel: CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
Apr 13 02:54:38 lsh1001 kernel: CR2: 0000000000412de0 CR3: 0000000077cbe000 CR4: 00000000000006e0
Apr 13 02:54:38 lsh1001 kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Apr 13 02:54:38 lsh1001 kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Apr 13 02:54:38 lsh1001 kernel: Process rpciod/0 (pid: 1317, threadinfo ffff88012f3fa000, task ffff88012f22aae0)
Apr 13 02:54:38 lsh1001 kernel: Stack:
Apr 13 02:54:38 lsh1001 kernel:  ffff88012f3fbeb0 ffff88012f35d218 ffff88012f35d200 ffff88012f3fbec0
Apr 13 02:54:38 lsh1001 kernel:  ffff88012f35d208 ffff88012f855ef0 ffff88012f3fbf10 ffffffff80251b73
Apr 13 02:54:38 lsh1001 kernel:  0000000000000000 ffff88012f22aae0 ffffffff80255090 ffff88012f3fbed8
Apr 13 02:54:38 lsh1001 kernel: Call Trace:
Apr 13 02:54:38 lsh1001 kernel:  [<ffffffff80251b73>] worker_thread+0x93/0xd0
Apr 13 02:54:38 lsh1001 kernel:  [<ffffffff80255090>] ? autoremove_wake_function+0x0/0x40
Apr 13 02:54:38 lsh1001 kernel:  [<ffffffff80251ae0>] ? worker_thread+0x0/0xd0
Apr 13 02:54:38 lsh1001 kernel:  [<ffffffff80254c1d>] kthread+0x4d/0x80
Apr 13 02:54:38 lsh1001 kernel:  [<ffffffff8020d659>] child_rip+0xa/0x11
Apr 13 02:54:38 lsh1001 kernel:  [<ffffffff80254bd0>] ? kthread+0x0/0x80
Apr 13 02:54:38 lsh1001 kernel:  [<ffffffff8020d64f>] ? child_rip+0x0/0x11
Apr 13 02:54:38 lsh1001 kernel: Code: 00 00 00 00 75 81 41 ff 4c 24 48 4c 89 e7 e8 74 5a fd ff 90 fb 0f 1f 80 00 00 00 00 48 83 c4 08 5b 41 5c 41 5d 41 5e 41 5f c9 c3 <0f> 0b eb fe 65 48 8b 34 25 00 00 00 00 8b 8e 68 01 00 00 48 c7 
Apr 13 02:54:38 lsh1001 kernel: RIP  [<ffffffff80251014>] run_workqueue+0xf4/0x150
Apr 13 02:54:38 lsh1001 kernel:  RSP <ffff88012f3fbe80>
Apr 13 02:54:38 lsh1001 kernel: ---[ end trace 22021e591705aaa8 ]---
Apr 13 02:56:38 lsh1001 kernel: lockd: server 10.10.52.220 not responding, still trying
Apr 13 02:56:38 lsh1001 kernel: lockd: server 10.10.52.220 not responding, still trying
...no further messages until manual reboot...
