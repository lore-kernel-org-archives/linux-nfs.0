From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 31/51] FIXME: nfsd: kref_get cb_client while doing the callback
Date: Mon, 10 Nov 2008 22:51:18 +0200
Message-ID: <1226350278-11264-1-git-send-email-bhalevy@panasas.com>
References: <491895A0.3040809@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:44802 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751766AbYKJUvb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:51:31 -0500
In-Reply-To: <491895A0.3040809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Marc Eshel <eshel@almaden.ibm.com>

FIXME: bhalevy: I think this patch should be dropped.
First, dp->dl_client is correctly refcounted while in do_recall and
should protect dp->dl_client->cl_callback.cb_client from going away.
Second, the rpc_clnt isn't dereferenced on the error-free path so
apparently this patch introduces a leak.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |   13 +++++++++++++
 net/sunrpc/clnt.c   |    1 +
 2 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0b45680..55fd003 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1810,6 +1810,7 @@ static
 void nfsd_break_deleg_cb(struct file_lock *fl)
 {
 	struct nfs4_delegation *dp=  (struct nfs4_delegation *)fl->fl_owner;
+	struct rpc_clnt *clnt;
 	struct task_struct *t;
 	int did_lock;
 
@@ -1817,6 +1818,17 @@ void nfsd_break_deleg_cb(struct file_lock *fl)
 	if (!dp)
 		return;
 
+	did_lock = nfs4_lock_state_nested();
+	clnt = dp->dl_client->cl_callback.cb_client;
+	if (!atomic_read(&dp->dl_client->cl_callback.cb_set) || !clnt) {
+		if (did_lock)
+			nfs4_unlock_state();
+		return;
+	}
+	kref_get(&clnt->cl_kref);
+	if (did_lock)
+		nfs4_unlock_state();
+
 	/* We're assuming the state code never drops its reference
 	 * without first removing the lease.  Since we're in this lease
 	 * callback (and since the lease code is serialized by the kernel
@@ -1846,6 +1858,7 @@ void nfsd_break_deleg_cb(struct file_lock *fl)
 		printk(KERN_INFO "NFSD: Callback thread failed for "
 			"for client (clientid %08x/%08x)\n",
 			clp->cl_clientid.cl_boot, clp->cl_clientid.cl_id);
+		rpc_release_client(clnt);
 		did_lock = nfs4_lock_state_nested();
 		put_nfs4_client(dp->dl_client);
 		nfs4_put_delegation(dp);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 5e8fba0..144f3bd 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -464,6 +464,7 @@ rpc_release_client(struct rpc_clnt *clnt)
 		wake_up(&destroy_wait);
 	kref_put(&clnt->cl_kref, rpc_free_auth);
 }
+EXPORT_SYMBOL_GPL(rpc_release_client);
 
 /**
  * rpc_bind_new_program - bind a new RPC program to an existing client
-- 
1.6.0.2

