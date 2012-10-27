Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:59451 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756070Ab2J0Me0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2012 08:34:26 -0400
Received: by mail-gg0-f174.google.com with SMTP id k5so690906ggd.19
        for <linux-nfs@vger.kernel.org>; Sat, 27 Oct 2012 05:34:26 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v8 20/32] vfs: allow utimensat() calls to retry once on an ESTALE error
Date: Sat, 27 Oct 2012 08:33:27 -0400
Message-Id: <1351341219-17837-21-git-send-email-jlayton@redhat.com>
In-Reply-To: <1351341219-17837-1-git-send-email-jlayton@redhat.com>
References: <1351341219-17837-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clearly, we can't handle the NULL filename case, but we can deal with
the case where there's a real pathname.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/utimes.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/fs/utimes.c b/fs/utimes.c
index bb0696a..2b91adc2 100644
--- a/fs/utimes.c
+++ b/fs/utimes.c
@@ -155,16 +155,21 @@ long do_utimes(int dfd, const char __user *filename, struct timespec *times,
 	} else {
 		struct path path;
 		int lookup_flags = 0;
+		unsigned int try = 0;
 
 		if (!(flags & AT_SYMLINK_NOFOLLOW))
 			lookup_flags |= LOOKUP_FOLLOW;
 
-		error = user_path_at(dfd, filename, lookup_flags, &path);
-		if (error)
-			goto out;
+		do {
+			error = user_path_at(dfd, filename,
+						lookup_flags, &path);
+			if (error)
+				break;
 
-		error = utimes_common(&path, times);
-		path_put(&path);
+			error = utimes_common(&path, times);
+			path_put(&path);
+			lookup_flags |= LOOKUP_REVAL;
+		} while (retry_estale(error, try++));
 	}
 
 out:
-- 
1.7.11.7

