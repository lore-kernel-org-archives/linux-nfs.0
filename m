Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45635 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752479AbcLHEoA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Dec 2016 23:44:00 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>,
        Steve Dickson <SteveD@redhat.com>
Date: Thu, 08 Dec 2016 15:27:25 +1100
Subject: [PATCH 08/10] exportfs: allow debugging to be enabled in nfs.conf
Cc: linux-nfs@vger.kernel.org
Message-ID: <148117124572.31271.14400211473865023109.stgit@noble>
In-Reply-To: <148117122602.31271.13586847542442809540.stgit@noble>
References: <148117122602.31271.13586847542442809540.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: NeilBrown <neilb@suse.com>
---
 systemd/nfs.conf.man        |    6 ++++++
 utils/exportfs/exportfs.c   |    5 +++++
 utils/exportfs/exportfs.man |    8 ++++++++
 3 files changed, 19 insertions(+)

diff --git a/systemd/nfs.conf.man b/systemd/nfs.conf.man
index 2de3919a0a80..9e427a61d621 100644
--- a/systemd/nfs.conf.man
+++ b/systemd/nfs.conf.man
@@ -189,6 +189,12 @@ See
 .BR sm-notify (8)
 for details.
 
+.TP
+.B exportfs
+Only
+.B debug=
+is recognized.
+
 .SH FILES
 .I /etc/nfs.conf
 .SH SEE ALSO
diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index b7a910efe353..740b79cd8f42 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -36,6 +36,7 @@
 #include "nfslib.h"
 #include "exportfs.h"
 #include "xlog.h"
+#include "conffile.h"
 
 static void	export_all(int verbose);
 static void	exportfs(char *arg, char *options, int verbose);
@@ -49,6 +50,7 @@ static void release_lockfile(void);
 
 static const char *lockfile = EXP_LOCKFILE;
 static int _lockfd = -1;
+char *conf_path = NFS_CONFFILE;
 
 /*
  * If we aren't careful, changes made by exportfs can be lost
@@ -103,6 +105,9 @@ main(int argc, char **argv)
 	xlog_stderr(1);
 	xlog_syslog(0);
 
+	conf_init();
+	xlog_from_conffile("exportfs");
+
 	while ((c = getopt(argc, argv, "ad:fhio:ruvs")) != EOF) {
 		switch(c) {
 		case 'a':
diff --git a/utils/exportfs/exportfs.man b/utils/exportfs/exportfs.man
index fdf9260c6c75..45b6d834ac4a 100644
--- a/utils/exportfs/exportfs.man
+++ b/utils/exportfs/exportfs.man
@@ -90,6 +90,13 @@ to be added to the kernel's export table.
 .TP
 .B \-d kind " or " \-\-debug kind
 Turn on debugging. Valid kinds are: all, auth, call, general and parse.
+Debugging can also be turned on by setting
+.B debug=
+in the
+.B [exportfs]
+section of
+.IR /etc/nfs.conf .
+
 .TP
 .B -a
 Export or unexport all directories.
@@ -295,6 +302,7 @@ master table of exports
 table of clients accessing server's exports
 .SH SEE ALSO
 .BR exports (5),
+.BR nfs.conf (5),
 .BR rpc.mountd (8),
 .BR netgroup (5)
 .SH AUTHORS


