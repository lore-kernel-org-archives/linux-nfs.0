Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:53076 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751180AbaDQVKJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Apr 2014 17:10:09 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 08/17] NFS: Create a common pgio_rpc_prepare function
Date: Thu, 17 Apr 2014 17:09:32 -0400
Message-ID: <1397768981-12856-9-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1397768981-12856-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1397768981-12856-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@netapp.com>

The read and write paths do exactly the same thing for the rpc_prepare
rpc_op.  This patch combines them together into a single function.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/internal.h        |  2 ++
 fs/nfs/nfs3proc.c        | 11 ++---------
 fs/nfs/nfs4proc.c        | 22 +++-------------------
 fs/nfs/pageio.c          | 17 +++++++++++++++++
 fs/nfs/proc.c            | 11 ++---------
 fs/nfs/read.c            | 19 +++----------------
 fs/nfs/write.c           | 19 +++++--------------
 include/linux/nfs_page.h |  2 ++
 include/linux/nfs_xdr.h  |  3 +--
 9 files changed, 37 insertions(+), 69 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 7e8d311..105e2b5 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -400,6 +400,8 @@ extern struct nfs_rw_header *nfs_rw_header_alloc(const struct nfs_rw_ops *);
 extern void nfs_rw_header_free(struct nfs_pgio_header *);
 extern struct nfs_pgio_data *nfs_pgio_data_alloc(struct nfs_pgio_header *, unsigned int);
 extern void nfs_pgio_data_release(struct nfs_pgio_data *);
+extern void nfs_pgio_prepare(struct rpc_task *, void *);
+extern void nfs_pgio_release_common(void *);
 
 /* read.c */
 extern void nfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index d235369..e7daa42 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -812,7 +812,7 @@ static void nfs3_proc_read_setup(struct nfs_pgio_data *data, struct rpc_message
 	msg->rpc_proc = &nfs3_procedures[NFS3PROC_READ];
 }
 
