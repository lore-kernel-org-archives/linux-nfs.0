Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37833 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754015Ab0HSP3H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Aug 2010 11:29:07 -0400
From: andros@netpp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 2/5] SQUASHME pnfs-submit: rename layoutget 1
Date: Thu, 19 Aug 2010 11:27:54 -0400
Message-Id: <1282231677-4412-3-git-send-email-andros@netpp.com>
In-Reply-To: <1282231677-4412-2-git-send-email-andros@netpp.com>
References: <1282231677-4412-1-git-send-email-andros@netpp.com>
 <1282231677-4412-2-git-send-email-andros@netpp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

squash into pnfs_submit-layout-segment-alloc-reference-destroy

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/nfs4_pnfs.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index cbb98f1..74e7b62 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -137,7 +137,7 @@ struct layoutdriver_io_operations {
 	 * a set_layout call to set the opaque layout in the layout driver.*/
 	struct pnfs_layout_hdr * (*alloc_layout) (struct inode *inode);
 	void (*free_layout) (struct pnfs_layout_hdr *);
-	struct pnfs_layout_segment * (*alloc_lseg) (struct pnfs_layout_hdr *layoutid, struct nfs4_pnfs_layoutget_res *lgr);
+	struct pnfs_layout_segment * (*alloc_lseg) (struct pnfs_layout_hdr *layoutid, struct nfs4_layoutget_res *lgr);
 	void (*free_lseg) (struct pnfs_layout_segment *lseg);
 
 	/* Registration information for a new mounted file system
-- 
1.6.2.5

