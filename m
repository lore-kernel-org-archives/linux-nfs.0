Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:53136 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758032Ab2EVOMv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 May 2012 10:12:51 -0400
Received: by mail-yw0-f46.google.com with SMTP id m54so5459399yhm.19
        for <linux-nfs@vger.kernel.org>; Tue, 22 May 2012 07:12:50 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: inux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, miklos@szeredi.hu, hch@infradead.org,
        michael.brantley@deshaw.com, pstaubach@exagrid.com
Subject: [PATCH v2 15/15] vfs: remove user_path_parent
Date: Tue, 22 May 2012 10:12:19 -0400
Message-Id: <1337695939-2741-16-git-send-email-jlayton@redhat.com>
In-Reply-To: <1337695939-2741-1-git-send-email-jlayton@redhat.com>
References: <1337695939-2741-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...there are no more callers.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c |   18 ------------------
 1 files changed, 0 insertions(+), 18 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 4d2b810..991306b 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -1915,24 +1915,6 @@ int user_path_at(int dfd, const char __user *name, unsigned flags,
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

