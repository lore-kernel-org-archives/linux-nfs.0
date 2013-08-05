Return-Path: linux-nfs-owner@vger.kernel.org
Received: from icebox.esperi.org.uk ([81.187.191.129]:58585 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753154Ab3HESdS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Aug 2013 14:33:18 -0400
From: Nix <nix@esperi.org.uk>
To: "Myklebust\, Trond" <Trond.Myklebust@netapp.com>
Cc: Toralf =?utf-8?Q?F=C3=B6rster?= <toralf.foerster@gmx.de>,
        Oleg Nesterov <oleg@redhat.com>, Jeff Layton <jlayton@redhat.com>,
        NFS list <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "dhowells\@redhat.com" <dhowells@redhat.com>
Subject: Re: [3.10.4] NFS locking panic, plus persisting NFS shutdown panic from 3.9.*
References: <8761vlv4z9.fsf@spindle.srvr.nix>
	<20130805084436.69ee4415@corrin.poochiereds.net>
	<87siyotcri.fsf@spindle.srvr.nix>
	<20130805110427.509db424@tlielax.poochiereds.net>
	<20130805111106.73d6ab90@tlielax.poochiereds.net>
	<87zjswrvaq.fsf@spindle.srvr.nix>
	<1375719301.7337.14.camel@leira.trondhjem.org>
Date: Mon, 05 Aug 2013 19:33:09 +0100
In-Reply-To: <1375719301.7337.14.camel@leira.trondhjem.org> (Trond Myklebust's
	message of "Mon, 5 Aug 2013 16:15:01 +0000")
Message-ID: <87txj4rnru.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5 Aug 2013, Trond Myklebust told this:
> Does the attached patch fix the problem?

> From 3c50ba80105464a28d456d9a1e0f1d81d4af92a8 Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Mon, 5 Aug 2013 12:06:12 -0400
> Subject: [PATCH] LOCKD: Don't call utsname()->nodename from
>  nlmclnt_setlockargs
> MIME-Version: 1.0
> Content-Type: text/plain; charset=UTF-8
> Content-Transfer-Encoding: 8bit

It makes it worse. Much, much worse. From a crash every so often when
I'm doing compilations over NFS, I get an immediate panic on startx,
long long before I even try to replicate the earlier panic:

[   83.432358] task: ffff88041aaa5ac0 ti: ffff8804199e2000 task.ti: ffff8804199e2000
[   83.432428] RIP: 0010:[<ffffffff8124af69>] [<ffffffff8124af69>] encode_nlm4_lock+0x26/0xbe
[   83.432512] RSP: 0018:ffff8804199e3a78  EFLAGS: 00010286
[   83.432564] RAX: 0000000000000000 RBX: ffff88041a577038 RCX: ffffffffffffffff
[   83.432630] RDX: ffff8804193b3098 RSI: ffff88041a577038 RDI: 000000000000008c
[   83.432697] RBP: ffff8804199e3aa8 R08: ffff8804193b3098 R09: 0000000000000001
[   83.432763] R10: ffff88042fa12980 R11: ffff88042fa12980 R12: ffff8804199e3ae8
[   83.432830] R13: 000000000000008c R14: ffff8804199e3fd8 R15: ffffffff815de80e
[   83.432898] FS:  00007f594b40c740(0000) GS:ffff88042fa00000(0000) knlGS:0000000000000000
[   83.432974] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   83.433028] CR2: 000000000000008c CR3: 000000041ab3d000 CR4: 00000000001407f0
[   83.433095] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   83.433176] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[   83.433255] Stack:
[   83.433276]  ffff88041a44fb70 ffff880400000004 ffff8804199e3ae8 ffff88041a577010 
[   83.433360]  ffff8804188e0e00 ffff8804199e3fd8 ffff8804199e3ac8 ffffffff8124b0d7 
[   83.433443]  ffff8804188e0e00 ffffffff8124b086 ffff8804199e3b38 ffffffff815e6032 
[   83.433616] Call Trace:
[   83.433646]  [<ffffffff8124b0d7>] nlm4_xdr_enc_lockargs+0x51/0x76
[   83.433707]  [<ffffffff8124b086>] ? nlm4_xdr_enc_cancargs+0x56/0x56
[   83.433769]  [<ffffffff815e6032>] rpcauth_wrap_req+0x57/0x62
[   83.433826]  [<ffffffff815de98a>] call_transmit+0x17c/0x1f9
[   83.433880]  [<ffffffff815e4e58>] __rpc_execute+0xe8/0x2ca
[   83.433935]  [<ffffffff815e50f9>] rpc_execute+0x76/0x9d
[   83.433986]  [<ffffffff815debc1>] rpc_run_task+0x78/0x80
[   83.434039]  [<ffffffff815decff>] rpc_call_sync+0x88/0x9e
[   83.434092]  [<ffffffff81244b3c>] nlmclnt_call+0xb5/0x240
[   83.434146]  [<ffffffff812454f0>] nlmclnt_proc+0x226/0x5fb
[   83.434226]  [<ffffffff812209a2>] nfs3_proc_lock+0x21/0x23
[   83.434280]  [<ffffffff81214a5e>] do_setlk+0x65/0xee
[   83.434329]  [<ffffffff81214ca6>] nfs_lock+0x14e/0x162
[   83.434382]  [<ffffffff81199661>] vfs_lock_file+0x29/0x35
[   83.434435]  [<ffffffff8119a51d>] fcntl_setlk+0x139/0x2c5
[   83.434490]  [<ffffffff81169621>] SyS_fcntl+0x2b6/0x47d
[   83.434543]  [<ffffffff81613e92>] system_call_fastpath+0x16/0x1b
[   83.434600] Code: 5b 41 5c 5d c3 0f 1f 44 00 00 55 31 c0 48 83 c9 ff 48 89 e5 41 56 41 55 41 54 49 89 fc 53 48 89 f3 48 83 ec 10 4c 8b 2e 4c 89 ef <f2> ae 4c 89 e7 48 f7 d1 4c 8d 71 ff 41 8d 76 04 e8 9f 16 3a 00 
[   83.435077] RIP [<ffffffff8124af69>] encode_nlm4_lock+0x26/0xbe
[   83.435140]  RSP <ffff8804199e3a78>
[   83.435197] CR2: 000000000000008c

That's here:

(gdb) list *(encode_nlm4_lock+0x26)
0xffffffff8124af69 is in encode_nlm4_lock (fs/lockd/clnt4xdr.c:329).
324      *      string caller_name<LM_MAXSTRLEN>;
325      */
326     static void encode_caller_name(struct xdr_stream *xdr, const char *name)
327     {
328             /* NB: client-side does not set lock->len */
329             u32 length = strlen(name);
330             __be32 *p;
331
332             p = xdr_reserve_space(xdr, 4 + length);
333             xdr_encode_opaque(p, name, length);

   0xffffffff8124af69 <+38>:    repnz scas %es:(%rdi),%al

Pretty clearly, "name" can be NULL after this patch...

-- 
NULL && (void)
