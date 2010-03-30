From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC] kernel panic at svc_xprt_release
Date: Mon, 29 Mar 2010 20:57:48 -0400
Message-ID: <20100330005748.GG24251@fieldses.org>
References: <4BA9DDC1.3020202@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFSv3 list <linux-nfs@vger.kernel.org>,
	"Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	Chuck Lever <chuck.lever@oracle.com>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39520 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753381Ab0C3Azn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Mar 2010 20:55:43 -0400
In-Reply-To: <4BA9DDC1.3020202@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 24, 2010 at 05:39:13PM +0800, Mi Jinlong wrote:
> Hi,
> 
> When testing the NFSv3's lock at RHEL with kernel 2.6.31, I got a kernel panic
> at server's svc_xprt_release function. 
> 
> The panic place:
> 
>  lockd
>   ->svc_recv
>     ->svc_xprt_release
>    *** rqstp->rq_xprt->xpt_ops->xpo_release_rqst(rqstp); *** panic
> 
> I guess that is the "->rq_xprt" use a deleted xprt which deleted at svc_delete_xprt ?
>   lockd
>    ->svc_recv
>       if (test_bit(XPT_CLOSE, &xprt->xpt_flags)) {
>          ->svc_delete_xprt
>             ->svc_xprt_put(xprt);
>       }
>  
> If someone known this bug? or give me some idea?
> 
> The following message is the panic message what I get from the crash core.
> 
> ========================================
> 
> BUG: sleeping function called from invalid context at net/core/sock.c:1897

Hm, OK, so it does look like tcp_close() can sleep, so we are wrong to
be calling svc_xprt_put() while holding sv_lock.

The commit ab1b18f "sunrpc: remove unnecessary svc_xprt_put" gets rid of
one svc_xprt_put(), and the remaining final svc_xprt_put() could easily
be delayed till after we drop the lock.

Might be worth checking the other svc_xprt_put() callers.

--b.


