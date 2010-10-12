Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51392 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752069Ab0JMSnT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Oct 2010 14:43:19 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: iisaman@netapp.com, linux-nfs@vger.kernel.org,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH 2/2] pnfs_submit: replace pnfs_layoutget_release with put_layout_hdr
Date: Tue, 12 Oct 2010 06:13:28 -0400
Message-Id: <1286878408-10287-2-git-send-email-andros@netapp.com>
In-Reply-To: <1286878408-10287-1-git-send-email-andros@netapp.com>
References: <1286878408-10287-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

They are the same function.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |    2 +-
 fs/nfs/pnfs.c     |   13 +------------
 fs/nfs/pnfs.h     |    1 -
 3 files changed, 2 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4c56d9b..9322e67 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5474,7 +5474,7 @@ static void nfs4_layoutget_release(void *calldata)
 	struct nfs4_layoutget *lgp = calldata;
 
 	dprintk("--> %s\n", __func__);
-	pnfs_layoutget_release(NFS_I(lgp->args.inode)->layout);
+	put_layout_hdr(lgp->args.inode);
 	if (lgp->res.layout.buf != NULL)
 		free_page((unsigned long) lgp->res.layout.buf);
 	put_nfs_open_context(lgp->args.ctx);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 124d3ca..52e56a1 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -381,17 +381,6 @@ pnfs_free_lseg_list(struct list_head *tmp_list)
 	}
 }
 
-
-void
-pnfs_layoutget_release(struct pnfs_layout_hdr *lo)
-{
-	struct nfs_inode *nfsi = NFS_I(lo->inode);
-
-	spin_lock(&nfsi->vfs_inode.i_lock);
-	put_layout_hdr_locked(lo); /* Matched in _pnfs_update_layout */
-	spin_unlock(&nfsi->vfs_inode.i_lock);
-}
-
 void
 pnfs_layoutreturn_release(struct pnfs_layout_hdr *lo,
 			  struct pnfs_layout_range *range)
@@ -541,7 +530,7 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 	BUG_ON(ctx == NULL);
 	lgp = kzalloc(sizeof(*lgp), GFP_KERNEL);
 	if (lgp == NULL) {
-		pnfs_layoutget_release(lo);
+		put_layout_hdr(ino);
 		return NULL;
 	}
 	lgp->args.minlength = NFS4_MAX_UINT64;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 3fd2bc3..ba3d3f7 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -202,7 +202,6 @@ void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *,
 			   struct nfs_open_context *, struct list_head *);
 void pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *);
 int pnfs_layout_process(struct nfs4_layoutget *lgp);
-void pnfs_layoutget_release(struct pnfs_layout_hdr *);
 void pnfs_layoutreturn_release(struct pnfs_layout_hdr *,
 			       struct pnfs_layout_range *range);
 void pnfs_destroy_layout(struct nfs_inode *);
-- 
1.6.6

