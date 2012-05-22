Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:60644 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757615Ab2EVOMf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 May 2012 10:12:35 -0400
Received: by mail-gg0-f174.google.com with SMTP id u4so5398234ggl.19
        for <linux-nfs@vger.kernel.org>; Tue, 22 May 2012 07:12:35 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: inux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, miklos@szeredi.hu, hch@infradead.org,
        michael.brantley@deshaw.com, pstaubach@exagrid.com
Subject: [PATCH v2 05/15] vfs: remove user_path_at_empty
Date: Tue, 22 May 2012 10:12:09 -0400
Message-Id: <1337695939-2741-6-git-send-email-jlayton@redhat.com>
In-Reply-To: <1337695939-2741-1-git-send-email-jlayton@redhat.com>
References: <1337695939-2741-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...there are no more callers.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c            |   12 +++---------
 include/linux/namei.h |    1 -
 2 files changed, 3 insertions(+), 10 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 516be34..f13ba02 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -1900,10 +1900,10 @@ int kern_path_at(int dfd, const char *name, unsigned flags, struct path *path)
 	return err;
 }
 
-int user_path_at_empty(int dfd, const char __user *name, unsigned flags,
-		 struct path *path, int *empty)
+int user_path_at(int dfd, const char __user *name, unsigned flags,
+		 struct path *path)
 {
-	char *tmp = getname_flags(name, flags, empty);
+	char *tmp = getname_flags(name, flags, NULL);
 	int err;
 
 	if (IS_ERR(tmp)) {
@@ -1915,12 +1915,6 @@ int user_path_at_empty(int dfd, const char __user *name, unsigned flags,
 	return err;
 }
 
-int user_path_at(int dfd, const char __user *name, unsigned flags,
-		 struct path *path)
-{
-	return user_path_at_empty(dfd, name, flags, path, NULL);
-}
-
 static int user_path_parent(int dfd, const char __user *path,
 			struct nameidata *nd, char **name)
 {
diff --git a/include/linux/namei.h b/include/linux/namei.h
index cd95fcb..1ea93d5 100644
--- a/include/linux/namei.h
+++ b/include/linux/namei.h
@@ -68,7 +68,6 @@ enum {LAST_NORM, LAST_ROOT, LAST_DOT, LAST_DOTDOT, LAST_BIND};
 
 extern int kern_path_at(int, const char *, unsigned, struct path *);
 extern int user_path_at(int, const char __user *, unsigned, struct path *);
-extern int user_path_at_empty(int, const char __user *, unsigned, struct path *, int *empty);
 
 #define user_path(name, path) user_path_at(AT_FDCWD, name, LOOKUP_FOLLOW, path)
 #define user_lpath(name, path) user_path_at(AT_FDCWD, name, 0, path)
-- 
1.7.7.6

