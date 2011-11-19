Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:41673 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751008Ab1KSQxx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 19 Nov 2011 11:53:53 -0500
Received: by iage36 with SMTP id e36so5070889iag.19
        for <linux-nfs@vger.kernel.org>; Sat, 19 Nov 2011 08:53:53 -0800 (PST)
From: Peng Tao <bergwolf@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Trond.Myklebust@netapp.com, bhalevy@tonian.com,
        Peng Tao <peng_tao@emc.com>
Subject: [PATCH RFC 1/4] nfsv41: export pnfs_find_alloc_layout
Date: Sat, 19 Nov 2011 08:53:13 -0800
Message-Id: <1321721596-3293-2-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1321721596-3293-1-git-send-email-bergwolf@gmail.com>
References: <1321721596-3293-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

So that layout driver can access layout header when there is none.

Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/pnfs.c |    3 ++-
 fs/nfs/pnfs.h |    4 ++++
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index baf7353..3be29c7 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -848,7 +848,7 @@ alloc_init_layout_hdr(struct inode *ino,
 	return lo;
 }
 
-static struct pnfs_layout_hdr *
+struct pnfs_layout_hdr *
 pnfs_find_alloc_layout(struct inode *ino,
 		       struct nfs_open_context *ctx,
 		       gfp_t gfp_flags)
@@ -875,6 +875,7 @@ pnfs_find_alloc_layout(struct inode *ino,
 		pnfs_free_layout_hdr(new);
 	return nfsi->layout;
 }
+EXPORT_SYMBOL_GPL(pnfs_find_alloc_layout);
 
 /*
  * iomode matching rules:
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 1509530..9614ac9 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -209,6 +209,10 @@ struct pnfs_layout_segment *pnfs_update_layout(struct inode *ino,
 					       u64 count,
 					       enum pnfs_iomode iomode,
 					       gfp_t gfp_flags);
+struct pnfs_layout_hdr *
+pnfs_find_alloc_layout(struct inode *ino,
+		       struct nfs_open_context *ctx,
+		       gfp_t gfp_flags);
 
 void nfs4_deviceid_mark_client_invalid(struct nfs_client *clp);
 
-- 
1.7.1.262.g5ef3d

