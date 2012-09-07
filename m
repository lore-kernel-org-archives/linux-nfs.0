Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f46.google.com ([209.85.212.46]:43357 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760781Ab2IGOTH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Sep 2012 10:19:07 -0400
Received: by mail-vb0-f46.google.com with SMTP id ff1so3363754vbb.19
        for <linux-nfs@vger.kernel.org>; Fri, 07 Sep 2012 07:19:06 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v6 11/20] vfs: make do_unlinkat retry on ESTALE errors
Date: Fri,  7 Sep 2012 10:18:18 -0400
Message-Id: <1347027507-20956-12-git-send-email-jlayton@redhat.com>
In-Reply-To: <1347027507-20956-1-git-send-email-jlayton@redhat.com>
References: <1347027507-20956-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/fs/namei.c b/fs/namei.c
index a9dd63f..77c2b1055 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3446,8 +3446,11 @@ static long do_unlinkat(int dfd, const char __user *pathname)
 	struct dentry *dentry;
 	struct nameidata nd;
 	struct inode *inode = NULL;
+	unsigned int try = 0;
+	unsigned int lookup_flags = LOOKUP_PARENT;
 
-	name = user_path_parent(dfd, pathname, &nd, 0);
+retry:
+	name = user_path_parent(dfd, pathname, &nd, try);
 	if (IS_ERR(name))
 		return PTR_ERR(name);
 
@@ -3485,6 +3488,10 @@ exit2:
 exit1:
 	path_put(&nd.path);
 	putname(name);
+	if (retry_estale(error, try++)) {
+		lookup_flags |= LOOKUP_REVAL;
+		goto retry;
+	}
 	return error;
 
 slashes:
-- 
1.7.11.4