-static int nfs3_proc_read_rpc_prepare(struct rpc_task *task, struct nfs_pgio_data *data)
+static int nfs3_proc_pgio_rpc_prepare(struct rpc_task *task, struct nfs_pgio_data *data)
 {
 	rpc_call_start(task);
 	return 0;
@@ -834,12 +834,6 @@ static void nfs3_proc_write_setup(struct nfs_pgio_data *data, struct rpc_message
 	msg->rpc_proc = &nfs3_procedures[NFS3PROC_WRITE];
 }
 
-static int nfs3_proc_write_rpc_prepare(struct rpc_task *task, struct nfs_pgio_data *data)
-{
-	rpc_call_start(task);
-	return 0;
-}
-
 static void nfs3_proc_commit_rpc_prepare(struct rpc_task *task, struct nfs_commit_data *data)
 {
 	rpc_call_start(task);
@@ -946,11 +940,10 @@ const struct nfs_rpc_ops nfs_v3_clientops = {
 	.fsinfo		= nfs3_proc_fsinfo,
 	.pathconf	= nfs3_proc_pathconf,
 	.decode_dirent	= nfs3_decode_dirent,
+	.pgio_rpc_prepare = nfs3_proc_pgio_rpc_prepare,
 	.read_setup	= nfs3_proc_read_setup,
-	.read_rpc_prepare = nfs3_proc_read_rpc_prepare,
 	.read_done	= nfs3_read_done,
 	.write_setup	= nfs3_proc_write_setup,
-	.write_rpc_prepare = nfs3_proc_write_rpc_prepare,
 	.write_done	= nfs3_write_done,
 	.commit_setup	= nfs3_proc_commit_setup,
 	.commit_rpc_prepare = nfs3_proc_commit_rpc_prepare,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e793aa9..44fb93a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4089,7 +4089,7 @@ static void nfs4_proc_read_setup(struct nfs_pgio_data *data, struct rpc_message
 	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 0);
 }
 
-static int nfs4_proc_read_rpc_prepare(struct rpc_task *task, struct nfs_pgio_data *data)
+static int nfs4_proc_pgio_rpc_prepare(struct rpc_task *task, struct nfs_pgio_data *data)
 {
 	if (nfs4_setup_sequence(NFS_SERVER(data->header->inode),
 			&data->args.seq_args,
@@ -4097,7 +4097,7 @@ static int nfs4_proc_read_rpc_prepare(struct rpc_task *task, struct nfs_pgio_dat
 			task))
 		return 0;
 	if (nfs4_set_rw_stateid(&data->args.stateid, data->args.context,
-				data->args.lock_context, FMODE_READ) == -EIO)
+				data->args.lock_context, data->header->rw_ops->rw_mode) == -EIO)
 		return -EIO;
 	if (unlikely(test_bit(NFS_CONTEXT_BAD, &data->args.context->flags)))
 		return -EIO;
@@ -4177,21 +4177,6 @@ static void nfs4_proc_write_setup(struct nfs_pgio_data *data, struct rpc_message
 	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 1);
 }
 
-static int nfs4_proc_write_rpc_prepare(struct rpc_task *task, struct nfs_pgio_data *data)
-{
-	if (nfs4_setup_sequence(NFS_SERVER(data->header->inode),
-			&data->args.seq_args,
-			&data->res.seq_res,
-			task))
-		return 0;
-	if (nfs4_set_rw_stateid(&data->args.stateid, data->args.context,
-				data->args.lock_context, FMODE_WRITE) == -EIO)
-		return -EIO;
-	if (unlikely(test_bit(NFS_CONTEXT_BAD, &data->args.context->flags)))
-		return -EIO;
-	return 0;
-}
-
 static void nfs4_proc_commit_rpc_prepare(struct rpc_task *task, struct nfs_commit_data *data)
 {
 	nfs4_setup_sequence(NFS_SERVER(data->inode),
@@ -8432,11 +8417,10 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.pathconf	= nfs4_proc_pathconf,
 	.set_capabilities = nfs4_server_capabilities,
 	.decode_dirent	= nfs4_decode_dirent,
+	.pgio_rpc_prepare = nfs4_proc_pgio_rpc_prepare,
 	.read_setup	= nfs4_proc_read_setup,
-	.read_rpc_prepare = nfs4_proc_read_rpc_prepare,
 	.read_done	= nfs4_read_done,
 	.write_setup	= nfs4_proc_write_setup,
-	.write_rpc_prepare = nfs4_proc_write_rpc_prepare,
 	.write_done	= nfs4_write_done,
 	.commit_setup	= nfs4_proc_commit_setup,
 	.commit_rpc_prepare = nfs4_proc_commit_rpc_prepare,
diff --git a/fs/nfs/pageio.c b/fs/nfs/pageio.c
index 05e3500..864d2f7 100644
--- a/fs/nfs/pageio.c
+++ b/fs/nfs/pageio.c
@@ -85,3 +85,20 @@ void nfs_pgio_data_release(struct nfs_pgio_data *data)
 	kfree(data);
 }
 EXPORT_SYMBOL_GPL(nfs_pgio_data_release);
+
+void nfs_pgio_prepare(struct rpc_task *task, void *calldata)
+{
+	struct nfs_pgio_data *data = calldata;
+	int err;
+	err = NFS_PROTO(data->header->inode)->pgio_rpc_prepare(task, data);
+	if (err)
+		rpc_exit(task, err);
+}
+
+void nfs_pgio_release_common(void *calldata)
+{
+	struct nfs_pgio_data *data = calldata;
+	if (data->header->rw_ops->rw_release)
+		data->header->rw_ops->rw_release(data);
+	nfs_pgio_data_release(data);
+}
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index c54829e..c171ce1 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -599,7 +599,7 @@ static void nfs_proc_read_setup(struct nfs_pgio_data *data, struct rpc_message *
 	msg->rpc_proc = &nfs_procedures[NFSPROC_READ];
 }
 
-static int nfs_proc_read_rpc_prepare(struct rpc_task *task, struct nfs_pgio_data *data)
+static int nfs_proc_pgio_rpc_prepare(struct rpc_task *task, struct nfs_pgio_data *data)
 {
 	rpc_call_start(task);
 	return 0;
@@ -621,12 +621,6 @@ static void nfs_proc_write_setup(struct nfs_pgio_data *data, struct rpc_message
 	msg->rpc_proc = &nfs_procedures[NFSPROC_WRITE];
 }
 
-static int nfs_proc_write_rpc_prepare(struct rpc_task *task, struct nfs_pgio_data *data)
-{
-	rpc_call_start(task);
-	return 0;
-}
-
 static void nfs_proc_commit_rpc_prepare(struct rpc_task *task, struct nfs_commit_data *data)
 {
 	BUG();
@@ -734,11 +728,10 @@ const struct nfs_rpc_ops nfs_v2_clientops = {
 	.fsinfo		= nfs_proc_fsinfo,
 	.pathconf	= nfs_proc_pathconf,
 	.decode_dirent	= nfs2_decode_dirent,
+	.pgio_rpc_prepare = nfs_proc_pgio_rpc_prepare,
 	.read_setup	= nfs_proc_read_setup,
-	.read_rpc_prepare = nfs_proc_read_rpc_prepare,
 	.read_done	= nfs_read_done,
 	.write_setup	= nfs_proc_write_setup,
-	.write_rpc_prepare = nfs_proc_write_rpc_prepare,
 	.write_done	= nfs_write_done,
 	.commit_setup	= nfs_proc_commit_setup,
 	.commit_rpc_prepare = nfs_proc_commit_rpc_prepare,
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 4cf3577..313835b 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -454,24 +454,10 @@ static void nfs_readpage_result_common(struct rpc_task *task, void *calldata)
 		nfs_readpage_retry(task, data);
 }
 
-static void nfs_readpage_release_common(void *calldata)
-{
-	nfs_pgio_data_release(calldata);
-}
-
-void nfs_read_prepare(struct rpc_task *task, void *calldata)
-{
-	struct nfs_pgio_data *data = calldata;
-	int err;
-	err = NFS_PROTO(data->header->inode)->read_rpc_prepare(task, data);
-	if (err)
-		rpc_exit(task, err);
-}
-
 static const struct rpc_call_ops nfs_read_common_ops = {
-	.rpc_call_prepare = nfs_read_prepare,
+	.rpc_call_prepare = nfs_pgio_prepare,
 	.rpc_call_done = nfs_readpage_result_common,
-	.rpc_release = nfs_readpage_release_common,
+	.rpc_release = nfs_pgio_release_common,
 };
 
 /*
@@ -636,6 +622,7 @@ void nfs_destroy_readpagecache(void)
 }
 
 static const struct nfs_rw_ops nfs_rw_read_ops = {
+	.rw_mode		= FMODE_READ,
 	.rw_alloc_header	= nfs_readhdr_alloc,
 	.rw_free_header		= nfs_readhdr_free,
 };
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 9c5cde3..b08fb7d 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1248,15 +1248,6 @@ void nfs_pageio_reset_write_mds(struct nfs_pageio_descriptor *pgio)
 EXPORT_SYMBOL_GPL(nfs_pageio_reset_write_mds);
 
 
-void nfs_write_prepare(struct rpc_task *task, void *calldata)
-{
-	struct nfs_pgio_data *data = calldata;
-	int err;
-	err = NFS_PROTO(data->header->inode)->write_rpc_prepare(task, data);
-	if (err)
-		rpc_exit(task, err);
-}
-
 void nfs_commit_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs_commit_data *data = calldata;
@@ -1278,9 +1269,8 @@ static void nfs_writeback_done_common(struct rpc_task *task, void *calldata)
 	nfs_writeback_done(task, data);
 }
 
-static void nfs_writeback_release_common(void *calldata)
+static void nfs_writeback_release_common(struct nfs_pgio_data *data)
 {
-	struct nfs_pgio_data	*data = calldata;
 	struct nfs_pgio_header *hdr = data->header;
 	int status = data->task.tk_status;
 
@@ -1294,13 +1284,12 @@ static void nfs_writeback_release_common(void *calldata)
 			set_bit(NFS_IOHDR_NEED_RESCHED, &hdr->flags);
 		spin_unlock(&hdr->lock);
 	}
-	nfs_pgio_data_release(data);
 }
 
 static const struct rpc_call_ops nfs_write_common_ops = {
-	.rpc_call_prepare = nfs_write_prepare,
+	.rpc_call_prepare = nfs_pgio_prepare,
 	.rpc_call_done = nfs_writeback_done_common,
-	.rpc_release = nfs_writeback_release_common,
+	.rpc_release = nfs_pgio_release_common,
 };
 
 /*
@@ -1918,6 +1907,8 @@ void nfs_destroy_writepagecache(void)
 }
 
 static const struct nfs_rw_ops nfs_rw_write_ops = {
+	.rw_mode		= FMODE_WRITE,
 	.rw_alloc_header	= nfs_writehdr_alloc,
 	.rw_free_header		= nfs_writehdr_free,
+	.rw_release		= nfs_writeback_release_common,
 };
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 5948125..da00a4d 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -53,8 +53,10 @@ struct nfs_pageio_ops {
 };
 
 struct nfs_rw_ops {
+	const fmode_t rw_mode;
 	struct nfs_rw_header *(*rw_alloc_header)(void);
 	void (*rw_free_header)(struct nfs_rw_header *);
+	void (*rw_release)(struct nfs_pgio_data *);
 };
 
 struct nfs_pageio_descriptor {
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index f846507..dacd240 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1428,11 +1428,10 @@ struct nfs_rpc_ops {
 			     struct nfs_pathconf *);
 	int	(*set_capabilities)(struct nfs_server *, struct nfs_fh *);
 	int	(*decode_dirent)(struct xdr_stream *, struct nfs_entry *, int);
+	int	(*pgio_rpc_prepare)(struct rpc_task *, struct nfs_pgio_data *);
 	void	(*read_setup)   (struct nfs_pgio_data *, struct rpc_message *);
-	int	(*read_rpc_prepare)(struct rpc_task *, struct nfs_pgio_data *);
 	int	(*read_done)  (struct rpc_task *, struct nfs_pgio_data *);
 	void	(*write_setup)  (struct nfs_pgio_data *, struct rpc_message *);
-	int	(*write_rpc_prepare)(struct rpc_task *, struct nfs_pgio_data *);
 	int	(*write_done)  (struct rpc_task *, struct nfs_pgio_data *);
 	void	(*commit_setup) (struct nfs_commit_data *, struct rpc_message *);
 	void	(*commit_rpc_prepare)(struct rpc_task *, struct nfs_commit_data *);
-- 
1.9.2

