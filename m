Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:41673 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751008Ab1KSQx7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 19 Nov 2011 11:53:59 -0500
Received: by mail-iy0-f174.google.com with SMTP id e36so5070889iag.19
        for <linux-nfs@vger.kernel.org>; Sat, 19 Nov 2011 08:53:59 -0800 (PST)
From: Peng Tao <bergwolf@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Trond.Myklebust@netapp.com, bhalevy@tonian.com,
        Peng Tao <peng_tao@emc.com>
Subject: [PATCH RFC 2/4] nfsv41: add and export pnfs_find_get_layout_locked
Date: Sat, 19 Nov 2011 08:53:14 -0800
Message-Id: <1321721596-3293-3-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1321721596-3293-1-git-send-email-bergwolf@gmail.com>
References: <1321721596-3293-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It tries to find the lseg from local cache but not retrive layout from server.

Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/pnfs.c |   25 +++++++++++++++++++++++++
 fs/nfs/pnfs.h |    5 +++++
 2 files changed, 30 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 3be29c7..734e670 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -933,6 +933,31 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo,
 }
 
 /*
+ * Find and reference lseg with ino->i_lock held.
+ */
+struct pnfs_layout_segment *
+pnfs_find_get_layout_locked(struct inode *ino,
+			loff_t pos,
+			u64 count,
+			enum pnfs_iomode iomode)
+{
+	struct pnfs_layout_segment *lseg = NULL;
+	struct pnfs_layout_range range = {
+		.iomode = iomode,
+		.offset = pos,
+		.length = count,
+	};
+
+	if (NFS_I(ino)->layout == NULL)
+		goto out;
+
+	lseg = pnfs_find_lseg(NFS_I(ino)->layout, &range);
+out:
+	return lseg;
+}
+EXPORT_SYMBOL_GPL(pnfs_find_get_layout_locked);
+
+/*
  * Layout segment is retreived from the server if not cached.
  * The appropriate layout segment is referenced and returned to the caller.
  */
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 9614ac9..0c55fc1 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -213,6 +213,11 @@ struct pnfs_layout_hdr *
 pnfs_find_alloc_layout(struct inode *ino,
 		       struct nfs_open_context *ctx,
 		       gfp_t gfp_flags);
+struct pnfs_layout_segment *
+pnfs_find_get_layout_locked(struct inode *ino,
+			loff_t pos,
+			u64 count,
+			enum pnfs_iomode iomode);
 
 void nfs4_deviceid_mark_client_invalid(struct nfs_client *clp);
 
-- 
1.7.1.262.g5ef3d

