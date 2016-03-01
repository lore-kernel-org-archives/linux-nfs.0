Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:35075 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750997AbcCASMx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Mar 2016 13:12:53 -0500
From: Goldwyn Rodrigues <rgoldwyn@suse.de>
To: miklos@szeredi.hu
Cc: linux-unionfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, Goldwyn Rodrigues <rgoldwyn@suse.com>
Subject: [PATCH 1/3] ovl: Add d_select_inode to reval dentry operations
Date: Tue,  1 Mar 2016 12:12:06 -0600
Message-Id: <1456855928-29913-2-git-send-email-rgoldwyn@suse.de>
In-Reply-To: <1456855928-29913-1-git-send-email-rgoldwyn@suse.de>
References: <1456855928-29913-1-git-send-email-rgoldwyn@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Goldwyn Rodrigues <rgoldwyn@suse.com>

This was missed in earlier commit because of which access to files
in distributed filesystems such as NFS would result in ENXIO
while opening the files.

Signed-off-by: Goldwyn Rodrigues <rgoldwyn@suse.com>
---
 fs/overlayfs/super.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/overlayfs/super.c b/fs/overlayfs/super.c
index 8d826bd..588a4b5 100644
--- a/fs/overlayfs/super.c
+++ b/fs/overlayfs/super.c
@@ -341,6 +341,7 @@ static const struct dentry_operations ovl_dentry_operations = {
 
 static const struct dentry_operations ovl_reval_dentry_operations = {
 	.d_release = ovl_dentry_release,
+	.d_select_inode = ovl_d_select_inode,
 	.d_revalidate = ovl_dentry_revalidate,
 	.d_weak_revalidate = ovl_dentry_weak_revalidate,
 };
-- 
2.6.2

