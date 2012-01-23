Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qw0-f46.google.com ([209.85.216.46]:60023 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754066Ab2AWUC3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jan 2012 15:02:29 -0500
Received: by mail-qw0-f46.google.com with SMTP id c10so2031574qad.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Jan 2012 12:02:29 -0800 (PST)
MIME-Version: 1.0
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 09/11] nfsdcld: reopen pipe if it's deleted and recreated
Date: Mon, 23 Jan 2012 15:02:09 -0500
Message-Id: <1327348931-785-10-git-send-email-jlayton@redhat.com>
In-Reply-To: <1327348931-785-1-git-send-email-jlayton@redhat.com>
References: <1327348931-785-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This can happen if nfsd is shut down and restarted. If that occurs,
then reopen the pipe so we're not waiting for data on the defunct
pipe.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/nfsdcld/nfsdcld.c |   84 +++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 74 insertions(+), 10 deletions(-)

diff --git a/utils/nfsdcld/nfsdcld.c b/utils/nfsdcld/nfsdcld.c
index b0c08e2..0dc5b37 100644
--- a/utils/nfsdcld/nfsdcld.c
+++ b/utils/nfsdcld/nfsdcld.c
@@ -57,6 +57,8 @@ struct cld_client {
 
 /* global variables */
 static char *pipepath = DEFAULT_CLD_PATH;
+static int 		inotify_fd = -1;
+static struct event	pipedir_event;
 
 static struct option longopts[] =
 {
@@ -68,8 +70,10 @@ static struct option longopts[] =
 	{ NULL, 0, 0, 0 },
 };
 
+
 /* forward declarations */
 static void cldcb(int UNUSED(fd), short which, void *data);
+static void cld_pipe_reopen(struct cld_client *clnt);
 
 static void
 usage(char *progname)
@@ -80,10 +84,62 @@ usage(char *progname)
 
 #define INOTIFY_EVENT_MAX (sizeof(struct inotify_event) + NAME_MAX)
 
+static void
+cld_inotify_cb(int UNUSED(fd), short which, void *data)
+{
+	int ret, oldfd;
+	char evbuf[INOTIFY_EVENT_MAX];
+	char *dirc = NULL, *pname;
+	struct inotify_event *event = (struct inotify_event *)evbuf;
+	struct cld_client *clnt = data;
+
+	if (which != EV_READ)
+		return;
+
+	dirc = strndup(pipepath, PATH_MAX);
+	if (!dirc) {
+		xlog_err("%s: unable to allocate memory", __func__);
+		goto out;
+	}
+
+	ret = read(inotify_fd, evbuf, INOTIFY_EVENT_MAX);
+	if (ret < 0) {
+		xlog_err("%s: read from inotify fd failed: %m", __func__);
+		goto out;
+	}
+
+	/* check to see if we have a filename in the evbuf */
+	if (!event->len)
+		goto out;
+
+	pname = basename(dirc);
+
+	/* does the filename match our pipe? */
+	if (strncmp(pname, event->name, event->len))
+		goto out;
+
+	/*
+	 * reopen the pipe. The old fd is not closed until the new one is
+	 * opened, so we know they should be different if the reopen is
+	 * successful.
+	 */
+	oldfd = clnt->cl_fd;
+	do {
+		cld_pipe_reopen(clnt);
+	} while (oldfd == clnt->cl_fd);
+
+	/* readd the event for the cl_event pipe */
+	event_add(&clnt->cl_event, NULL);
+
+out:
+	event_add(&pipedir_event, NULL);
+	free(dirc);
+}
+
 static int
 cld_pipe_open(struct cld_client *clnt)
 {
-	int ifd, wat;
+	int wat;
 	ssize_t ret;
 	char *dirc, *dname;
 	char event[INOTIFY_EVENT_MAX];
@@ -97,16 +153,16 @@ cld_pipe_open(struct cld_client *clnt)
 
 	dname = dirname(dirc);
 
-	ifd = inotify_init();
-	if (ifd < 0) {
+	inotify_fd = inotify_init();
+	if (inotify_fd < 0) {
 		xlog_err("%s: inotify_init failed: %m", __func__);
 		goto out_free;
 	}
 
-	wat = inotify_add_watch(ifd, dname, IN_CREATE);
+	wat = inotify_add_watch(inotify_fd, dname, IN_CREATE);
 	if (wat < 0) {
 		xlog_err("%s: inotify_add_watch failed: %m", __func__);
-		goto out;
+		goto out_err;
 	}
 
 	for (;;) {
@@ -117,24 +173,31 @@ cld_pipe_open(struct cld_client *clnt)
 		else if (errno != ENOENT) {
 			xlog_err("%s: unable to open %s: %m", __func__,
 					pipepath);
-			goto out;
+			goto out_err;
 		}
-		ret = read(ifd, event, INOTIFY_EVENT_MAX);
+		ret = read(inotify_fd, event, INOTIFY_EVENT_MAX);
 		if (ret < 0) {
 			xlog_err("%s: read from inotify fd failed: %m",
 					__func__);
-			goto out;
+			goto out_err;
 		}
 	}
 
+	/* set event for the pipe reads */
 	event_set(&clnt->cl_event, clnt->cl_fd, EV_READ, cldcb, clnt);
 	event_add(&clnt->cl_event, NULL);
 
-out:
-	close(ifd);
+	/* another event for inotify read */
+	event_set(&pipedir_event, inotify_fd, EV_READ, cld_inotify_cb, clnt);
+	event_add(&pipedir_event, NULL);
+
 out_free:
 	free(dirc);
 	return clnt->cl_fd;
+
+out_err:
+	close(inotify_fd);
+	goto out_free;
 }
 
 static void
@@ -142,6 +205,7 @@ cld_pipe_reopen(struct cld_client *clnt)
 {
 	int fd;
 
+	xlog(D_GENERAL, "%s: reopening pipe", __func__);
 	fd = open(pipepath, O_RDWR, 0);
 	if (fd < 0) {
 		xlog_warn("%s: Re-opening of %s failed: %m",
-- 
1.7.7.5

