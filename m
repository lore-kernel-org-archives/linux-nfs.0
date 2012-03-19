Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:48333 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758934Ab2CSSyo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Mar 2012 14:54:44 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 1/4] NFS: Remove nfs4_setup_sequence from generic write code
Date: Mon, 19 Mar 2012 14:54:39 -0400
Message-Id: <1332183282-9743-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This is an NFS v4 specific operation, so it belongs in the NFS v4 code
and not the generic client.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/direct.c         |    4 ----
 fs/nfs/nfs3proc.c       |    6 ++++++
 fs/nfs/nfs4proc.c       |   11 +++++++++++
 fs/nfs/proc.c           |    6 ++++++
 fs/nfs/write.c          |   15 +--------------
 include/linux/nfs_xdr.h |    1 +
 6 files changed, 25 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 1940f1a..c4bdaf1 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -554,9 +554,7 @@ static void nfs_direct_commit_release(void *calldata)
 }
 
 static const struct rpc_call_ops nfs_commit_direct_ops = {
-#if defined(CONFIG_NFS_V4_1)
 	.rpc_call_prepare = nfs_write_prepare,
-#endif /* CONFIG_NFS_V4_1 */
 	.rpc_call_done = nfs_direct_commit_result,
 	.rpc_release = nfs_direct_commit_release,
 };
@@ -696,9 +694,7 @@ out_unlock:
 }
 
 static const struct rpc_call_ops nfs_write_direct_ops = {
-#if defined(CONFIG_NFS_V4_1)
 	.rpc_call_prepare = nfs_write_prepare,
-#endif /* CONFIG_NFS_V4_1 */
 	.rpc_call_done = nfs_direct_write_result,
 	.rpc_release = nfs_direct_write_release,
 };
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 9194395..3bcf722 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -828,6 +828,11 @@ static void nfs3_proc_write_setup(struct nfs_write_data *data, struct rpc_messag
 	msg->rpc_proc = &nfs3_procedures[NFS3PROC_WRITE];
 }
 
+static void nfs3_proc_write_rpc_prepare(struct rpc_task *task, struct nfs_write_data *data)
+{
+	rpc_call_start(task);
+}
+
 static int nfs3_commit_done(struct rpc_task *task, struct nfs_write_data *data)
 {
 	if (nfs3_async_handle_jukebox(task, data->inode))
@@ -881,6 +886,7 @@ const struct nfs_rpc_ops nfs_v3_clientops = {
 	.read_setup	= nfs3_proc_read_setup,
 	.read_done	= nfs3_read_done,
 	.write_setup	= nfs3_proc_write_setup,
+	.write_rpc_prepare = nfs3_proc_write_rpc_prepare,
 	.write_done	= nfs3_write_done,
 	.commit_setup	= nfs3_proc_commit_setup,
 	.commit_done	= nfs3_commit_done,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5e0961a..aea7e78 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3373,6 +3373,16 @@ static void nfs4_proc_write_setup(struct nfs_write_data *data, struct rpc_messag
 	nfs41_init_sequence(&data->args.seq_args, &data->res.seq_res, 1);
 }
 
+static void nfs4_proc_write_rpc_prepare(struct rpc_task *task, struct nfs_write_data *data)
+{
+	if (nfs4_setup_sequence(NFS_SERVER(data->inode),
+				&data->args.seq_args,
+				&data->res.seq_res,
+				task))
+		return;
+	rpc_call_start(task);
+}
+
 static int nfs4_commit_done_cb(struct rpc_task *task, struct nfs_write_data *data)
 {
 	struct inode *inode = data->inode;
@@ -6447,6 +6457,7 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.read_setup	= nfs4_proc_read_setup,
 	.read_done	= nfs4_read_done,
 	.write_setup	= nfs4_proc_write_setup,
+	.write_rpc_prepare = nfs4_proc_write_rpc_prepare,
 	.write_done	= nfs4_write_done,
 	.commit_setup	= nfs4_proc_commit_setup,
 	.commit_done	= nfs4_commit_done,
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 0c672588..8069b41 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -668,6 +668,11 @@ static void nfs_proc_write_setup(struct nfs_write_data *data, struct rpc_message
 	msg->rpc_proc = &nfs_procedures[NFSPROC_WRITE];
 }
 
+static void nfs_proc_write_rpc_prepare(struct rpc_task *task, struct nfs_write_data *data)
+{
+	rpc_call_start(task);
+}
+
 static void
 nfs_proc_commit_setup(struct nfs_write_data *data, struct rpc_message *msg)
 {
@@ -738,6 +743,7 @@ const struct nfs_rpc_ops nfs_v2_clientops = {
 	.read_setup	= nfs_proc_read_setup,
 	.read_done	= nfs_read_done,
 	.write_setup	= nfs_proc_write_setup,
+	.write_rpc_prepare = nfs_proc_write_rpc_prepare,
 	.write_done	= nfs_write_done,
 	.commit_setup	= nfs_proc_commit_setup,
 	.lock		= nfs_proc_lock,
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 52e8e09..4119e55 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1175,23 +1175,14 @@ out:
 	nfs_writedata_release(calldata);
 }
 
-#if defined(CONFIG_NFS_V4_1)
 void nfs_write_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs_write_data *data = calldata;
-
-	if (nfs4_setup_sequence(NFS_SERVER(data->inode),
-				&data->args.seq_args,
-				&data->res.seq_res, task))
-		return;
-	rpc_call_start(task);
+	NFS_PROTO(data->inode)->write_rpc_prepare(task, data);
 }
-#endif /* CONFIG_NFS_V4_1 */
 
 static const struct rpc_call_ops nfs_write_partial_ops = {
-#if defined(CONFIG_NFS_V4_1)
 	.rpc_call_prepare = nfs_write_prepare,
-#endif /* CONFIG_NFS_V4_1 */
 	.rpc_call_done = nfs_writeback_done_partial,
 	.rpc_release = nfs_writeback_release_partial,
 };
@@ -1253,9 +1244,7 @@ remove_request:
 }
 
 static const struct rpc_call_ops nfs_write_full_ops = {
-#if defined(CONFIG_NFS_V4_1)
 	.rpc_call_prepare = nfs_write_prepare,
-#endif /* CONFIG_NFS_V4_1 */
 	.rpc_call_done = nfs_writeback_done_full,
 	.rpc_release = nfs_writeback_release_full,
 };
@@ -1547,9 +1536,7 @@ static void nfs_commit_release(void *calldata)
 }
 
 static const struct rpc_call_ops nfs_commit_ops = {
-#if defined(CONFIG_NFS_V4_1)
 	.rpc_call_prepare = nfs_write_prepare,
-#endif /* CONFIG_NFS_V4_1 */
 	.rpc_call_done = nfs_commit_done,
 	.rpc_release = nfs_commit_release,
 };
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index c1cf86c..b02a5f9 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1246,6 +1246,7 @@ struct nfs_rpc_ops {
 	void	(*read_setup)   (struct nfs_read_data *, struct rpc_message *);
 	int	(*read_done)  (struct rpc_task *, struct nfs_read_data *);
 	void	(*write_setup)  (struct nfs_write_data *, struct rpc_message *);
+	void	(*write_rpc_prepare)(struct rpc_task *, struct nfs_write_data *);
 	int	(*write_done)  (struct rpc_task *, struct nfs_write_data *);
 	void	(*commit_setup) (struct nfs_write_data *, struct rpc_message *);
 	int	(*commit_done) (struct rpc_task *, struct nfs_write_data *);
-- 
1.7.9.4

