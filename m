From: andros@netapp.com
Subject: [PATCH 04/10] SQUASHME pnfs_submit: don't use pnfs_use_write for commit
Date: Wed, 12 May 2010 10:44:16 -0400
Message-ID: <1273675462-15758-5-git-send-email-andros@netapp.com>
References: <1273675462-15758-1-git-send-email-andros@netapp.com>
 <1273675462-15758-2-git-send-email-andros@netapp.com>
 <1273675462-15758-3-git-send-email-andros@netapp.com>
 <1273675462-15758-4-git-send-email-andros@netapp.com>
Cc: iisaman@netapp.com, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:3866 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754366Ab0ELOpB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 May 2010 10:45:01 -0400
In-Reply-To: <1273675462-15758-4-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Prepare to remove unused threshold calculations
Squash into: "pnfs:commit and pnfs_write_end"

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 316275d..c48bcd7 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1874,7 +1874,7 @@ _pnfs_try_to_commit(struct nfs_write_data *data,
 {
 	struct inode *inode = data->inode;
 
-	if (!pnfs_use_write(inode, -1)) {
+	if (!pnfs_enabled_sb(NFS_SERVER(inode))) {
 		dprintk("%s: Not using pNFS I/O\n", __func__);
 		return PNFS_NOT_ATTEMPTED;
 	} else {
-- 
1.6.6

