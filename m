Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33566 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751856AbdDEAMJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Apr 2017 20:12:09 -0400
Received: by mail-pf0-f181.google.com with SMTP id s16so25545099pfs.0
        for <linux-nfs@vger.kernel.org>; Tue, 04 Apr 2017 17:12:09 -0700 (PDT)
Date: Tue, 4 Apr 2017 17:12:06 -0700
From: Kees Cook <keescook@chromium.org>
To: linux-kernel@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Avoid cross-structure casting
Message-ID: <20170405001206.GA58184@beast>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the call to nfs_devname() fails, the error path attempts to retain
the error via the mnt variable, but this requires a cast across very
different types (char * to struct vfsmount), which the upcoming structure
layout randomization plugin flags as being potentially dangerous in the
face of randomization. This is a false positive, but what this code
actually wants to do is retain the error value, so this patch explicitly
sets it, instead of using what seems to be an unexpected cast.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 fs/nfs/namespace.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 786f17580582..89f50bf12f52 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -259,9 +259,10 @@ struct vfsmount *nfs_do_submount(struct dentry *dentry, struct nfs_fh *fh,
 	if (page == NULL)
 		goto out;
 	devname = nfs_devname(dentry, page, PAGE_SIZE);
-	mnt = (struct vfsmount *)devname;
-	if (IS_ERR(devname))
+	if (IS_ERR(devname)) {
+		mnt = ERR_PTR(PTR_ERR(devname));
 		goto free_page;
+	}
 	mnt = nfs_do_clone_mount(NFS_SB(dentry->d_sb), devname, &mountdata);
 free_page:
 	free_page((unsigned long)page);
-- 
2.7.4


-- 
Kees Cook
Pixel Security
