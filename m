Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:38821 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753897AbbLZXVt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 26 Dec 2015 18:21:49 -0500
Received: by mail-ig0-f177.google.com with SMTP id mw1so5208569igb.1
        for <linux-nfs@vger.kernel.org>; Sat, 26 Dec 2015 15:21:49 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 14/14] pNFS/flexfiles: Ensure we record layoutstats even if RPC is terminated early
Date: Sat, 26 Dec 2015 18:21:00 -0500
Message-Id: <1451172060-28238-14-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1451172060-28238-13-git-send-email-trond.myklebust@primarydata.com>
References: <1451172060-28238-1-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-2-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-3-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-4-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-5-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-6-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-7-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-8-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-9-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-10-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-11-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-12-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-13-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, we will only record the layoutstats correctly if the
RPC call successfully obtains a slot. If we exit before that
happens, then we may find ourselves starting the busy timer through
the call in ff_layout_(read|write)_prepare_layoutstats, but never stopping it.

The same thing happens if we're doing DA-DS.

The fix is to ensure that we catch these cases in the rpc_release()
callback.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 37 ++++++++++++++++++++++++++++------
 1 file changed, 31 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 9257679a15ba..2981cd190bfd 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1397,6 +1397,15 @@ static void ff_layout_read_count_stats(struct rpc_task *task, void *data)
 	    &NFS_CLIENT(hdr->inode)->cl_metrics[NFSPROC4_CLNT_READ]);
 }
 
+static void ff_layout_read_release(void *data)
+{
+	struct nfs_pgio_header *hdr = data;
+
+	ff_layout_read_record_layoutstats_done(&hdr->task, hdr);
+	pnfs_generic_rw_release(data);
+}
+
+
 static int ff_layout_write_done_cb(struct rpc_task *task,
 				struct nfs_pgio_header *hdr)
 {
@@ -1564,6 +1573,14 @@ static void ff_layout_write_count_stats(struct rpc_task *task, void *data)
 	    &NFS_CLIENT(hdr->inode)->cl_metrics[NFSPROC4_CLNT_WRITE]);
 }
 
+static void ff_layout_write_release(void *data)
+{
+	struct nfs_pgio_header *hdr = data;
+
+	ff_layout_write_record_layoutstats_done(&hdr->task, hdr);
+	pnfs_generic_rw_release(data);
+}
+
 static void ff_layout_commit_record_layoutstats_start(struct rpc_task *task,
 		struct nfs_commit_data *cdata)
 {
@@ -1630,46 +1647,54 @@ static void ff_layout_commit_count_stats(struct rpc_task *task, void *data)
 	    &NFS_CLIENT(cdata->inode)->cl_metrics[NFSPROC4_CLNT_COMMIT]);
 }
 
+static void ff_layout_commit_release(void *data)
+{
+	struct nfs_commit_data *cdata = data;
+
+	ff_layout_commit_record_layoutstats_done(&cdata->task, cdata);
+	pnfs_generic_commit_release(data);
+}
+
 static const struct rpc_call_ops ff_layout_read_call_ops_v3 = {
 	.rpc_call_prepare = ff_layout_read_prepare_v3,
 	.rpc_call_done = ff_layout_read_call_done,
 	.rpc_count_stats = ff_layout_read_count_stats,
-	.rpc_release = pnfs_generic_rw_release,
+	.rpc_release = ff_layout_read_release,
 };
 
 static const struct rpc_call_ops ff_layout_read_call_ops_v4 = {
 	.rpc_call_prepare = ff_layout_read_prepare_v4,
 	.rpc_call_done = ff_layout_read_call_done,
 	.rpc_count_stats = ff_layout_read_count_stats,
-	.rpc_release = pnfs_generic_rw_release,
+	.rpc_release = ff_layout_read_release,
 };
 
 static const struct rpc_call_ops ff_layout_write_call_ops_v3 = {
 	.rpc_call_prepare = ff_layout_write_prepare_v3,
 	.rpc_call_done = ff_layout_write_call_done,
 	.rpc_count_stats = ff_layout_write_count_stats,
-	.rpc_release = pnfs_generic_rw_release,
+	.rpc_release = ff_layout_write_release,
 };
 
 static const struct rpc_call_ops ff_layout_write_call_ops_v4 = {
 	.rpc_call_prepare = ff_layout_write_prepare_v4,
 	.rpc_call_done = ff_layout_write_call_done,
 	.rpc_count_stats = ff_layout_write_count_stats,
-	.rpc_release = pnfs_generic_rw_release,
+	.rpc_release = ff_layout_write_release,
 };
 
 static const struct rpc_call_ops ff_layout_commit_call_ops_v3 = {
 	.rpc_call_prepare = ff_layout_commit_prepare_v3,
 	.rpc_call_done = ff_layout_commit_done,
 	.rpc_count_stats = ff_layout_commit_count_stats,
-	.rpc_release = pnfs_generic_commit_release,
+	.rpc_release = ff_layout_commit_release,
 };
 
 static const struct rpc_call_ops ff_layout_commit_call_ops_v4 = {
 	.rpc_call_prepare = ff_layout_commit_prepare_v4,
 	.rpc_call_done = ff_layout_commit_done,
 	.rpc_count_stats = ff_layout_commit_count_stats,
-	.rpc_release = pnfs_generic_commit_release,
+	.rpc_release = ff_layout_commit_release,
 };
 
 static enum pnfs_try_status
-- 
2.5.0

