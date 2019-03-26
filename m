Return-Path: <SRS0=uQmJ=R5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A7FDC10F06
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Mar 2019 22:07:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DC4BC2075D
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Mar 2019 22:07:34 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731535AbfCZWHd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 26 Mar 2019 18:07:33 -0400
Received: from mx1.redhat.com ([209.132.183.28]:45530 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1731589AbfCZWHc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 26 Mar 2019 18:07:32 -0400
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 7974931688F7;
        Tue, 26 Mar 2019 22:07:31 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-122-200.rdu2.redhat.com [10.10.122.200])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 2E78C600C1;
        Tue, 26 Mar 2019 22:07:31 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id C8BE620C54; Tue, 26 Mar 2019 18:07:30 -0400 (EDT)
From:   Scott Mayhew <smayhew@redhat.com>
To:     steved@redhat.com
Cc:     bfields@fieldses.org, jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH RFC v3 1/8] Revert "nfsdcltrack: remove the nfsdcld daemon"
Date:   Tue, 26 Mar 2019 18:07:23 -0400
Message-Id: <20190326220730.3763-2-smayhew@redhat.com>
In-Reply-To: <20190326220730.3763-1-smayhew@redhat.com>
References: <20190326220730.3763-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Tue, 26 Mar 2019 22:07:31 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This reverts commit 2cf11ec6ed261ef56bbd0d73ff404fe69f1fefb0.

nfsdcld was originally deprecated in favor of a usermodehelper, so as to
not require another running daemon.  But that turned out to make
namespaced nfsd's too difficult, so this commit brings back nfsdcld.

A few things have been changed since nfsdcld was removed in 2012:

- libnfs.a is now libnfs.la
- sqlite_insert_client and sqlite_check_client both take a bool
  has_session which is being hard-coded to false for now.
- sqlite_insert_client also takes a bool zerotime which is being
  hard-coded to false.
- an xlog() call whose arguments did not match the format string
  (and could crash nfsdcld) has been fixed
- cld_pipe_open() now calls event_initialized() rather than checking for
  EVLIST_INIT directly (which does not compile with newer versions
  of libevent).

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 .gitignore                    |   1 +
 utils/nfsdcltrack/Makefile.am |   7 +-
 utils/nfsdcltrack/nfsdcld.c   | 611 ++++++++++++++++++++++++++++++++++
 utils/nfsdcltrack/nfsdcld.man | 185 ++++++++++
 4 files changed, 802 insertions(+), 2 deletions(-)
 create mode 100644 utils/nfsdcltrack/nfsdcld.c
 create mode 100644 utils/nfsdcltrack/nfsdcld.man

diff --git a/.gitignore b/.gitignore
index e91e7a2..d4f4f34 100644
--- a/.gitignore
+++ b/.gitignore
@@ -54,6 +54,7 @@ utils/rquotad/rquotad
 utils/rquotad/rquota.h
 utils/rquotad/rquota_xdr.c
 utils/showmount/showmount
+utils/nfsdcltrack/nfsdcld
 utils/nfsdcltrack/nfsdcltrack
 utils/statd/statd
 tools/locktest/testlk
diff --git a/utils/nfsdcltrack/Makefile.am b/utils/nfsdcltrack/Makefile.am
index 2f7fe3d..0f599c0 100644
--- a/utils/nfsdcltrack/Makefile.am
+++ b/utils/nfsdcltrack/Makefile.am
@@ -4,11 +4,14 @@
 # overridden at config time. The kernel "knows" the /sbin name.
 sbindir = /sbin
 
-man8_MANS	= nfsdcltrack.man
+man8_MANS	= nfsdcld.man nfsdcltrack.man
 EXTRA_DIST	= $(man8_MANS)
 
 AM_CFLAGS	+= -D_LARGEFILE64_SOURCE
-sbin_PROGRAMS	= nfsdcltrack
+sbin_PROGRAMS	= nfsdcld nfsdcltrack
+
+nfsdcld_SOURCES = nfsdcld.c sqlite.c
+nfsdcld_LDADD = ../../support/nfs/libnfs.la $(LIBEVENT) $(LIBSQLITE) $(LIBCAP)
 
 noinst_HEADERS	= sqlite.h
 
