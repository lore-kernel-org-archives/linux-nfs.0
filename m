From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 30/51] nfsd: lock state around nfs4_put_delegation in nfsd_break_deleg_cb err path
Date: Mon, 10 Nov 2008 22:50:57 +0200
Message-ID: <1226350257-11225-1-git-send-email-bhalevy@panasas.com>
References: <491895A0.3040809@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:44797 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752047AbYKJUvL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:51:11 -0500
In-Reply-To: <491895A0.3040809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If kthread_run fails we put the client and delegation.  This requires
the state lock since the fi_hash is manipulated in the process.
Use nfs4_lock_state_nested as nfsd_break_deleg_cb may be called
back by the filesystem while under the state lock (e.g. in the close path)

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7fe074a..0b45680 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -94,6 +94,7 @@ static void nfs4_set_recdir(char *recdir);
  * 	unconfstr_hashtbl[], uncofid_hashtbl[].
  */
 static DEFINE_MUTEX(client_mutex);
+static struct thread_info *client_mutex_owner;
 
 static struct kmem_cache *stateowner_slab = NULL;
 static struct kmem_cache *file_slab = NULL;
@@ -106,14 +107,26 @@ void
 nfs4_lock_state(void)
 {
 	mutex_lock(&client_mutex);
+	client_mutex_owner = current_thread_info();
 }
 
 void
 nfs4_unlock_state(void)
 {
+	BUG_ON(client_mutex_owner != current_thread_info());
+	client_mutex_owner = NULL;
 	mutex_unlock(&client_mutex);
 }
 
+static int
+nfs4_lock_state_nested(void)
+{
+	if (client_mutex_owner == current_thread_info())
+		return 0;
+	nfs4_lock_state();
+	return 1;
+}
+
 static inline u32
 opaque_hashval(const void *ptr, int nbytes)
 {
@@ -1798,6 +1811,7 @@ void nfsd_break_deleg_cb(struct file_lock *fl)
 {
 	struct nfs4_delegation *dp=  (struct nfs4_delegation *)fl->fl_owner;
 	struct task_struct *t;
+	int did_lock;
 
 	dprintk("NFSD nfsd_break_deleg_cb: dp %p fl %p\n",dp,fl);
 	if (!dp)
@@ -1832,8 +1846,11 @@ void nfsd_break_deleg_cb(struct file_lock *fl)
 		printk(KERN_INFO "NFSD: Callback thread failed for "
 			"for client (clientid %08x/%08x)\n",
 			clp->cl_clientid.cl_boot, clp->cl_clientid.cl_id);
+		did_lock = nfs4_lock_state_nested();
 		put_nfs4_client(dp->dl_client);
 		nfs4_put_delegation(dp);
+		if (did_lock)
+			nfs4_unlock_state();
 	}
 }
 
-- 
1.6.0.2

