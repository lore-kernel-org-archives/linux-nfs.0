From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] nfs-utils: fix endptr check in closeall (try #2)
Date: Wed,  3 Jun 2009 15:44:41 -0400
Message-ID: <1244058281-10228-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:59979 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751977AbZFCToo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Jun 2009 15:44:44 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The closeall function is broken in such a way that it almost never
closes any file descriptors. It's calling strtol on the text
representation of the file descriptor, and then checking to see if the
value of *endptr is not '\0' before trying to close the file. This check
is wrong.

When strtol returns an endptr that points to a NULL byte, that indicates
that the conversion was completely successful. I believe this check
should instead be requiring that endptr is pointing to '\0' before closing
the fd.

Also, fix up the function to check for conversion errors from strtol. If
one occurs, just skip the close on that entry.

Reported-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 support/nfs/closeall.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/support/nfs/closeall.c b/support/nfs/closeall.c
index cc7fb3b..5fe07de 100644
--- a/support/nfs/closeall.c
+++ b/support/nfs/closeall.c
@@ -7,6 +7,7 @@
 #include <unistd.h>
 #include <stdlib.h>
 #include <dirent.h>
+#include <errno.h>
 
 void
 closeall(int min)
@@ -18,8 +19,9 @@ closeall(int min)
 
 		while ((d = readdir(dir)) != NULL) {
 			char *endp;
+			errno = 0;
 			long n = strtol(d->d_name, &endp, 10);
-			if (*endp != '\0' && n >= min && n != dfd)
+			if (!errno && *endp == '\0' && n >= min && n != dfd)
 				(void) close(n);
 		}
 		closedir(dir);
-- 
1.6.0.6

