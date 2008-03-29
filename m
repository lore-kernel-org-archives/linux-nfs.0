From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 3/3] mount.nfs: get rid of prev_bg_host cruft in nfsmount()
Date: Sat, 29 Mar 2008 16:30:08 -0400
Message-ID: <1206822608-20154-4-git-send-email-jlayton@redhat.com>
References: <1206822608-20154-1-git-send-email-jlayton@redhat.com>
 <1206822608-20154-2-git-send-email-jlayton@redhat.com>
 <1206822608-20154-3-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54734 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754363AbYC2UaN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 29 Mar 2008 16:30:13 -0400
In-Reply-To: <1206822608-20154-3-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The prev_bg_host stuff made sense when NFS didn't have its own mount
handler. Now though, each mount.nfs invocation is really a one-shot
affair, and this check no longer works. It also leaked memory. Remove
it.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/mount/nfsmount.c |   14 --------------
 1 files changed, 0 insertions(+), 14 deletions(-)

diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index 27c46a7..3effcf3 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -494,7 +494,6 @@ int
 nfsmount(const char *spec, const char *node, int flags,
 	 char **extra_opts, int fake, int running_bg)
 {
-	static char *prev_bg_host;
 	char hostdir[1024];
 	char *hostname, *dirname, *old_opts, *mounthost = NULL;
 	char new_opts[1024], cbuf[1024];
@@ -628,18 +627,6 @@ nfsmount(const char *spec, const char *node, int flags,
 	if (flags & MS_REMOUNT)
 		goto out_ok;
 
-	/*
-	 * If the previous mount operation on the same host was
-	 * backgrounded, and the "bg" for this mount is also set,
-	 * give up immediately, to avoid the initial timeout.
-	 */
-	if (bg && !running_bg &&
-	    prev_bg_host && strcmp(hostname, prev_bg_host) == 0) {
-		if (retry > 0)
-			retval = EX_BG;
-		return retval;
-	}
-
 	/* create mount deamon client */
 
 	/*
@@ -708,7 +695,6 @@ nfsmount(const char *spec, const char *node, int flags,
 			continue;
 		}
 		if (!running_bg) {
-			prev_bg_host = xstrdup(hostname);
 			if (retry > 0)
 				retval = EX_BG;
 			goto fail;
-- 
1.5.3.6

