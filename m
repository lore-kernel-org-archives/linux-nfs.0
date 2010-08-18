Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6955 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752227Ab0HROob (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Aug 2010 10:44:31 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 06/11] SQUASHME pnfs-submit: rename pnfs_layout_type 6
Date: Wed, 18 Aug 2010 10:44:13 -0400
Message-Id: <1282142658-21579-7-git-send-email-andros@netapp.com>
In-Reply-To: <1282142658-21579-6-git-send-email-andros@netapp.com>
References: <1282142658-21579-1-git-send-email-andros@netapp.com>
 <1282142658-21579-2-git-send-email-andros@netapp.com>
 <1282142658-21579-3-git-send-email-andros@netapp.com>
 <1282142658-21579-4-git-send-email-andros@netapp.com>
 <1282142658-21579-5-git-send-email-andros@netapp.com>
 <1282142658-21579-6-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

squash into pnfs_submit: filelayout layout segment alloc and free

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index fa08540..87c8fe0 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -317,7 +317,7 @@ filelayout_free_layout(struct pnfs_layout_hdr *lo)
  */
 
 static int
-filelayout_check_layout(struct pnfs_layout_type *lo,
+filelayout_check_layout(struct pnfs_layout_hdr *lo,
 			struct pnfs_layout_segment *lseg)
 {
 	struct nfs4_filelayout_segment *fl = LSEG_LD_DATA(lseg);
@@ -453,7 +453,7 @@ filelayout_set_layout(struct nfs4_filelayout *flo,
 }
 
 static struct pnfs_layout_segment *
-filelayout_alloc_lseg(struct pnfs_layout_type *layoutid,
+filelayout_alloc_lseg(struct pnfs_layout_hdr *layoutid,
 		      struct nfs4_pnfs_layoutget_res *lgr)
 {
 	struct nfs4_filelayout *flo = FILE_LO(layoutid);
-- 
1.6.2.5

