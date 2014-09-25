Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f172.google.com ([209.85.213.172]:55492 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750821AbaIYOPs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Sep 2014 10:15:48 -0400
Received: by mail-ig0-f172.google.com with SMTP id a13so8533497igq.11
        for <linux-nfs@vger.kernel.org>; Thu, 25 Sep 2014 07:15:47 -0700 (PDT)
Message-ID: <1411654543.3044.24.camel@leira.trondhjem.org>
Subject: Re: NMI/soft lockup in nfs_delegation_need_return()
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: David Howells <dhowells@redhat.com>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
Date: Thu, 25 Sep 2014 10:15:43 -0400
In-Reply-To: <28059.1411650278@warthog.procyon.org.uk>
References: <28059.1411650278@warthog.procyon.org.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi David,

On Thu, 2014-09-25 at 14:04 +0100, David Howells wrote:
> [Let me put a subject in this time]
> 
> Hi Trond,
> 
> I'm seeing the soft lockup below occasionally.  I'm using the head of Linus's
> master branch (005f800508eb391480f463dad3d54e5b4ec67d57).  Plus a pair of
> cachefiles patches that should have no bearing on the matter.  I'm seeing the
> lockup both with and without a cache.  I did the following:
> 
> 	insmod /tmp/sunrpc.ko
> 	mount -t rpc_pipefs sunrpc /var/lib/nfs/rpc_pipefs
> 	insmod /tmp/lockd.ko
> 	insmod /tmp/nfs_acl.ko
> 	insmod /tmp/auth_rpcgss.ko
> 	insmod /tmp/fscache.ko
> 	insmod /tmp/nfs.ko
> 	insmod /tmp/nfsv2.ko
> 	insmod /tmp/nfsv3.ko
> 	insmod /tmp/nfsv4.ko
> 	mount warthog:/warthog /warthog -o async,intr
> 	tar cf - /warthog/fs/linux-2.6-fscache | cat >/dev/null
> 
> where the directory being tar'd is a kernel tree with a couple of builds in
> there plus a load of git data (about 3GB worth).
> 
> The RIP points here:
> 
>    0x0000000000010e81 <+141>:   lea    0x48(%r12),%rdx
>    0x0000000000010e86 <+146>:   lock btrl $0x1,0x48(%r12)
>    0x0000000000010e8e <+154>:   jb     0x10e95 <nfs_client_return_marked_delegations+161>
> 
> and it appears to be the first test_and_clear_bit() in
> nfs_delegation_need_return() which seems to have been inlined.
> 
> I got at least three barks from the watchdog the last time I ran it before I
> killed it.
> 
> David
> ---
> NMI watchdog: BUG: soft lockup - CPU#1 stuck for 22s! [90.155.74.18-ma:2776]
> Modules linked in: nfsv4 nfsv3 nfsv2 nfs fscache auth_rpcgss nfs_acl lockd sunrpc
> irq event stamp: 134630
> hardirqs last  enabled at (134629): [<ffffffff81088a54>] __call_rcu+0x203/0x212
> hardirqs last disabled at (134630): [<ffffffff8151133a>] apic_timer_interrupt+0x6a/0x80
> softirqs last  enabled at (134618): [<ffffffff8103de29>] __do_softirq+0x243/0x305
> softirqs last disabled at (134613): [<ffffffff8103e106>] irq_exit+0x61/0xda
> CPU: 1 PID: 2776 Comm: 90.155.74.18-ma Tainted: G        W      3.17.0-rc6-fsdevel+ #794
> Hardware name:                  /DG965RY, BIOS MQ96510J.86A.0816.2006.0716.2308 07/16/2006
> task: ffff880012ab6250 ti: ffff8800129e8000 task.ti: ffff8800129e8000
> RIP: 0010:[<ffffffffa00fde8e>]  [<ffffffffa00fde8e>] nfs_client_return_marked_delegations+0x9a/0x1aa [nfsv4]
> RSP: 0018:ffff8800129ebde8  EFLAGS: 00000202
> RAX: ffff880020bfd4c0 RBX: ffff8800129ebdd0 RCX: 0000000000000000
> RDX: ffff880020bfd508 RSI: ffff880012ab6250 RDI: ffff880012ab6250
> RBP: ffff8800129ebe28 R08: 0000000000000000 R09: 0000000000000000
> R10: ffff8800129ebd78 R11: 0000000000000000 R12: 0000000000000000
> R13: 0000000000000000 R14: ffffffff81a43340 R15: ffff8800129ebd78
> FS:  0000000000000000(0000) GS:ffff88003db00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 0000000000a62418 CR3: 00000000060f1000 CR4: 00000000000007e0
> Stack:
>  ffff8800065e58c8 ffff88000610f7f0 ffff880020bfd4c0 ffff8800065e5800
>  ffff8800065e5800 ffff8800065e5930 0000000000000000 0000000000000000
>  ffff8800129ebe68 ffffffffa00fc180 000000000000000b ffff8800062f8e80
> Call Trace:
>  [<ffffffffa00fc180>] nfs4_run_state_manager+0x614/0x619 [nfsv4]
>  [<ffffffffa00fbb6c>] ? nfs4_do_reclaim+0x527/0x527 [nfsv4]
>  [<ffffffff81053a97>] kthread+0xfa/0x102
>  [<ffffffff8105399d>] ? kthread_create_on_node+0x1ca/0x1ca
>  [<ffffffff8151036c>] ret_from_fork+0x7c/0xb0
>  [<ffffffff8105399d>] ? kthread_create_on_node+0x1ca/0x1ca
> Code: 00 48 89 45 d0 4c 8b 65 d0 48 8d 83 f0 07 00 00 48 89 45 c8 4c 3b 65 c8 0f 84 d7 00 00 00 49 8d 54 24 48 f0 41 0f ba 74 24 48 01 <72> 05 45 31 f6 eb 03 41 b6 01 f0 0f ba 32 02 72 02 eb 36 45 84 

The 22s hang above appears to occur in a timer interrupt. Could that be
triggering the Oops by delaying the state manager thread for long enough
that the delegation is getting freed?

I can't see anything obviously violating the RCU rules in the delegation
code:
- All delegations are freed via kfree_rcu(), so they should not normally
be able to disappear from underneath us while we're in a rcu_read_lock()
protected section such as above.
- All additions/removals from the server->delegations list are done
using list_add/del_rcu(), and I don't see any way for a delegation to be
put on the list twice or to be put back on the list once it has been
removed.
- The nfs_server code calls synchronize_rcu() after removing the server
from the clp->cl_superblocks list (which it does using list_del_rcu()).

Cheers
  Trond

