Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:63391 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752440Ab2GZLzq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jul 2012 07:55:46 -0400
Received: by gglu4 with SMTP id u4so1821343ggl.19
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jul 2012 04:55:46 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v4 13/17] vfs: make do_unlinkat retry on ESTALE errors
Date: Thu, 26 Jul 2012 07:55:16 -0400
Message-Id: <1343303720-11199-14-git-send-email-jlayton@redhat.com>
In-Reply-To: <1343303720-11199-1-git-send-email-jlayton@redhat.com>
References: <1343303720-11199-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/fs/namei.c b/fs/namei.c
index 09427f2..65e5177 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3262,8 +3262,14 @@ static long do_unlinkat(int dfd, const char __user *pathname)
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
 
@@ -3301,6 +3307,10 @@ exit3:
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
1.7.11.2

