Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13672 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753280Ab1BDVey (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Feb 2011 16:34:54 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 35/40] pnfs_submit wave3 filelayout_read_prepare
Date: Fri,  4 Feb 2011 16:33:57 -0500
Message-Id: <1296855242-2592-36-git-send-email-andros@netapp.com>
In-Reply-To: <1296855242-2592-35-git-send-email-andros@netapp.com>
References: <1296855242-2592-1-git-send-email-andros@netapp.com>
 <1296855242-2592-2-git-send-email-andros@netapp.com>
 <1296855242-2592-3-git-send-email-andros@netapp.com>
 <1296855242-2592-4-git-send-email-andros@netapp.com>
 <1296855242-2592-5-git-send-email-andros@netapp.com>
 <1296855242-2592-6-git-send-email-andros@netapp.com>
 <1296855242-2592-7-git-send-email-andros@netapp.com>
 <1296855242-2592-8-git-send-email-andros@netapp.com>
 <1296855242-2592-9-git-send-email-andros@netapp.com>
 <1296855242-2592-10-git-send-email-andros@netapp.com>
 <1296855242-2592-11-git-send-email-andros@netapp.com>
 <1296855242-2592-12-git-send-email-andros@netapp.com>
 <1296855242-2592-13-git-send-email-andros@netapp.com>
 <1296855242-2592-14-git-send-email-andros@netapp.com>
 <1296855242-2592-15-git-send-email-andros@netapp.com>
 <1296855242-2592-16-git-send-email-andros@netapp.com>
 <1296855242-2592-17-git-send-email-andros@netapp.com>
 <1296855242-2592-18-git-send-email-andros@netapp.com>
 <1296855242-2592-19-git-send-email-andros@netapp.com>
 <1296855242-2592-20-git-send-email-andros@netapp.com>
 <1296855242-2592-21-git-send-email-andros@netapp.com>
 <1296855242-2592-22-git-send-email-andros@netapp.com>
 <1296855242-2592-23-git-send-email-andros@netapp.com>
 <1296855242-2592-24-git-send-email-andros@netapp.com>
 <1296855242-2592-25-git-send-email-andros@netapp.com>
 <1296855242-2592-26-git-send-email-andros@netapp.com>
 <1296855242-2592-27-git-send-email-andros@netapp.com>
 <1296855242-2592-28-git-send-email-andros@netapp.com>
 <1296855242-2592-29-git-send-email-andros@netapp.com>
 <1296855242-2592-30-git-send-email-andros@netapp.com>
 <1296855242-2592-31-git-send-email-andros@netapp.com>
 <1296855242-2592-32-git-send-email-andros@netapp.com>
 <1296855242-2592-33-git-send-email-andros@netapp.com>
 <1296855242-2592-34-git-send-email-andros@netapp.com>
 <1296855242-2592-35-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4_fs.h        |    3 +++
 fs/nfs/nfs4filelayout.c |   14 +++++++++++++-
 fs/nfs/nfs4proc.c       |    3 ++-
 3 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 5dc378e..457b1fe 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -252,6 +252,9 @@ static inline struct nfs4_session *nfs4_get_session(const struct nfs_server *ser
 extern int nfs4_setup_sequence(const struct nfs_server *server,
 		struct nfs4_sequence_args *args, struct nfs4_sequence_res *res,
 		int cache_reply, struct rpc_task *task);
+extern int nfs41_setup_sequence(struct nfs4_session *session,
+		struct nfs4_sequence_args *args, struct nfs4_sequence_res *res,
+		int cache_reply, struct rpc_task *task);
 extern void nfs4_destroy_session(struct nfs4_session *session);
 extern struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp);
 extern int nfs4_proc_create_session(struct nfs_client *);
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 4c841c0..5fd8ed3 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -100,6 +100,18 @@ filelayout_get_dserver_offset(struct pnfs_layout_segment *lseg, loff_t offset)
  * In the case of dense layouts, the offset needs to be reset to its
  * original value.
  */
+static void filelayout_read_prepare(struct rpc_task *task, void *data)
+{
+	struct nfs_read_data *rdata = (struct nfs_read_data *)data;
+
+	if (nfs41_setup_sequence(rdata->ds_clp->cl_session,
+				&rdata->args.seq_args, &rdata->res.seq_res,
+				0, task))
+		return;
+
+	rpc_call_start(task);
+}
+
 static void filelayout_read_call_done(struct rpc_task *task, void *data)
 {
 	struct nfs_read_data *rdata = (struct nfs_read_data *)data;
@@ -123,7 +135,7 @@ static void filelayout_read_release(void *data)
 }
 
 struct rpc_call_ops filelayout_read_call_ops = {
-	.rpc_call_prepare = nfs_read_prepare,
+	.rpc_call_prepare = filelayout_read_prepare,
 	.rpc_call_done = filelayout_read_call_done,
 	.rpc_release = filelayout_read_release,
 };
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 213e3f0..3fcf756 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -505,7 +505,7 @@ out:
 	return ret_id;
 }
 
-static int nfs41_setup_sequence(struct nfs4_session *session,
+int nfs41_setup_sequence(struct nfs4_session *session,
 				struct nfs4_sequence_args *args,
 				struct nfs4_sequence_res *res,
 				int cache_reply,
@@ -571,6 +571,7 @@ static int nfs41_setup_sequence(struct nfs4_session *session,
 	res->sr_status = 1;
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs41_setup_sequence);
 
 int nfs4_setup_sequence(const struct nfs_server *server,
 			struct nfs4_sequence_args *args,
-- 
1.6.6

