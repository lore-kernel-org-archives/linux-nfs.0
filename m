From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] nfs-utils: fix endptr check in closeall (try #4)
Date: Thu,  4 Jun 2009 07:53:07 -0400
Message-ID: <1244116387-19827-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com,
	trond.myklebust@fys.uio.no
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:53166 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757187AbZFDLxR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Jun 2009 07:53:17 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The closeall function is broken in such a way that it almost never
closes any file descriptors. It's calling strtol on the text
representation of the file descriptor, and then checking to see if the
value of *endptr is not '\0' before trying to close the file. This check
is wrong.

When strtol returns an endptr that points to a NULL byte, that indicates
that the conversion was completely successful. I believe this check
should instead be requiring that endptr is pointing to '\0' before
closing the fd.

Also, fix up the function to check for conversion errors from strtol. If
one occurs, just skip the close on that entry.

Finally, as Trond pointed out, it's unlikely that readdir will return a
blank string in d_name but that situation wouldn't be detected by the
current code. This patch adds such a check and skips the close if it
occurs.

Reported-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 support/nfs/closeall.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/support/nfs/closeall.c b/support/nfs/closeall.c
index cc7fb3b..38fb162 100644
--- a/support/nfs/closeall.c
+++ b/support/nfs/closeall.c
@@ -7,19 +7,24 @@
 #include <unistd.h>
 #include <stdlib.h>
 #include <dirent.h>
+#include <errno.h>
 
 void
 closeall(int min)
 {
+	char *endp;
+	long n;
 	DIR *dir = opendir("/proc/self/fd");
+
 	if (dir != NULL) {
 		int dfd = dirfd(dir);
 		struct dirent *d;
 
 		while ((d = readdir(dir)) != NULL) {
-			char *endp;
-			long n = strtol(d->d_name, &endp, 10);
-			if (*endp != '\0' && n >= min && n != dfd)
+			errno = 0;
+			n = strtol(d->d_name, &endp, 10);
+			if (!errno && *endp == '\0' && endp != d->d_name &&
+			    n >= min && n != dfd)
 				(void) close(n);
 		}
 		closedir(dir);
-- 
1.6.0.6

