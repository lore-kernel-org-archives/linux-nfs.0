Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53659 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751788Ab0GaTUU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 31 Jul 2010 15:20:20 -0400
Subject: Re: auth_gss.c - rcu dereference warning
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Johannes Berg <johannes@sipsolutions.net>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
In-Reply-To: <1280227718.3755.3.camel@jlt3.sipsolutions.net>
References: <1280227718.3755.3.camel@jlt3.sipsolutions.net>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 31 Jul 2010 15:20:11 -0400
Message-ID: <1280604011.3125.28.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-07-27 at 12:48 +0200, Johannes Berg wrote:
> I consistently get this when I unmount an NFS volume.
> 
> johannes
> 
> [  381.427221] ===================================================
> [  381.427225] [ INFO: suspicious rcu_dereference_check() usage. ]
> [  381.427228] ---------------------------------------------------
> [  381.427232] /home/johannes/sys/wireless-testing/net/sunrpc/auth_gss/auth_gss.c:947 invoked rcu_dereference_check() without protection!
> [  381.427236] 
> [  381.427237] other info that might help us debug this:
> [  381.427238] 
> [  381.427241] 
> [  381.427242] rcu_scheduler_active = 1, debug_locks = 1
> [  381.427246] 2 locks held by rpciod/0/1881:
> [  381.427248]  #0:  (rpciod){+.+.+.}, at: [<ffffffff810640cf>] run_workqueue+0x11f/0x3c0
> [  381.427262]  #1:  ((&task->u.tk_work)){+.+.+.}, at: [<ffffffff810640cf>] run_workqueue+0x11f/0x3c0
> [  381.427271] 
> [  381.427272] stack backtrace:
> [  381.427276] Pid: 1881, comm: rpciod/0 Not tainted 2.6.35-rc6-wl-47665-gc2e2180-dirty #174
> [  381.427280] Call Trace:
> [  381.427289]  [<ffffffff8107e494>] lockdep_rcu_dereference+0xa4/0xc0
> [  381.427297]  [<ffffffffa05e0191>] gss_free_ctx+0x91/0xa0 [auth_rpcgss]
> [  381.427311]  [<ffffffffa05e19ed>] gss_destroy_nullcred+0x4d/0x70 [auth_rpcgss]
> [  381.427331]  [<ffffffffa0598f97>] put_rpccred+0x127/0x140 [sunrpc]
> [  381.427348]  [<ffffffffa059922e>] rpcauth_unbindcred+0x2e/0x70 [sunrpc]
> [  381.427371]  [<ffffffffa05970ea>] rpc_put_task+0x3a/0xd0 [sunrpc]
> [  381.427386]  [<ffffffffa0597810>] rpc_release_task+0x70/0xa0 [sunrpc]
> [  381.427402]  [<ffffffffa0598229>] __rpc_execute+0x179/0x200 [sunrpc]
> [  381.427433]  [<ffffffffa05982f5>] rpc_async_schedule+0x15/0x20 [sunrpc]
> [  381.427438]  [<ffffffff81064120>] run_workqueue+0x170/0x3c0
> [  381.427457]  [<ffffffff81064413>] worker_thread+0xa3/0x110
> [  381.427472]  [<ffffffff81069386>] kthread+0x96/0xa0
> [  381.427479]  [<ffffffff81003514>] kernel_thread_helper+0x4/0x10

Hi,

Does the following patch help?

Cheers
  Trond
------------------------------------------------------------------------------------------
From: Trond Myklebust <Trond.Myklebust@netapp.com>
SUNRPC: Defer deleting the security context until gss_do_free_ctx()
    
There is no need to delete the gss context separately from the rest
of the security context information, and doing so gives rise to a
an rcu_dereference_check() warning.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 8da2a0e..496601f 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -928,6 +928,7 @@ gss_do_free_ctx(struct gss_cl_ctx *ctx)
 {
 	dprintk("RPC:       gss_free_ctx\n");
 
+	gss_delete_sec_context(&ctx->gc_gss_ctx);
 	kfree(ctx->gc_wire_ctx.data);
 	kfree(ctx);
 }
@@ -942,13 +943,7 @@ gss_free_ctx_callback(struct rcu_head *head)
 static void
 gss_free_ctx(struct gss_cl_ctx *ctx)
 {
-	struct gss_ctx *gc_gss_ctx;
-
-	gc_gss_ctx = rcu_dereference(ctx->gc_gss_ctx);
-	rcu_assign_pointer(ctx->gc_gss_ctx, NULL);
 	call_rcu(&ctx->gc_rcu, gss_free_ctx_callback);
-	if (gc_gss_ctx)
-		gss_delete_sec_context(&gc_gss_ctx);
 }
 
 static void

