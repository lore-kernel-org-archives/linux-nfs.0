Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51757 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756468Ab0BPQM1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Feb 2010 11:12:27 -0500
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: libtirpc-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org
Subject: [PATCH] libtirpc: handle large numbers of supplimental groups gracefully
Date: Tue, 16 Feb 2010 11:12:18 -0500
Message-Id: <1266336738-9611-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

If authunix_create_default() is called by a user with more than 16
supplimental groups, it'll abort(), which causes the program to
crash and coredump.

Fix it to handle this situation gracefully. Get the number of
groups that the user has first, and then allocate a big enough
buffer to hold them. Then, just don't let the lower function use
more than the NGRPS groups.

Also fix up the error handling in this function so that it just
returns a NULL pointer on error and logs a message via warnx()
instead of calling abort().

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 src/auth_unix.c |   61 +++++++++++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 55 insertions(+), 6 deletions(-)

diff --git a/src/auth_unix.c b/src/auth_unix.c
index 71ca15d..4ac1263 100644
--- a/src/auth_unix.c
+++ b/src/auth_unix.c
@@ -49,6 +49,7 @@
 #include <stdlib.h>
 #include <unistd.h>
 #include <string.h>
+#include <errno.h>
 
 #include <rpc/types.h>
 #include <rpc/xdr.h>
@@ -175,20 +176,68 @@ AUTH *
 authunix_create_default()
 {
 	int len;
+	size_t bufsize = 0;
 	char machname[MAXHOSTNAMELEN + 1];
 	uid_t uid;
 	gid_t gid;
-	gid_t gids[NGRPS];
+	gid_t *gids = NULL;
+	AUTH *auth;
+
+	if (gethostname(machname, sizeof machname) == -1) {
+		warnx("%s: gethostname() failed: %s", __func__,
+			strerror(errno));
+		return NULL;
+	}
 
-	if (gethostname(machname, sizeof machname) == -1)
-		abort();
 	machname[sizeof(machname) - 1] = 0;
 	uid = geteuid();
 	gid = getegid();
-	if ((len = getgroups(NGRPS, gids)) < 0)
-		abort();
+
+retry:
+	if ((len = getgroups(0, NULL)) < 0) {
+		warnx("%s: failed to get number of groups: %s", __func__,
+			strerror(errno));
+		return NULL;
+	}
+
+	/* paranoia -- never pass a buffer smaller than NGRPS */
+	bufsize = (len < NGRPS ? NGRPS : len) * sizeof(gid_t);
+	gids = mem_alloc(bufsize);
+	if (gids == NULL) {
+		warnx("%s: memory allocation failed: %s", __func__,
+			strerror(ENOMEM));
+		return gids;
+	}
+
+	if (len == 0)
+		goto no_groups;
+
+	len = getgroups(len, gids);
+	if (len < 0) {
+		mem_free(gids, bufsize);
+		/*
+		 * glibc mentions that it's possible for the number of groups
+		 * to change between two getgroups calls. If that happens,
+		 * retry the whole thing again.
+		 */
+		if (len == -EINVAL) {
+			gids = NULL;
+			bufsize = 0;
+			goto retry;
+		}
+		warnx("%s: failed to get group list: %s", __func__,
+			strerror(errno));
+		return NULL;
+	}
+
+	if (len > NGRPS)
+		len = NGRPS;
+
+no_groups:
 	/* XXX: interface problem; those should all have been unsigned */
-	return (authunix_create(machname, uid, gid, len, gids));
+	auth = authunix_create(machname, uid, gid, len, gids);
+	mem_free(gids, bufsize);
+	return auth;
 }
 
 /*
-- 
1.6.6

