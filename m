Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:60601 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751522Ab2I0Ubq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Sep 2012 16:31:46 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 1/2] NFSv4: Fix the legacy idmapper upcall locking
Date: Thu, 27 Sep 2012 16:31:39 -0400
Message-Id: <1348777900-44647-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We must not touch the idmap->idmap_key_cons field when a downcall
is in progress. Set up a mutex and helper functions to ensure that
we wait until the downcall is finished.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/idmap.c | 65 ++++++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 45 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index a850079..7c7072a 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -59,6 +59,7 @@ struct idmap {
 	struct rpc_pipe		*idmap_pipe;
 	struct key_construction	*idmap_key_cons;
 	struct mutex		idmap_mutex;
+	struct mutex		idmap_downcall_mutex;
 };
 
 struct idmap_legacy_upcalldata {
@@ -330,7 +331,6 @@ static ssize_t nfs_idmap_get_key(const char *name, size_t namelen,
 		ret = nfs_idmap_request_key(&key_type_id_resolver_legacy,
 					    name, namelen, type, data,
 					    data_size, idmap);
-		idmap->idmap_key_cons = NULL;
 		mutex_unlock(&idmap->idmap_mutex);
 	}
 	return ret;
@@ -485,6 +485,7 @@ nfs_idmap_new(struct nfs_client *clp)
 	}
 	idmap->idmap_pipe = pipe;
 	mutex_init(&idmap->idmap_mutex);
+	mutex_init(&idmap->idmap_downcall_mutex);
 
 	clp->cl_idmap = idmap;
 	return 0;
@@ -665,6 +666,32 @@ out:
 	return ret;
 }
 
+static void
+nfs_idmap_prepare_pipe_upcall(struct idmap *idmap,
+		struct key_construction *cons)
+{
+	mutex_lock(&idmap->idmap_downcall_mutex);
+	WARN_ON_ONCE(idmap->idmap_key_cons != NULL);
+	idmap->idmap_key_cons = cons;
+	mutex_unlock(&idmap->idmap_downcall_mutex);
+}
+
+static void
+nfs_idmap_complete_pipe_upcall_locked(struct idmap *idmap, int ret)
+{
+	complete_request_key(idmap->idmap_key_cons, ret);
+	idmap->idmap_key_cons = NULL;
+}
+
+static void
+nfs_idmap_abort_pipe_upcall(struct idmap *idmap, int ret)
+{
+	mutex_lock(&idmap->idmap_downcall_mutex);
+	if (idmap->idmap_key_cons != NULL)
+		nfs_idmap_complete_pipe_upcall_locked(idmap, ret);
+	mutex_unlock(&idmap->idmap_downcall_mutex);
+}
+
 static int nfs_idmap_legacy_upcall(struct key_construction *cons,
 				   const char *op,
 				   void *aux)
@@ -689,17 +716,14 @@ static int nfs_idmap_legacy_upcall(struct key_construction *cons,
 	if (ret < 0)
 		goto out2;
 
-	BUG_ON(idmap->idmap_key_cons != NULL);
-	idmap->idmap_key_cons = cons;
-
+	nfs_idmap_prepare_pipe_upcall(idmap, cons);
 	ret = rpc_queue_upcall(idmap->idmap_pipe, msg);
-	if (ret < 0)
-		goto out3;
+	if (ret < 0) {
+		nfs_idmap_abort_pipe_upcall(idmap, ret);
+		kfree(data);
+	}
 
 	return ret;
-
-out3:
-	idmap->idmap_key_cons = NULL;
 out2:
 	kfree(data);
 out1:
@@ -740,14 +764,16 @@ idmap_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 	struct key_construction *cons;
 	struct idmap_msg im;
 	size_t namelen_in;
-	int ret;
+	int ret = -ENOKEY;
 
 	/* If instantiation is successful, anyone waiting for key construction
 	 * will have been woken up and someone else may now have used
 	 * idmap_key_cons - so after this point we may no longer touch it.
 	 */
-	cons = ACCESS_ONCE(idmap->idmap_key_cons);
-	idmap->idmap_key_cons = NULL;
+	mutex_lock(&idmap->idmap_downcall_mutex);
+	cons = idmap->idmap_key_cons;
+	if (cons == NULL)
+		goto out_unlock;
 
 	if (mlen != sizeof(im)) {
 		ret = -ENOSPC;
@@ -777,7 +803,9 @@ idmap_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 	}
 
 out:
-	complete_request_key(cons, ret);
+	nfs_idmap_complete_pipe_upcall_locked(idmap, ret);
+out_unlock:
+	mutex_unlock(&idmap->idmap_downcall_mutex);
 	return ret;
 }
 
@@ -788,12 +816,8 @@ idmap_pipe_destroy_msg(struct rpc_pipe_msg *msg)
 			struct idmap_legacy_upcalldata,
 			pipe_msg);
 	struct idmap *idmap = data->idmap;
-	struct key_construction *cons;
-	if (msg->errno) {
-		cons = ACCESS_ONCE(idmap->idmap_key_cons);
-		idmap->idmap_key_cons = NULL;
-		complete_request_key(cons, msg->errno);
-	}
+	if (msg->errno)
+		nfs_idmap_abort_pipe_upcall(idmap, msg->errno);
 	/* Free memory allocated in nfs_idmap_legacy_upcall() */
 	kfree(data);
 }
@@ -803,7 +827,8 @@ idmap_release_pipe(struct inode *inode)
 {
 	struct rpc_inode *rpci = RPC_I(inode);
 	struct idmap *idmap = (struct idmap *)rpci->private;
-	idmap->idmap_key_cons = NULL;
+
+	nfs_idmap_abort_pipe_upcall(idmap, -EPIPE);
 }
 
 int nfs_map_name_to_uid(const struct nfs_server *server, const char *name, size_t namelen, __u32 *uid)
-- 
1.7.11.4

