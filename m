Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:34830 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933270AbbJHQze convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Oct 2015 12:55:34 -0400
Received: by qgt47 with SMTP id 47so47143136qgt.2
        for <linux-nfs@vger.kernel.org>; Thu, 08 Oct 2015 09:55:34 -0700 (PDT)
Date: Thu, 8 Oct 2015 12:55:29 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v5 00/20] nfsd: open file caching
Message-ID: <20151008125529.3f30308e@synchrony.poochiereds.net>
In-Reply-To: <20151008164225.GA496@fieldses.org>
References: <1444042962-6947-1-git-send-email-jeff.layton@primarydata.com>
	<20151008164225.GA496@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 8 Oct 2015 12:42:25 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> I get a this on the client running some lease tests:
> 
> [   38.552120] BUG: unable to handle kernel NULL pointer dereference at (null)
> [   38.552723] IP: [<ffffffff811fcb3f>] vfs_setlease+0x1f/0x70
> [   38.553111] PGD 56c2d067 PUD 51145067 PMD 0 
> [   38.553534] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC 
> [   38.554128] Modules linked in: nfsd auth_rpcgss oid_registry nfs_acl lockd grace sunrpc
> [   38.555102] CPU: 0 PID: 4890 Comm: lease_tests Not tainted 4.3.0-rc3-14186-g7619b8e #322
> [   38.555593] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140709_153950- 04/01/2014
> [   38.556005] task: ffff880075bd8080 ti: ffff880055560000 task.ti: ffff880055560000
> [   38.556005] RIP: 0010:[<ffffffff811fcb3f>]  [<ffffffff811fcb3f>] vfs_setlease+0x1f/0x70
> [   38.556005] RSP: 0018:ffff880055563e98  EFLAGS: 00010246
> [   38.556005] RAX: 0000000000000000 RBX: 0000000000000002 RCX: ffff880055563ec8
> [   38.556005] RDX: 0000000000000000 RSI: 0000000000000002 RDI: ffff880051133e40
> [   38.556005] RBP: ffff880055563eb8 R08: 0000000000000000 R09: 00007ffc941da360
> [   38.556005] R10: 0000000000000008 R11: 0000000000000212 R12: ffff880051133e40
> [   38.556005] R13: 0000000000000000 R14: ffff880051133e40 R15: ffff880051133e40
> [   38.556005] FS:  00007fbbe6864700(0000) GS:ffff88007f800000(0000) knlGS:0000000000000000
> [   38.556005] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   38.556005] CR2: 0000000000000000 CR3: 00000000590b0000 CR4: 00000000000406f0
> [   38.556005] Stack:
> [   38.556005]  ffff880056dd1f88 0000000000000002 0000000000000400 0000000000000002
> [   38.556005]  ffff880055563ef8 ffffffff811fd4c1 ffff880051133e40 ffffffff8157b913
> [   38.556005]  0000000000000000 0000000000000000 0000000000000400 0000000000000002
> [   38.556005] Call Trace:
> [   38.556005]  [<ffffffff811fd4c1>] fcntl_setlease+0xa1/0xd0
> [   38.556005]  [<ffffffff8157b913>] ? security_file_fcntl+0x43/0x60
> [   38.556005]  [<ffffffff811bc74f>] SyS_fcntl+0x31f/0x630
> [   38.556005]  [<ffffffff81a77117>] entry_SYSCALL_64_fastpath+0x12/0x6f
> [   38.556005] Code: ff ff 66 2e 0f 1f 84 00 00 00 00 00 66 66 66 66 90 55 48 89 e5 41 55 41 54 53 49 89 d5 49 89 fc 48 89 f3 48 83 ec 08 48 83 fe 02 <48> 8b 12 74 14 48 c7 c7 40 cb 27 83 48 89 4d e0 e8 9c d8 e9 ff 
> [   38.556005] RIP  [<ffffffff811fcb3f>] vfs_setlease+0x1f/0x70
> [   38.556005]  RSP <ffff880055563e98>
> [   38.556005] CR2: 0000000000000000
> [   38.573673] ---[ end trace 2e6e1d4b9df8a11e ]---
> 
> --b.

My bad...it needs this patch. I'll roll this into the set before the
next posting.