diff --git a/utils/nfsdcltrack/nfsdcld.c b/utils/nfsdcltrack/nfsdcld.c
new file mode 100644
index 0000000..082f3ab
--- /dev/null
+++ b/utils/nfsdcltrack/nfsdcld.c
@@ -0,0 +1,611 @@
+/*
+ * nfsdcld.c -- NFSv4 client name tracking daemon
+ *
+ * Copyright (C) 2011  Red Hat, Jeff Layton <jlayton@redhat.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor,
+ * Boston, MA 02110-1301, USA.
+ */
+
+#ifdef HAVE_CONFIG_H
+#include "config.h"
+#endif /* HAVE_CONFIG_H */
+
+#include <errno.h>
+#include <event.h>
+#include <stdbool.h>
+#include <getopt.h>
+#include <string.h>
+#include <sys/stat.h>
+#include <sys/types.h>
+#include <fcntl.h>
+#include <unistd.h>
+#include <libgen.h>
+#include <sys/inotify.h>
+#ifdef HAVE_SYS_CAPABILITY_H
+#include <sys/prctl.h>
+#include <sys/capability.h>
+#endif
+
+#include "xlog.h"
+#include "nfslib.h"
+#include "cld.h"
+#include "sqlite.h"
+
+#ifndef PIPEFS_DIR
+#define PIPEFS_DIR NFS_STATEDIR "/rpc_pipefs"
+#endif
+
+#define DEFAULT_CLD_PATH	PIPEFS_DIR "/nfsd/cld"
+
+#ifndef CLD_DEFAULT_STORAGEDIR
+#define CLD_DEFAULT_STORAGEDIR NFS_STATEDIR "/nfsdcld"
+#endif
+
+#define UPCALL_VERSION		1
+
+/* private data structures */
+struct cld_client {
+	int			cl_fd;
+	struct event		cl_event;
+	struct cld_msg	cl_msg;
+};
+
+/* global variables */
+static char *pipepath = DEFAULT_CLD_PATH;
+static int 		inotify_fd = -1;
+static struct event	pipedir_event;
+
+static struct option longopts[] =
+{
+	{ "help", 0, NULL, 'h' },
+	{ "foreground", 0, NULL, 'F' },
+	{ "debug", 0, NULL, 'd' },
+	{ "pipe", 1, NULL, 'p' },
+	{ "storagedir", 1, NULL, 's' },
+	{ NULL, 0, 0, 0 },
+};
+
+/* forward declarations */
+static void cldcb(int UNUSED(fd), short which, void *data);
+
+static void
+usage(char *progname)
+{
+	printf("%s [ -hFd ] [ -p pipe ] [ -s dir ]\n", progname);
+}
+
+static int
+cld_set_caps(void)
+{
+	int ret = 0;
+#ifdef HAVE_SYS_CAPABILITY_H
+	unsigned long i;
+	cap_t caps;
+
+	if (getuid() != 0) {
+		xlog(L_ERROR, "Not running as root. Daemon won't be able to "
+			      "open the pipe after dropping capabilities!");
+		return -EINVAL;
+	}
+
+	/* prune the bounding set to nothing */
+	for (i = 0; prctl(PR_CAPBSET_READ, i, 0, 0, 0) >= 0 ; ++i) {
+		ret = prctl(PR_CAPBSET_DROP, i, 0, 0, 0);
+		if (ret) {
+			xlog(L_ERROR, "Unable to prune capability %lu from "
+				      "bounding set: %m", i);
+			return -errno;
+		}
+	}
+
+	/* get a blank capset */
+	caps = cap_init();
+	if (caps == NULL) {
+		xlog(L_ERROR, "Unable to get blank capability set: %m");
+		return -errno;
+	}
+
+	/* reset the process capabilities */
+	if (cap_set_proc(caps) != 0) {
+		xlog(L_ERROR, "Unable to set process capabilities: %m");
+		ret = -errno;
+	}
+	cap_free(caps);
+#endif
+	return ret;
+}
+
+#define INOTIFY_EVENT_MAX (sizeof(struct inotify_event) + NAME_MAX)
+
+static int
+cld_pipe_open(struct cld_client *clnt)
+{
+	int fd;
+
+	xlog(D_GENERAL, "%s: opening upcall pipe %s", __func__, pipepath);
+	fd = open(pipepath, O_RDWR, 0);
+	if (fd < 0) {
+		xlog(D_GENERAL, "%s: open of %s failed: %m", __func__, pipepath);
+		return -errno;
+	}
+
+	if (event_initialized(&clnt->cl_event))
+		event_del(&clnt->cl_event);
+	if (clnt->cl_fd >= 0)
+		close(clnt->cl_fd);
+
+	clnt->cl_fd = fd;
+	event_set(&clnt->cl_event, clnt->cl_fd, EV_READ, cldcb, clnt);
+	/* event_add is done by the caller */
+	return 0;
+}
+
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
+static int
+cld_pipe_init(struct cld_client *clnt)
+{
+	int ret;
+
+	xlog(D_GENERAL, "%s: init pipe handlers", __func__);
+
+	ret = cld_inotify_setup();
+	if (ret != 0)
+		goto out;
+
+	clnt->cl_fd = -1;
+	ret = cld_pipe_open(clnt);
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
+
+	/* set event for inotify read */
+	event_set(&pipedir_event, inotify_fd, EV_READ, cld_inotify_cb, clnt);
+	event_add(&pipedir_event, NULL);
+out:
+	return ret;
+}
+
+static void
+cld_not_implemented(struct cld_client *clnt)
+{
+	int ret;
+	ssize_t bsize, wsize;
+	struct cld_msg *cmsg = &clnt->cl_msg;
+
+	xlog(D_GENERAL, "%s: downcalling with not implemented error", __func__);
+
+	/* set up reply */
+	cmsg->cm_status = -EOPNOTSUPP;
+
+	bsize = sizeof(*cmsg);
+
+	wsize = atomicio((void *)write, clnt->cl_fd, cmsg, bsize);
+	if (wsize != bsize)
+		xlog(L_ERROR, "%s: problem writing to cld pipe (%ld): %m",
+			 __func__, wsize);
+
+	/* reopen pipe, just to be sure */
+	ret = cld_pipe_open(clnt);
+	if (ret) {
+		xlog(L_FATAL, "%s: unable to reopen pipe: %d", __func__, ret);
+		exit(ret);
+	}
+}
+
+static void
+cld_create(struct cld_client *clnt)
+{
+	int ret;
+	ssize_t bsize, wsize;
+	struct cld_msg *cmsg = &clnt->cl_msg;
+
+	xlog(D_GENERAL, "%s: create client record.", __func__);
+
+
+	ret = sqlite_insert_client(cmsg->cm_u.cm_name.cn_id,
+				   cmsg->cm_u.cm_name.cn_len,
+				   false,
+				   false);
+
+	cmsg->cm_status = ret ? -EREMOTEIO : ret;
+
+	bsize = sizeof(*cmsg);
+
+	xlog(D_GENERAL, "Doing downcall with status %d", cmsg->cm_status);
+	wsize = atomicio((void *)write, clnt->cl_fd, cmsg, bsize);
+	if (wsize != bsize) {
+		xlog(L_ERROR, "%s: problem writing to cld pipe (%ld): %m",
+			 __func__, wsize);
+		ret = cld_pipe_open(clnt);
+		if (ret) {
+			xlog(L_FATAL, "%s: unable to reopen pipe: %d",
+					__func__, ret);
+			exit(ret);
+		}
+	}
+}
+
+static void
+cld_remove(struct cld_client *clnt)
+{
+	int ret;
+	ssize_t bsize, wsize;
+	struct cld_msg *cmsg = &clnt->cl_msg;
+
+	xlog(D_GENERAL, "%s: remove client record.", __func__);
+
+	ret = sqlite_remove_client(cmsg->cm_u.cm_name.cn_id,
+				   cmsg->cm_u.cm_name.cn_len);
+
+	cmsg->cm_status = ret ? -EREMOTEIO : ret;
+
+	bsize = sizeof(*cmsg);
+
+	xlog(D_GENERAL, "%s: downcall with status %d", __func__,
+			cmsg->cm_status);
+	wsize = atomicio((void *)write, clnt->cl_fd, cmsg, bsize);
+	if (wsize != bsize) {
+		xlog(L_ERROR, "%s: problem writing to cld pipe (%ld): %m",
+			 __func__, wsize);
+		ret = cld_pipe_open(clnt);
+		if (ret) {
+			xlog(L_FATAL, "%s: unable to reopen pipe: %d",
+					__func__, ret);
+			exit(ret);
+		}
+	}
+}
+
+static void
+cld_check(struct cld_client *clnt)
+{
+	int ret;
+	ssize_t bsize, wsize;
+	struct cld_msg *cmsg = &clnt->cl_msg;
+
+	xlog(D_GENERAL, "%s: check client record", __func__);
+
+	ret = sqlite_check_client(cmsg->cm_u.cm_name.cn_id,
+				  cmsg->cm_u.cm_name.cn_len,
+				  false);
+
+	/* set up reply */
+	cmsg->cm_status = ret ? -EACCES : ret;
+
+	bsize = sizeof(*cmsg);
+
+	xlog(D_GENERAL, "%s: downcall with status %d", __func__,
+			cmsg->cm_status);
+	wsize = atomicio((void *)write, clnt->cl_fd, cmsg, bsize);
+	if (wsize != bsize) {
+		xlog(L_ERROR, "%s: problem writing to cld pipe (%ld): %m",
+			 __func__, wsize);
+		ret = cld_pipe_open(clnt);
+		if (ret) {
+			xlog(L_FATAL, "%s: unable to reopen pipe: %d",
+					__func__, ret);
+			exit(ret);
+		}
+	}
+}
+
+static void
+cld_gracedone(struct cld_client *clnt)
+{
+	int ret;
+	ssize_t bsize, wsize;
+	struct cld_msg *cmsg = &clnt->cl_msg;
+
+	xlog(D_GENERAL, "%s: grace done. cm_gracetime=%ld", __func__,
+			cmsg->cm_u.cm_gracetime);
+
+	ret = sqlite_remove_unreclaimed(cmsg->cm_u.cm_gracetime);
+
+	/* set up reply: downcall with 0 status */
+	cmsg->cm_status = ret ? -EREMOTEIO : ret;
+
+	bsize = sizeof(*cmsg);
+
+	xlog(D_GENERAL, "Doing downcall with status %d", cmsg->cm_status);
+	wsize = atomicio((void *)write, clnt->cl_fd, cmsg, bsize);
+	if (wsize != bsize) {
+		xlog(L_ERROR, "%s: problem writing to cld pipe (%ld): %m",
+			 __func__, wsize);
+		ret = cld_pipe_open(clnt);
+		if (ret) {
+			xlog(L_FATAL, "%s: unable to reopen pipe: %d",
+					__func__, ret);
+			exit(ret);
+		}
+	}
+}
+
+static void
+cldcb(int UNUSED(fd), short which, void *data)
+{
+	ssize_t len;
+	struct cld_client *clnt = data;
+	struct cld_msg *cmsg = &clnt->cl_msg;
+
+	if (which != EV_READ)
+		goto out;
+
+	len = atomicio(read, clnt->cl_fd, cmsg, sizeof(*cmsg));
+	if (len <= 0) {
+		xlog(L_ERROR, "%s: pipe read failed: %m", __func__);
+		cld_pipe_open(clnt);
+		goto out;
+	}
+
+	if (cmsg->cm_vers > UPCALL_VERSION) {
+		xlog(L_ERROR, "%s: unsupported upcall version: %hu",
+				__func__, cmsg->cm_vers);
+		cld_pipe_open(clnt);
+		goto out;
+	}
+
+	switch(cmsg->cm_cmd) {
+	case Cld_Create:
+		cld_create(clnt);
+		break;
+	case Cld_Remove:
+		cld_remove(clnt);
+		break;
+	case Cld_Check:
+		cld_check(clnt);
+		break;
+	case Cld_GraceDone:
+		cld_gracedone(clnt);
+		break;
+	default:
+		xlog(L_WARNING, "%s: command %u is not yet implemented",
+				__func__, cmsg->cm_cmd);
+		cld_not_implemented(clnt);
+	}
+out:
+	event_add(&clnt->cl_event, NULL);
+}
+
+int
+main(int argc, char **argv)
+{
+	char arg;
+	int rc = 0;
+	bool foreground = false;
+	char *progname;
+	char *storagedir = CLD_DEFAULT_STORAGEDIR;
+	struct cld_client clnt;
+
+	memset(&clnt, 0, sizeof(clnt));
+
+	progname = strdup(basename(argv[0]));
+	if (!progname) {
+		fprintf(stderr, "%s: unable to allocate memory.\n", argv[0]);
+		return 1;
+	}
+
+	event_init();
+	xlog_syslog(0);
+	xlog_stderr(1);
+
+	/* process command-line options */
+	while ((arg = getopt_long(argc, argv, "hdFp:s:", longopts,
+				  NULL)) != EOF) {
+		switch (arg) {
+		case 'd':
+			xlog_config(D_ALL, 1);
+			break;
+		case 'F':
+			foreground = true;
+			break;
+		case 'p':
+			pipepath = optarg;
+			break;
+		case 's':
+			storagedir = optarg;
+			break;
+		default:
+			usage(progname);
+			return 0;
+		}
+	}
+
+
+	xlog_open(progname);
+	if (!foreground) {
+		xlog_syslog(1);
+		xlog_stderr(0);
+		rc = daemon(0, 0);
+		if (rc) {
+			xlog(L_ERROR, "Unable to daemonize: %m");
+			goto out;
+		}
+	}
+
+	/* drop all capabilities */
+	rc = cld_set_caps();
+	if (rc)
+		goto out;
+
+	/*
+	 * now see if the storagedir is writable by root w/o CAP_DAC_OVERRIDE.
+	 * If it isn't then give the user a warning but proceed as if
+	 * everything is OK. If the DB has already been created, then
+	 * everything might still work. If it doesn't exist at all, then
+	 * assume that the maindb init will be able to create it. Fail on
+	 * anything else.
+	 */
+	if (access(storagedir, W_OK) == -1) {
+		switch (errno) {
+		case EACCES:
+			xlog(L_WARNING, "Storage directory %s is not writable. "
+					"Should be owned by root and writable "
+					"by owner!", storagedir);
+			break;
+		case ENOENT:
+			/* ignore and assume that we can create dir as root */
+			break;
+		default:
+			xlog(L_ERROR, "Unexpected error when checking access "
+				      "on %s: %m", storagedir);
+			rc = -errno;
+			goto out;
+		}
+	}
+
+	/* set up storage db */
+	rc = sqlite_prepare_dbh(storagedir);
+	if (rc) {
+		xlog(L_ERROR, "Failed to open main database: %d", rc);
+		goto out;
+	}
+
+	/* set up event handler */
+	rc = cld_pipe_init(&clnt);
+	if (rc)
+		goto out;
+
+	xlog(D_GENERAL, "%s: Starting event dispatch handler.", __func__);
+	rc = event_dispatch();
+	if (rc < 0)
+		xlog(L_ERROR, "%s: event_dispatch failed: %m", __func__);
+
+	close(clnt.cl_fd);
+	close(inotify_fd);
+out:
+	free(progname);
+	return rc;
+}
diff --git a/utils/nfsdcltrack/nfsdcld.man b/utils/nfsdcltrack/nfsdcld.man
new file mode 100644
index 0000000..9ddaf64
--- /dev/null
+++ b/utils/nfsdcltrack/nfsdcld.man
@@ -0,0 +1,185 @@
+.\" Automatically generated by Pod::Man 2.22 (Pod::Simple 3.13)
+.\"
+.\" Standard preamble:
+.\" ========================================================================
+.de Sp \" Vertical space (when we can't use .PP)
+.if t .sp .5v
+.if n .sp
+..
+.de Vb \" Begin verbatim text
+.ft CW
+.nf
+.ne \\$1
+..
+.de Ve \" End verbatim text
+.ft R
+.fi
+..
+.\" Set up some character translations and predefined strings.  \*(-- will
+.\" give an unbreakable dash, \*(PI will give pi, \*(L" will give a left
+.\" double quote, and \*(R" will give a right double quote.  \*(C+ will
+.\" give a nicer C++.  Capital omega is used to do unbreakable dashes and
+.\" therefore won't be available.  \*(C` and \*(C' expand to `' in nroff,
+.\" nothing in troff, for use with C<>.
+.tr \(*W-
+.ds C+ C\v'-.1v'\h'-1p'\s-2+\h'-1p'+\s0\v'.1v'\h'-1p'
+.ie n \{\
+.    ds -- \(*W-
+.    ds PI pi
+.    if (\n(.H=4u)&(1m=24u) .ds -- \(*W\h'-12u'\(*W\h'-12u'-\" diablo 10 pitch
+.    if (\n(.H=4u)&(1m=20u) .ds -- \(*W\h'-12u'\(*W\h'-8u'-\"  diablo 12 pitch
+.    ds L" ""
+.    ds R" ""
+.    ds C` ""
+.    ds C' ""
+'br\}
+.el\{\
+.    ds -- \|\(em\|
+.    ds PI \(*p
+.    ds L" ``
+.    ds R" ''
+'br\}
+.\"
+.\" Escape single quotes in literal strings from groff's Unicode transform.
+.ie \n(.g .ds Aq \(aq
+.el       .ds Aq '
+.\"
+.\" If the F register is turned on, we'll generate index entries on stderr for
+.\" titles (.TH), headers (.SH), subsections (.SS), items (.Ip), and index
+.\" entries marked with X<> in POD.  Of course, you'll have to process the
+.\" output yourself in some meaningful fashion.
+.ie \nF \{\
+.    de IX
+.    tm Index:\\$1\t\\n%\t"\\$2"
+..
+.    nr % 0
+.    rr F
+.\}
+.el \{\
+.    de IX
+..
+.\}
+.\"
+.\" Accent mark definitions (@(#)ms.acc 1.5 88/02/08 SMI; from UCB 4.2).
+.\" Fear.  Run.  Save yourself.  No user-serviceable parts.
+.    \" fudge factors for nroff and troff
+.if n \{\
+.    ds #H 0
+.    ds #V .8m
+.    ds #F .3m
+.    ds #[ \f1
+.    ds #] \fP
+.\}
+.if t \{\
+.    ds #H ((1u-(\\\\n(.fu%2u))*.13m)
+.    ds #V .6m
+.    ds #F 0
+.    ds #[ \&
+.    ds #] \&
+.\}
+.    \" simple accents for nroff and troff
+.if n \{\
+.    ds ' \&
+.    ds ` \&
+.    ds ^ \&
+.    ds , \&
+.    ds ~ ~
+.    ds /
+.\}
+.if t \{\
+.    ds ' \\k:\h'-(\\n(.wu*8/10-\*(#H)'\'\h"|\\n:u"
+.    ds ` \\k:\h'-(\\n(.wu*8/10-\*(#H)'\`\h'|\\n:u'
+.    ds ^ \\k:\h'-(\\n(.wu*10/11-\*(#H)'^\h'|\\n:u'
+.    ds , \\k:\h'-(\\n(.wu*8/10)',\h'|\\n:u'
+.    ds ~ \\k:\h'-(\\n(.wu-\*(#H-.1m)'~\h'|\\n:u'
+.    ds / \\k:\h'-(\\n(.wu*8/10-\*(#H)'\z\(sl\h'|\\n:u'
+.\}
+.    \" troff and (daisy-wheel) nroff accents
+.ds : \\k:\h'-(\\n(.wu*8/10-\*(#H+.1m+\*(#F)'\v'-\*(#V'\z.\h'.2m+\*(#F'.\h'|\\n:u'\v'\*(#V'
+.ds 8 \h'\*(#H'\(*b\h'-\*(#H'
+.ds o \\k:\h'-(\\n(.wu+\w'\(de'u-\*(#H)/2u'\v'-.3n'\*(#[\z\(de\v'.3n'\h'|\\n:u'\*(#]
+.ds d- \h'\*(#H'\(pd\h'-\w'~'u'\v'-.25m'\f2\(hy\fP\v'.25m'\h'-\*(#H'
+.ds D- D\\k:\h'-\w'D'u'\v'-.11m'\z\(hy\v'.11m'\h'|\\n:u'
+.ds th \*(#[\v'.3m'\s+1I\s-1\v'-.3m'\h'-(\w'I'u*2/3)'\s-1o\s+1\*(#]
+.ds Th \*(#[\s+2I\s-2\h'-\w'I'u*3/5'\v'-.3m'o\v'.3m'\*(#]
+.ds ae a\h'-(\w'a'u*4/10)'e
+.ds Ae A\h'-(\w'A'u*4/10)'E
+.    \" corrections for vroff
+.if v .ds ~ \\k:\h'-(\\n(.wu*9/10-\*(#H)'\s-2\u~\d\s+2\h'|\\n:u'
+.if v .ds ^ \\k:\h'-(\\n(.wu*10/11-\*(#H)'\v'-.4m'^\v'.4m'\h'|\\n:u'
+.    \" for low resolution devices (crt and lpr)
+.if \n(.H>23 .if \n(.V>19 \
+\{\
+.    ds : e
+.    ds 8 ss
+.    ds o a
+.    ds d- d\h'-1'\(ga
+.    ds D- D\h'-1'\(hy
+.    ds th \o'bp'
+.    ds Th \o'LP'
+.    ds ae ae
+.    ds Ae AE
+.\}
+.rm #[ #] #H #V #F C
+.\" ========================================================================
+.\"
+.IX Title "NFSDCLD 8"
+.TH NFSDCLD 8 "2011-12-21" "" ""
+.\" For nroff, turn off justification.  Always turn off hyphenation; it makes
+.\" way too many mistakes in technical documents.
+.if n .ad l
+.nh
+.SH "NAME"
+nfsdcld \- NFSv4 Client Tracking Daemon
+.SH "SYNOPSIS"
+.IX Header "SYNOPSIS"
+nfsdcld [\-d] [\-F] [\-p path] [\-s stable storage dir]
+.SH "DESCRIPTION"
+.IX Header "DESCRIPTION"
+nfsdcld is the NFSv4 client tracking daemon. It is not necessary to run
+this daemon on machines that are not acting as NFSv4 servers.
+.PP
+When a network partition is combined with a server reboot, there are
+edge conditions that can cause the server to grant lock reclaims when
+other clients have taken conflicting locks in the interim. A more detailed
+explanation of this issue is described in \s-1RFC\s0 3530, section 8.6.3.
+.PP
+In order to prevent these problems, the server must track a small amount
+of per-client information on stable storage. This daemon provides the
+userspace piece of that functionality.
+.SH "OPTIONS"
+.IX Header "OPTIONS"
+.IP "\fB\-d\fR, \fB\-\-debug\fR" 4
+.IX Item "-d, --debug"
+Enable debug level logging.
+.IP "\fB\-F\fR, \fB\-\-foreground\fR" 4
+.IX Item "-F, --foreground"
+Runs the daemon in the foreground and prints all output to stderr
+.IP "\fB\-p\fR \fIpipe\fR, \fB\-\-pipe\fR=\fIpipe\fR" 4
+.IX Item "-p pipe, --pipe=pipe"
+Location of the \*(L"cld\*(R" upcall pipe. The default value is
+\&\fI/var/lib/nfs/rpc_pipefs/nfsd/cld\fR. If the pipe does not exist when the
+daemon starts then it will wait for it to be created.
+.IP "\fB\-s\fR \fIstorage_dir\fR, \fB\-\-storagedir\fR=\fIstorage_dir\fR" 4
+.IX Item "-s storagedir, --storagedir=storage_dir"
+Directory where stable storage information should be kept. The default
+value is \fI/var/lib/nfs/nfsdcld\fR.
+.SH "NOTES"
+.IX Header "NOTES"
+The Linux kernel NFSv4 server has historically tracked this information
+on stable storage by manipulating information on the filesystem
+directly, in the directory to which \fI/proc/fs/nfsd/nfsv4recoverydir\fR
+points.
+.PP
+This daemon requires a kernel that supports the nfsdcld upcall. If the
+kernel does not support the new upcall, or is using the legacy client
+name tracking code then it will not create the pipe that nfsdcld uses to
+talk to the kernel.
+.PP
+This daemon should be run as root, as the pipe that it uses to communicate
+with the kernel is only accessable by root. The daemon however does drop all
+superuser capabilities after starting. Because of this, the \fIstoragedir\fR
+should be owned by root, and be readable and writable by owner.
+.SH "AUTHORS"
+.IX Header "AUTHORS"
+The nfsdcld daemon was developed by Jeff Layton <jlayton@redhat.com>.
-- 
2.17.2

