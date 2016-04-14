Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:35537 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932101AbcDNMhR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Apr 2016 08:37:17 -0400
Received: by mail-qg0-f44.google.com with SMTP id f105so61700580qge.2
        for <linux-nfs@vger.kernel.org>; Thu, 14 Apr 2016 05:37:17 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 6/8] nfs: have ff_layout_get_ds_cred take a reference to the cred
Date: Thu, 14 Apr 2016 08:37:03 -0400
Message-Id: <1460637425-1580-7-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1460637425-1580-1-git-send-email-jeff.layton@primarydata.com>
References: <1460637425-1580-1-git-send-email-jeff.layton@primarydata.com>
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
 fs/nfs/flexfilelayout/flexfilelayout.c    |  9 ++++++---
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 30 ++++++++++++++++++++++++++----
 2 files changed, 32 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 0cb1abd535e3..ba48fdf960e0 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1737,7 +1737,7 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
 			  vers == 3 ? &ff_layout_read_call_ops_v3 :
 				      &ff_layout_read_call_ops_v4,
 			  0, RPC_TASK_SOFTCONN);
-
+	put_rpccred(ds_cred);
 	return PNFS_ATTEMPTED;
 
 out_failed:
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

