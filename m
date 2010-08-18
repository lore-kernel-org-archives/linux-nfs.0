Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6955 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753378Ab0HROoc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Aug 2010 10:44:32 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 07/11] SQUASHME pnfs_submit: rename pnfs_layout_type 7
Date: Wed, 18 Aug 2010 10:44:14 -0400
Message-Id: <1282142658-21579-8-git-send-email-andros@netapp.com>
In-Reply-To: <1282142658-21579-7-git-send-email-andros@netapp.com>
References: <1282142658-21579-1-git-send-email-andros@netapp.com>
 <1282142658-21579-2-git-send-email-andros@netapp.com>
 <1282142658-21579-3-git-send-email-andros@netapp.com>
 <1282142658-21579-4-git-send-email-andros@netapp.com>
 <1282142658-21579-5-git-send-email-andros@netapp.com>
 <1282142658-21579-6-git-send-email-andros@netapp.com>
 <1282142658-21579-7-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

squash into pnfs_submit: layoutreturn helper functions

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index a10143e..b9bf9d6 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -590,7 +590,7 @@ should_free_lseg(struct pnfs_layout_segment *lseg,
 }
 
 static struct pnfs_layout_segment *
-has_layout_to_return(struct pnfs_layout_type *lo,
+has_layout_to_return(struct pnfs_layout_hdr *lo,
 		     struct nfs4_pnfs_layout_segment *range)
 {
 	struct pnfs_layout_segment *out = NULL, *lseg;
@@ -674,7 +674,7 @@ pnfs_return_layout_barrier(struct nfs_inode *nfsi,
 
 static int
 return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
-	      enum pnfs_layoutreturn_type type, struct pnfs_layout_type *lo,
+	      enum pnfs_layoutreturn_type type, struct pnfs_layout_hdr *lo,
 	      bool wait)
 {
 	struct nfs4_pnfs_layoutreturn *lrp;
@@ -709,7 +709,7 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 		    enum pnfs_layoutreturn_type type,
 		    bool wait)
 {
-	struct pnfs_layout_type *lo = NULL;
+	struct pnfs_layout_hdr *lo = NULL;
 	struct nfs_inode *nfsi = NFS_I(ino);
 	struct nfs4_pnfs_layout_segment arg;
 	int status = 0;
-- 
1.6.2.5

