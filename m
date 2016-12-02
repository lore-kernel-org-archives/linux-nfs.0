Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:36433 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751164AbcLBD7T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Dec 2016 22:59:19 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>,
        Steve Dickson <SteveD@redhat.com>
Date: Fri, 02 Dec 2016 14:58:28 +1100
Subject: [PATCH 05/15] Add /etc/nfs.conf support for statd
Cc: linux-nfs@vger.kernel.org
Message-ID: <148065110872.28046.13166174517415675834.stgit@noble>
In-Reply-To: <148065078775.28046.5506130555300891075.stgit@noble>
References: <148065078775.28046.5506130555300891075.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some options appear in the [lockd] section.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 systemd/nfs.conf.man  |   25 +++++++++++++++++++++++++
 utils/statd/statd.c   |   20 ++++++++++++++++++++
 utils/statd/statd.man |   35 +++++++++++++++++++++++++++++++++--
 3 files changed, 78 insertions(+), 2 deletions(-)

diff --git a/systemd/nfs.conf.man b/systemd/nfs.conf.man
index 9fe9d0eff1fc..a1121e46ef5e 100644
--- a/systemd/nfs.conf.man
+++ b/systemd/nfs.conf.man
@@ -118,6 +118,31 @@ section, are used to configure mountd.  See
 .BR rpc.mountd (8)
 for details.
 
+.TP
+.B statd
+Recognized values:
+.BR port ,
+.BR outgoing-port ,
+.BR name ,
+.BR state-directory-path ,
+.BR ha-callout .
+
+See
+.BR rpc.statd (8)
+for details.
+
+.TP
+.B lockd
+Recognized values:
+.B port
+and
+.BR udp-port .
+
+See
+.BR rpc.statd (8)
+for details.
+
+
 .SH FILES
 .I /etc/nfs.conf
 .SH SEE ALSO
diff --git a/utils/statd/statd.c b/utils/statd/statd.c
index 15f2b18d104d..5f4ad79e6bf3 100644
--- a/utils/statd/statd.c
+++ b/utils/statd/statd.c
@@ -26,6 +26,7 @@
 #include <sys/wait.h>
 #include <grp.h>
 
+#include "conffile.h"
 #include "statd.h"
 #include "nfslib.h"
 #include "nfsrpc.h"
@@ -36,6 +37,7 @@
 #include <sys/socket.h>
 
 int	run_mode = 0;		/* foreground logging mode */
+char	*conf_path = NFS_CONFFILE;
 
 /* LH - I had these local to main, but it seemed silly to have 
  * two copies of each - one in main(), one static in log.c... 
@@ -242,6 +244,7 @@ static void set_nlm_port(char *type, int port)
 int main (int argc, char **argv)
 {
 	extern char *optarg;
+	char *s;
 	int pid;
 	int arg;
 	int port = 0, out_port = 0;
@@ -266,6 +269,23 @@ int main (int argc, char **argv)
 	/* Set hostname */
 	MY_NAME = NULL;
 
+	conf_init();
+	out_port = conf_get_num("statd", "outgoing-port", out_port);
+	port = conf_get_num("statd", "port", port);
+	MY_NAME = conf_get_str("statd", "name");
+	if (MY_NAME)
+		run_mode |= STATIC_HOSTNAME;
+	s = conf_get_str("statd", "state-directory-path");
+	if (s && !nsm_setup_pathnames(argv[0], s))
+		exit(1);
+	s = conf_get_str("statd", "ha-callout");
+	if (s)
+		ha_callout_prog = s;
+
+	nlm_tcp = conf_get_num("lockd", "port", nlm_tcp);
+	/* udp defaults to the same as tcp ! */
+	nlm_udp = conf_get_num("lockd", "udp-port", nlm_tcp);
+
 	/* Process command line switches */
 	while ((arg = getopt_long(argc, argv, "h?vVFNH:dn:p:o:P:LT:U:", longopts, NULL)) != EOF) {
 		switch (arg) {
diff --git a/utils/statd/statd.man b/utils/statd/statd.man
index 1e5520c6dfea..91c260f1bf5e 100644
--- a/utils/statd/statd.man
+++ b/utils/statd/statd.man
@@ -8,7 +8,7 @@
 .\" Rewritten by Chuck Lever <chuck.lever@oracle.com>, 2009.
 .\" Copyright 2009 Oracle.  All rights reserved.
 .\"
-.TH RPC.STATD 8 "1 November 2009
+.TH RPC.STATD 8 "1 November 2009"
 .SH NAME
 rpc.statd \- NSM service daemon
 .SH SYNOPSIS
@@ -247,7 +247,7 @@ should listen on for
 .B NLM
 requests.
 .TP
-.BI "\-P, " "" \-\-state\-directory\-path " pathname
+.BI "\-P, " "" \-\-state\-directory\-path " pathname"
 Specifies the pathname of the parent directory
 where NSM state information resides.
 If this option is not specified,
@@ -267,6 +267,37 @@ Causes
 to display version information on
 .I stderr
 and then exit.
+.SH CONFIGURATION FILE
+Many of the options that can be set on the command line can also be
+controlled through values set in the
+.B [statd]
+or, in some cases, the
+.B [lockd]
+sections of the
+.I /etc/nfs.conf
+configuration file.
+Values recognized in the
+.B [statd]
+section include
+.BR port ,
+.BR outgoing-port ,
+.BR name ,
+.BR state-directory-path ", and"
+.B ha-callout
+which each have the same effect as the option with the same name.
+
+The values recognized in the
+.B [lockd]
+section include
+.B port
+and
+.B udp-port
+which have the same effect as the
+.B --nlm-port
+and
+.B --nlm-udp-port
+options, respectively.
+
 .SH SECURITY
 The
 .B rpc.statd


