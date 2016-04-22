Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:36606 "EHLO
	mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751731AbcDVAwP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Apr 2016 20:52:15 -0400
Received: by mail-qk0-f171.google.com with SMTP id x7so33030879qkd.3
        for <linux-nfs@vger.kernel.org>; Thu, 21 Apr 2016 17:52:14 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 5/7] nfs: have ff_layout_get_ds_cred take a reference to the cred
Date: Thu, 21 Apr 2016 20:51:58 -0400
Message-Id: <1461286320-24601-6-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1461286320-24601-1-git-send-email-jeff.layton@primarydata.com>
References: <1461286320-24601-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In later patches, we're going to want to allow the creds to be updated
when we get a new layout with updated creds. Have this function take
a reference to the cred that is later put once the call has been
dispatched.

Also, prepare for this change by ensuring we follow RCU rules when
getting a reference to the cred as well.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c    | 15 +++++++++------
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 30 ++++++++++++++++++++++++++----
 2 files changed, 35 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 0cb1abd535e3..432d5b0009c7 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1712,7 +1712,7 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
 		goto out_failed;
 
 	ds_cred = ff_layout_get_ds_cred(lseg, idx, hdr->cred);
-	if (IS_ERR(ds_cred))
+	if (!ds_cred)
 		goto out_failed;
 
 	vers = nfs4_ff_layout_ds_version(lseg, idx);
@@ -1737,7 +1737,7 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
 			  vers == 3 ? &ff_layout_read_call_ops_v3 :
 				      &ff_layout_read_call_ops_v4,
 			  0, RPC_TASK_SOFTCONN);
-
+	put_rpccred(ds_cred);
 	return PNFS_ATTEMPTED;
 
 out_failed:
@@ -1769,7 +1769,7 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 		return PNFS_NOT_ATTEMPTED;
 
 	ds_cred = ff_layout_get_ds_cred(lseg, idx, hdr->cred);
-	if (IS_ERR(ds_cred))
+	if (!ds_cred)
 		return PNFS_NOT_ATTEMPTED;
 
 	vers = nfs4_ff_layout_ds_version(lseg, idx);
@@ -1798,6 +1798,7 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 			  vers == 3 ? &ff_layout_write_call_ops_v3 :
 				      &ff_layout_write_call_ops_v4,
 			  sync, RPC_TASK_SOFTCONN);
+	put_rpccred(ds_cred);
 	return PNFS_ATTEMPTED;
 }
 
@@ -1824,7 +1825,7 @@ static int ff_layout_initiate_commit(struct nfs_commit_data *data, int how)
 	struct rpc_clnt *ds_clnt;
 	struct rpc_cred *ds_cred;
 	u32 idx;
-	int vers;
+	int vers, ret;
 	struct nfs_fh *fh;
 
 	idx = calc_ds_index_from_commit(lseg, data->ds_commit_index);
@@ -1838,7 +1839,7 @@ static int ff_layout_initiate_commit(struct nfs_commit_data *data, int how)
 		goto out_err;
 
 	ds_cred = ff_layout_get_ds_cred(lseg, idx, data->cred);
-	if (IS_ERR(ds_cred))
+	if (!ds_cred)
 		goto out_err;
 
 	vers = nfs4_ff_layout_ds_version(lseg, idx);
@@ -1854,10 +1855,12 @@ static int ff_layout_initiate_commit(struct nfs_commit_data *data, int how)
 	if (fh)
 		data->args.fh = fh;
 
-	return nfs_initiate_commit(ds_clnt, data, ds->ds_clp->rpc_ops,
+	ret = nfs_initiate_commit(ds_clnt, data, ds->ds_clp->rpc_ops,
 				   vers == 3 ? &ff_layout_commit_call_ops_v3 :
 					       &ff_layout_commit_call_ops_v4,
 				   how, RPC_TASK_SOFTCONN);
+	put_rpccred(ds_cred);
+	return ret;
 out_err:
 	pnfs_generic_prepare_to_resend_writes(data);
 	pnfs_generic_commit_release(data);
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index a0dbf94d15ae..baee22929174 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -338,6 +338,25 @@ static int ff_layout_update_mirror_cred(struct nfs4_ff_layout_mirror *mirror,
 	return 0;
 }
 
+static struct rpc_cred *
+ff_layout_get_mirror_cred(struct nfs4_ff_layout_mirror *mirror, u32 iomode)
+{
+	struct rpc_cred *cred, **pcred;
+
+	pcred = &mirror->cred;
+
+	rcu_read_lock();
+	do {
+		cred = rcu_dereference(*pcred);
+		if (!cred)
+			break;
+
+		cred = get_rpccred_rcu(cred);
+	} while(!cred);
+	rcu_read_unlock();
+	return cred;
+}
+
 struct nfs_fh *
 nfs4_ff_layout_select_ds_fh(struct pnfs_layout_segment *lseg, u32 mirror_idx)
 {
@@ -435,10 +454,13 @@ ff_layout_get_ds_cred(struct pnfs_layout_segment *lseg, u32 ds_idx,
 	struct nfs4_ff_layout_mirror *mirror = FF_LAYOUT_COMP(lseg, ds_idx);
 	struct rpc_cred *cred;
 
-	if (mirror && mirror->cred)
-		cred = mirror->cred;
-	else
-		cred = mdscred;
+	if (mirror) {
+		cred = ff_layout_get_mirror_cred(mirror, lseg->pls_range.iomode);
+		if (!cred)
+			cred = get_rpccred(mdscred);
+	} else {
+		cred = get_rpccred(mdscred);
+	}
 	return cred;
 }
 
-- 
2.5.5

