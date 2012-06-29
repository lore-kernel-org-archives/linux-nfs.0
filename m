Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f42.google.com ([209.85.213.42]:40749 "EHLO
	mail-yw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932777Ab2F2S63 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jun 2012 14:58:29 -0400
Received: by mail-yw0-f42.google.com with SMTP id q11so4407178yhf.1
        for <linux-nfs@vger.kernel.org>; Fri, 29 Jun 2012 11:58:28 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v3 15/17] vfs: remove user_path_parent
Date: Fri, 29 Jun 2012 14:57:58 -0400
Message-Id: <1340996280-27123-16-git-send-email-jlayton@redhat.com>
In-Reply-To: <1340996280-27123-1-git-send-email-jlayton@redhat.com>
References: <1340996280-27123-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...there are no more callers.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c |   18 ------------------
 1 files changed, 0 insertions(+), 18 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index b38d734..7c03af9 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -1941,24 +1941,6 @@ int user_path_at(int dfd, const char __user *name, unsigned flags,
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
1.7.7.6

