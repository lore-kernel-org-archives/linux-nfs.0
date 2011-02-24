Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:15993 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753434Ab1BYR5e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Feb 2011 12:57:34 -0500
From: andros@netapp.com
To: iisaman@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 4/4] SQUASHME put_lseg before setting pointer to NULL
Date: Thu, 24 Feb 2011 05:11:09 -0500
Message-Id: <1298542269-2477-4-git-send-email-andros@netapp.com>
In-Reply-To: <1298542269-2477-1-git-send-email-andros@netapp.com>
References: <1298542269-2477-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 58217dd..cbeb873 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -910,8 +910,8 @@ pnfs_try_to_write_data(struct nfs_write_data *wdata,
 
 	trypnfs = nfss->pnfs_curr_ld->write_pagelist(wdata, how);
 	if (trypnfs == PNFS_NOT_ATTEMPTED) {
-		wdata->lseg = NULL;
 		put_lseg(wdata->lseg);
+		wdata->lseg = NULL;
 	} else
 		nfs_inc_stats(inode, NFSIOS_PNFS_WRITE);
 
-- 
1.7.3.1

