Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40708 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755639AbdDEVMp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 5 Apr 2017 17:12:45 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 84FA2C04B94F
        for <linux-nfs@vger.kernel.org>; Wed,  5 Apr 2017 21:12:44 +0000 (UTC)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v2 1/4] idmapd: move the pipefs-directory config option to nfs.conf
Date: Wed,  5 Apr 2017 17:12:40 -0400
Message-Id: <20170405211243.12282-2-smayhew@redhat.com>
In-Reply-To: <20170405211243.12282-1-smayhew@redhat.com>
References: <20170405211243.12282-1-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Changed idmapd to read its value for the pipefs-directory from
/etc/nfs.conf rather than /etc/idmapd.conf.  All other configurations
related to id mapping still reside in /etc/idmapd.conf for now.

Added a warning to indicate that idmapd's -c option is deprecated.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 nfs.conf                |  3 +++
 systemd/nfs.conf.man    |  9 +++++++++
 utils/idmapd/idmapd.c   | 40 ++++++++++++++++++++++++++++------------
 utils/idmapd/idmapd.man | 21 ++++++++++++++++++++-
 4 files changed, 60 insertions(+), 13 deletions(-)

diff --git a/nfs.conf b/nfs.conf
index 81ece06..ed516f5 100644
--- a/nfs.conf
+++ b/nfs.conf
@@ -2,6 +2,9 @@
 # This is a general conifguration for the 
 # NFS daemons and tools
 #
+#[global]
+# pipefs-directory=/var/lib/nfs/rpc_pipefs
+#
 #[exportfs]
 # debug=0
 #
diff --git a/systemd/nfs.conf.man b/systemd/nfs.conf.man
index bdc0988..f8849c5 100644
--- a/systemd/nfs.conf.man
+++ b/systemd/nfs.conf.man
@@ -96,6 +96,15 @@ value, which can be one or more from the list
 .BR all .
 When a list is given, the members should be comma-separated.
 .TP
+.B global
+Recognized values:
+.BR pipefs-directory .
+
+See
+.BR rpc.idmapd (8)
+for details.
+
+.TP
 .B nfsdcltrack
 Recognized values:
 .BR storagedir .
diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
index f4e083a..5cac3a5 100644
--- a/utils/idmapd/idmapd.c
+++ b/utils/idmapd/idmapd.c
@@ -166,7 +166,7 @@ static uid_t nobodyuid;
 static gid_t nobodygid;
 
 /* Used by conffile.c in libnfs.a */
-char *conf_path;
+char *conf_path = NULL;
 
 static int
 flush_nfsd_cache(char *path, time_t now)
@@ -220,7 +220,6 @@ main(int argc, char **argv)
 	int ret;
 	char *progname;
 
-	conf_path = _PATH_IDMAPDCONF;
 	nobodyuser = NFS4NOBODY_USER;
 	nobodygroup = NFS4NOBODY_GROUP;
 	strlcpy(pipefsdir, PIPEFS_DIR, sizeof(pipefsdir));
