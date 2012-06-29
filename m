Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:41418 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932556Ab2F2S6J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jun 2012 14:58:09 -0400
Received: by mail-yx0-f174.google.com with SMTP id l2so3038059yen.19
        for <linux-nfs@vger.kernel.org>; Fri, 29 Jun 2012 11:58:09 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v3 02/17] vfs: add a kern_path_at function
Date: Fri, 29 Jun 2012 14:57:45 -0400
Message-Id: <1340996280-27123-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1340996280-27123-1-git-send-email-jlayton@redhat.com>
References: <1340996280-27123-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This will function like user_path_at, but does not do the getname and
putname, leaving that to the caller.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c            |   27 +++++++++++++++++++--------
 include/linux/namei.h |    1 +
 2 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 196f039..3f46b2f 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -1912,20 +1912,31 @@ struct dentry *lookup_one_len(const char *name, struct dentry *base, int len)
 	return __lookup_hash(&this, base, NULL);
 }
 
+int kern_path_at(int dfd, const char *name, unsigned flags, struct path *path)
+{
+	struct nameidata nd;
+	int err;
+
+	BUG_ON(flags & LOOKUP_PARENT);
+
+	err = do_path_lookup(dfd, name, flags, &nd);
+	if (!err)
+		*path = nd.path;
+
+	return err;
+}
+
 int user_path_at_empty(int dfd, const char __user *name, unsigned flags,
 		 struct path *path, int *empty)
 {
-	struct nameidata nd;
 	char *tmp = getname_flags(name, flags, empty);
-	int err = PTR_ERR(tmp);
-	if (!IS_ERR(tmp)) {
-
-		BUG_ON(flags & LOOKUP_PARENT);
+	int err;
 
-		err = do_path_lookup(dfd, tmp, flags, &nd);
+	if (IS_ERR(tmp)) {
+		err = PTR_ERR(tmp);
+	} else {
+		err = kern_path_at(dfd, tmp, flags, path);
 		putname(tmp);
-		if (!err)
-			*path = nd.path;
 	}
 	return err;
 }
diff --git a/include/linux/namei.h b/include/linux/namei.h
index ffc0213..cd95fcb 100644
--- a/include/linux/namei.h
+++ b/include/linux/namei.h
@@ -66,6 +66,7 @@ enum {LAST_NORM, LAST_ROOT, LAST_DOT, LAST_DOTDOT, LAST_BIND};
 #define LOOKUP_ROOT		0x2000
 #define LOOKUP_EMPTY		0x4000
 
+extern int kern_path_at(int, const char *, unsigned, struct path *);
 extern int user_path_at(int, const char __user *, unsigned, struct path *);
 extern int user_path_at_empty(int, const char __user *, unsigned, struct path *, int *empty);
 
-- 
1.7.7.6

