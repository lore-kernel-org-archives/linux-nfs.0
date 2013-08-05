Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:6117 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753714Ab3HEQVQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Aug 2013 12:21:16 -0400
Date: Mon, 5 Aug 2013 12:21:09 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Nix <nix@esperi.org.uk>
Cc: NFS list <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        dhowells@redhat.com
Subject: Re: [3.10.4] NFS locking panic, plus persisting NFS shutdown panic
 from 3.9.*
Message-ID: <20130805122109.16c19dd9@tlielax.poochiereds.net>
In-Reply-To: <87zjswrvaq.fsf@spindle.srvr.nix>
References: <8761vlv4z9.fsf@spindle.srvr.nix>
	<20130805084436.69ee4415@corrin.poochiereds.net>
	<87siyotcri.fsf@spindle.srvr.nix>
	<20130805110427.509db424@tlielax.poochiereds.net>
	<20130805111106.73d6ab90@tlielax.poochiereds.net>
	<87zjswrvaq.fsf@spindle.srvr.nix>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 05 Aug 2013 16:50:37 +0100
Nix <nix@esperi.org.uk> wrote:

> On 5 Aug 2013, Jeff Layton said:
> 
> > On Mon, 5 Aug 2013 11:04:27 -0400
> > Jeff Layton <jlayton@redhat.com> wrote:
> >
> >> On Mon, 05 Aug 2013 15:48:01 +0100
> >> Nix <nix@esperi.org.uk> wrote:
> >> 
> >> > On 5 Aug 2013, Jeff Layton stated:
> >> > 
> >> > > On Sun, 04 Aug 2013 16:40:58 +0100
> >> > > Nix <nix@esperi.org.uk> wrote:
> >> > >
> >> > >> I just got this panic on 3.10.4, in the middle of a large parallel
> >> > >> compilation (of Chromium, as it happens) over NFSv3:
> >> > >> 
> >> > >> [16364.527516] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
> >> > >> [16364.527571] IP: [<ffffffff81245157>] nlmclnt_setlockargs+0x55/0xcf
> >> > >> [16364.527611] PGD 0 
> >> > >> [16364.527626] Oops: 0000 [#1] PREEMPT SMP 
> >> > >> [16364.527656] Modules linked in: [last unloaded: microcode] 
> >> > >> [16364.527690] CPU: 0 PID: 17034 Comm: flock Not tainted 3.10.4-05315-gf4ce424-dirty #1
> >> > >> [16364.527730] Hardware name: System manufacturer System Product Name/P8H61-MX USB3, BIOS 0506 08/10/2012
> >> > >> [16364.527775] task: ffff88041a97ad60 ti: ffff8803501d4000 task.ti: ffff8803501d4000
> >> > >> [16364.527813] RIP: 0010:[<ffffffff81245157>] [<ffffffff81245157>] nlmclnt_setlockargs+0x55/0xcf
> >> > >> [16364.527860] RSP: 0018:ffff8803501d5c58  EFLAGS: 00010282
> >> > >> [16364.527889] RAX: ffff88041a97ad60 RBX: ffff8803e49c8800 RCX: 0000000000000000
> >> > >> [16364.527926] RDX: 0000000000000000 RSI: 000000000000004a RDI: ffff8803e49c8b54
> >> > >> [16364.527962] RBP: ffff8803501d5c68 R08: 0000000000015720 R09: 0000000000000000
> >> > >> [16364.527998] R10: 00007ffffffff000 R11: ffff8803501d5d58 R12: ffff8803501d5d58
> >> > >> [16364.528034] R13: ffff88041bd2bc00 R14: 0000000000000000 R15: ffff8803fc9e2900
> >> > >> [16364.528070] FS:  0000000000000000(0000) GS:ffff88042fa00000(0000) knlGS:0000000000000000
> >> > >> [16364.528111] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> >> > >> [16364.528142] CR2: 0000000000000008 CR3: 0000000001c0b000 CR4: 00000000001407f0
> >> > >> [16364.528177] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> >> > >> [16364.528214] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> >> > >> [16364.528303] Stack:
> >> > >> [16364.528316]  ffff8803501d5d58 ffff8803e49c8800 ffff8803501d5cd8 ffffffff81245418 
> >> > >> [16364.528369]  0000000000000000 ffff8803516f0bc0 ffff8803d7b7b6c0 ffffffff81215c81 
> >> > >> [16364.528418]  ffff880300000007 ffff88041bd2bdc8 ffff8801aabe9650 ffff8803fc9e2900 
> >> > >> [16364.528467] Call Trace:
> >> > >> [16364.528485]  [<ffffffff81245418>] nlmclnt_proc+0x148/0x5fb
> >> > >> [16364.528516]  [<ffffffff81215c81>] ? nfs_put_lock_context+0x69/0x6e
> >> > >> [16364.528550]  [<ffffffff812209a2>] nfs3_proc_lock+0x21/0x23
> >> > >> [16364.528581]  [<ffffffff812149dd>] do_unlk+0x96/0xb2
> >> > >> [16364.528608]  [<ffffffff81214b41>] nfs_flock+0x5a/0x71
> >> > >> [16364.528637]  [<ffffffff8119a747>] locks_remove_flock+0x9e/0x113
> >> > >> [16364.528668]  [<ffffffff8115cc68>] __fput+0xb6/0x1e6
> >> > >> [16364.528695]  [<ffffffff8115cda6>] ____fput+0xe/0x10
> >> > >> [16364.528724]  [<ffffffff810998da>] task_work_run+0x7e/0x98
> >> > >> [16364.528754]  [<ffffffff81082bc5>] do_exit+0x3cc/0x8fa
> >> > >> [16364.528782]  [<ffffffff81083501>] ? SyS_wait4+0xa5/0xc2
> >> > >> [16364.528811]  [<ffffffff8108328d>] do_group_exit+0x6f/0xa2
> >> > >> [16364.528843]  [<ffffffff810832d7>] SyS_exit_group+0x17/0x17
> >> > >> [16364.528876]  [<ffffffff81613e92>] system_call_fastpath+0x16/0x1b
> >> > >> [16364.528907] Code: 00 00 65 48 8b 04 25 c0 b8 00 00 48 8b 72 20 48 81 ee c0 01 00 00 f3 a4 48 8d bb 54 03 00 00 be 4a 00 00 00 48 8b 90 68 05 00 00 <48> 8b 52 08 48 89 bb d0 00 00 00 48 83 c2 45 48 89 53 38 48 8b 
> >> > >> [16364.529176] RIP [<ffffffff81245157>] nlmclnt_setlockargs+0x55/0xcf
> >> > >> [16364.529264]  RSP <ffff8803501d5c58>
> >> > >> [16364.529283] CR2: 0000000000000008
> >> > >> [16364.539039] ---[ end trace 5a73fddf23441377 ]---
> [...]
> > The listing and disassembly from nlmclnt_proc is not terribly
> > interesting unfortunately. You really want to do the listing and
> > disassembly of the RIP at panic time (nlmclnt_setlockargs+0x55).
> 
> Oh, sorry! Wrong end of the oops :)
> 
> 0xffffffff81245157 is in nlmclnt_setlockargs (fs/lockd/clntproc.c:131).
> 126             struct nlm_args *argp = &req->a_args;
> 127             struct nlm_lock *lock = &argp->lock;
> 128
> 129             nlmclnt_next_cookie(&argp->cookie);
> 130             memcpy(&lock->fh, NFS_FH(file_inode(fl->fl_file)), sizeof(struct nfs_fh));
> 131             lock->caller  = utsname()->nodename;
> 132             lock->oh.data = req->a_owner;
> 133             lock->oh.len  = snprintf(req->a_owner, sizeof(req->a_owner), "%u@%s",
> 134                                     (unsigned int)fl->fl_u.nfs_fl.owner->pid,
> 135                                     utsname()->nodename);
> 
>    0xffffffff81245102 <+0>:     callq  0xffffffff81613b00 <__fentry__>
>    0xffffffff81245107 <+5>:     push   %rbp
>    0xffffffff81245108 <+6>:     mov    %rsp,%rbp
>    0xffffffff8124510b <+9>:     push   %r12
>    0xffffffff8124510d <+11>:    mov    %rsi,%r12
>    0xffffffff81245110 <+14>:    push   %rbx
>    0xffffffff81245111 <+15>:    mov    %rdi,%rbx
>    0xffffffff81245114 <+18>:    lea    0x10(%rdi),%rdi
>    0xffffffff81245118 <+22>:    callq  0xffffffff812450df <nlmclnt_next_cookie>
>    0xffffffff8124511d <+27>:    mov    0x60(%r12),%rdx
>    0xffffffff81245122 <+32>:    lea    0x44(%rbx),%rax
>    0xffffffff81245126 <+36>:    mov    %rax,%rdi
>    0xffffffff81245129 <+39>:    mov    $0x82,%ecx
>    0xffffffff8124512e <+44>:    mov    %gs:0xb8c0,%rax
>    0xffffffff81245137 <+53>:    mov    0x20(%rdx),%rsi
>    0xffffffff8124513b <+57>:    sub    $0x1c0,%rsi
>    0xffffffff81245142 <+64>:    rep movsb %ds:(%rsi),%es:(%rdi)
>    0xffffffff81245144 <+66>:    lea    0x354(%rbx),%rdi
>    0xffffffff8124514b <+73>:    mov    $0x4a,%esi
>    0xffffffff81245150 <+78>:    mov    0x568(%rax),%rdx
> -> 0xffffffff81245157 <+85>:    mov    0x8(%rdx),%rdx
>    0xffffffff8124515b <+89>:    mov    %rdi,0xd0(%rbx)
>    0xffffffff81245162 <+96>:    add    $0x45,%rdx
> 
> (aside: wish GDB reported those offsets in hex, or the kernel reported
> them in decimal. Every time I look at these I forget to convert and get
> confused...)
> 
> I wonder if req is NULL (possible if the assignment to argp at the top
> of the function's been pushed down by the optimizer). Time to stick a
> printk() in and find out (after work is over so I can reboot this box
> like billy-o).
> 

Ah-ha! That same bug was discussed earlier this week. See the thread with this title:

    Subject: fuzz tested user mode linux core dumps in fs/lockd/clntproc.c:131

I haven't followed it too closely, unfortunately, but both oopses look
like similar problems. The kernel is tearing things down in the fput
codepath prior to running exit tasks that require those things...

-- 
Jeff Layton <jlayton@redhat.com>
