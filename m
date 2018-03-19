Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41696 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755745AbeCSOgr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Mar 2018 10:36:47 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 08/10] nfsd: move sc_file assignment into alloc_init_deleg
Date: Mon, 19 Mar 2018 10:36:32 -0400
Message-Id: <1521470194-24840-9-git-send-email-bfields@redhat.com>
In-Reply-To: <1521470194-24840-1-git-send-email-bfields@redhat.com>
References: <1521470194-24840-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Take an easy chance to simplify the caller a little.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 268d095477e8..26880d0122c5 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -777,7 +777,8 @@ static void block_delegations(struct knfsd_fh *fh)
 }
 
 static struct nfs4_delegation *
-alloc_init_deleg(struct nfs4_client *clp, struct svc_fh *current_fh,
+alloc_init_deleg(struct nfs4_client *clp, struct nfs4_file *fp,
+		 struct svc_fh *current_fh,
 		 struct nfs4_clnt_odstate *odstate)
 {
 	struct nfs4_delegation *dp;
@@ -808,6 +809,8 @@ alloc_init_deleg(struct nfs4_client *clp, struct svc_fh *current_fh,
 	dp->dl_retries = 1;
 	nfsd4_init_cb(&dp->dl_recall, dp->dl_stid.sc_client,
 		      &nfsd4_cb_recall_ops, NFSPROC4_CLNT_CB_RECALL);
+	get_nfs4_file(fp);
+	dp->dl_stid.sc_file = fp;
 	return dp;
 out_dec:
 	atomic_long_dec(&num_delegations);
@@ -4352,13 +4355,10 @@ nfs4_set_delegation(struct nfs4_client *clp, struct svc_fh *fh,
 	if (status)
 		return ERR_PTR(status);
 
-	dp = alloc_init_deleg(clp, fh, odstate);
+	dp = alloc_init_deleg(clp, fp, fh, odstate);
 	if (!dp)
 		return ERR_PTR(-ENOMEM);
 
-	get_nfs4_file(fp);
-	dp->dl_stid.sc_file = fp;
-
 	spin_lock(&state_lock);
 	spin_lock(&fp->fi_lock);
 	if (!fp->fi_deleg_file) {
-- 
2.14.3

