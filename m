Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f170.google.com ([209.85.223.170]:63263 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751861AbaLXHOA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Dec 2014 02:14:00 -0500
Received: by mail-ie0-f170.google.com with SMTP id rd18so7270062iec.15
        for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2014 23:13:59 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <Trond.Myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 24/49] nfs41: make a helper function to send layoutreturn
Date: Tue, 23 Dec 2014 23:13:03 -0800
Message-Id: <1419405208-25975-25-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1419405208-25975-1-git-send-email-loghyr@primarydata.com>
References: <1419405208-25975-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

It allows to specify different iomode to return.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
---
 fs/nfs/pnfs.c | 53 +++++++++++++++++++++++++++++++++--------------------
 1 file changed, 33 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 1b544c1..1b97209 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -845,6 +845,38 @@ static void pnfs_clear_layoutcommit(struct inode *inode,
 	}
 }
 
+static int
+pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, nfs4_stateid stateid,
+		       enum pnfs_iomode iomode)
+{
+	struct inode *ino = lo->plh_inode;
+	struct nfs4_layoutreturn *lrp;
+	int status = 0;
+
+	lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
+	if (unlikely(lrp == NULL)) {
+		status = -ENOMEM;
+		spin_lock(&ino->i_lock);
+		lo->plh_block_lgets--;
+		spin_unlock(&ino->i_lock);
+		pnfs_put_layout_hdr(lo);
+		goto out;
+	}
+
+	lrp->args.stateid = stateid;
+	lrp->args.layout_type = NFS_SERVER(ino)->pnfs_curr_ld->id;
+	lrp->args.inode = ino;
+	lrp->args.iomode = iomode;
+	lrp->args.layout = lo;
+	lrp->clp = NFS_SERVER(ino)->nfs_client;
+	lrp->cred = lo->plh_lc_cred;
+
+	status = nfs4_proc_layoutreturn(lrp);
+out:
+	dprintk("<-- %s status: %d\n", __func__, status);
+	return status;
+}
+
 /*
  * Initiates a LAYOUTRETURN(FILE), and removes the pnfs_layout_hdr
  * when the layout segment list is empty.
@@ -859,7 +891,6 @@ _pnfs_return_layout(struct inode *ino)
 	struct pnfs_layout_hdr *lo = NULL;
 	struct nfs_inode *nfsi = NFS_I(ino);
 	LIST_HEAD(tmp_list);
-	struct nfs4_layoutreturn *lrp;
 	nfs4_stateid stateid;
 	int status = 0, empty;
 
@@ -901,25 +932,7 @@ _pnfs_return_layout(struct inode *ino)
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&tmp_list);
 
-	lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
-	if (unlikely(lrp == NULL)) {
-		status = -ENOMEM;
-		spin_lock(&ino->i_lock);
-		lo->plh_block_lgets--;
-		spin_unlock(&ino->i_lock);
-		pnfs_put_layout_hdr(lo);
-		goto out;
-	}
-
-	lrp->args.stateid = stateid;
-	lrp->args.layout_type = NFS_SERVER(ino)->pnfs_curr_ld->id;
-	lrp->args.inode = ino;
-	lrp->args.iomode = IOMODE_ANY;
-	lrp->args.layout = lo;
-	lrp->clp = NFS_SERVER(ino)->nfs_client;
-	lrp->cred = lo->plh_lc_cred;
-
-	status = nfs4_proc_layoutreturn(lrp);
+	status = pnfs_send_layoutreturn(lo, stateid, IOMODE_ANY);
 out:
 	dprintk("<-- %s status: %d\n", __func__, status);
 	return status;
-- 
1.9.3

