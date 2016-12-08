Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:44037 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752789AbcLHEaB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Dec 2016 23:30:01 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>,
        Steve Dickson <SteveD@redhat.com>
Date: Thu, 08 Dec 2016 15:27:26 +1100
Subject: [PATCH 09/10] gssd: add /etc/nfs.conf support
Cc: linux-nfs@vger.kernel.org
Message-ID: <148117124585.31271.16880270503226995999.stgit@noble>
In-Reply-To: <148117122602.31271.13586847542442809540.stgit@noble>
References: <148117122602.31271.13586847542442809540.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: NeilBrown <neilb@suse.com>
---
 systemd/nfs.conf.man |   18 +++++++++++++++++
 utils/gssd/gssd.c    |   29 +++++++++++++++++++++++++++
 utils/gssd/gssd.man  |   54 ++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 101 insertions(+)

diff --git a/systemd/nfs.conf.man b/systemd/nfs.conf.man
index 9e427a61d621..938b9705414a 100644
--- a/systemd/nfs.conf.man
+++ b/systemd/nfs.conf.man
@@ -190,6 +190,24 @@ See
 for details.
 
 .TP
+.B gssd
+Recognized values:
+.BR use-memcache ,
+.BR use-machine-creds ,
+.BR avoid-dns ,
+.BR limit-to-legacy-enctypes ,
+.BR context-timeout ,
+.BR rpc-timeout ,
+.BR pipefs-directory ,
+.BR keytab-file ,
+.BR cred-cache-directory ,
+.BR preferred-realm .
+
+See
+.BR rpc.gssd (8)
+for details.
+
+.TP
 .B exportfs
 Only
 .B debug=
diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 3b4d1476c0ad..c65e97cb8fac 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -71,6 +71,7 @@
 #include "gss_util.h"
 #include "krb5_util.h"
 #include "nfslib.h"
+#include "conffile.h"
 
 static char *pipefs_path = GSSD_PIPEFS_DIR;
 static DIR *pipefs_dir;
@@ -78,6 +79,7 @@ static int pipefs_fd;
 static int inotify_fd;
 struct event inotify_ev;
 
+char *conf_path = NFS_CONFFILE;
 char *keytabfile = GSSD_DEFAULT_KEYTAB_FILE;
 char **ccachesearch;
 int  use_memcache = 0;
@@ -847,6 +849,33 @@ main(int argc, char *argv[])
 	char *progname;
 	char *ccachedir = NULL;
 	struct event sighup_ev;
+	char *s;
+
+	conf_init();
+	use_memcache = conf_get_bool("gssd", "use-memcache", use_memcache);
+	root_uses_machine_creds = conf_get_bool("gssd", "use-machine-creds",
+						root_uses_machine_creds);
+	avoid_dns = conf_get_bool("gssd", "avoid-dns", avoid_dns);
+#ifdef HAVE_SET_ALLOWABLE_ENCTYPES
+	limit_to_legacy_enctypes = conf_get_bool("gssd", "limit-to-legacy-enctypes",
+						 limit_to_legacy_enctypes);
+#endif
+	context_timeout = conf_get_num("gssd", "context-timeout", context_timeout);
+	rpc_timeout = conf_get_num("gssd", "rpc-timeout", rpc_timeout);
+	s = conf_get_str("gssd", "pipefs-directory");
+	if (!s)
+		s = conf_get_str("general", "pipefs-directory");
+	if (s)
+		pipefs_path = s;
+	s = conf_get_str("gssd", "keytab-file");
+	if (s)
+		keytablfile = s;
+	s = conf_get_str("gssd", "cred-cache-directory");
+	if (s)
+		ccachedir = s;
+	s = conf_get_str("gssd", "preferred-realm");
+	if (s)
+		preferred_realm = s;
 
 	while ((opt = getopt(argc, argv, "DfvrlmnMp:k:d:t:T:R:")) != -1) {
 		switch (opt) {
diff --git a/utils/gssd/gssd.man b/utils/gssd/gssd.man
index ea58fa0965e8..87eef0249a12 100644
--- a/utils/gssd/gssd.man
+++ b/utils/gssd/gssd.man
@@ -297,6 +297,60 @@ The default timeout is set to 5 seconds.
 If you get messages like "WARNING: can't create tcp rpc_clnt to server
 %servername% for user with uid %uid%: RPC: Remote system error -
 Connection timed out", you should consider an increase of this timeout.
+.SH CONFIGURATION FILE
+Many of the options that can be set on the command line can also be
+controlled through values set in the
+.B [gssd]
+section of the
+.I /etc/nfs.conf
+configuration file.  Values recognized include:
+.TP
+.B use-memcache
+A Boolean flag equivalent to
+.BR -M .
+.TP
+.B use-machine-creds
+A Boolean flag. Setting to
+.B false
+is equivalent to giving the
+.B -n
+flag.
+.TP
+.B avoid-dns
+Setting to
+.B false
+is equivalent to providing the
+.B -D
+flag.
+.TP
+.B limit-to-legacy-enctypes
+Equivalent to
+.BR -l .
+.TP
+.B context-timeout
+Equivalent to
+.BR -T .
+.TP
+.B rpc-timeout
+Equivalent to
+.BR -t .
+.TP
+.B pipefs-directory
+Equivalent to
+.BR -p .
+.TP
+.B keytab-file
+Equivalent to
+.BR -k .
+.TP
+.BR cred-cache-directory
+Equivalent to
+.BR -d .
+.TP
+.B preferred-realm
+Equivalent to
+.BR -R .
+
 .SH SEE ALSO
 .BR rpc.svcgssd (8),
 .BR kerberos (1),


