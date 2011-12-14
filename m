Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:57475 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757122Ab1LNN5N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Dec 2011 08:57:13 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pBEDvDH8007532
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 14 Dec 2011 08:57:13 -0500
Received: from dantu.rdu.redhat.com (dantu.rdu.redhat.com [10.11.228.66])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id pBEDvC3a005913
	for <linux-nfs@vger.kernel.org>; Wed, 14 Dec 2011 08:57:13 -0500
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/7] clstated: add clname tracking daemon stub
Date: Wed, 14 Dec 2011 08:57:06 -0500
Message-Id: <1323871032-3191-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1323871032-3191-1-git-send-email-jlayton@redhat.com>
References: <1323871032-3191-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This program opens and "listens" on the new nfsd/clname rpc_pipefs pipe.
The code here doesn't actually do anything on stable storage yet. That
will be added in a later patch.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 configure.ac               |    1 +
 utils/Makefile.am          |    1 +
 utils/clstated/Makefile.am |   14 +++
 utils/clstated/clstated.c  |  243 ++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 259 insertions(+), 0 deletions(-)
 create mode 100644 utils/clstated/Makefile.am
 create mode 100644 utils/clstated/clstated.c

diff --git a/configure.ac b/configure.ac
index f101b86..822cf17 100644
--- a/configure.ac
+++ b/configure.ac
@@ -458,6 +458,7 @@ AC_CONFIG_FILES([
 	tools/nfs-iostat/Makefile
 	utils/Makefile
 	utils/blkmapd/Makefile
+	utils/clstated/Makefile
 	utils/exportfs/Makefile
 	utils/gssd/Makefile
 	utils/idmapd/Makefile
diff --git a/utils/Makefile.am b/utils/Makefile.am
index d074b85..beaf4e9 100644
--- a/utils/Makefile.am
+++ b/utils/Makefile.am
@@ -22,6 +22,7 @@ OPTDIRS += mount
 endif
 
 SUBDIRS = \
+	clstated \
 	exportfs \
 	mountd \
 	nfsd \
diff --git a/utils/clstated/Makefile.am b/utils/clstated/Makefile.am
new file mode 100644
index 0000000..9937353
--- /dev/null
+++ b/utils/clstated/Makefile.am
@@ -0,0 +1,14 @@
+## Process this file with automake to produce Makefile.in
+
+#man8_MANS	= clstated.man
+#EXTRA_DIST = $(man8_MANS)
+
+AM_CFLAGS	+= -D_LARGEFILE64_SOURCE
+sbin_PROGRAMS	= clstated
+
+clstated_SOURCES = clstated.c
+
+clstated_LDADD = ../../support/nfs/libnfs.a $(LIBEVENT)
+
+MAINTAINERCLEANFILES = Makefile.in
+
diff --git a/utils/clstated/clstated.c b/utils/clstated/clstated.c
new file mode 100644
index 0000000..93a2710
--- /dev/null
+++ b/utils/clstated/clstated.c
@@ -0,0 +1,243 @@
+/*
+ * clstated.c -- NFSv4 client state tracking daemon
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
+#include <linux/nfsd/clstate.h>
+
+#include "xlog.h"
+#include "nfslib.h"
+
+#ifndef PIPEFS_DIR
+#define PIPEFS_DIR NFS_STATEDIR "/rpc_pipefs"
+#endif
+
+#define DEFAULT_CLNAMED_PATH	PIPEFS_DIR "/nfsd/clstate"
+
+/* private data structures */
+struct clstate_client {
+	int			cl_fd;
+	struct event		cl_event;
+	struct clstate_msg	cl_msg;
+};
+
+/* global variables */
+static char *pipepath = DEFAULT_CLNAMED_PATH;
+
+static struct option longopts[] =
+{
+	{ "help", 0, NULL, 'h' },
+	{ "foreground", 0, NULL, 'F' },
+	{ "debug", 0, NULL, 'd' },
+	{ "path", 1, NULL, 'p' },
+	{ NULL, 0, 0, 0 },
+};
+
+/* forward declarations */
+static void clstatecb(int UNUSED(fd), short which, void *data);
+
+static void
+usage(char *progname)
+{
+	printf("Usage:\n");
+	printf("%s [ -hFdp ]\n", progname);
+}
+
+static int
+clstate_pipe_open(struct clstate_client *clnt)
+{
+	clnt->cl_fd = open(pipepath, O_RDWR, 0);
+	if (clnt->cl_fd < 0) {
+		xlog(L_ERROR, "%s: unable to open %s: %m", __func__, pipepath);
+		return clnt->cl_fd;
+	}
+
+	event_set(&clnt->cl_event, clnt->cl_fd, EV_READ, clstatecb, clnt);
+	event_add(&clnt->cl_event, NULL);
+
+	return clnt->cl_fd;
+}
+
+static void
+clstate_pipe_reopen(struct clstate_client *clnt)
+{
+	int fd;
+
+	fd = open(pipepath, O_RDWR, 0);
+	if (fd < 0) {
+		xlog_warn("%s: Re-opening of %s failed: %m");
+		return;
+	}
+
+	if ((clnt->cl_event.ev_flags & EVLIST_INIT))
+		event_del(&clnt->cl_event);
+	if (clnt->cl_fd > 0)
+		close(clnt->cl_fd);
+
+	clnt->cl_fd = fd;
+	event_set(&clnt->cl_event, clnt->cl_fd, EV_READ, clstatecb, clnt);
+	/* event_add is done by the caller */
+}
+
+static void
+clstate_create(struct clstate_client *clnt)
+{
+	ssize_t bsize, wsize;
+	struct clstate_msg *cmsg = &clnt->cl_msg;
+
+	xlog(D_GENERAL, "%s: create client record", __func__);
+
+	/* FIXME: create client record on storage here */
+
+	/* set up reply */
+	cmsg->cm_status = 0;
+	cmsg->cm_len = 0;
+	memset(cmsg->cm_addr, 0, sizeof(cmsg->cm_addr) +
+		sizeof(cmsg->cm_u.cm_id));
+
+	bsize = sizeof(*cmsg);
+
+	wsize = atomicio((void *)write, clnt->cl_fd, cmsg, bsize);
+	if (wsize != bsize) {
+		xlog(L_ERROR, "%s: problem writing to clstate pipe (%ld): %m",
+			 __func__, wsize);
+		clstate_pipe_reopen(clnt);
+	}
+}
+
+static void
+clstatecb(int UNUSED(fd), short which, void *data)
+{
+	ssize_t len;
+	struct clstate_client *clnt = data;
+	struct clstate_msg *cmsg = &clnt->cl_msg;
+
+	if (which != EV_READ)
+		goto out;
+
+	len = atomicio(read, clnt->cl_fd, cmsg, sizeof(*cmsg));
+	if (len <= 0) {
+		xlog_warn("%s: pipe read failed: %m", __func__);
+		clstate_pipe_reopen(clnt);
+		goto out;
+	}
+
+	switch(cmsg->cm_cmd) {
+	case Cl_Create:
+		clstate_create(clnt);
+		break;
+	case Cl_Expire:
+	case Cl_NrToReclaim:
+	case Cl_Allow:
+	case Cl_GraceDone:
+		xlog_warn("%s: command %u is not yet implemented", __func__,
+			  cmsg->cm_cmd);
+		break;
+	default:
+		xlog_warn("%s: unrecognized command %u", __func__,
+			  cmsg->cm_cmd);
+		clstate_pipe_reopen(clnt);
+	}
+out:
+	event_add(&clnt->cl_event, NULL);
+}
+
+int
+main(int argc, char **argv)
+{
+	char arg;
+	int rc = 0, fd;
+	bool foreground = false;
+	char *progname;
+	struct clstate_client clnt;
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
+	while ((arg = getopt_long(argc, argv, "hdFp:", longopts,
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
+	/* set up storage db */
+
+	/* set up event handler */
+	fd = clstate_pipe_open(&clnt);
+	if (fd < 0) {
+		rc = fd;
+		goto out;
+	}
+
+	rc = event_dispatch();
+	if (rc < 0)
+		xlog(L_ERROR, "%s: event_dispatch failed: %m", __func__);
+
+	close(clnt.cl_fd);
+out:
+	free(progname);
+	return rc;
+}
-- 
1.7.1

