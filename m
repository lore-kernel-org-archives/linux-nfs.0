Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f46.google.com ([209.85.213.46]:55832 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756016Ab2J0MeZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2012 08:34:25 -0400
Received: by mail-yh0-f46.google.com with SMTP id m54so691039yhm.19
        for <linux-nfs@vger.kernel.org>; Sat, 27 Oct 2012 05:34:24 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v8 19/32] vfs: fix user_statfs to retry once on ESTALE errors
Date: Sat, 27 Oct 2012 08:33:26 -0400
Message-Id: <1351341219-17837-20-git-send-email-jlayton@redhat.com>
In-Reply-To: <1351341219-17837-1-git-send-email-jlayton@redhat.com>
References: <1351341219-17837-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/statfs.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/fs/statfs.c b/fs/statfs.c
index f8e832e..7b42ca3 100644
--- a/fs/statfs.c
+++ b/fs/statfs.c
@@ -77,11 +77,19 @@ EXPORT_SYMBOL(vfs_statfs);
 int user_statfs(const char __user *pathname, struct kstatfs *st)
 {
 	struct path path;
-	int error = user_path_at(AT_FDCWD, pathname, LOOKUP_FOLLOW|LOOKUP_AUTOMOUNT, &path);
-	if (!error) {
+	int error;
+	unsigned int try = 0;
+	unsigned int lookup_flags = LOOKUP_FOLLOW|LOOKUP_AUTOMOUNT;
+
+	do {
+		error  = user_path_at(AT_FDCWD, pathname, lookup_flags, &path);
+		if (error)
+			break;
+
 		error = vfs_statfs(&path, st);
 		path_put(&path);
-	}
+		lookup_flags |= LOOKUP_REVAL;
+	} while (retry_estale(error, try++));
 	return error;
 }
 
-- 
1.7.11.7

