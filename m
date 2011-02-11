Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51329 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757844Ab1BKSAo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Feb 2011 13:00:44 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 09/17] SQUASHME cleanup read_pagelist declaration and comment
Date: Thu, 10 Feb 2011 20:52:42 -0500
Message-Id: <1297389170-26702-10-git-send-email-andros@netapp.com>
In-Reply-To: <1297389170-26702-9-git-send-email-andros@netapp.com>
References: <1297389170-26702-1-git-send-email-andros@netapp.com>
 <1297389170-26702-2-git-send-email-andros@netapp.com>
 <1297389170-26702-3-git-send-email-andros@netapp.com>
 <1297389170-26702-4-git-send-email-andros@netapp.com>
 <1297389170-26702-5-git-send-email-andros@netapp.com>
 <1297389170-26702-6-git-send-email-andros@netapp.com>
 <1297389170-26702-7-git-send-email-andros@netapp.com>
 <1297389170-26702-8-git-send-email-andros@netapp.com>
 <1297389170-26702-9-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

squash into pnfs_submit-wave3-generic-read

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.h |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 218cdfe..b47598c 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -76,15 +76,11 @@ struct pnfs_layoutdriver_type {
 	/* test for nfs page cache coalescing */
 	int (*pg_test)(struct nfs_pageio_descriptor *, struct nfs_page *, struct nfs_page *);
 
-	/* read and write pagelist should return just 0 (to indicate that
-	 * the layout code has taken control) or 1 (to indicate that the
-	 * layout code wishes to fall back to normal nfs.)  If 0 is returned,
-	 * information can be passed back through nfs_data->res and
-	 * nfs_data->task.tk_status, and the appropriate pnfs done function
-	 * MUST be called.
+	/*
+	 * Return PNFS_ATTEMPTED to indicate the layout code has attempted
+	 * I/O, else return PNFS_NOT_ATTEMPTED to fall back to normal NFS
 	 */
-	enum pnfs_try_status
-	(*read_pagelist) (struct nfs_read_data *nfs_data);
+	enum pnfs_try_status (*read_pagelist) (struct nfs_read_data *nfs_data);
 };
 
 struct pnfs_layout_hdr {
-- 
1.6.6

