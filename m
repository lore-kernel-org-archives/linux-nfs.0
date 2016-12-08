Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:44053 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752887AbcLHEaA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Dec 2016 23:30:00 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>,
        Steve Dickson <SteveD@redhat.com>
Date: Thu, 08 Dec 2016 15:27:26 +1100
Subject: [PATCH 10/10] svcgssd: add /etc/nfs.conf support
Cc: linux-nfs@vger.kernel.org
Message-ID: <148117124604.31271.10528572108892267997.stgit@noble>
In-Reply-To: <148117122602.31271.13586847542442809540.stgit@noble>
References: <148117122602.31271.13586847542442809540.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: NeilBrown <neilb@suse.com>
---
 systemd/nfs.conf.man   |    9 +++++++++
 utils/gssd/svcgssd.c   |   14 ++++++++++++++
 utils/gssd/svcgssd.man |   17 +++++++++++++++++
 3 files changed, 40 insertions(+)

diff --git a/systemd/nfs.conf.man b/systemd/nfs.conf.man
index 938b9705414a..91c49a0f76ab 100644
--- a/systemd/nfs.conf.man
+++ b/systemd/nfs.conf.man
@@ -208,6 +208,15 @@ See
 for details.
 
 .TP
+.B svcgssd
+Recognized values:
+.BR principal .
+
+See
+.BR rpc.svcgssd (8)
+for details.
+
+.TP
 .B exportfs
 Only
 .B debug=
diff --git a/utils/gssd/svcgssd.c b/utils/gssd/svcgssd.c
index 0fe7c6ddb686..1fb579aa03f3 100644
--- a/utils/gssd/svcgssd.c
+++ b/utils/gssd/svcgssd.c
@@ -61,6 +61,9 @@
 #include "svcgssd.h"
 #include "gss_util.h"
 #include "err_util.h"
+#include "conffile.h"
+
+char *conf_path = NFS_CONFFILE;
 
 void
 sig_die(int signal)
@@ -98,6 +101,17 @@ main(int argc, char *argv[])
 	extern char *optarg;
 	char *progname;
 	char *principal = NULL;
+	char *s;
+
+	conf_init();
+
+	s = conf_get_str("svcgssd", "principal");
+	if (!s)
+		;
+	else if (strcmp(s, "system")== 0)
+		get_creds = 0;
+	else
+		principal = s;
 
 	while ((opt = getopt(argc, argv, "fivrnp:")) != -1) {
 		switch (opt) {
diff --git a/utils/gssd/svcgssd.man b/utils/gssd/svcgssd.man
index 7b2de6b1ab91..15ef4c94af19 100644
--- a/utils/gssd/svcgssd.man
+++ b/utils/gssd/svcgssd.man
@@ -45,6 +45,23 @@ Use the system default credentials
 .RI (host/ FQDN @ REALM )
 rather than the default
 .RI nfs/ FQDN @ REALM .
+.SH CONFIGURATION FILE
+Some of the options that can be set on the command line can also be
+controlled through values set in the
+.B [svcgssd]
+section of the
+.I /etc/nfs.conf
+configuration file.  Values recognized include:
+.TP
+.B principal
+If set to
+.B system
+this is equivalent to the
+.B -n
+option.  If set to any other value, that is used like the
+.B -p
+option.
+
 .SH SEE ALSO
 .BR rpc.gssd(8),
 .SH AUTHORS


