Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:41971 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752993Ab1LDNsK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Dec 2011 08:48:10 -0500
Received: by mail-ey0-f174.google.com with SMTP id k14so3592866eaa.19
        for <linux-nfs@vger.kernel.org>; Sun, 04 Dec 2011 05:48:10 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 02/13] DEBUG: pnfsd: printouts
Date: Sun,  4 Dec 2011 15:48:04 +0200
Message-Id: <1323006484-13504-1-git-send-email-benny@tonian.com>
In-Reply-To: <4EDB79A9.2080109@tonian.com>
References: <4EDB79A9.2080109@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@tonian.com>

---
 fs/nfsd/bl_ops.c  |    1 +
 fs/nfsd/nfs4xdr.c |    3 +++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/bl_ops.c b/fs/nfsd/bl_ops.c
index 22875fb..89249c4 100644
--- a/fs/nfsd/bl_ops.c
+++ b/fs/nfsd/bl_ops.c
@@ -184,6 +184,7 @@ static boolean_t extents_process(struct fiemap_extent_info *fei,
 int
 bl_layout_type(struct super_block *sb)
 {
+	dprintk("%s --> %d\n", __func__, LAYOUT_BLOCK_VOLUME);
 	return LAYOUT_BLOCK_VOLUME;
 }
 
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 2263830..bd8e693 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2592,6 +2592,8 @@ static __be32 fattr_handle_absent_fs(u32 *bmval0, u32 *bmval1, u32 *rdattr_err)
 
 		if (sb && sb->s_pnfs_op && sb->s_pnfs_op->layout_type)
 			type = sb->s_pnfs_op->layout_type(sb);
+		dprintk("%s: sb=%p s_pnfs_op=%p layout_type()=%p layout_type=%u\n",
+			__func__, sb, sb->s_pnfs_op, sb->s_pnfs_op ? sb->s_pnfs_op->layout_type : NULL, type);
 		if (type) {
 			if ((buflen -= 4) < 0)	/* type */
 				goto out_resource;
@@ -2604,6 +2606,7 @@ static __be32 fattr_handle_absent_fs(u32 *bmval0, u32 *bmval1, u32 *rdattr_err)
 	if (bmval2 & FATTR4_WORD2_LAYOUT_BLKSIZE) {
 		if ((buflen -= 4) < 0)
 			goto out_resource;
+		dprintk("%s: layout_blksize=%lu\n", __func__, stat.blksize);
 		WRITE32(stat.blksize);
 	}
 #endif /* CONFIG_PNFSD */
-- 
1.7.6

