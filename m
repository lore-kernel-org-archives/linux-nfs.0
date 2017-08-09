Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36010 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752033AbdHIBkm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Aug 2017 21:40:42 -0400
Received: by mail-io0-f194.google.com with SMTP id j32so3683809iod.3
        for <linux-nfs@vger.kernel.org>; Tue, 08 Aug 2017 18:40:42 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFSv4: Use correct inode in _nfs4_opendata_to_nfs4_state()
Date: Tue,  8 Aug 2017 21:40:20 -0400
Message-Id: <20170809014021.42909-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When doing open by filehandle we don't really want to lookup a new inode,
but rather update the one we've got. Add a helper which does this for us.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 28 +++++++++++++++++++++++-----
 1 file changed, 23 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1c73aa92b079..71c469bd1ae9 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1659,6 +1659,28 @@ _nfs4_opendata_reclaim_to_nfs4_state(struct nfs4_opendata *data)
 	return state;
 }
 
+static struct inode *
+nfs4_opendata_get_inode(struct nfs4_opendata *data)
+{
+	struct inode *inode;
+
+	switch (data->o_arg.claim) {
+	case NFS4_OPEN_CLAIM_NULL:
+	case NFS4_OPEN_CLAIM_DELEGATE_CUR:
+	case NFS4_OPEN_CLAIM_DELEGATE_PREV:
+		if (!(data->f_attr.valid & NFS_ATTR_FATTR))
+			return ERR_PTR(-EAGAIN);
+		inode = nfs_fhget(data->dir->d_sb, &data->o_res.fh,
+				&data->f_attr, data->f_label);
+		break;
+	default:
+		inode = d_inode(data->dentry);
+		ihold(inode);
+		nfs_refresh_inode(inode, &data->f_attr);
+	}
+	return inode;
+}
+
 static struct nfs4_state *
 _nfs4_opendata_to_nfs4_state(struct nfs4_opendata *data)
 {
@@ -1672,10 +1694,7 @@ _nfs4_opendata_to_nfs4_state(struct nfs4_opendata *data)
 		goto out;
 	}
 
-	ret = -EAGAIN;
-	if (!(data->f_attr.valid & NFS_ATTR_FATTR))
-		goto err;
-	inode = nfs_fhget(data->dir->d_sb, &data->o_res.fh, &data->f_attr, data->f_label);
+	inode = nfs4_opendata_get_inode(data);
 	ret = PTR_ERR(inode);
 	if (IS_ERR(inode))
 		goto err;
@@ -2071,7 +2090,6 @@ static void nfs4_open_prepare(struct rpc_task *task, void *calldata)
 		data->o_arg.open_bitmap = &nfs4_open_noattr_bitmap[0];
 	case NFS4_OPEN_CLAIM_FH:
 		task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN_NOATTR];
-		nfs_copy_fh(&data->o_res.fh, data->o_arg.fh);
 	}
 	data->timestamp = jiffies;
 	if (nfs4_setup_sequence(data->o_arg.server->nfs_client,
-- 
2.13.4

