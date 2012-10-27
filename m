Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:53867 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756689Ab2J0Mel (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2012 08:34:41 -0400
Received: by mail-gg0-f174.google.com with SMTP id k5so690907ggd.19
        for <linux-nfs@vger.kernel.org>; Sat, 27 Oct 2012 05:34:41 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v8 30/32] vfs: convert do_file_open_root to use retry_estale helper
Date: Sat, 27 Oct 2012 08:33:37 -0400
Message-Id: <1351341219-17837-31-git-send-email-jlayton@redhat.com>
In-Reply-To: <1351341219-17837-1-git-send-email-jlayton@redhat.com>
References: <1351341219-17837-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/namei.c b/fs/namei.c
index 6930e91..c6173cc 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3028,6 +3028,7 @@ struct file *do_file_open_root(struct dentry *dentry, struct vfsmount *mnt,
 	struct nameidata nd;
 	struct file *file;
 	struct filename filename = { .name = name };
+	unsigned int try = 0;
 
 	nd.root.mnt = mnt;
 	nd.root.dentry = dentry;
@@ -3040,7 +3041,7 @@ struct file *do_file_open_root(struct dentry *dentry, struct vfsmount *mnt,
 	file = path_openat(-1, &filename, &nd, op, flags | LOOKUP_RCU);
 	if (unlikely(file == ERR_PTR(-ECHILD)))
 		file = path_openat(-1, &filename, &nd, op, flags);
-	if (unlikely(file == ERR_PTR(-ESTALE)))
+	while (retry_estale(PTR_ERR(file), try++))
 		file = path_openat(-1, &filename, &nd, op, flags | LOOKUP_REVAL);
 	return file;
 }
-- 
1.7.11.7

