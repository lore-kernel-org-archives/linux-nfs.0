Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:48333 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759247Ab2CSSyp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Mar 2012 14:54:45 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 2/4] NFS: Remove nfs4_setup_sequence from generic read code
Date: Mon, 19 Mar 2012 14:54:40 -0400
Message-Id: <1332183282-9743-2-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1332183282-9743-1-git-send-email-bjschuma@netapp.com>
References: <1332183282-9743-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This is an NFS v4 specific operation, so it belongs in the NFS v4 code
and not the generic client.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/direct.c         |    2 --
 fs/nfs/nfs3proc.c       |    6 ++++++
 fs/nfs/nfs4proc.c       |   11 +++++++++++
 fs/nfs/proc.c           |    6 ++++++
 fs/nfs/read.c           |   13 +------------
 include/linux/nfs_xdr.h |    1 +
 6 files changed, 25 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index c4bdaf1..9c7f66a 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -265,9 +265,7 @@ static void nfs_direct_read_release(void *calldata)
 }
 
 static const struct rpc_call_ops nfs_read_direct_ops = {
-#if defined(CONFIG_NFS_V4_1)
 	.rpc_call_prepare = nfs_read_prepare,
-#endif /* CONFIG_NFS_V4_1 */
 	.rpc_call_done = nfs_direct_read_result,
 	.rpc_release = nfs_direct_read_release,
 };
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 3bcf722..9d9b239 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -814,6 +814,11 @@ static void nfs3_proc_read_setup(struct nfs_read_data *data, struct rpc_message
 	msg->rpc_proc = &nfs3_procedures[NFS3PROC_READ];
 }
 
+static void nfs3_proc_read_rpc_prepare(struct rpc_task *task, struct nfs_read_data *data)
+{
+	rpc_call_start(task);
+}
+
 static int nfs3_write_done(struct rpc_task *task, struct nfs_write_data *data)
 {
 	if (nfs3_async_handle_jukebox(task, data->inode))
@@ -884,6 +889,7 @@ const struct nfs_rpc_ops nfs_v3_clientops = {
 	.pathconf	= nfs3_proc_pathconf,
 	.decode_dirent	= nfs3_decode_dirent,
 	.read_setup	= nfs3_proc_read_setup,
+	.read_rpc_prepare = nfs3_proc_read_rpc_prepare,
 	.read_done	= nfs3_read_done,
 	.write_setup	= nfs3_proc_write_setup,
 	.write_rpc_prepare = nfs3_proc_write_rpc_prepare,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index aea7e78..0845733 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3299,6 +3299,16 @@ static void nfs4_proc_read_setup(struct nfs_read_data *data, struct rpc_message
 	nfs41_init_sequence(&data->args.seq_args, &data->res.seq_res, 0);
 }
 
+static void nfs4_proc_read_rpc_prepare(struct rpc_task *task, struct nfs_read_data *data)
+{
+	if (nfs4_setup_sequence(NFS_SERVER(data->inode),
+				&data->args.seq_args,
+				&data->res.seq_res,
+				task))
+		return;
+	rpc_call_start(task);
+}
+
 /* Reset the the nfs_read_data to send the read to the MDS. */
 void nfs4_reset_read(struct rpc_task *task, struct nfs_read_data *data)
 {
@@ -6455,6 +6465,7 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.set_capabilities = nfs4_server_capabilities,
 	.decode_dirent	= nfs4_decode_dirent,
 	.read_setup	= nfs4_proc_read_setup,
+	.read_rpc_prepare = nfs4_proc_read_rpc_prepare,
 	.read_done	= nfs4_read_done,
 	.write_setup	= nfs4_proc_write_setup,
 	.write_rpc_prepare = nfs4_proc_write_rpc_prepare,
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 8069b41..a8df707 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -651,6 +651,11 @@ static void nfs_proc_read_setup(struct nfs_read_data *data, struct rpc_message *
 	msg->rpc_proc = &nfs_procedures[NFSPROC_READ];
 }
 
+static void nfs_proc_read_rpc_prepare(struct rpc_task *task, struct nfs_read_data *data)
+{
+	rpc_call_start(task);
+}
+
 static int nfs_write_done(struct rpc_task *task, struct nfs_write_data *data)
 {
 	if (nfs_async_handle_expired_key(task))
@@ -741,6 +746,7 @@ const struct nfs_rpc_ops nfs_v2_clientops = {
 	.pathconf	= nfs_proc_pathconf,
 	.decode_dirent	= nfs2_decode_dirent,
 	.read_setup	= nfs_proc_read_setup,
+	.read_rpc_prepare = nfs_proc_read_rpc_prepare,
 	.read_done	= nfs_read_done,
 	.write_setup	= nfs_proc_write_setup,
 	.write_rpc_prepare = nfs_proc_write_rpc_prepare,
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 2662c02..cc1f758 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -464,23 +464,14 @@ static void nfs_readpage_release_partial(void *calldata)
 	nfs_readdata_release(calldata);
 }
 
-#if defined(CONFIG_NFS_V4_1)
 void nfs_read_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs_read_data *data = calldata;
-
-	if (nfs4_setup_sequence(NFS_SERVER(data->inode),
-				&data->args.seq_args, &data->res.seq_res,
-				task))
-		return;
-	rpc_call_start(task);
+	NFS_PROTO(data->inode)->read_rpc_prepare(task, data);
 }
-#endif /* CONFIG_NFS_V4_1 */
 
 static const struct rpc_call_ops nfs_read_partial_ops = {
-#if defined(CONFIG_NFS_V4_1)
 	.rpc_call_prepare = nfs_read_prepare,
-#endif /* CONFIG_NFS_V4_1 */
 	.rpc_call_done = nfs_readpage_result_partial,
 	.rpc_release = nfs_readpage_release_partial,
 };
@@ -544,9 +535,7 @@ static void nfs_readpage_release_full(void *calldata)
 }
 
 static const struct rpc_call_ops nfs_read_full_ops = {
-#if defined(CONFIG_NFS_V4_1)
 	.rpc_call_prepare = nfs_read_prepare,
-#endif /* CONFIG_NFS_V4_1 */
 	.rpc_call_done = nfs_readpage_result_full,
 	.rpc_release = nfs_readpage_release_full,
 };
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index b02a5f9..286d74d 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1244,6 +1244,7 @@ struct nfs_rpc_ops {
 	int	(*set_capabilities)(struct nfs_server *, struct nfs_fh *);
 	int	(*decode_dirent)(struct xdr_stream *, struct nfs_entry *, int);
 	void	(*read_setup)   (struct nfs_read_data *, struct rpc_message *);
+	void	(*read_rpc_prepare)(struct rpc_task *, struct nfs_read_data *);
 	int	(*read_done)  (struct rpc_task *, struct nfs_read_data *);
 	void	(*write_setup)  (struct nfs_write_data *, struct rpc_message *);
 	void	(*write_rpc_prepare)(struct rpc_task *, struct nfs_write_data *);
-- 
1.7.9.4

