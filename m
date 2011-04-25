Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:41311 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758696Ab1DYSnf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Apr 2011 14:43:35 -0400
Received: by iyb14 with SMTP id 14so2054039iyb.19
        for <linux-nfs@vger.kernel.org>; Mon, 25 Apr 2011 11:43:34 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/15] NFS: Address lockdep splat during NFSv4 mount
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 25 Apr 2011 14:43:32 -0400
Message-ID: <20110425184332.5669.45119.stgit@matisse.1015granger.net>
In-Reply-To: <20110425183405.5669.52507.stgit@matisse.1015granger.net>
References: <20110425183405.5669.52507.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

===================================================
[ INFO: suspicious rcu_dereference_check() usage. ]
---------------------------------------------------
linux/nfs-2.6/fs/nfs/client.c:1289 invoked rcu_dereference_check() without protection!

other info that might help us debug this:


rcu_scheduler_active = 1, debug_locks = 0
no locks held by mount.nfs/2525.

stack backtrace:
Pid: 2525, comm: mount.nfs Not tainted 2.6.39-rc3-00045-g2fb8dcc #6
Call Trace:
[<ffffffff8107c44b>] lockdep_rcu_dereference+0xaa/0xb2
[<ffffffffa033ed38>] nfs4_init_client+0x126/0x1d7 [nfs]
[<ffffffffa033f924>] nfs_get_client+0x459/0x5b1 [nfs]
[<ffffffff81085735>] ?  is_module_address+0xe/0x16
[<ffffffff8107bee5>] ?  lockdep_init_map+0x9b/0x110
[<ffffffffa033fb02>] nfs4_set_client+0x86/0xda [nfs]
[<ffffffffa034037e>] nfs4_create_server+0xf7/0x228 [nfs]
[<ffffffff811148cb>] ?  kmem_cache_alloc_trace+0xaf/0xbe
[<ffffffffa034922b>] nfs4_remote_mount+0x80/0x1ec [nfs]
[<ffffffff81123e3c>] mount_fs+0x70/0x157
[<ffffffff810f251a>] ?  __alloc_percpu+0x10/0x12
[<ffffffff8113a83a>] vfs_kern_mount+0x65/0xa0
[<ffffffffa0349603>] nfs_do_root_mount+0x7b/0x9a [nfs]
[<ffffffffa034997f>] nfs4_try_mount+0x5a/0xbf [nfs]
[<ffffffffa034ac0c>] nfs_fs_mount+0x4a6/0x6fe [nfs]
[<ffffffff81123e3c>] mount_fs+0x70/0x157
[<ffffffff810f251a>] ?  __alloc_percpu+0x10/0x12
[<ffffffff8113a83a>] vfs_kern_mount+0x65/0xa0
[<ffffffff8113b1eb>] do_kern_mount+0x4d/0xdd
[<ffffffff8113c026>] do_mount+0x6bd/0x720
[<ffffffff8113c111>] sys_mount+0x88/0xc2
[<ffffffff814970c2>] system_call_fastpath+0x16/0x1b

Commit cf8bebc9 "SUNRPC: Use RCU to dereference the rpc_client cl_xprt
structure" seems to have introduced this.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/client.c   |   40 +++++++++++++++++++++++-----------------
 net/sunrpc/xprt.c |    2 ++
 2 files changed, 25 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 86cc751..8f8035e 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1270,29 +1270,35 @@ nfs4_find_client_sessionid(const struct sockaddr *addr,
  */
 static int nfs4_init_callback(struct nfs_client *clp)
 {
+	struct rpc_xprt *xprt;
 	int error;
 
-	if (clp->rpc_ops->version == 4) {
-		struct rpc_xprt *xprt;
+	if (clp->rpc_ops->version != 4)
+		return 0;
 
-		xprt = rcu_dereference(clp->cl_rpcclient->cl_xprt);
+	rcu_read_lock();
+	xprt = xprt_get(rcu_dereference(clp->cl_rpcclient->cl_xprt));
+	rcu_read_unlock();
 
-		if (nfs4_has_session(clp)) {
-			error = xprt_setup_backchannel(xprt,
-						NFS41_BC_MIN_CALLBACKS);
-			if (error < 0)
-				return error;
-		}
+	if (nfs4_has_session(clp)) {
+		error = xprt_setup_backchannel(xprt, NFS41_BC_MIN_CALLBACKS);
+		if (error < 0)
+			goto out;
+	}
 
-		error = nfs_callback_up(clp->cl_mvops->minor_version, xprt);
-		if (error < 0) {
-			dprintk("%s: failed to start callback. Error = %d\n",
-				__func__, error);
-			return error;
-		}
-		__set_bit(NFS_CS_CALLBACK, &clp->cl_res_state);
+	error = nfs_callback_up(clp->cl_mvops->minor_version, xprt);
+	if (error < 0) {
+		dprintk("%s: failed to start callback. Error = %d\n",
+			__func__, error);
+		goto out;
 	}
-	return 0;
+
+	error = 0;
+	__set_bit(NFS_CS_CALLBACK, &clp->cl_res_state);
+
+out:
+	xprt_put(xprt);
+	return error;
 }
 
 /*
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 201debb..531ab6b 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1187,6 +1187,7 @@ void xprt_put(struct rpc_xprt *xprt)
 	if (atomic_dec_and_test(&xprt->count))
 		xprt_destroy(xprt);
 }
+EXPORT_SYMBOL_GPL(xprt_put);
 
 /**
  * xprt_get - return a reference to an RPC transport.
@@ -1199,3 +1200,4 @@ struct rpc_xprt *xprt_get(struct rpc_xprt *xprt)
 		return xprt;
 	return NULL;
 }
+EXPORT_SYMBOL_GPL(xprt_get);

