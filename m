Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:38668 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932117Ab2IGO01 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Sep 2012 10:26:27 -0400
Received: by ggdk6 with SMTP id k6so543330ggd.19
        for <linux-nfs@vger.kernel.org>; Fri, 07 Sep 2012 07:26:26 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v6 20/20] vfs: convert do_file_open_root to use retry_estale helper
Date: Fri,  7 Sep 2012 10:18:27 -0400
Message-Id: <1347027507-20956-21-git-send-email-jlayton@redhat.com>
In-Reply-To: <1347027507-20956-1-git-send-email-jlayton@redhat.com>
References: <1347027507-20956-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/namei.c b/fs/namei.c
index 66b24fa..870352d 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3027,6 +3027,7 @@ struct file *do_file_open_root(struct dentry *dentry, struct vfsmount *mnt,
 	struct nameidata nd;
 	struct file *file;
 	struct getname_info ginfo = { .name = name };
+	unsigned int try = 0;
 
 	nd.root.mnt = mnt;
 	nd.root.dentry = dentry;
@@ -3039,7 +3040,7 @@ struct file *do_file_open_root(struct dentry *dentry, struct vfsmount *mnt,
 	file = path_openat(-1, &ginfo, &nd, op, flags | LOOKUP_RCU);
 	if (unlikely(file == ERR_PTR(-ECHILD)))
 		file = path_openat(-1, &ginfo, &nd, op, flags);
-	if (unlikely(file == ERR_PTR(-ESTALE)))
+	while (retry_estale(PTR_ERR(file), try++))
 		file = path_openat(-1, &ginfo, &nd, op, flags | LOOKUP_REVAL);
 	return file;
 }
-- 
1.7.11.4

