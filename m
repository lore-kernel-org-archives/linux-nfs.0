From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] nfs-utils: fix endptr check in closeall
Date: Wed,  3 Jun 2009 12:07:22 -0400
Message-ID: <1244045242-8853-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:40239 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752488AbZFCQH1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Jun 2009 12:07:27 -0400
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

Reported-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 support/nfs/closeall.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/support/nfs/closeall.c b/support/nfs/closeall.c
index cc7fb3b..4c93882 100644
--- a/support/nfs/closeall.c
+++ b/support/nfs/closeall.c
@@ -19,7 +19,7 @@ closeall(int min)
 		while ((d = readdir(dir)) != NULL) {
 			char *endp;
 			long n = strtol(d->d_name, &endp, 10);
-			if (*endp != '\0' && n >= min && n != dfd)
+			if (*endp == '\0' && n >= min && n != dfd)
 				(void) close(n);
 		}
 		closedir(dir);
-- 
1.6.2.2

