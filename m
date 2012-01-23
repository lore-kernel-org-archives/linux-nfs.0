Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qw0-f46.google.com ([209.85.216.46]:60023 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754066Ab2AWUC2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jan 2012 15:02:28 -0500
Received: by mail-qw0-f46.google.com with SMTP id c10so2031574qad.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Jan 2012 12:02:27 -0800 (PST)
MIME-Version: 1.0
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 08/11] nfsdcld: allow daemon to wait for pipe to show up
Date: Mon, 23 Jan 2012 15:02:08 -0500
Message-Id: <1327348931-785-9-git-send-email-jlayton@redhat.com>
In-Reply-To: <1327348931-785-1-git-send-email-jlayton@redhat.com>
References: <1327348931-785-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use inotify to set a watch for IN_CREATE events in the nfsd rpc_pipefs
directory. Then, try to open the pipe. If that fails with -ENOENT, then
wait for an inotify event. When one comes in, then retry opening the
pipe.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 configure.ac            |    2 +-
 utils/nfsdcld/nfsdcld.c |   54 +++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 51 insertions(+), 5 deletions(-)

diff --git a/configure.ac b/configure.ac
index 134b609..191a72a 100644
--- a/configure.ac
+++ b/configure.ac
@@ -270,7 +270,7 @@ if test "$enable_nfsv4" = yes; then
   AC_SQLITE3_VERS
 
   if test "$enable_nfsdcld" = "yes"; then
-    AC_CHECK_HEADERS([linux/nfsd/cld.h], ,
+    AC_CHECK_HEADERS([linux/nfsd/cld.h libgen.h sys/inotify.h], ,
 		     AC_MSG_ERROR([Cannot find header needed for nfsdcld]))
 
     if test "$libsqlite3_cv_is_recent" != "yes" ; then
diff --git a/utils/nfsdcld/nfsdcld.c b/utils/nfsdcld/nfsdcld.c
index afc53d2..b0c08e2 100644
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
@@ -76,18 +78,62 @@ usage(char *progname)
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
+	char *dirc, *dname;
+	char event[INOTIFY_EVENT_MAX];
+
+	clnt->cl_fd = -1;
+	dirc = strndup(pipepath, PATH_MAX);
+	if (!dirc) {
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
 	return clnt->cl_fd;
 }
 
-- 
1.7.7.5

