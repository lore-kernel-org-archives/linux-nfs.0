From: andros@netapp.com
Subject: [PATCH 02/10] SQUASHME pnfs_submit: don't use pnfs_use_read
Date: Wed, 12 May 2010 10:44:14 -0400
Message-ID: <1273675462-15758-3-git-send-email-andros@netapp.com>
References: <1273675462-15758-1-git-send-email-andros@netapp.com>
 <1273675462-15758-2-git-send-email-andros@netapp.com>
Cc: iisaman@netapp.com, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:3866 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752564Ab0ELOpA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 May 2010 10:45:00 -0400
In-Reply-To: <1273675462-15758-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Prepare to remove unused threshold calculations
Squash into: "pnfs:read"

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 57d3ff0..618bb08 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1834,7 +1834,7 @@ _pnfs_try_to_read_data(struct nfs_read_data *data,
 
 	dprintk("--> %s\n", __func__);
 	/* Only create an rpc request if utilizing NFSv4 I/O */
-	if (!pnfs_use_read(ino, data->args.count) ||
+	if (!pnfs_enabled_sb(nfss) ||
 	    !nfss->pnfs_curr_ld->ld_io_ops->read_pagelist) {
 		dprintk("<-- %s: not using pnfs\n", __func__);
 		return PNFS_NOT_ATTEMPTED;
-- 
1.6.6

