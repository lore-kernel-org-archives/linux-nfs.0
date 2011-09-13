Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from peace.netnation.com ([204.174.223.2]:60715 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755500Ab1IMQnn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Sep 2011 12:43:43 -0400
Date: Tue, 13 Sep 2011 09:43:42 -0700
From: Simon Kirby <sim@hostway.ca>
To: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [3.1-rc4] vfs_rmdir() -> mutex_unlock() Oops
Message-ID: <20110913164342.GA1039@hostway.ca>
References: <20110908222420.GE8043@hostway.ca> <20110912221700.GA11962@hostway.ca>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110912221700.GA11962@hostway.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Sep 12, 2011 at 03:17:00PM -0700, Simon Kirby wrote:

> On Thu, Sep 08, 2011 at 03:24:20PM -0700, Simon Kirby wrote:
> 
> > This box primarily does most of its VFS stuff over lots of NFS mounts,
> > but has some local EXT3 filesystems. This has happened a couple of times:
> > 
> > BUG: unable to handle kernel NULL pointer dereference at 00000000000000b8
>...
> Got a few more identical Oopses on another box running slightly past
> 3.1-rc5 (79016f648872549392d232cd648bd02298c2d2bb). It seems to be
> do_rmdir()'s mutex_unlock() call.
> 
> I'm building -rc6 with CONFIG_DEBUG_MUTEXES now.

...and not much more help with CONFIG_DEBUG_MUTEXES, from 3.1-rc6:

BUG: unable to handle kernel NULL pointer dereference at 00000000000000a4
IP: [<ffffffff816adc93>] __mutex_unlock_slowpath+0x53/0x140
PGD 13c6c4067 PUD 2256fc067 PMD 0 
Oops: 0002 [#1] SMP 
CPU 2 
Modules linked in: ipmi_devintf ipmi_si ipmi_msghandler xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 bnx2

Pid: 27658, comm: php Not tainted 3.1.0-rc6-hw-mudbg+ #32 Dell Inc. PowerEdge 1950/0TT740
RIP: 0010:[<ffffffff816adc93>]  [<ffffffff816adc93>] __mutex_unlock_slowpath+0x53/0x140
RSP: 0018:ffff8800b65e1e28  EFLAGS: 00010046
RAX: 0000000000000100 RBX: ffff88001bcece48 RCX: ffff88001bd05348
RDX: 0000000040000200 RSI: ffff8800916cf6c0 RDI: 00000000000000a0
RBP: ffff8800b65e1e48 R08: 00000000043205bc R09: ffffea00011340c0
R10: 0000000000000000 R11: 0000000000000002 R12: 00000000000000a0
R13: 00000000000000a4 R14: 0000000000000246 R15: 00007f7fe2d15680
FS:  00007f7fe2e1f720(0000) GS:ffff88022fc80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000000000a4 CR3: 0000000215c16000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process php (pid: 27658, threadinfo ffff8800b65e0000, task ffff8800175d4320)
Stack:
 ffff88001bcece48 00000000fffffffe ffff8800916cf6c0 00007f7fe2d146a8
 ffff8800b65e1e58 ffffffff816add89 ffff8800b65e1e88 ffffffff8110ec70
 ffff8800b65e1e98 ffff8800916cf6c0 ffff8800b65e1e98 0000000000000000
Call Trace:
 [<ffffffff816add89>] mutex_unlock+0x9/0x10
 [<ffffffff8110ec70>] vfs_rmdir+0xb0/0x100
 [<ffffffff8110ed96>] do_rmdir+0xd6/0x130
 [<ffffffff81102063>] ? fput+0x1c3/0x260
 [<ffffffff810fe648>] ? filp_close+0x68/0xa0
 [<ffffffff8110ee41>] sys_rmdir+0x11/0x20
 [<ffffffff816b6f3b>] system_call_fastpath+0x16/0x1b
Code: 75 1b 65 48 8b 04 25 c8 b5 00 00 48 63 80 44 e0 ff ff a9 00 ff ff 07 0f 85 bb 00 00 00 9c 41 5e fa b8 00 01 00 00 4d 8d 6c 24 04 <f0> 66 41 0f c1 45 00 38 e0 74 08 f3 90 41 8a 45 00 eb f4 44 8b 
RIP  [<ffffffff816adc93>] __mutex_unlock_slowpath+0x53/0x140
 RSP <ffff8800b65e1e28>
CR2: 00000000000000a4
---[ end trace f515ec8376bdb799 ]---

How can I further debug this? At this point, it seems to be happening several times daily.

Simon-
