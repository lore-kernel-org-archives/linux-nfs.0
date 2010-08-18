Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6955 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752227Ab0HROo1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Aug 2010 10:44:27 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 04/11] SQUASHME pnfs-submit rename pnfs_layout_type 4
Date: Wed, 18 Aug 2010 10:44:11 -0400
Message-Id: <1282142658-21579-5-git-send-email-andros@netapp.com>
In-Reply-To: <1282142658-21579-4-git-send-email-andros@netapp.com>
References: <1282142658-21579-1-git-send-email-andros@netapp.com>
 <1282142658-21579-2-git-send-email-andros@netapp.com>
 <1282142658-21579-3-git-send-email-andros@netapp.com>
 <1282142658-21579-4-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

squash into pnfs_submit: layoutget

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c |    2 +-
 fs/nfs/pnfs.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 98f53c2..fdc4028 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -348,7 +348,7 @@ put_layout(struct inode *inode)
 }
 
 void
-pnfs_layout_release(struct pnfs_layout_type *lo,
+pnfs_layout_release(struct pnfs_layout_hdr *lo,
 		    struct nfs4_pnfs_layout_segment *range)
 {
 	struct nfs_inode *nfsi = PNFS_NFS_INODE(lo);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 7da54fe..e39af4f 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -58,7 +58,7 @@ void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *,
 void pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *);
 void pnfs_get_layout_done(struct nfs4_pnfs_layoutget *, int rpc_status);
 int pnfs_layout_process(struct nfs4_pnfs_layoutget *lgp);
-void pnfs_layout_release(struct pnfs_layout_type *, struct nfs4_pnfs_layout_segment *range);
+void pnfs_layout_release(struct pnfs_layout_hdr *, struct nfs4_pnfs_layout_segment *range);
 void pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
 			     const nfs4_stateid *stateid);
 void pnfs_destroy_layout(struct nfs_inode *);
-- 
1.6.2.5

