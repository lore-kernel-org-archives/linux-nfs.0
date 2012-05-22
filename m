Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:61482 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757582Ab2EVOMd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 May 2012 10:12:33 -0400
Received: by mail-gh0-f174.google.com with SMTP id r11so777867ghr.19
        for <linux-nfs@vger.kernel.org>; Tue, 22 May 2012 07:12:33 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: inux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, miklos@szeredi.hu, hch@infradead.org,
        michael.brantley@deshaw.com, pstaubach@exagrid.com
Subject: [PATCH v2 04/15] vfs: fix readlinkat to retry on ESTALE
Date: Tue, 22 May 2012 10:12:08 -0400
Message-Id: <1337695939-2741-5-git-send-email-jlayton@redhat.com>
In-Reply-To: <1337695939-2741-1-git-send-email-jlayton@redhat.com>
References: <1337695939-2741-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/stat.c |   21 +++++++++++++++++----
 1 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/fs/stat.c b/fs/stat.c
index 60a8813..671106d 100644
--- a/fs/stat.c
+++ b/fs/stat.c
@@ -307,14 +307,25 @@ SYSCALL_DEFINE4(readlinkat, int, dfd, const char __user *, pathname,
 	struct path path;
 	int error;
 	int empty = 0;
+	char *name;
+	unsigned int try = 0;
+	unsigned int lookup_flags = LOOKUP_EMPTY;
 
 	if (bufsiz <= 0)
 		return -EINVAL;
 
-	error = user_path_at_empty(dfd, pathname, LOOKUP_EMPTY, &path, &empty);
-	if (!error) {
-		struct inode *inode = path.dentry->d_inode;
+	name = getname_flags(pathname, lookup_flags, &empty);
+	if (IS_ERR(name))
+		return PTR_ERR(name);
+
+	do {
+		struct inode *inode;
+
+		error = kern_path_at(dfd, name, lookup_flags, &path);
+		if (error)
+			break;
 
+		inode = path.dentry->d_inode;
 		error = empty ? -ENOENT : -EINVAL;
 		if (inode->i_op->readlink) {
 			error = security_inode_readlink(path.dentry);
@@ -325,7 +336,9 @@ SYSCALL_DEFINE4(readlinkat, int, dfd, const char __user *, pathname,
 			}
 		}
 		path_put(&path);
-	}
+		lookup_flags |= LOOKUP_REVAL;
+	} while (retry_estale(error, try++));
+	putname(name);
 	return error;
 }
 
-- 
1.7.7.6

