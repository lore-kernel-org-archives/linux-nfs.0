Return-Path: linux-nfs-owner@vger.kernel.org
Received: from catastrophix.ugh.no ([178.79.162.34]:51368 "EHLO
	catastrophix.ugh.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756632Ab2FPCmq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jun 2012 22:42:46 -0400
Message-ID: <4FDBF056.7040404@tomt.net>
Date: Sat, 16 Jun 2012 04:32:54 +0200
From: Andre Tomt <andre@tomt.net>
MIME-Version: 1.0
To: Linux-NFS <linux-nfs@vger.kernel.org>
CC: Fengguang Wu <fengguang.wu@intel.com>, David Howells <dhowells@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>
Subject: Re: BUG in __key_instantiate_and_link(): unable to handle kernel
 paging request at 0000632e6472616f
References: <20120601034114.GA9248@localhost>
In-Reply-To: <20120601034114.GA9248@localhost>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01. juni 2012 05:41, Fengguang Wu wrote:
> Hi David,
>
> It's the second time the machine oops in __key_instantiate_and_link() on
> 3.4 kernel.  This bug only happens after several days of run. Do you
> have any advices or debug patches? For now I can try older (or newer)
> kernels and see if it's any better.

FWIW; I am (still) seeing this exact same crash several times an hour on 
3.4.3-rc1 on Ubuntu 12.04 client. Only that the same second it happens, 
all my three displays corrupts badly, becoming completely unreadable. 
Switching to console and back usually gets my desktop back on two of 
three displays, and sometimes it will need a full xserver restart. 
Obviously some memory corruption going on.

One of the crashes also triggered a NX error:
[20292.196332] kernel tried to execute NX-protected page - exploit 
attempt? (uid: 0)

And after a while, things start locking up.

It didn't really start happening until a few days ago though, I've been 
running 3.4 for since some -rc through all the stable releases. Perhaps 
server suddenly got a working idmapper or something? Its a debian 
unstable updated a couple times a month.

Booting latest git master now, to see if any of the recent NFS fixes 
just pulled by Linus fixes anything (-rc2 had other showstopper nfs issues).

>
> [53056.100019] BUG: unable to handle kernel paging request at 0000632e6472616f
> [53056.108072] IP: [<0000632e6472616f>] 0x632e6472616e
> [53056.113702] PGD 0
> [53056.116119] Oops: 0010 [#1] SMP
> [53056.119982] CPU 0
> [53056.122111] Modules linked in:
> [53056.125969]
> [53056.127713] Pid: 3502, comm: rpc.idmapd Not tainted 3.4.0 #130 Intel Corporation S2600CP/S2600CP
> [53056.137880] RIP: 0010:[<0000632e6472616f>]  [<0000632e6472616f>] 0x632e6472616e
> [53056.146228] RSP: 0018:ffff880421d2fd30  EFLAGS: 00010246
> [53056.152249] RAX: ffff8803bef69100 RBX: ffff8803bef690d0 RCX: ffffffff81f0f440
> [53056.160309] RDX: 0000000000000005 RSI: ffff880421d2fe8d RDI: ffff8803bef690d0
> [53056.168371] RBP: ffff880421d2fd88 R08: ffff880421d2fcd8 R09: 0000000000000000
> [53056.176435] R10: ffffffff81f0f468 R11: ffffffff813bbdbf R12: ffff880421d2fe8d
> [53056.184504] R13: ffff8805c9957b00 R14: ffff8804287b9c00 R15: 0000000000000000
> [53056.192564] FS:  00007f87fbce5700(0000) GS:ffff88042fa00000(0000) knlGS:0000000000000000
> [53056.202451] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [53056.209343] CR2: 0000632e6472616f CR3: 000000042951a000 CR4: 00000000000407f0
> [53056.217784] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [53056.226226] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [53056.234675] Process rpc.idmapd (pid: 3502, threadinfo ffff880421d2e000, task ffff880427865e20)
> [53056.245144] Stack:
> [53056.247841]  ffffffff813bbde2 ffff880416c54820 0000000000000005 ffff880421d2fdb0
> [53056.257281]  fffffff0287b9c28 ffff8803bef690b0 ffff8803bef690d0 ffff8804287b9c00
> [53056.266725]  0000000000000005 ffff880421d2fe8d 00007f87fbaea800 ffff880421d2fdd8
> [53056.276172] Call Trace:
> [53056.279363]  [<ffffffff813bbde2>] ? __key_instantiate_and_link+0x5e/0xe4
> [53056.287316]  [<ffffffff813bbec5>] key_instantiate_and_link+0x5d/0x85
> [53056.294888]  [<ffffffff81262c29>] idmap_pipe_downcall+0x14a/0x18f
> [53056.302176]  [<ffffffff81958071>] rpc_pipe_write+0x5d/0x77
> [53056.308782]  [<ffffffff8114bfbd>] vfs_write+0xb2/0x142
> [53056.315000]  [<ffffffff8114c247>] sys_write+0x4a/0x71
> [53056.321108]  [<ffffffff819bc329>] system_call_fastpath+0x16/0x1b
> [53056.328278] Code:  Bad RIP value.
> [53056.332599] RIP  [<0000632e6472616f>] 0x632e6472616e
> [53056.338687]  RSP<ffff880421d2fd30>
> [53056.343035] CR2: 0000632e6472616f
> [53056.347640] ---[ end trace ee5d4100fdd3e1d2 ]---