@@ -234,8 +233,11 @@ main(int argc, char **argv)
 #define GETOPTSTR "hvfd:p:U:G:c:CS"
 	opterr=0; /* Turn off error messages */
 	while ((opt = getopt(argc, argv, GETOPTSTR)) != -1) {
-		if (opt == 'c')
+		if (opt == 'c') {
+			warnx("-c is deprecated and may be removed in the "
+			      "future.  See idmapd(8).");
 			conf_path = optarg;
+		}
 		if (opt == '?') {
 			if (strchr(GETOPTSTR, optopt))
 				warnx("'-%c' option requires an argument.", optopt);
@@ -247,17 +249,33 @@ main(int argc, char **argv)
 	}
 	optind = 1;
 
-	if (stat(conf_path, &sb) == -1 && (errno == ENOENT || errno == EACCES)) {
-		warn("Skipping configuration file \"%s\"", conf_path);
-		conf_path = NULL;
+	if (conf_path) { /* deprecated -c option was specified */
+		if (stat(conf_path, &sb) == -1 && (errno == ENOENT || errno == EACCES)) {
+			warn("Skipping configuration file \"%s\"", conf_path);
+			conf_path = NULL;
+		} else {
+			conf_init();
+			verbose = conf_get_num("General", "Verbosity", 0);
+			cache_entry_expiration = conf_get_num("General",
+					"Cache-Expiration", DEFAULT_IDMAP_CACHE_EXPIRY);
+			CONF_SAVE(xpipefsdir, conf_get_str("General", "Pipefs-Directory"));
+			if (xpipefsdir != NULL)
+				strlcpy(pipefsdir, xpipefsdir, sizeof(pipefsdir));
+			CONF_SAVE(nobodyuser, conf_get_str("Mapping", "Nobody-User"));
+			CONF_SAVE(nobodygroup, conf_get_str("Mapping", "Nobody-Group"));
+		}
 	} else {
+		conf_path = NFS_CONFFILE;
 		conf_init();
-		verbose = conf_get_num("General", "Verbosity", 0);
-		cache_entry_expiration = conf_get_num("General",
-				"Cache-Expiration", DEFAULT_IDMAP_CACHE_EXPIRY);
-		CONF_SAVE(xpipefsdir, conf_get_str("General", "Pipefs-Directory"));
+		CONF_SAVE(xpipefsdir, conf_get_str("global", "pipefs-directory"));
 		if (xpipefsdir != NULL)
 			strlcpy(pipefsdir, xpipefsdir, sizeof(pipefsdir));
+
+		conf_path = _PATH_IDMAPDCONF;
+		conf_init();
+		verbose = conf_get_num("General", "Verbosity", 0);
+		cache_entry_expiration = conf_get_num("General",
+				"cache-expiration", DEFAULT_IDMAP_CACHE_EXPIRY);
 		CONF_SAVE(nobodyuser, conf_get_str("Mapping", "Nobody-User"));
 		CONF_SAVE(nobodygroup, conf_get_str("Mapping", "Nobody-Group"));
 	}
@@ -307,8 +325,6 @@ main(int argc, char **argv)
 #ifdef HAVE_NFS4_SET_DEBUG
 	nfs4_set_debug(verbose, xlog_warn);
 #endif
-	if (conf_path == NULL)
-		conf_path = _PATH_IDMAPDCONF;
 	if (nfs4_init_name_mapping(conf_path))
 		errx(1, "Unable to create name to user id mappings.");
 
diff --git a/utils/idmapd/idmapd.man b/utils/idmapd/idmapd.man
index d4ab894..301a8e9 100644
--- a/utils/idmapd/idmapd.man
+++ b/utils/idmapd/idmapd.man
@@ -73,11 +73,28 @@ The default value is \&"/var/lib/nfs/rpc_pipefs\&".
 .It Fl c Ar path
 Use configuration file
 .Ar path .
+This option is deprecated.
 .It Fl C
 Client-only: perform no idmapping for any NFS server, even if one is detected.
 .It Fl S
 Server-only: perform no idmapping for any NFS client, even if one is detected.
 .El
+.Sh CONFIGURATION FILES
+.Nm
+recognizes the following value from the
+.Sy [global]
+section of the
+.Pa /etc/nfs.conf
+configuration file:
+.Bl -tag -width Ds_imagedir
+.It Sy pipefs-directory
+Equivalent to
+.Sy -p .
+.El
+.Pp
+All other settings related to id mapping are found in the
+.Pa /etc/idmapd.conf
+configuration file.
 .Sh EXAMPLES
 .Cm rpc.idmapd -f -vvv
 .Pp
@@ -94,9 +111,11 @@ messages to console, and with a verbosity level of 3.
 .\" This next request is for sections 1, 6, 7 & 8 only.
 .\" .Sh ENVIRONMENT
 .Sh FILES
-.Pa /etc/idmapd.conf
+.Pa /etc/idmapd.conf ,
+.Pa /etc/nfs.conf
 .Sh SEE ALSO
 .Xr idmapd.conf 5 ,
+.Xr nfs.conf 5 ,
 .Xr nfsidmap 8
 .\".Sh SEE ALSO
 .\".Xr nylon.conf 4
-- 
2.9.3

