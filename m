Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:43831 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932141AbcKOPJY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 15 Nov 2016 10:09:24 -0500
Subject: Re: [BUG] Suspicious RCU usage: NFS client - 4.9-rc4
To: Russell King - ARM Linux <linux@armlinux.org.uk>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Josh Triplett <josh@joshtriplett.org>
References: <20161115150706.GW1041@n2100.armlinux.org.uk>
CC: <linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <b8111506-5003-058f-6f9f-e3c137e5c90a@Netapp.com>
Date: Tue, 15 Nov 2016 10:09:14 -0500
MIME-Version: 1.0
In-Reply-To: <20161115150706.GW1041@n2100.armlinux.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Russel,

On 11/15/2016 10:07 AM, Russell King - ARM Linux wrote:
> While booting two of my machines, I noticed this splat on the console.
> Not sure if this is due to a RCU change or NFS change, so adding folk
> on both sides.

The patch to fix this went into rc5 :)

Thanks for reporting!
Anna

> 
> ===============================
> [ INFO: suspicious RCU usage. ]
> 4.9.0-rc4+ #2050 Not tainted
> -------------------------------
> net/sunrpc/clnt.c:2773 suspicious rcu_dereference_check() usage!
> 
> other info that might help us debug this:
> 
> 
> rcu_scheduler_active = 1, debug_locks = 0
> 1 lock held by mount.nfs/1499:
>  #0: 
>  (
> &(&nn->nfs_client_lock)->rlock
> ){+.+...}
> , at: 
> [<c026c6d4>] nfs_get_client+0xe8/0x580
> 
> stack backtrace:
> CPU: 1 PID: 1499 Comm: mount.nfs Not tainted 4.9.0-rc4+ #2050
> Hardware name: Freescale i.MX6 Quad/DualLite (Device Tree)
> Backtrace: 
> [<c0013b84>] (dump_backtrace) from [<c0013dc4>] (show_stack+0x18/0x1c)
>  r6:60010013 r5:ffffffff r4:00000000 r3:00000000
> [<c0013dac>] (show_stack) from [<c035d300>] (dump_stack+0xa4/0xdc)
> [<c035d25c>] (dump_stack) from [<c008093c>] (lockdep_rcu_suspicious+0xbc/0x11c)
>  r6:00000ad5 r5:c08f4078 r4:ee58a4c0 r3:ee58a4c0
> [<c0080880>] (lockdep_rcu_suspicious) from [<c0721ba4>] (rpc_clnt_xprt_switch_has_addr+0x134/0x15c)
>  r7:ef27dd80 r6:c0ae3972 r5:eeb5a110 r4:ee930400
> [<c0721a70>] (rpc_clnt_xprt_switch_has_addr) from [<c026c814>] (nfs_get_client+0x228/0x580)
>  r6:ef27ddd0 r5:eeb5a110 r4:00000000
> [<c026c5ec>] (nfs_get_client) from [<c026cc20>] (nfs_create_server+0xb4/0x3d4)
>  r10:edaebe6c r9:c0a84d54 r8:edaebd30 r7:edf7b480 r6:00000000 r5:ed50a000
>  r4:eeb5a000
> [<c026cb6c>] (nfs_create_server) from [<c028a2f8>] (nfs3_create_server+0x10/0x28)
>  r10:00000000 r9:edbea200 r8:c0a84d54 r7:edaebe6c r6:00000000 r5:00000001
>  r4:eeb5a000
> [<c028a2e8>] (nfs3_create_server) from [<c02792a0>] (nfs_try_mount+0x188/0x280)
>  r4:eeb5a000 r3:c028a2e8
> [<c0279118>] (nfs_try_mount) from [<c027b28c>] (nfs_fs_mount+0x420/0x8c0)
>  r10:00000000 r9:00000400 r8:edbea200 r7:edbea200 r6:c0a84d54 r5:edbea206
>  r4:eeb5a000
> [<c027ae6c>] (nfs_fs_mount) from [<c016eaf4>] (mount_fs+0x1c/0xa8)
>  r10:ed4f5000 r9:edbea340 r8:c0a82204 r7:c019091c r6:c0a82204 r5:edbea200
>  r4:ed8a3700
> [<c016ead8>] (mount_fs) from [<c018d6d0>] (vfs_kern_mount+0x5c/0x138)
>  r6:00000000 r5:edbea200 r4:ed8a3700
> [<c018d674>] (vfs_kern_mount) from [<c019091c>] (do_mount+0x164/0xc58)
>  r10:c0191774 r8:edbea200 r7:00000020 r6:ed4f5000 r5:c0a82204 r4:00000000
> [<c01907b8>] (do_mount) from [<c0191774>] (SyS_mount+0x7c/0xa4)
>  r10:00000000 r9:edaea000 r8:0078c0f8 r7:00000000 r6:ed4f5000 r5:edbea200
>  r4:edbea340
> [<c01916f8>] (SyS_mount) from [<c000fd60>] (ret_fast_syscall+0x0/0x1c)
>  r8:c000ff04 r7:00000015 r6:0078dd50 r5:bed2bad0 r4:007968a8
> 
> 

