From: andros@netapp.com
Subject: [PATCH 08/10] SQUASHME pnfs_submit: don't use below_threshold in direct io
Date: Wed, 12 May 2010 10:44:20 -0400
Message-ID: <1273675462-15758-9-git-send-email-andros@netapp.com>
References: <1273675462-15758-1-git-send-email-andros@netapp.com>
 <1273675462-15758-2-git-send-email-andros@netapp.com>
 <1273675462-15758-3-git-send-email-andros@netapp.com>
 <1273675462-15758-4-git-send-email-andros@netapp.com>
 <1273675462-15758-5-git-send-email-andros@netapp.com>
 <1273675462-15758-6-git-send-email-andros@netapp.com>
 <1273675462-15758-7-git-send-email-andros@netapp.com>
 <1273675462-15758-8-git-send-email-andros@netapp.com>
Cc: iisaman@netapp.com, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:65392 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752518Ab0ELOpD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 May 2010 10:45:03 -0400
In-Reply-To: <1273675462-15758-8-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Prepare to remove unused threshold calculations
Squash into: "pnfs: Add function to set up O_DIRECT I/O"

Signed-off-by: Andy Adamon <andros@netapp.com>
---
 fs/nfs/pnfs.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 19cc193..9276bf8 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1455,7 +1455,6 @@ _pnfs_direct_init_io(struct inode *inode, struct nfs_open_context *ctx,
 	unsigned int rwsize;
 
 	if (count <= 0 ||
-	    below_threshold(inode, count, iswrite) ||
 	    pnfs_update_layout(inode, ctx, count, loff, IOMODE_READ, NULL))
 		return;
 
-- 
1.6.6

