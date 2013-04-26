Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([212.227.17.22]:55483 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932116Ab3DZRup (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Apr 2013 13:50:45 -0400
Received: from mailout-de.gmx.net ([10.1.76.4]) by mrigmx.server.lan
 (mrigmx002) with ESMTP (Nemesis) id 0M1TnD-1UlNs21Wx7-00tV9N for
 <linux-nfs@vger.kernel.org>; Fri, 26 Apr 2013 19:50:43 +0200
Message-ID: <517ABE71.3040208@gmx.de>
Date: Fri, 26 Apr 2013 19:50:41 +0200
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: fuzzying a user mode linux let a task hung
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I run trinity within a user mode linux image (latest git kernel).
The directory for victims files is located at a NFS mounted share.

What I get sometimes when running 4 trinity childrens in parallel is something like the following :

2013-04-26T19:25:29.241+02:00 trinity kernel: INFO: task trinity-child1:1580 blocked for more than 120 seconds.
2013-04-26T19:25:29.241+02:00 trinity kernel: "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
2013-04-26T19:25:29.241+02:00 trinity kernel: trinity-child1  D 001000ce     0  1580   1569 0x00000002
2013-04-26T19:25:29.241+02:00 trinity kernel: 4088902c 00000001 00000000 3b9f7cac 0806198f 3bad786c 4088902c 3b9f4000 
2013-04-26T19:25:29.241+02:00 trinity kernel: 080a5290 3b9f7cd8 0837420c 3bad73c0 40888b80 00000001 40585530 3dc54660 
2013-04-26T19:25:29.241+02:00 trinity kernel: 3b9f4000 40585610 3bad73c0 ffffffff 3b9f7cec 083742a5 3b9f7de0 00000001 3b9f7c98:  [<0806198f>] __switch_to+0x5f/0x100
2013-04-26T19:25:29.241+02:00 trinity kernel: 3b9f7cb0:  [<0837420c>] __schedule+0x2dc/0x320
2013-04-26T19:25:29.241+02:00 trinity kernel: 3b9f7cdc:  [<083742a5>] schedule+0x55/0x60
2013-04-26T19:25:29.241+02:00 trinity kernel: 3b9f7cf0:  [<083742b8>] schedule_preempt_disabled+0x8/0x10
2013-04-26T19:25:29.241+02:00 trinity kernel: 3b9f7cf8:  [<083736b3>] __mutex_lock_slowpath+0x63/0x90
2013-04-26T19:25:29.256+02:00 trinity kernel: 3b9f7d20:  [<083736fe>] mutex_lock+0x1e/0x30
2013-04-26T19:25:29.256+02:00 trinity kernel: 3b9f7d2c:  [<0810928c>] do_last+0x23c/0xd30
2013-04-26T19:25:29.256+02:00 trinity kernel: 3b9f7db8:  [<08109e1f>] path_openat+0x9f/0x450
2013-04-26T19:25:29.256+02:00 trinity kernel: 3b9f7e0c:  [<0810a201>] do_filp_open+0x31/0x80
2013-04-26T19:25:29.256+02:00 trinity kernel: 3b9f7e7c:  [<081026e8>] sys_uselib+0x48/0x150
2013-04-26T19:25:29.256+02:00 trinity kernel: 3b9f7eac:  [<08064a92>] handle_syscall+0x82/0xb0
2013-04-26T19:25:29.256+02:00 trinity kernel: 3b9f7ef4:  [<08076f2d>] userspace+0x46d/0x590
2013-04-26T19:25:29.256+02:00 trinity kernel: 3b9f7fec:  [<080617fc>] fork_handler+0x6c/0x70
2013-04-26T19:25:29.256+02:00 trinity kernel: 3b9f7ffc:  [<09e47c20>] 0x9e47c20
2013-04-26T19:25:29.256+02:00 trinity kernel: 
2013-04-26T19:25:29.262+02:00 trinity kernel: INFO: task trinity-child0:1609 blocked for more than 120 seconds.
2013-04-26T19:25:29.262+02:00 trinity kernel: "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
2013-04-26T19:25:29.262+02:00 trinity kernel: trinity-child0  D 001000ce     0  1609   1569 0x00000002
2013-04-26T19:25:29.262+02:00 trinity kernel: 409b902c 00000001 00000000 115f7db8 0806198f 409bacec 409b902c 115f4000 
2013-04-26T19:25:29.262+02:00 trinity kernel: 080a5290 115f7de4 0837420c 409ba840 409b8b80 00000001 0844cb4c 115f7e00 
2013-04-26T19:25:29.262+02:00 trinity kernel: 115f4000 40585610 409ba840 ffffffff 115f7df8 083742a5 00000000 115f7e14 115f7da4:  [<0806198f>] __switch_to+0x5f/0x100
2013-04-26T19:25:29.262+02:00 trinity kernel: 115f7dbc:  [<0837420c>] __schedule+0x2dc/0x320
2013-04-26T19:25:29.262+02:00 trinity kernel: 115f7de8:  [<083742a5>] schedule+0x55/0x60
2013-04-26T19:25:29.262+02:00 trinity kernel: 115f7dfc:  [<083742b8>] schedule_preempt_disabled+0x8/0x10
2013-04-26T19:25:29.262+02:00 trinity kernel: 115f7e04:  [<083736b3>] __mutex_lock_slowpath+0x63/0x90
2013-04-26T19:25:29.266+02:00 trinity kernel: 115f7e2c:  [<083736fe>] mutex_lock+0x1e/0x30
2013-04-26T19:25:29.266+02:00 trinity kernel: 115f7e38:  [<080fb952>] chown_common.isra.18+0x52/0x80
2013-04-26T19:25:29.266+02:00 trinity kernel: 115f7e84:  [<080fc862>] sys_fchown+0x62/0xc0
2013-04-26T19:25:29.266+02:00 trinity kernel: 115f7eac:  [<08064a92>] handle_syscall+0x82/0xb0
2013-04-26T19:25:29.266+02:00 trinity kernel: 115f7ef4:  [<08076f2d>] userspace+0x46d/0x590
2013-04-26T19:25:29.266+02:00 trinity kernel: 115f7fec:  [<080617fc>] fork_handler+0x6c/0x70
2013-04-26T19:25:29.266+02:00 trinity kernel: 115f7ffc:  [<00000000>] 0x0
2013-04-26T19:25:29.266+02:00 trinity kernel:

Does those log message contains something interesting for you ?

-- 
MfG/Sincerely
Toralf Förster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3
