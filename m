Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6955 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753082Ab0HROog (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Aug 2010 10:44:36 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 11/11] SQUASHME pnfs_submit rename pnfs_layout_type 11
Date: Wed, 18 Aug 2010 10:44:18 -0400
Message-Id: <1282142658-21579-12-git-send-email-andros@netapp.com>
In-Reply-To: <1282142658-21579-11-git-send-email-andros@netapp.com>
References: <1282142658-21579-1-git-send-email-andros@netapp.com>
 <1282142658-21579-2-git-send-email-andros@netapp.com>
 <1282142658-21579-3-git-send-email-andros@netapp.com>
 <1282142658-21579-4-git-send-email-andros@netapp.com>
 <1282142658-21579-5-git-send-email-andros@netapp.com>
 <1282142658-21579-6-git-send-email-andros@netapp.com>
 <1282142658-21579-7-git-send-email-andros@netapp.com>
 <1282142658-21579-8-git-send-email-andros@netapp.com>
 <1282142658-21579-9-git-send-email-andros@netapp.com>
 <1282142658-21579-10-git-send-email-andros@netapp.com>
 <1282142658-21579-11-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

squash into pnfs_submit: filelayout policy operations

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 87c8fe0..eb9c907 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -673,9 +673,9 @@ filelayout_commit(struct nfs_write_data *data, int sync)
 
 /* Return the stripesize for the specified file */
 ssize_t
-filelayout_get_stripesize(struct pnfs_layout_type *layoutid)
+filelayout_get_stripesize(struct pnfs_layout_hdr *lo)
 {
-	struct nfs4_filelayout *flo = FILE_LO(layoutid);
+	struct nfs4_filelayout *flo = FILE_LO(lo);
 
 	return flo->stripe_unit;
 }
-- 
1.6.2.5

