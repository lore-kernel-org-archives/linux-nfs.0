Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:22076 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754100AbcJZOkg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 26 Oct 2016 10:40:36 -0400
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Subject: Re: nfs NULL-dereferencing in net-next
To: Yotam Gigi <yotamg@mellanox.com>, Jakub Kicinski <kubakici@wp.pl>,
        "Andy Adamson" <andros@Netapp.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <20161017201943.64529739@jkicinski-Precision-T1700>
 <DB3PR05MB0764DF28BC53A4A4E78A4DD8ACA80@DB3PR05MB0764.eurprd05.prod.outlook.com>
CC: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@Netapp.com>,
        Yotam Gigi <yotam.gi@gmail.com>, mlxsw <mlxsw@mellanox.com>
Message-ID: <817e43c5-d88d-e616-7074-5715de29d319@Netapp.com>
Date: Wed, 26 Oct 2016 10:40:14 -0400
MIME-Version: 1.0
In-Reply-To: <DB3PR05MB0764DF28BC53A4A4E78A4DD8ACA80@DB3PR05MB0764.eurprd05.prod.outlook.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/25/2016 01:19 PM, Yotam Gigi wrote:
> 
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>> Behalf Of Jakub Kicinski
>> Sent: Monday, October 17, 2016 10:20 PM
>> To: Andy Adamson <andros@netapp.com>; Anna Schumaker
>> <Anna.Schumaker@Netapp.com>; linux-nfs@vger.kernel.org
>> Cc: netdev@vger.kernel.org; Trond Myklebust <Trond.Myklebust@netapp.com>
>> Subject: nfs NULL-dereferencing in net-next
>>
>> Hi!
>>
>> I'm hitting this reliably on net-next, HEAD at 3f3177bb680f
>> ("fsl/fman: fix error return code in mac_probe()").
> 
> 
> I see the same thing. It happens constantly on some of my machines, making them
> completely unusable.
> 
> I bisected it and got to the commit:
> 
> commit 04ea1b3e6d8ed4978bb608c1748530af3de8c274
> Author: Andy Adamson <andros@netapp.com>
> Date:   Fri Sep 9 09:22:27 2016 -0400
> 
>     NFS add xprt switch addrs test to match client
>     
>     Signed-off-by: Andy Adamson <andros@netapp.com>
>     Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>

Thanks for reporting on this everyone!  Does this patch help?

>From 96376ca1dd4077a1d341bdcb9cc86426ee3844f1 Mon Sep 17 00:00:00 2001
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Date: Wed, 26 Oct 2016 10:33:31 -0400
Subject: [PATCH] SUNRPC: Fix suspicious RCU usage

We need to hold the rcu_read_lock() when calling rcu_dereference(),
otherwise we can't guarantee that the object being dereferenced still
exists.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 net/sunrpc/clnt.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 34dd7b2..62a4827 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2753,14 +2753,18 @@ EXPORT_SYMBOL_GPL(rpc_cap_max_reconnect_timeout);

 void rpc_clnt_xprt_switch_put(struct rpc_clnt *clnt)
 {
+       rcu_read_lock();
        xprt_switch_put(rcu_dereference(clnt->cl_xpi.xpi_xpswitch));
+       rcu_read_unlock();
 }
 EXPORT_SYMBOL_GPL(rpc_clnt_xprt_switch_put);

 void rpc_clnt_xprt_switch_add_xprt(struct rpc_clnt *clnt, struct rpc_xprt *xprt)
 {
+       rcu_read_lock();
        rpc_xprt_switch_add_xprt(rcu_dereference(clnt->cl_xpi.xpi_xpswitch),
                                 xprt);
+       rcu_read_unlock();
 }
 EXPORT_SYMBOL_GPL(rpc_clnt_xprt_switch_add_xprt);

