Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f46.google.com ([209.85.213.46]:48417 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933006Ab2KEPW6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Nov 2012 10:22:58 -0500
Received: by mail-yh0-f46.google.com with SMTP id m54so972001yhm.19
        for <linux-nfs@vger.kernel.org>; Mon, 05 Nov 2012 07:22:58 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v9 20/34] vfs: allow utimensat() calls to retry once on an ESTALE error
Date: Mon,  5 Nov 2012 10:21:59 -0500
Message-Id: <1352128933-28526-21-git-send-email-jlayton@redhat.com>
In-Reply-To: <1352128933-28526-1-git-send-email-jlayton@redhat.com>
References: <1352128933-28526-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clearly, we can't handle the NULL filename case, but we can deal with
the case where there's a real pathname.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/utimes.c | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/fs/utimes.c b/fs/utimes.c
index bb0696a..c9ce931 100644
--- a/fs/utimes.c
+++ b/fs/utimes.c
@@ -154,17 +154,22 @@ long do_utimes(int dfd, const char __user *filename, struct timespec *times,
 		fdput(f);
 	} else {
 		struct path path;
-		int lookup_flags = 0;
+		unsigned int lookup_flags = 0;
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

