Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:36452 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751164AbcLBD7Z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Dec 2016 22:59:25 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>,
        Steve Dickson <SteveD@redhat.com>
Date: Fri, 02 Dec 2016 14:58:29 +1100
Subject: [PATCH 06/15] Add /etc/nfs.conf support for sm-notify
Cc: linux-nfs@vger.kernel.org
Message-ID: <148065110892.28046.18251782958732101170.stgit@noble>
In-Reply-To: <148065078775.28046.5506130555300891075.stgit@noble>
References: <148065078775.28046.5506130555300891075.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: NeilBrown <neilb@suse.com>
---
 systemd/nfs.conf.man      |   10 ++++++++++
 utils/statd/sm-notify.c   |   11 +++++++++++
 utils/statd/sm-notify.man |   27 +++++++++++++++++++++++++++
 3 files changed, 48 insertions(+)

diff --git a/systemd/nfs.conf.man b/systemd/nfs.conf.man
index a1121e46ef5e..726f603544b7 100644
--- a/systemd/nfs.conf.man
+++ b/systemd/nfs.conf.man
@@ -142,6 +142,16 @@ See
 .BR rpc.statd (8)
 for details.
 
+.TP
+.B sm-notify
+Recognized values:
+.BR retry-time ,
+.BR outgoing-port ", and"
+.BR outgoing-addr .
+
+See
+.BR sm-notify (8)
+for details.
 
 .SH FILES
 .I /etc/nfs.conf
diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 8afddd97da73..19f40afcb376 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -29,6 +29,7 @@
 #include <errno.h>
 #include <grp.h>
 
+#include "conffile.h"
 #include "sockaddr.h"
 #include "xlog.h"
 #include "nsm.h"
@@ -66,6 +67,7 @@ static _Bool		opt_update_state = true;
 static unsigned int	opt_max_retry = 15 * 60;
 static char *		opt_srcaddr = NULL;
 static char *		opt_srcport = NULL;
+char *			conf_path = NFS_CONFFILE;
 
 static void		notify(const int sock);
 static int		notify_host(int, struct nsm_host *);
@@ -479,6 +481,7 @@ main(int argc, char **argv)
 {
 	int	c, sock, force = 0;
 	char *	progname;
+	char *	s;
 
 	progname = strrchr(argv[0], '/');
 	if (progname != NULL)
@@ -486,6 +489,14 @@ main(int argc, char **argv)
 	else
 		progname = argv[0];
 
+	conf_init();
+	opt_max_retry = conf_get_num("sm-notify", "retry-time", opt_max_retry / 60) * 60;
+	opt_srcport = conf_get_str("sm-notify", "outgoing-port");
+	opt_srcaddr = conf_get_str("sm-notify", "outgoing-addr");
+	s = conf_get_str("statd", "state-directory-path");
+	if (s && !nsm_setup_pathnames(argv[0], s))
+		exit(1);
+
 	while ((c = getopt(argc, argv, "dm:np:v:P:f")) != -1) {
 		switch (c) {
 		case 'f':
diff --git a/utils/statd/sm-notify.man b/utils/statd/sm-notify.man
index 7a1cbfae998f..bb7f6e0a1420 100644
--- a/utils/statd/sm-notify.man
+++ b/utils/statd/sm-notify.man
@@ -219,6 +219,33 @@ argument when sending SM_NOTIFY requests.
 .IP
 This option can be useful in multi-homed configurations where
 the remote requires notification from a specific network address.
+.SH CONFIGURATION FILE
+Many of the options that can be set on the command line can also be
+controlled through values set in the
+.B [sm-notify]
+or, in one case, the
+.B [statd]
+section of the
+.I /etc/nfs.conf
+configuration file.
+
+Values recognized in the
+.B [sm-notify]
+section include:
+.BR retry-time ,
+.BR outgoing-port ", and"
+.BR outgoing-addr .
+These have the same effect as the command line options
+.BR m ,
+.BR p ", and"
+.B v
+respectively.
+
+The value recognized in the
+.B [statd]
+section is
+.BR state-directory-path .
+
 .SH SECURITY
 The
 .B sm-notify


