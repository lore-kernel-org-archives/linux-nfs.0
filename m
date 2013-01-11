Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:28311 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753733Ab3AKEYr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jan 2013 23:24:47 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Fengguang Wu <fengguang.wu@intel.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [SUNPRC] BUG: unable to handle kernel NULL pointer dereference
 at 0000000000000070
Date: Fri, 11 Jan 2013 04:24:45 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9119984C5@SACEXCMBX04-PRD.hq.netapp.com>
References: <20130111024644.GA9508@localhost>
In-Reply-To: <20130111024644.GA9508@localhost>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2013-01-11 at 10:46 +-0800, Fengguang Wu wrote:
+AD4- tree:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git linux-next
+AD4- commit: 51b63a538c54cb9c3b83c4d62572cf18da165cba +AFs-1/1+AF0- SUNRPC: Ensure we release the socket write lock if the rpc+AF8-task exits early
+AD4- 
+AD4- +AFs-  106.308511+AF0- md: autorun ...
+AD4- +AFs-  106.309477+AF0- md: ... autorun DONE.
+AD4- +AFs-  107.923634+AF0- BUG: unable to handle kernel NULL pointer dereference at 0000000000000070
+AD4- +AFs-  107.926207+AF0- IP: +AFsAPA-ffffffff82a7c8ac+AD4AXQ- xprt+AF8-release+-0x24/0x1cb
+AD4- +AFs-  107.927223+AF0- PGD 0 
+AD4- +AFs-  107.927223+AF0- Oops: 0000 +AFsAIw-1+AF0- SMP DEBUG+AF8-PAGEALLOC
+AD4- +AFs-  107.927223+AF0- Modules linked in:
+AD4- +AFs-  107.927223+AF0- CPU 1 
+AD4- +AFs-  107.927223+AF0- Pid: 1, comm: swapper/0 Not tainted 3.8.0-rc2-00187-gf958f23 +ACM-1651 Bochs Bochs
+AD4- +AFs-  107.927223+AF0- RIP: 0010:+AFsAPA-ffffffff82a7c8ac+AD4AXQ-  +AFsAPA-ffffffff82a7c8ac+AD4AXQ- xprt+AF8-release+-0x24/0x1cb
+AD4- +AFs-  107.927223+AF0- RSP: 0000:ffff88001d831908  EFLAGS: 00010246
+AD4- +AFs-  107.927223+AF0- RAX: 0000000000000000 RBX: ffff88001bff1080 RCX: ffff88001f400000
+AD4- +AFs-  107.927223+AF0- RDX: 0000000000000002 RSI: 000000000000051c RDI: ffff88001bff1080
+AD4- +AFs-  107.927223+AF0- RBP: ffff88001d831938 R08: 000000000000051c R09: 0000000000000004
+AD4- +AFs-  107.927223+AF0- R10: 000000000000332e R11: ffff88001bff1080 R12: 0000000000000000
+AD4- +AFs-  107.927223+AF0- R13: ffff88001bff1080 R14: ffff880010008380 R15: 000000000000000c
+AD4- +AFs-  107.927223+AF0- FS:  0000000000000000(0000) GS:ffff88001f400000(0000) knlGS:0000000000000000
+AD4- +AFs-  107.927223+AF0- CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
+AD4- +AFs-  107.927223+AF0- CR2: 0000000000000070 CR3: 0000000003c15000 CR4: 00000000000006e0
+AD4- +AFs-  107.927223+AF0- DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
+AD4- +AFs-  107.927223+AF0- DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
+AD4- +AFs-  107.927223+AF0- Process swapper/0 (pid: 1, threadinfo ffff88001d830000, task ffff88001e27c040)
+AD4- +AFs-  107.927223+AF0- Stack:
+AD4- +AFs-  107.927223+AF0-  000000000000332e ffff88001bff1080 ffff880010722e00 0000000000008000
+AD4- +AFs-  107.927223+AF0-  ffff880010008380 000000000000000c ffff88001d831958 ffffffff82a80445
+AD4- +AFs-  107.927223+AF0-  000000000000332e ffff88001bff1080 ffff88001d831978 ffffffff82a81cfa
+AD4- +AFs-  107.927223+AF0- Call Trace:
+AD4- +AFs-  107.927223+AF0-  +AFsAPA-ffffffff82a80445+AD4AXQ- rpc+AF8-release+AF8-resources+AF8-task+-0x14/0x37
+AD4- +AFs-  107.927223+AF0-  +AFsAPA-ffffffff82a81cfa+AD4AXQ- rpc+AF8-put+AF8-task+-0x1f/0x2d
+AD4- +AFs-  107.927223+AF0-  +AFsAPA-ffffffff82a7b002+AD4AXQ- rpc+AF8-call+AF8-sync+-0x69/0x9e
+AD4- +AFs-  107.927223+AF0-  +AFsAPA-ffffffff82a79942+AD4AXQ- ? net+AF8-generic.isra.10+-0x2e/0x3d
+AD4- +AFs-  107.927223+AF0-  +AFsAPA-ffffffff82a7b07e+AD4AXQ- rpc+AF8-ping+-0x47/0x5d
+AD4- +AFs-  107.927223+AF0-  +AFsAPA-ffffffff82a7a42d+AD4AXQ- ? rpc+AF8-new+AF8-client+-0x2c8/0x331
+AD4- +AFs-  107.927223+AF0-  +AFsAPA-ffffffff82a7b231+AD4AXQ- rpc+AF8-create+-0x11b/0x1ad
+AD4- +AFs-  107.927223+AF0-  +AFsAPA-ffffffff810e5bc4+AD4AXQ- ? trace+AF8-hardirqs+AF8-off+-0xd/0xf
+AD4- +AFs-  107.927223+AF0-  +AFsAPA-ffffffff810e8090+AD4AXQ- ? mark+AF8-lock+-0x2d/0x212
+AD4- +AFs-  107.927223+AF0-  +AFsAPA-ffffffff812f24ce+AD4AXQ- nfs+AF8-mount+-0xdf/0x140
+AD4- +AFs-  107.927223+AF0-  +AFsAPA-ffffffff812eaa1c+AD4AXQ- nfs+AF8-request+AF8-mount+-0x114/0x170
+AD4- +AFs-  107.927223+AF0-  +AFsAPA-ffffffff810e93e4+AD4AXQ- ? lock+AF8-release+-0x17d/0x1cd
+AD4- +AFs-  107.927223+AF0-  +AFsAPA-ffffffff812eaaa7+AD4AXQ- nfs+AF8-try+AF8-mount+-0x2f/0x6d
+AD4- +AFs-  107.927223+AF0-  +AFsAPA-ffffffff812ebbcf+AD4AXQ- nfs+AF8-fs+AF8-mount+-0x6cf/0x7ad
+AD4- +AFs-  107.927223+AF0-  +AFsAPA-ffffffff812ec0a5+AD4AXQ- ? nfs+AF8-clone+AF8-super+-0x6b/0x6b
+AD4- +AFs-  107.927223+AF0-  +AFsAPA-ffffffff812e98f3+AD4AXQ- ? nfs+AF8-clone+AF8-sb+AF8-security+-0x51/0x51
+AD4- +AFs-  107.927223+AF0-  +AFsAPA-ffffffff81194055+AD4AXQ- mount+AF8-fs+-0x69/0x158
+AD4- +AFs-  107.927223+AF0-  +AFsAPA-ffffffff8116190a+AD4AXQ- ? +AF8AXw-alloc+AF8-percpu+-0x10/0x12
+AD4- +AFs-  107.927223+AF0-  +AFsAPA-ffffffff811a9158+AD4AXQ- vfs+AF8-kern+AF8-mount+-0x62/0xd9
+AD4- +AFs-  107.927223+AF0-  +AFsAPA-ffffffff811ab23d+AD4AXQ- do+AF8-mount+-0x763/0x875
+AD4- +AFs-  107.927223+AF0-  +AFsAPA-ffffffff811ab3d4+AD4AXQ- sys+AF8-mount+-0x85/0xbe
+AD4- +AFs-  107.927223+AF0-  +AFsAPA-ffffffff841690d4+AD4AXQ- mount+AF8-root+-0x61/0x14f
+AD4- +AFs-  107.927223+AF0-  +AFsAPA-ffffffff8416932f+AD4AXQ- prepare+AF8-namespace+-0x16d/0x1a6
+AD4- +AFs-  107.927223+AF0-  +AFsAPA-ffffffff82bdcb9b+AD4AXQ- kernel+AF8-init+-0x1c5/0x29b
+AD4- +AFs-  107.927223+AF0-  +AFsAPA-ffffffff84168590+AD4AXQ- ? do+AF8-early+AF8-param+-0x8c/0x8c
+AD4- +AFs-  107.927223+AF0-  +AFsAPA-ffffffff82bdc9d6+AD4AXQ- ? rest+AF8-init+-0xda/0xda
+AD4- +AFs-  107.927223+AF0-  +AFsAPA-ffffffff82c260ac+AD4AXQ- ret+AF8-from+AF8-fork+-0x7c/0xb0
+AD4- +AFs-  107.927223+AF0-  +AFsAPA-ffffffff82bdc9d6+AD4AXQ- ? rest+AF8-init+-0xda/0xda
+AD4- +AFs-  107.927223+AF0- Code: 89 e5 ff 50 18 5d c3 0f 1f 44 00 00 55 48 89 e5 41 57 41 56 41 55 49 89 fd 41 54 53 41 52 4c 8b 67 20 4d 85 e4 75 22 48 8b 47 18 +ADw-48+AD4- 8b 78 70 48 8b b7 70 07 00 00 4c 39 ee 0f 85 86 01 00 00 e8 
+AD4- +AFs-  107.927223+AF0- RIP  +AFsAPA-ffffffff82a7c8ac+AD4AXQ- xprt+AF8-release+-0x24/0x1cb
+AD4- +AFs-  107.927223+AF0-  RSP +ADw-ffff88001d831908+AD4-
+AD4- +AFs-  107.927223+AF0- CR2: 0000000000000070
+AD4- 
+AD4- Thanks,
+AD4- Fengguang

Hi Fengguang,

Thanks for testing+ACE- The above Oops should be fixed in commit
87ed50036b866db2ec2ba16b2a7aec4a2b0b7c39, which is in the current
linux-next branch on git.linux-nfs.org. It was due to a missing test for
task-+AD4-tk+AF8-client +ACEAPQ- NULL.

I should also have fixed the RCU dereference warning that the build
robot found on Tuesday.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
