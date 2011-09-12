Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from peace.netnation.com ([204.174.223.2]:50644 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755173Ab1ILWRC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Sep 2011 18:17:02 -0400
Date: Mon, 12 Sep 2011 15:17:00 -0700
From: Simon Kirby <sim@hostway.ca>
To: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [3.1-rc4] vfs_rmdir() -> mutex_unlock() Oops
Message-ID: <20110912221700.GA11962@hostway.ca>
References: <20110908222420.GE8043@hostway.ca>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110908222420.GE8043@hostway.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 08, 2011 at 03:24:20PM -0700, Simon Kirby wrote:

> This box primarily does most of its VFS stuff over lots of NFS mounts,
> but has some local EXT3 filesystems. This has happened a couple of times:
> 
> BUG: unable to handle kernel NULL pointer dereference at 00000000000000b8
> IP: [<ffffffff816a6641>] mutex_unlock+0x1/0x20
> PGD 12e07e067 PUD 102dfa067 PMD 0
> Oops: 0002 [#1] SMP
> CPU 3
> Modules linked in: ipmi_devintf ipmi_si ipmi_msghandler xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 bnx2
> [445464.657194]
> Pid: 13796, comm: php Tainted: G        W   3.1.0-rc4-hw+ #27 Dell Inc. PowerEdge 1950/0UR033
> RIP: 0010:[<ffffffff816a6641>]  [<ffffffff816a6641>] mutex_unlock+0x1/0x20
> RSP: 0018:ffff8801381c7e58  EFLAGS: 00010206
> RAX: 00000000fffffffe RBX: ffff88002e95aca8 RCX: ffff88010712dc70
> RDX: 0000000040000200 RSI: ffff880126d21cc0 RDI: 00000000000000a0
> RBP: ffff8801381c7e88 R08: 0000000026361000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000002 R12: 00000000fffffffe
> R13: ffff880126d21cc0 R14: 00007f0a6e0ba9d8 R15: 00007f0a6e0bd258
> FS:  00007f0a6e1c1720(0000) GS:ffff88022fcc0000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00000000000000b8 CR3: 000000012692a000 CR4: 00000000000006e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process php (pid: 13796, threadinfo ffff8801381c6000, task ffff88003ed4d900)
> Stack:
>  ffff8801381c7e88 ffffffff8110e680 ffff8801381c7e98 ffff880126d21cc0
>  ffff8801381c7e98 0000000000000000 ffff8801381c7f68 ffffffff8110e7a6
>  ffff880225eed800 ffff8800bea6d780 00000004018245d5 ffff88003ed0b03b
> Call Trace:
>  [<ffffffff8110e680>] ? vfs_rmdir+0xb0/0x100
>  [<ffffffff8110e7a6>] do_rmdir+0xd6/0x130
>  [<ffffffff811049c1>] ? sys_newlstat+0x31/0x50
>  [<ffffffff8110e851>] sys_rmdir+0x11/0x20
>  [<ffffffff816af57b>] system_call_fastpath+0x16/0x1b
> Code: 0f 79 05 e8 d2 00 00 00 65 48 8b 04 25 c0 b5 00 00 48 8b 1c 24 49 89 44 24 18 4c 8b 64 24 08 c9 c3 66 0f 1f 84 00 00 00 00 00 55
>  c7 47 18 00 00 00 00 48 89 e5 f0 ff 07 7f 05 e8 4a 00 00 00
> RIP  [<ffffffff816a6641>] mutex_unlock+0x1/0x20
>  RSP <ffff8801381c7e58>
> CR2: 00000000000000b8
> ---[ end trace 3ad1ff5004f78cbb ]---
> 
> I don't see any relevant changes in Linus HEAD yet. This build was of
> 9e79e3e9dd9672b37ac9412e9a926714306551fe (slightly past 3.1-rc4).

Got a few more identical Oopses on another box running slightly past
3.1-rc5 (79016f648872549392d232cd648bd02298c2d2bb). It seems to be
do_rmdir()'s mutex_unlock() call.

I'm building -rc6 with CONFIG_DEBUG_MUTEXES now.

Simon-
