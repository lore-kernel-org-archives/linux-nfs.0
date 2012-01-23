Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:40698 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751990Ab2AWR5c convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jan 2012 12:57:32 -0500
Message-ID: <1327341448.2628.1.camel@lade.trondhjem.org>
Subject: Re: [PATCH] SUNRPC: Clean up the RPCSEC_GSS service ticket requests
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Date: Mon, 23 Jan 2012 12:57:28 -0500
In-Reply-To: <20120123165124.GA32197@fieldses.org>
References: <1325608907-17801-1-git-send-email-Trond.Myklebust@netapp.com>
	 <20120103165544.GC6309@fieldses.org> <20120123165124.GA32197@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2012-01-23 at 11:51 -0500, Bruce Fields wrote: 
> general protection fault: 0000 [#1] PREEMPT SMP 
> CPU 0 
> Modules linked in: rpcsec_gss_krb5 nfs nfsd lockd nfs_acl auth_rpcgss sunrpc [last unloaded: scsi_wait_scan]
> 
> Pid: 6645, comm: 192.168.122.11- Not tainted 3.2.0-00001-g68c9715 #966 Bochs Bochs
> RIP: 0010:[<ffffffff81516399>]  [<ffffffff81516399>] strnlen+0x9/0x40
> RSP: 0018:ffff8800376b77d0  EFLAGS: 00010286
> RAX: ffffffff81d027fc RBX: ffff88003758e398 RCX: ffffffffff0a0004
> RDX: 5a5a5a5a5a5a5a5a RSI: ffffffffffffffff RDI: 5a5a5a5a5a5a5a5a
> RBP: ffff8800376b77d0 R08: 000000000000fffb R09: 0000ffffffffff0a
> R10: 0000000000000001 R11: 0000000000000000 R12: ffff8800b758e38f
> R13: 5a5a5a5a5a5a5a5a R14: ffffffffffffffff R15: 00000000ffffffff
> FS:  0000000000000000(0000) GS:ffff88003fc00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 00000000004073e0 CR3: 0000000001e05000 CR4: 00000000000006f0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process 192.168.122.11- (pid: 6645, threadinfo ffff8800376b6000, task ffff88003b576080)
> Stack:
>  ffff8800376b7820 ffffffff815179ef ffff8800376b7800 ffffffff81097110
>  ffff8800376b7810 ffff88003758e398 ffffffffa00524f9 ffffffffa00524f7
>  ffff8800376b78a0 ffff8800b758e38f ffff8800376b7890 ffffffff81518b6a
> Call Trace:
>  [<ffffffff815179ef>] string+0x4f/0xf0
>  [<ffffffff81097110>] ? is_module_address+0x30/0x60
>  [<ffffffff81518b6a>] vsnprintf+0x1da/0x5b0
>  [<ffffffff81088964>] ? static_obj+0x44/0x60
>  [<ffffffff81518f80>] sprintf+0x40/0x50
>  [<ffffffffa004d938>] gss_setup_upcall+0x1d8/0x2d0 [auth_rpcgss]
>  [<ffffffffa004dcc3>] gss_cred_init+0xc3/0x3a0 [auth_rpcgss]
>  [<ffffffffa000c3ac>] ? rpcauth_lookup_credcache+0x21c/0x2c0 [sunrpc]
>  [<ffffffff81077500>] ? wake_up_bit+0x40/0x40
>  [<ffffffff81950afd>] ? sub_preempt_count+0x9d/0xd0
>  [<ffffffffa000c327>] rpcauth_lookup_credcache+0x197/0x2c0 [sunrpc]
>  [<ffffffffa000c190>] ? rpcauth_refreshcred+0x1d0/0x1d0 [sunrpc]
>  [<ffffffff8105b1a2>] ? local_bh_enable_ip+0x82/0x100
>  [<ffffffffa004c5ce>] gss_lookup_cred+0xe/0x10 [auth_rpcgss]
>  [<ffffffffa000cdbf>] generic_bind_cred+0x1f/0x30 [sunrpc]
>  [<ffffffffa000c061>] rpcauth_refreshcred+0xa1/0x1d0 [sunrpc]
>  [<ffffffffa00006d3>] call_refresh+0x43/0x70 [sunrpc]
>  [<ffffffffa000a8c6>] __rpc_execute+0x66/0x2b0 [sunrpc]
>  [<ffffffff810774ef>] ? wake_up_bit+0x2f/0x40
>  [<ffffffffa000ab53>] rpc_execute+0x43/0x50 [sunrpc]
>  [<ffffffffa0002315>] rpc_run_task+0x75/0x90 [sunrpc]
>  [<ffffffffa0002432>] rpc_call_sync+0x42/0x70 [sunrpc]
>  [<ffffffffa00e5a1f>] nfs4_proc_setclientid+0x1af/0x210 [nfs]
>  [<ffffffffa00f2e17>] nfs4_init_clientid+0xc7/0x130 [nfs]
>  [<ffffffff8194d55b>] ? _raw_spin_unlock_irq+0x3b/0x60
>  [<ffffffffa00f24dd>] nfs4_run_state_manager+0x2ad/0x600 [nfs]
>  [<ffffffffa00f2230>] ? nfs4_do_reclaim+0x590/0x590 [nfs]
>  [<ffffffff81076fc6>] kthread+0x96/0xa0
>  [<ffffffff81955bf4>] kernel_thread_helper+0x4/0x10
>  [<ffffffff81046548>] ? finish_task_switch+0x88/0xf0
>  [<ffffffff8194d961>] ? retint_restore_args+0xe/0xe
>  [<ffffffff81076f30>] ? __init_kthread_worker+0x70/0x70
>  [<ffffffff81955bf0>] ? gs_change+0xb/0xb
> Code: 66 90 48 83 c2 01 80 3a 00 75 f7 48 89 d0 48 29 f8 c9 c3 66 66 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 85 f6 48 89 e5 74 2e <80> 3f 00 74 29 48 83 ee 01 48 89 f8 eb 12 66 0f 1f 84 00 00 00 
> RIP  [<ffffffff81516399>] strnlen+0x9/0x40
>  RSP <ffff8800376b77d0>
> ---[ end trace bff324891ae17805 ]---

Does the following patch help?

8<------------------------------------------------------------------------ 
>From 831dd055bd8111f02bca7c248cba25261969e318 Mon Sep 17 00:00:00 2001
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Mon, 23 Jan 2012 12:49:36 -0500
Subject: [PATCH] SUNRPC: Fix machine creds in generic_create_cred and
 generic_match

- generic_create_cred needs to copy the '.principal' field.
- generic_match needs to ignore the groups and match on the '.principal'
  field.

This fixes an Oops that was introduced by commit 68c9715 (SUNRPC:
Clean up the RPCSEC_GSS service ticket requests)

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/auth_generic.c |   17 ++++++++++++++++-
 1 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
index 1426ec3..75762f3 100644
--- a/net/sunrpc/auth_generic.c
+++ b/net/sunrpc/auth_generic.c
@@ -92,6 +92,7 @@ generic_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
 	if (gcred->acred.group_info != NULL)
 		get_group_info(gcred->acred.group_info);
 	gcred->acred.machine_cred = acred->machine_cred;
+	gcred->acred.principal = acred->principal;
 
 	dprintk("RPC:       allocated %s cred %p for uid %d gid %d\n",
 			gcred->acred.machine_cred ? "machine" : "generic",
@@ -123,6 +124,17 @@ generic_destroy_cred(struct rpc_cred *cred)
 	call_rcu(&cred->cr_rcu, generic_free_cred_callback);
 }
 
+static int
+machine_cred_match(struct auth_cred *acred, struct generic_cred *gcred, int flags)
+{
+	if (!gcred->acred.machine_cred ||
+	    gcred->acred.principal != acred->principal ||
+	    gcred->acred.uid != acred->uid ||
+	    gcred->acred.gid != acred->gid)
+		return 0;
+	return 1;
+}
+
 /*
  * Match credentials against current process creds.
  */
@@ -132,9 +144,12 @@ generic_match(struct auth_cred *acred, struct rpc_cred *cred, int flags)
 	struct generic_cred *gcred = container_of(cred, struct generic_cred, gc_base);
 	int i;
 
+	if (acred->machine_cred)
+		return machine_cred_match(acred, gcred, flags);
+
 	if (gcred->acred.uid != acred->uid ||
 	    gcred->acred.gid != acred->gid ||
-	    gcred->acred.machine_cred != acred->machine_cred)
+	    gcred->acred.machine_cred != 0)
 		goto out_nomatch;
 
 	/* Optimisation in the case where pointers are identical... */
-- 
1.7.7.5


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

