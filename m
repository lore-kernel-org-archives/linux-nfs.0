Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:58363 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752558Ab2GZLzt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jul 2012 07:55:49 -0400
Received: by mail-yx0-f174.google.com with SMTP id l2so1826947yen.19
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jul 2012 04:55:49 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v4 15/17] vfs: remove user_path_parent
Date: Thu, 26 Jul 2012 07:55:18 -0400
Message-Id: <1343303720-11199-16-git-send-email-jlayton@redhat.com>
In-Reply-To: <1343303720-11199-1-git-send-email-jlayton@redhat.com>
References: <1343303720-11199-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...there are no more callers.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c | 18 ------------------
 1 file changed, 18 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 7cf5e91..862ec6f 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2003,24 +2003,6 @@ int user_path_at(int dfd, const char __user *name, unsigned flags,
 	return err;
 }
 
-static int user_path_parent(int dfd, const char __user *path,
-			struct nameidata *nd, char **name)
-{
-	char *s = getname(path);
-	int error;
-
-	if (IS_ERR(s))
-		return PTR_ERR(s);
-
-	error = do_path_lookup(dfd, s, LOOKUP_PARENT, nd);
-	if (error)
-		putname(s);
-	else
-		*name = s;
-
-	return error;
-}
-
 /*
  * It's inline, so penalty for filesystems that don't use sticky bit is
  * minimal.
-- 
1.7.11.2

