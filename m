Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:42250 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753065Ab2D1UZu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 28 Apr 2012 16:25:50 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 11/11] NFSv4: Don't request cache consistency attributes on some writes and commits
Date: Sat, 28 Apr 2012 16:25:20 -0400
Message-Id: <1335644720-28305-12-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1335644720-28305-11-git-send-email-Trond.Myklebust@netapp.com>
References: <1335644720-28305-1-git-send-email-Trond.Myklebust@netapp.com>
 <1335644720-28305-2-git-send-email-Trond.Myklebust@netapp.com>
 <1335644720-28305-3-git-send-email-Trond.Myklebust@netapp.com>
 <1335644720-28305-4-git-send-email-Trond.Myklebust@netapp.com>
 <1335644720-28305-5-git-send-email-Trond.Myklebust@netapp.com>
 <1335644720-28305-6-git-send-email-Trond.Myklebust@netapp.com>
 <1335644720-28305-7-git-send-email-Trond.Myklebust@netapp.com>
 <1335644720-28305-8-git-send-email-Trond.Myklebust@netapp.com>
 <1335644720-28305-9-git-send-email-Trond.Myklebust@netapp.com>
 <1335644720-28305-10-git-send-email-Trond.Myklebust@netapp.com>
 <1335644720-28305-11-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We don't need cache consistency information when we're doing O_DIRECT
writes or commits. Ditto for the case of delegated writes and commits.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c |   30 ++++++++++++++++++++++++++++--
 1 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c746b0c..eb6a85a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3401,11 +3401,25 @@ void nfs4_reset_write(struct rpc_task *task, struct nfs_write_data *data)
 }
 EXPORT_SYMBOL_GPL(nfs4_reset_write);
 
+static
+bool nfs4_write_need_cache_consistency_data(const struct nfs_write_data *data)
+{
+	const struct nfs_pgio_header *hdr = data->header;
+
+	/* Don't request attributes for pNFS or O_DIRECT writes */
+	if (data->ds_clp != NULL || hdr->dreq != NULL)
+		return false;
+	/* Otherwise, request attributes if and only if we don't hold
+	 * a delegation
+	 */
+	return nfs_have_delegation(hdr->inode, FMODE_READ) == 0;
+}
+
 static void nfs4_proc_write_setup(struct nfs_write_data *data, struct rpc_message *msg)
 {
 	struct nfs_server *server = NFS_SERVER(data->header->inode);
 
-	if (data->ds_clp) {
+	if (!nfs4_write_need_cache_consistency_data(data)) {
 		data->args.bitmask = NULL;
 		data->res.fattr = NULL;
 	} else
@@ -3458,11 +3472,23 @@ static int nfs4_commit_done(struct rpc_task *task, struct nfs_commit_data *data)
 	return data->commit_done_cb(task, data);
 }
 
+static
+bool nfs4_commit_need_cache_consistency_data(const struct nfs_commit_data *data)
+{
+	/* Don't request attributes for pNFS or O_DIRECT writes */
+	if (data->ds_clp != NULL || data->dreq != NULL)
+		return false;
+	/* Otherwise, request attributes if and only if we don't hold
+	 * a delegation
+	 */
+	return nfs_have_delegation(data->inode, FMODE_READ) == 0;
+}
+
 static void nfs4_proc_commit_setup(struct nfs_commit_data *data, struct rpc_message *msg)
 {
 	struct nfs_server *server = NFS_SERVER(data->inode);
 
-	if (data->lseg) {
+	if (!nfs4_commit_need_cache_consistency_data(data)) {
 		data->args.bitmask = NULL;
 		data->res.fattr = NULL;
 	} else
-- 
1.7.7.6