@@ -2770,9 +2774,8 @@ bool rpc_clnt_xprt_switch_has_addr(struct rpc_clnt *clnt,
        struct rpc_xprt_switch *xps;
        bool ret;

-       xps = rcu_dereference(clnt->cl_xpi.xpi_xpswitch);
-
        rcu_read_lock();
+       xps = rcu_dereference(clnt->cl_xpi.xpi_xpswitch);
        ret = rpc_xprt_switch_has_addr(xps, sap);
        rcu_read_unlock();
        return ret;
--
2.10.1

> 
> 
>>
>> [   23.409633] BUG: unable to handle kernel NULL pointer dereference at
>> 0000000000000172
>> [   23.418716] IP: [<ffffffffc041776c>] rpc_clnt_xprt_switch_has_addr+0xc/0x40
>> [sunrpc]
>> [   23.427574] PGD 859020067 [   23.430472] PUD 858f2d067
>> PMD 0 [   23.434311]
>> [   23.436133] Oops: 0000 [#1] PREEMPT SMP
>> [   23.440506] Modules linked in: nfsv4 ip6table_filter ip6_tables iptable_filter
>> ip_tables ebtable_nat ebtables x_tables intel_ri
>> [   23.505915] CPU: 1 PID: 1067 Comm: mount.nfs Not tainted 4.8.0-perf-13951-
>> g3f3177bb680f #51
>> [   23.515363] Hardware name: Dell Inc. PowerEdge T630/0W9WXC, BIOS 1.2.10
>> 03/10/2015
>> [   23.523937] task: ffff983e9086ea00 task.stack: ffffac6c0a57c000
>> [   23.530641] RIP: 0010:[<ffffffffc041776c>]  [<ffffffffc041776c>]
>> rpc_clnt_xprt_switch_has_addr+0xc/0x40 [sunrpc]
>> [   23.542229] RSP: 0018:ffffac6c0a57fb28  EFLAGS: 00010a97
>> [   23.548255] RAX: 00000000c80214ac RBX: ffff983e97c7b000 RCX: ffff983e9b3bc180
>> [   23.556320] RDX: 0000000000000001 RSI: ffff983e9928ed28 RDI: ffffffffffffffea
>> [   23.564386] RBP: ffffac6c0a57fb38 R08: ffff983e97090630 R09: ffff983e9928ed30
>> [   23.572452] R10: ffffac6c0a57fba0 R11: 0000000000000010 R12: ffffac6c0a57fba0
>> [   23.580517] R13: ffff983e9928ed28 R14: 0000000000000000 R15: ffff983e91360560
>> [   23.588585] FS:  00007f4c348aa880(0000) GS:ffff983e9f240000(0000)
>> knlGS:0000000000000000
>> [   23.597742] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [   23.604251] CR2: 0000000000000172 CR3: 0000000850a5f000 CR4:
>> 00000000001406e0
>> [   23.612316] Stack:
>> [   23.614648]  ffff983e97c7b000 ffffac6c0a57fba0 ffffac6c0a57fb90 ffffffffc04d38c3
>> [   23.623331]  ffff983e91360500 ffff983e9928ed30 ffffffffc0b9e560
>> ffff983e913605b8
>> [   23.632016]  ffff983e9882e800 ffff983e9882e800 ffffac6c0a57fc30 ffffac6c0a57fdb8
>> [   23.640706] Call Trace:
>> [   23.643535]  [<ffffffffc04d38c3>] nfs_get_client+0x123/0x340 [nfs]
>> [   23.650542]  [<ffffffffc0b8f070>] nfs4_set_client+0x80/0xb0 [nfsv4]
>> [   23.657642]  [<ffffffffc0b90305>] nfs4_create_server+0x115/0x2a0 [nfsv4]
>> [   23.665230]  [<ffffffffc0b888ce>] nfs4_remote_mount+0x2e/0x60 [nfsv4]
>> [   23.672519]  [<ffffffffba1e590a>] mount_fs+0x3a/0x160
>> [   23.678254]  [<ffffffffba201a5e>] ? alloc_vfsmnt+0x19e/0x230
>> [   23.684669]  [<ffffffffba201b57>] vfs_kern_mount+0x67/0x110
>> [   23.690990]  [<ffffffffc0b887f4>] nfs_do_root_mount+0x84/0xc0 [nfsv4]
>> [   23.698284]  [<ffffffffc0b88b97>] nfs4_try_mount+0x37/0x50 [nfsv4]
>> [   23.705287]  [<ffffffffc04dfbd1>] nfs_fs_mount+0x2d1/0xa70 [nfs]
>> [   23.712092]  [<ffffffffba3a6228>] ? find_next_bit+0x18/0x20
>> [   23.718413]  [<ffffffffc04deac0>] ? nfs_remount+0x3c0/0x3c0 [nfs]
>> [   23.725316]  [<ffffffffc04dedb0>] ? nfs_clone_super+0x130/0x130 [nfs]
>> [   23.732606]  [<ffffffffba1e590a>] mount_fs+0x3a/0x160
>> [   23.738340]  [<ffffffffba201a5e>] ? alloc_vfsmnt+0x19e/0x230
>> [   23.744755]  [<ffffffffba201b57>] vfs_kern_mount+0x67/0x110
>> [   23.751071]  [<ffffffffba2041df>] do_mount+0x1bf/0xc70
>> [   23.756904]  [<ffffffffba203e9b>] ? copy_mount_options+0xbb/0x220
>> [   23.763803]  [<ffffffffba204fa3>] SyS_mount+0x83/0xd0
>> [   23.769538]  [<ffffffffba6f1ea4>] entry_SYSCALL_64_fastpath+0x17/0x98
>> [   23.776817] Code: 01 00 48 8b 93 f8 04 00 00 44 89 e6 48 c7 c7 98 b2 43 c0 e8 9f 0d d4
>> f9 eb c0 0f 1f 44 00 00 0f 1f 44 00 00
>> [   23.802909] RIP  [<ffffffffc041776c>] rpc_clnt_xprt_switch_has_addr+0xc/0x40
>> [sunrpc]
>> [   23.811857]  RSP <ffffac6c0a57fb28>
>> [   23.815839] CR2: 0000000000000172
>> [   23.819629] ---[ end trace 9958eca92c9eeafe ]---
>> [   23.827345] note: mount.nfs[1067] exited with preempt_count 1
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

