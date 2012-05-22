Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:37481 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757819Ab2EVOMs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 May 2012 10:12:48 -0400
Received: by yhmm54 with SMTP id m54so5459373yhm.19
        for <linux-nfs@vger.kernel.org>; Tue, 22 May 2012 07:12:47 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: inux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, miklos@szeredi.hu, hch@infradead.org,
        michael.brantley@deshaw.com, pstaubach@exagrid.com
Subject: [PATCH v2 13/15] vfs: make do_unlinkat retry on ESTALE errors
Date: Tue, 22 May 2012 10:12:17 -0400
Message-Id: <1337695939-2741-14-git-send-email-jlayton@redhat.com>
In-Reply-To: <1337695939-2741-1-git-send-email-jlayton@redhat.com>
References: <1337695939-2741-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index a11fcc7..486a60a 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2888,8 +2888,14 @@ static long do_unlinkat(int dfd, const char __user *pathname)
 	struct dentry *dentry;
 	struct nameidata nd;
 	struct inode *inode = NULL;
+	unsigned int try = 0;
+	unsigned int lookup_flags = LOOKUP_PARENT;
 
-	error = user_path_parent(dfd, pathname, &nd, &name);
+	name = getname(pathname);
+	if (IS_ERR(name))
+		return PTR_ERR(name);
+retry:
+	error = do_path_lookup(dfd, name, lookup_flags, &nd);
 	if (error)
 		return error;
 
@@ -2927,6 +2933,10 @@ exit3:
 		iput(inode);	/* truncate the inode here */
 exit1:
 	path_put(&nd.path);
+	if (retry_estale(error, try++)) {
+		lookup_flags |= LOOKUP_REVAL;
+		goto retry;
+	}
 	putname(name);
 	return error;
 
-- 
1.7.7.6

