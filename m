Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:2842 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752134Ab1LUUf0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Dec 2011 15:35:26 -0500
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org, steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 08/10] nfsdcld: allow daemon to wait for pipe to show up
Date: Wed, 21 Dec 2011 15:35:20 -0500
Message-Id: <1324499722-10363-9-git-send-email-jlayton@redhat.com>
In-Reply-To: <1324499722-10363-1-git-send-email-jlayton@redhat.com>
References: <1324499722-10363-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use inotify to set a watch for IN_CREATE events in the nfsd rpc_pipefs
directory. Then, try to open the pipe. If that fails with -ENOENT, then
wait for an inotify event. When one comes in, then retry opening the
pipe.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 configure.ac            |    2 +-
 utils/nfsdcld/nfsdcld.c |   55 +++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 52 insertions(+), 5 deletions(-)

diff --git a/configure.ac b/configure.ac
index e43ec3e..2b202cb 100644
--- a/configure.ac
+++ b/configure.ac
@@ -269,7 +269,7 @@ if test "$enable_nfsv4" = yes; then
   AC_SQLITE3_VERS
 
   if test "$enable_nfsdcld" = "yes"; then
-    AC_CHECK_HEADERS([linux/nfsd/cld.h], ,
+    AC_CHECK_HEADERS([linux/nfsd/cld.h libgen.h sys/inotify.h], ,
 		     AC_MSG_ERROR([Cannot find header needed for nfsdcld]))
 
     if test "$libsqlite3_cv_is_recent" != "yes" ; then
diff --git a/utils/nfsdcld/nfsdcld.c b/utils/nfsdcld/nfsdcld.c
index b66fe39..d65b2c9 100644
--- a/utils/nfsdcld/nfsdcld.c
+++ b/utils/nfsdcld/nfsdcld.c
@@ -32,6 +32,8 @@
 #include <sys/types.h>
 #include <fcntl.h>
 #include <unistd.h>
+#include <libgen.h>
+#include <sys/inotify.h>
 #include <linux/nfsd/cld.h>
 
 #include "xlog.h"
@@ -76,18 +78,63 @@ usage(char *progname)
 	printf("%s [ -hFd ] [ -p pipe ] [ -s dir ]\n", progname);
 }
 
+#define INOTIFY_EVENT_MAX (sizeof(struct inotify_event) + NAME_MAX)
+
 static int
 cld_pipe_open(struct cld_client *clnt)
 {
-	clnt->cl_fd = open(pipepath, O_RDWR, 0);
-	if (clnt->cl_fd < 0) {
-		xlog(L_ERROR, "%s: unable to open %s: %m", __func__, pipepath);
-		return clnt->cl_fd;
+	int ifd, wat;
+	ssize_t ret;
+	char *dirc, *dname, *event;
+
+	clnt->cl_fd = -1;
+	dirc = strndup(pipepath, PATH_MAX);
+	event = malloc(INOTIFY_EVENT_MAX);
+	if (!dirc || !event) {
+		xlog_err("%s: unable to allocate memory", __func__);
+		goto out_free;
+	}
+
+	dname = dirname(dirc);
+
+	ifd = inotify_init();
+	if (ifd < 0) {
+		xlog_err("%s: inotify_init failed: %m", __func__);
+		goto out_free;
+	}
+
+	wat = inotify_add_watch(ifd, dname, IN_CREATE);
+	if (wat < 0) {
+		xlog_err("%s: inotify_add_watch failed: %m", __func__);
+		goto out;
+	}
+
+	for (;;) {
+		errno = 0;
+		clnt->cl_fd = open(pipepath, O_RDWR, 0);
+		if (clnt->cl_fd >= 0)
+			break;
+		else if (errno != ENOENT) {
+			xlog_err("%s: unable to open %s: %m", __func__,
+					pipepath);
+			goto out;
+		}
+		ret = read(ifd, event, INOTIFY_EVENT_MAX);
+		if (ret < 0) {
+			xlog_err("%s: read from inotify fd failed: %m",
+					__func__);
+			goto out;
+		}
 	}
 
 	event_set(&clnt->cl_event, clnt->cl_fd, EV_READ, cldcb, clnt);
 	event_add(&clnt->cl_event, NULL);
 
+out:
+	close(ifd);
+out_free:
+	free(dirc);
+	free(event);
 	return clnt->cl_fd;
 }
 
-- 
1.7.1

