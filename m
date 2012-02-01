Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qy0-f174.google.com ([209.85.216.174]:46265 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756490Ab2BAPpL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Feb 2012 10:45:11 -0500
Received: by mail-qy0-f174.google.com with SMTP id w6so740319qcq.19
        for <linux-nfs@vger.kernel.org>; Wed, 01 Feb 2012 07:45:11 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v5 7/9] nfsdcld: make it watch for inotify events in the containing directory
Date: Wed,  1 Feb 2012 10:44:54 -0500
Message-Id: <1328111096-28430-8-git-send-email-jlayton@redhat.com>
In-Reply-To: <1328111096-28430-1-git-send-email-jlayton@redhat.com>
References: <1328111096-28430-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Before opening the pipe, set an inotify watch on the containing dir and
then try to open the pipe. If it succeeds, then set up pipe and inotify
events and return success. If it fails with -ENOENT, then just set up
the inotify event and return success. If it fails with any other error
then return the error and the caller can then abort the program.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 configure.ac            |    2 +-
 utils/nfsdcld/nfsdcld.c |  146 +++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 143 insertions(+), 5 deletions(-)

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
index d2a5f2c..9e7a9a5 100644
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
@@ -55,6 +57,8 @@ struct cld_client {
 
 /* global variables */
 static char *pipepath = DEFAULT_CLD_PATH;
+static int 		inotify_fd = -1;
+static struct event	pipedir_event;
 
 static struct option longopts[] =
 {
@@ -76,6 +80,8 @@ usage(char *progname)
 	printf("%s [ -hFd ] [ -p pipe ] [ -s dir ]\n", progname);
 }
 
+#define INOTIFY_EVENT_MAX (sizeof(struct inotify_event) + NAME_MAX)
+
 static int
 cld_pipe_open(struct cld_client *clnt)
 {
@@ -99,18 +105,149 @@ cld_pipe_open(struct cld_client *clnt)
 	return 0;
 }
 
+static void
+cld_inotify_cb(int UNUSED(fd), short which, void *data)
+{
+	int ret;
+	size_t elen;
+	ssize_t rret;
+	char evbuf[INOTIFY_EVENT_MAX];
+	char *dirc = NULL, *pname;
+	struct inotify_event *event = (struct inotify_event *)evbuf;
+	struct cld_client *clnt = data;
+
+	if (which != EV_READ)
+		return;
+
+	xlog(D_GENERAL, "%s: called for EV_READ", __func__);
+
+	dirc = strndup(pipepath, PATH_MAX);
+	if (!dirc) {
+		xlog(L_ERROR, "%s: unable to allocate memory", __func__);
+		goto out;
+	}
+
+	rret = read(inotify_fd, evbuf, INOTIFY_EVENT_MAX);
+	if (rret < 0) {
+		xlog(L_ERROR, "%s: read from inotify fd failed: %m", __func__);
+		goto out;
+	}
+
+	/* check to see if we have a filename in the evbuf */
+	if (!event->len) {
+		xlog(D_GENERAL, "%s: no filename in inotify event", __func__);
+		goto out;
+	}
+
+	pname = basename(dirc);
+	elen = strnlen(event->name, event->len);
+
+	/* does the filename match our pipe? */
+	if (strlen(pname) != elen || memcmp(pname, event->name, elen)) {
+		xlog(D_GENERAL, "%s: wrong filename (%s)", __func__,
+				event->name);
+		goto out;
+	}
+
+	ret = cld_pipe_open(clnt);
+	switch (ret) {
+	case 0:
+		/* readd the event for the cl_event pipe */
+		event_add(&clnt->cl_event, NULL);
+		break;
+	case -ENOENT:
+		/* pipe must have disappeared, wait for it to come back */
+		goto out;
+	default:
+		/* anything else is fatal */
+		xlog(L_FATAL, "%s: unable to open new pipe (%d). Aborting.",
+			ret, __func__);
+		exit(ret);
+	}
+
+out:
+	event_add(&pipedir_event, NULL);
+	free(dirc);
+}
+
+static int
+cld_inotify_setup(void)
+{
+	int ret;
+	char *dirc, *dname;
+
+	dirc = strndup(pipepath, PATH_MAX);
+	if (!dirc) {
+		xlog_err("%s: unable to allocate memory", __func__);
+		ret = -ENOMEM;
+		goto out_free;
+	}
+
+	dname = dirname(dirc);
+
+	inotify_fd = inotify_init();
+	if (inotify_fd < 0) {
+		xlog_err("%s: inotify_init failed: %m", __func__);
+		ret = -errno;
+		goto out_free;
+	}
+
+	ret = inotify_add_watch(inotify_fd, dname, IN_CREATE);
+	if (ret < 0) {
+		xlog_err("%s: inotify_add_watch failed: %m", __func__);
+		ret = -errno;
+		goto out_err;
+	}
+
+out_free:
+	free(dirc);
+	return 0;
+out_err:
+	close(inotify_fd);
+	goto out_free;
+}
+
+/*
+ * Set an inotify watch on the directory that should contain the pipe, and then
+ * try to open it. If it fails with anything but -ENOENT, return the error
+ * immediately.
+ *
+ * If it succeeds, then set up the pipe event handler. At that point, set up
+ * the inotify event handler and go ahead and return success.
+ */
 static int
 cld_pipe_init(struct cld_client *clnt)
 {
 	int ret;
 
+	xlog(D_GENERAL, "%s: init pipe handlers", __func__);
+
+	ret = cld_inotify_setup();
+	if (ret != 0)
+		goto out;
+
 	clnt->cl_fd = -1;
 	ret = cld_pipe_open(clnt);
-	if (ret)
-		return ret;
+	switch (ret) {
+	case 0:
+		/* add the event and we're good to go */
+		event_add(&clnt->cl_event, NULL);
+		break;
+	case -ENOENT:
+		/* ignore this error -- cld_inotify_cb will handle it */
+		ret = 0;
+		break;
+	default:
+		/* anything else is fatal */
+		close(inotify_fd);
+		goto out;
+	}
 
-	event_add(&clnt->cl_event, NULL);
-	return 0;
+	/* set event for inotify read */
+	event_set(&pipedir_event, inotify_fd, EV_READ, cld_inotify_cb, clnt);
+	event_add(&pipedir_event, NULL);
+out:
+	return ret;
 }
 
 static void
@@ -384,6 +521,7 @@ main(int argc, char **argv)
 		xlog(L_ERROR, "%s: event_dispatch failed: %m", __func__);
 
 	close(clnt.cl_fd);
+	close(inotify_fd);
 out:
 	free(progname);
 	return rc;
-- 
1.7.7.6

