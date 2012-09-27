Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:60601 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752697Ab2I0Ubr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Sep 2012 16:31:47 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 2/2] NFSv4: Ensure that idmap_pipe_downcall sanity-checks the downcall data
Date: Thu, 27 Sep 2012 16:31:40 -0400
Message-Id: <1348777900-44647-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1348777900-44647-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1348777900-44647-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the idmapper upcall data to verify that the legacy idmapper daemon
is indeed responding to an upcall that we sent.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/idmap.c | 62 +++++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 37 insertions(+), 25 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index 7c7072a..34d3072 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -55,19 +55,20 @@
 static const struct cred *id_resolver_cache;
 static struct key_type key_type_id_resolver_legacy;
 
-struct idmap {
-	struct rpc_pipe		*idmap_pipe;
-	struct key_construction	*idmap_key_cons;
-	struct mutex		idmap_mutex;
-	struct mutex		idmap_downcall_mutex;
-};
-
 struct idmap_legacy_upcalldata {
 	struct rpc_pipe_msg pipe_msg;
 	struct idmap_msg idmap_msg;
+	struct key_construction	*key_cons;
 	struct idmap *idmap;
 };
 
+struct idmap {
+	struct rpc_pipe		*idmap_pipe;
+	struct idmap_legacy_upcalldata *idmap_upcall_data;
+	struct mutex		idmap_mutex;
+	struct mutex		idmap_downcall_mutex;
+};
+
 /**
  * nfs_fattr_init_names - initialise the nfs_fattr owner_name/group_name fields
  * @fattr: fully initialised struct nfs_fattr
@@ -668,26 +669,27 @@ out:
 
 static void
 nfs_idmap_prepare_pipe_upcall(struct idmap *idmap,
-		struct key_construction *cons)
+		struct idmap_legacy_upcalldata *data)
 {
 	mutex_lock(&idmap->idmap_downcall_mutex);
-	WARN_ON_ONCE(idmap->idmap_key_cons != NULL);
-	idmap->idmap_key_cons = cons;
+	WARN_ON_ONCE(idmap->idmap_upcall_data != NULL);
+	idmap->idmap_upcall_data = data;
 	mutex_unlock(&idmap->idmap_downcall_mutex);
 }
 
 static void
 nfs_idmap_complete_pipe_upcall_locked(struct idmap *idmap, int ret)
 {
-	complete_request_key(idmap->idmap_key_cons, ret);
-	idmap->idmap_key_cons = NULL;
+	complete_request_key(idmap->idmap_upcall_data->key_cons, ret);
+	kfree(idmap->idmap_upcall_data);
+	idmap->idmap_upcall_data = NULL;
 }
 
 static void
 nfs_idmap_abort_pipe_upcall(struct idmap *idmap, int ret)
 {
 	mutex_lock(&idmap->idmap_downcall_mutex);
-	if (idmap->idmap_key_cons != NULL)
+	if (idmap->idmap_upcall_data != NULL)
 		nfs_idmap_complete_pipe_upcall_locked(idmap, ret);
 	mutex_unlock(&idmap->idmap_downcall_mutex);
 }
@@ -716,12 +718,10 @@ static int nfs_idmap_legacy_upcall(struct key_construction *cons,
 	if (ret < 0)
 		goto out2;
 
-	nfs_idmap_prepare_pipe_upcall(idmap, cons);
+	nfs_idmap_prepare_pipe_upcall(idmap, data);
 	ret = rpc_queue_upcall(idmap->idmap_pipe, msg);
-	if (ret < 0) {
+	if (ret < 0)
 		nfs_idmap_abort_pipe_upcall(idmap, ret);
-		kfree(data);
-	}
 
 	return ret;
 out2:
@@ -738,21 +738,32 @@ static int nfs_idmap_instantiate(struct key *key, struct key *authkey, char *dat
 					authkey);
 }
 
-static int nfs_idmap_read_message(struct idmap_msg *im, struct key *key, struct key *authkey)
+static int nfs_idmap_read_and_verify_message(struct idmap_msg *im,
+		struct idmap_msg *upcall,
+		struct key *key, struct key *authkey)
 {
 	char id_str[NFS_UINT_MAXLEN];
-	int ret = -EINVAL;
+	int ret = -ENOKEY;
 
+	/* ret = -ENOKEY */
+	if (upcall->im_type != im->im_type || upcall->im_conv != im->im_conv)
+		goto out;
 	switch (im->im_conv) {
 	case IDMAP_CONV_NAMETOID:
+		if (strcmp(upcall->im_name, im->im_name) != 0)
+			break;
 		sprintf(id_str, "%d", im->im_id);
 		ret = nfs_idmap_instantiate(key, authkey, id_str);
 		break;
 	case IDMAP_CONV_IDTONAME:
+		if (upcall->im_id != im->im_id)
+			break;
 		ret = nfs_idmap_instantiate(key, authkey, im->im_name);
 		break;
+	default:
+		ret = -EINVAL;
 	}
-
+out:
 	return ret;
 }
 
@@ -771,10 +782,11 @@ idmap_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 	 * idmap_key_cons - so after this point we may no longer touch it.
 	 */
 	mutex_lock(&idmap->idmap_downcall_mutex);
-	cons = idmap->idmap_key_cons;
-	if (cons == NULL)
+	if (idmap->idmap_upcall_data == NULL)
 		goto out_unlock;
 
+	cons = idmap->idmap_upcall_data->key_cons;
+
 	if (mlen != sizeof(im)) {
 		ret = -ENOSPC;
 		goto out;
@@ -796,7 +808,9 @@ idmap_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 		goto out;
 	}
 
-	ret = nfs_idmap_read_message(&im, cons->key, cons->authkey);
+	ret = nfs_idmap_read_and_verify_message(&im,
+			&idmap->idmap_upcall_data->idmap_msg,
+			cons->key, cons->authkey);
 	if (ret >= 0) {
 		key_set_timeout(cons->key, nfs_idmap_cache_timeout);
 		ret = mlen;
@@ -818,8 +832,6 @@ idmap_pipe_destroy_msg(struct rpc_pipe_msg *msg)
 	struct idmap *idmap = data->idmap;
 	if (msg->errno)
 		nfs_idmap_abort_pipe_upcall(idmap, msg->errno);
-	/* Free memory allocated in nfs_idmap_legacy_upcall() */
-	kfree(data);
 }
 
 static void
-- 
1.7.11.4

