From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] nfs-utils: fix endptr check in closeall (try #3)
Date: Wed,  3 Jun 2009 16:06:29 -0400
Message-ID: <1244059589-10494-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:53713 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751409AbZFCUGd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Jun 2009 16:06:33 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Third attempt...this gets rid of the mixed declarations and code that
the second patch introduced.

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
 support/nfs/closeall.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/support/nfs/closeall.c b/support/nfs/closeall.c
index cc7fb3b..3bdd2b6 100644
--- a/support/nfs/closeall.c
+++ b/support/nfs/closeall.c
@@ -7,19 +7,23 @@
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
+			if (!errno && *endp == '\0' && n >= min && n != dfd)
 				(void) close(n);
 		}
 		closedir(dir);
-- 
1.6.2.2

