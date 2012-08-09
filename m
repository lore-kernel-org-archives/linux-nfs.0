Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:50787 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754668Ab2HISGY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Aug 2012 14:06:24 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] NFS: Clear key construction data if the idmap upcall fails
Date: Thu,  9 Aug 2012 14:05:49 -0400
Message-Id: <1344535551-4412-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

idmap_pipe_downcall already clears this field if the upcall succeeds,
but if it fails (rpc.idmapd isn't running) the field will still be set
on the next call triggering a BUG_ON().  This patch tries to handle all
possible ways that the upcall could fail and clear the idmap key data
for each one.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/idmap.c            | 29 ++++++++++++++++++++++++++---
 include/linux/nfs_idmap.h |  1 +
 2 files changed, 27 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index 66d0e85..c2b4004 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -324,6 +324,7 @@ static ssize_t nfs_idmap_get_key(const char *name, size_t namelen,
 		ret = nfs_idmap_request_key(&key_type_id_resolver_legacy,
 					    name, namelen, type, data,
 					    data_size, idmap);
+		idmap->idmap_key_cons = NULL;
 		mutex_unlock(&idmap->idmap_mutex);
 	}
 	return ret;
@@ -380,11 +381,13 @@ static const match_table_t nfs_idmap_tokens = {
 static int nfs_idmap_legacy_upcall(struct key_construction *, const char *, void *);
 static ssize_t idmap_pipe_downcall(struct file *, const char __user *,
 				   size_t);
+static void idmap_release_pipe(struct inode *);
 static void idmap_pipe_destroy_msg(struct rpc_pipe_msg *);
 
 static const struct rpc_pipe_ops idmap_upcall_ops = {
 	.upcall		= rpc_pipe_generic_upcall,
 	.downcall	= idmap_pipe_downcall,
+	.release_pipe	= idmap_release_pipe,
 	.destroy_msg	= idmap_pipe_destroy_msg,
 };
 
@@ -616,7 +619,8 @@ void nfs_idmap_quit(void)
 	nfs_idmap_quit_keyring();
 }
 
-static int nfs_idmap_prepare_message(char *desc, struct idmap_msg *im,
+static int nfs_idmap_prepare_message(char *desc, struct idmap *idmap,
+				     struct idmap_msg *im,
 				     struct rpc_pipe_msg *msg)
 {
 	substring_t substr;
@@ -626,6 +630,7 @@ static int nfs_idmap_prepare_message(char *desc, struct idmap_msg *im,
 	memset(msg, 0, sizeof(*msg));
 
 	im->im_type = IDMAP_TYPE_GROUP;
+	im->im_private = idmap;
 	token = match_token(desc, nfs_idmap_tokens, &substr);
 
 	switch (token) {
@@ -674,7 +679,7 @@ static int nfs_idmap_legacy_upcall(struct key_construction *cons,
 	if (!im)
 		goto out1;
 
-	ret = nfs_idmap_prepare_message(key->description, im, msg);
+	ret = nfs_idmap_prepare_message(key->description, idmap, im, msg);
 	if (ret < 0)
 		goto out2;
 
@@ -683,10 +688,12 @@ static int nfs_idmap_legacy_upcall(struct key_construction *cons,
 
 	ret = rpc_queue_upcall(idmap->idmap_pipe, msg);
 	if (ret < 0)
-		goto out2;
+		goto out3;
 
 	return ret;
 
+out3:
+	idmap->idmap_key_cons = NULL;
 out2:
 	kfree(im);
 out1:
@@ -775,11 +782,27 @@ out_incomplete:
 static void
 idmap_pipe_destroy_msg(struct rpc_pipe_msg *msg)
 {
+	struct idmap_msg *im = msg->data;
+	struct idmap *idmap = (struct idmap *)im->im_private;
+	struct key_construction *cons;
+	if (msg->errno) {
+		cons = ACCESS_ONCE(idmap->idmap_key_cons);
+		idmap->idmap_key_cons = NULL;
+		complete_request_key(cons, msg->errno);
+	}
 	/* Free memory allocated in nfs_idmap_legacy_upcall() */
 	kfree(msg->data);
 	kfree(msg);
 }
 
+static void
+idmap_release_pipe(struct inode *inode)
+{
+	struct rpc_inode *rpci = RPC_I(inode);
+	struct idmap *idmap = (struct idmap *)rpci->private;
+	idmap->idmap_key_cons = NULL;
+}
+
 int nfs_map_name_to_uid(const struct nfs_server *server, const char *name, size_t namelen, __u32 *uid)
 {
 	struct idmap *idmap = server->nfs_client->cl_idmap;
diff --git a/include/linux/nfs_idmap.h b/include/linux/nfs_idmap.h
index ece91c5..8a645c7 100644
--- a/include/linux/nfs_idmap.h
+++ b/include/linux/nfs_idmap.h
@@ -59,6 +59,7 @@ struct idmap_msg {
 	char  im_name[IDMAP_NAMESZ];
 	__u32 im_id;
 	__u8  im_status;
+	void *im_private;
 };
 
 #ifdef __KERNEL__
-- 
1.7.11.4

