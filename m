Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34176 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752033AbdHIBkn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Aug 2017 21:40:43 -0400
Received: by mail-io0-f193.google.com with SMTP id m88so3685236iod.1
        for <linux-nfs@vger.kernel.org>; Tue, 08 Aug 2017 18:40:43 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFSv4: Use the nfs4_state being recovered in _nfs4_opendata_to_nfs4_state()
Date: Tue,  8 Aug 2017 21:40:21 -0400
Message-Id: <20170809014021.42909-2-trond.myklebust@primarydata.com>
In-Reply-To: <20170809014021.42909-1-trond.myklebust@primarydata.com>
References: <20170809014021.42909-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we're recovering a nfs4_state, then we should try to use that instead
of looking up a new stateid. Only do that if the inodes match, though.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 41 +++++++++++++++++++++++++----------------
 1 file changed, 25 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 71c469bd1ae9..08cc97488904 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1682,11 +1682,29 @@ nfs4_opendata_get_inode(struct nfs4_opendata *data)
 }
 
 static struct nfs4_state *
-_nfs4_opendata_to_nfs4_state(struct nfs4_opendata *data)
+nfs4_opendata_find_nfs4_state(struct nfs4_opendata *data)
 {
+	struct nfs4_state *state;
 	struct inode *inode;
-	struct nfs4_state *state = NULL;
-	int ret;
+
+	inode = nfs4_opendata_get_inode(data);
+	if (IS_ERR(inode))
+		return ERR_CAST(inode);
+	if (data->state != NULL && data->state->inode == inode) {
+		state = data->state;
+		atomic_inc(&state->count);
+	} else
+		state = nfs4_get_open_state(inode, data->owner);
+	iput(inode);
+	if (state == NULL)
+		state = ERR_PTR(-ENOMEM);
+	return state;
+}
+
+static struct nfs4_state *
+_nfs4_opendata_to_nfs4_state(struct nfs4_opendata *data)
+{
+	struct nfs4_state *state;
 
 	if (!data->rpc_done) {
 		state = nfs4_try_open_cached(data);
@@ -1694,26 +1712,17 @@ _nfs4_opendata_to_nfs4_state(struct nfs4_opendata *data)
 		goto out;
 	}
 
-	inode = nfs4_opendata_get_inode(data);
-	ret = PTR_ERR(inode);
-	if (IS_ERR(inode))
-		goto err;
-	ret = -ENOMEM;
-	state = nfs4_get_open_state(inode, data->owner);
-	if (state == NULL)
-		goto err_put_inode;
+	state = nfs4_opendata_find_nfs4_state(data);
+	if (IS_ERR(state))
+		goto out;
+
 	if (data->o_res.delegation_type != 0)
 		nfs4_opendata_check_deleg(data, state);
 	update_open_stateid(state, &data->o_res.stateid, NULL,
 			data->o_arg.fmode);
-	iput(inode);
 out:
 	nfs_release_seqid(data->o_arg.seqid);
 	return state;
-err_put_inode:
-	iput(inode);
-err:
-	return ERR_PTR(ret);
 }
 
 static struct nfs4_state *
-- 
2.13.4