> in_atomic(): 1, irqs_disabled(): 0, pid: 1580, name: lockd
> 1 lock held by lockd/1580:
>  #0:  (&serv->sv_lock){+.....}, at: [<e09ae747>] svc_delete_xprt+0x4d/0xba [sunrpc]
> Pid: 1580, comm: lockd Not tainted 2.6.31-38.el6.i686 #1
> Call Trace:
>  [<c04402f1>] __might_sleep+0xec/0x102
>  [<c075f3a6>] lock_sock_nested+0x28/0xe5
>  [<e09adff6>] ? svc_deferred_dequeue+0x28/0x85 [sunrpc]
>  [<c07a1bb2>] lock_sock+0x17/0x2a
>  [<c07a247a>] tcp_close+0x20/0x346
>  [<c07becdf>] inet_release+0x50/0x68
>  [<c075c99c>] sock_release+0x24/0x7a
>  [<e09a57ea>] svc_sock_free+0x45/0x62 [sunrpc]
>  [<e09af2bf>] svc_xprt_free+0x3a/0x57 [sunrpc]
>  [<e09af285>] ? svc_xprt_free+0x0/0x57 [sunrpc]
>  [<c05f8fd7>] kref_put+0x47/0x62
>  [<e09ae6e7>] svc_xprt_put+0x1f/0x32 [sunrpc]
>  [<e09ae794>] svc_delete_xprt+0x9a/0xba [sunrpc]
>  [<e09aed9f>] svc_recv+0x36a/0x654 [sunrpc]
>  [<c0444f4e>] ? default_wake_function+0x0/0x30
>  [<e0943b06>] lockd+0xd2/0x194 [lockd]
>  [<c04741e7>] ? trace_hardirqs_on+0x19/0x2c
>  [<c0439287>] ? complete+0x42/0x5d
>  [<e0943a34>] ? lockd+0x0/0x194 [lockd]
>  [<c0461a52>] kthread+0x76/0x7b
>  [<c04619dc>] ? kthread+0x0/0x7b
>  [<c040a27f>] kernel_thread_helper+0x7/0x10
> BUG: scheduling while atomic: lockd/1580/0x10000100
> 1 lock held by lockd/1580:
>  #0:  (&serv->sv_lock){+.....}, at: [<e09ae747>] svc_delete_xprt+0x4d/0xba [sunrpc]
> Modules linked in: ipt_MASQUERADE(U) iptable_nat(U) nf_nat(U) bridge(U) stp(U) llc(U) nfsd(U) lockd(U) nfs_acl(U) auth_rpcgss(U) exportfs(U) autofs4(U) sunrpc(U) ipv6(U) dm_mirror(U) dm_region_hash(U) dm_log(U) dm_multipath(U) pcnet32(U) mii(U) ppdev(U) parport_pc(U) parport(U) i2c_piix4(U) i2c_core(U) pata_acpi(U) ata_generic(U) ata_piix(U) BusLogic(U) floppy(U) dm_mod(U) [last unloaded: microcode]
> Pid: 1580, comm: lockd Not tainted 2.6.31-38.el6.i686 #1
> Call Trace:
>  [<c0442c9e>] __schedule_bug+0x70/0x88
>  [<c0806e43>] schedule+0x9c/0x7fe
>  [<c0806abf>] ? dump_stack+0x62/0x7d
>  [<c044571b>] __cond_resched+0x33/0x5a
>  [<c080767e>] _cond_resched+0x29/0x45
>  [<c075f3ab>] lock_sock_nested+0x2d/0xe5
>  [<e09adff6>] ? svc_deferred_dequeue+0x28/0x85 [sunrpc]
>  [<c07a1bb2>] lock_sock+0x17/0x2a
>  [<c07a247a>] tcp_close+0x20/0x346
>  [<c07becdf>] inet_release+0x50/0x68
>  [<c075c99c>] sock_release+0x24/0x7a
>  [<e09a57ea>] svc_sock_free+0x45/0x62 [sunrpc]
>  [<e09af2bf>] svc_xprt_free+0x3a/0x57 [sunrpc]
>  [<e09af285>] ? svc_xprt_free+0x0/0x57 [sunrpc]
>  [<c05f8fd7>] kref_put+0x47/0x62
>  [<e09ae6e7>] svc_xprt_put+0x1f/0x32 [sunrpc]
>  [<e09ae794>] svc_delete_xprt+0x9a/0xba [sunrpc]
>  [<e09aed9f>] svc_recv+0x36a/0x654 [sunrpc]
>  [<c0444f4e>] ? default_wake_function+0x0/0x30
>  [<e0943b06>] lockd+0xd2/0x194 [lockd]
>  [<c04741e7>] ? trace_hardirqs_on+0x19/0x2c
>  [<c0439287>] ? complete+0x42/0x5d
>  [<e0943a34>] ? lockd+0x0/0x194 [lockd]
>  [<c0461a52>] kthread+0x76/0x7b
>  [<c04619dc>] ? kthread+0x0/0x7b
>  [<c040a27f>] kernel_thread_helper+0x7/0x10
> BUG: unable to handle kernel paging request at 6b6b6b83
> IP: [<e09ae898>] svc_xprt_release+0x1e/0xd0 [sunrpc]
> *pdpt = 000000001bd33001 *pde = 0000000000000000
> Oops: 0000 [#1] SMP
> last sysfs file: /sys/module/nfsd/initstate
> Modules linked in: ipt_MASQUERADE(U) iptable_nat(U) nf_nat(U) bridge(U) stp(U) llc(U) nfsd(U) lockd(U) nfs_acl(U) auth_rpcgss(U) exportfs(U) autofs4(U) sunrpc(U) ipv6(U) dm_mirror(U) dm_region_hash(U) dm_log(U) dm_multipath(U) pcnet32(U) mii(U) ppdev(U) parport_pc(U) parport(U) i2c_piix4(U) i2c_core(U) pata_acpi(U) ata_generic(U) ata_piix(U) BusLogic(U) floppy(U) dm_mod(U) [last unloaded: microcode]
> Pid: 1580, comm: lockd Not tainted (2.6.31-38.el6.i686 #1) VMware Virtual Platform
> EIP: 0060:[<e09ae898>] EFLAGS: 00010246 CPU: 0
> EIP is at svc_xprt_release+0x1e/0xd0 [sunrpc]
> EAX: dc5a8000 EBX: dc5a8000 ECX: 00000007 EDX: 6b6b6b6b
> ESI: dc0948c0 EDI: dd9ca124 EBP: dd091f00 ESP: dd091ef0
>  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
> Process lockd (pid: 1580, ti=dd090000 task=dc5fd520 task.ti=dd090000)
> Stack:
>  7ab857c6 dc5a8000 fffffff5 dd9ca124 dd091f3c e09af02a 7fffffff dd9d3780
> <0> 7fffffff dc0948c0 00000000 dc5fd520 c0444f4e 00100100 00200200 7ab857c6
> <0> fffffff5 fffffff5 dc5a8000 dd091f94 e0943b06 dc5fd7bc 7ab857c6 c0c13fa0
> Call Trace:
>  [<e09af02a>] ? svc_recv+0x5f5/0x654 [sunrpc]
>  [<c0444f4e>] ? default_wake_function+0x0/0x30
>  [<e0943b06>] ? lockd+0xd2/0x194 [lockd]
>  [<c04741e7>] ? trace_hardirqs_on+0x19/0x2c
>  [<c0439287>] ? complete+0x42/0x5d
>  [<e0943a34>] ? lockd+0x0/0x194 [lockd]
>  [<c0461a52>] ? kthread+0x76/0x7b
>  [<c04619dc>] ? kthread+0x0/0x7b
>  [<c040a27f>] ? kernel_thread_helper+0x7/0x10
> Code: 74 05 e8 cf b4 a9 df 5a 5b 5e 5f 5d c3 55 89 e5 57 56 53 89 c3 83 ec 04 8b 73 10 65 a1 14 00 00 00 89 45 f0 31 c0 89 d8 8b 56 04 <ff> 52 18 8b 83 bc 00 00 00 e8 59 e2 b3 df c7 83 bc 00 00 00 00
> EIP: [<e09ae898>] svc_xprt_release+0x1e/0xd0 [sunrpc] SS:ESP 0068:dd091ef0
> CR2: 000000006b6b6b83
> CR2: 000000006b6b6b83
> 
> =========================================================
> 
> thanks,
> Mi Jinlong
> 
