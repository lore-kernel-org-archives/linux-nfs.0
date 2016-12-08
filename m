Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45636 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752956AbcLHEoA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Dec 2016 23:44:00 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>,
        Steve Dickson <SteveD@redhat.com>
Date: Thu, 08 Dec 2016 15:27:25 +1100
Subject: [PATCH 07/10] xlog: Add common support for "debug=??" in
 /etc/nfs.conf
Cc: linux-nfs@vger.kernel.org
Message-ID: <148117124556.31271.1177612832649558919.stgit@noble>
In-Reply-To: <148117122602.31271.13586847542442809540.stgit@noble>
References: <148117122602.31271.13586847542442809540.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The value is from the list general, call, auth, parse, all.
Most daemons recognise this in their dedicated section.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 support/include/xlog.h          |    1 +
 support/nfs/xlog.c              |   14 ++++++++++++++
 systemd/nfs.conf.man            |   10 +++++++++-
 utils/mountd/mountd.c           |    1 +
 utils/nfsd/nfsd.c               |    1 +
 utils/nfsdcltrack/nfsdcltrack.c |    1 +
 utils/statd/sm-notify.c         |    1 +
 utils/statd/statd.c             |    1 +
 8 files changed, 29 insertions(+), 1 deletion(-)

diff --git a/support/include/xlog.h b/support/include/xlog.h
index 06dc1ab2e8e6..a11463ed8aac 100644
--- a/support/include/xlog.h
+++ b/support/include/xlog.h
@@ -41,6 +41,7 @@ void			xlog_stderr(int on);
 void			xlog_syslog(int on);
 void			xlog_config(int fac, int on);
 void			xlog_sconfig(char *, int on);
+void			xlog_from_conffile(char *);
 int			xlog_enabled(int fac);
 void			xlog(int fac, const char *fmt, ...);
 void			xlog_warn(const char *fmt, ...);
diff --git a/support/nfs/xlog.c b/support/nfs/xlog.c
index 594ae9b61461..c8e4263408f8 100644
--- a/support/nfs/xlog.c
+++ b/support/nfs/xlog.c
@@ -29,6 +29,7 @@
 #include <syslog.h>
 #include <errno.h>
 #include "nfslib.h"
+#include "conffile.h"
 
 #undef	VERBOSE_PRINTF
 
@@ -125,6 +126,19 @@ xlog_sconfig(char *kind, int on)
 	xlog_config(tbl->df_fac, on);
 }
 
+void
+xlog_from_conffile(char *service)
+{
+	struct conf_list *kinds;
+	struct conf_list_node *n;
+
+	kinds = conf_get_list(service, "debug");
+	if (!kinds || !kinds->cnt)
+		return;
+	TAILQ_FOREACH(n, &(kinds->fields), link)
+		xlog_sconfig(n->field, 1);
+}
+
 int
 xlog_enabled(int fac)
 {
diff --git a/systemd/nfs.conf.man b/systemd/nfs.conf.man
index 2713bb06c6ed..2de3919a0a80 100644
--- a/systemd/nfs.conf.man
+++ b/systemd/nfs.conf.man
@@ -86,7 +86,15 @@ can be used for "false".  Comparisons are case-insensitive.
 
 .SH SECTIONS
 The following sections are known to various programs, and can contain
-the given named values.
+the given named values.  Most sections can also contain a
+.B debug
+value, which can be one or more from the list
+.BR general ,
+.BR call ,
+.BR auth ,
+.BR parse ,
+.BR all .
+When a list is given, the members should be comma-separated.
 .TP
 .B nfsdcltrack
 Recognized values:
diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 2048fce92b8e..5d9466f5c651 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -675,6 +675,7 @@ main(int argc, char **argv)
 		progname = argv[0];
 
 	conf_init();
+	xlog_from_conffile("mountd");
 	manage_gids = conf_get_bool("mountd", "manage-gids", manage_gids);
 	descriptors = conf_get_num("mountd", "descriptors", descriptors);
 	port = conf_get_num("mountd", "port", port);
diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index 8ee8bf0fe082..3c451aa46be1 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -80,6 +80,7 @@ main(int argc, char **argv)
 	xlog_stderr(1);
 
 	conf_init();
+	xlog_from_conffile("nfsd");
 	count = conf_get_num("nfsd", "threads", count);
 	grace = conf_get_num("nfsd", "grace-time", grace);
 	lease = conf_get_num("nfsd", "lease-time", lease);
diff --git a/utils/nfsdcltrack/nfsdcltrack.c b/utils/nfsdcltrack/nfsdcltrack.c
index e6e514b78316..70093bb6dc1a 100644
--- a/utils/nfsdcltrack/nfsdcltrack.c
+++ b/utils/nfsdcltrack/nfsdcltrack.c
@@ -567,6 +567,7 @@ main(int argc, char **argv)
 	xlog_stderr(0);
 
 	conf_init();
+	xlog_from_conffile("nfsdcltrack");
 	val = conf_get_str("nfsdcltrack", "storagedir");
 	if (val)
 		storagedir = val;
diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 19f40afcb376..623213efcb42 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -490,6 +490,7 @@ main(int argc, char **argv)
 		progname = argv[0];
 
 	conf_init();
+	xlog_from_conffile("sm-notify");
 	opt_max_retry = conf_get_num("sm-notify", "retry-time", opt_max_retry / 60) * 60;
 	opt_srcport = conf_get_str("sm-notify", "outgoing-port");
 	opt_srcaddr = conf_get_str("sm-notify", "outgoing-addr");
diff --git a/utils/statd/statd.c b/utils/statd/statd.c
index 1c34c9ef02cb..d333b2950d88 100644
--- a/utils/statd/statd.c
+++ b/utils/statd/statd.c
@@ -275,6 +275,7 @@ int main (int argc, char **argv)
 	MY_NAME = NULL;
 
 	conf_init();
+	xlog_from_conffile("statd");
 	out_port = conf_get_num("statd", "outgoing-port", out_port);
 	port = conf_get_num("statd", "port", port);
 	MY_NAME = conf_get_str("statd", "name");


