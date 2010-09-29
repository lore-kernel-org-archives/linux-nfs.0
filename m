Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:10677 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752536Ab0I2LKD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Sep 2010 07:10:03 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/5] pnfs-submit: file needs layout commit, server attributes may be stale
Date: Wed, 29 Sep 2010 13:10:01 +0200
Message-Id: <1285758601-26860-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4CA31DC3.8070300@panasas.com>
References: <4CA31DC3.8070300@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

[part of "pnfs: layoutcommit"]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/inode.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 979483f..8cdea1a 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1212,6 +1212,14 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 		server->fsid = fattr->fsid;
 
 	/*
+	 * file needs layout commit, server attributes may be stale
+	 */
+	if (layoutcommit_needed(nfsi) && nfsi->change_attr >= fattr->change_attr) {
+		dprintk("NFS: %s: layoutcommit is needed for file %s/%ld\n",
+			__func__, inode->i_sb->s_id, inode->i_ino);
+		return 0;
+	}
+	/*
 	 * Update the read time so we don't revalidate too often.
 	 */
 	nfsi->read_cache_jiffies = fattr->time_start;
-- 
1.7.2.3

