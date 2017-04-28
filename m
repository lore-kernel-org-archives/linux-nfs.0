Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38708 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1425047AbdD1Itx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 28 Apr 2017 04:49:53 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 5D288C051664
        for <linux-nfs@vger.kernel.org>; Fri, 28 Apr 2017 08:49:53 +0000 (UTC)
Received: from jumitche.remote.csb (unknown [10.33.36.27])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id B5D7288B28
        for <linux-nfs@vger.kernel.org>; Fri, 28 Apr 2017 08:49:52 +0000 (UTC)
Message-ID: <1493369389.4169.4.camel@redhat.com>
Subject: [PATCH] Remove the conf_path global
From: Justin Mitchell <jumitche@redhat.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Fri, 28 Apr 2017 09:49:49 +0100
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Working towards an nfs.conf library and API for system config tools,
first step, replace the conf_path global with a parameter to conf_init

Signed-off-by: Justin Mitchell <jumitche@rehat.com>
---
 support/include/conffile.h       |  5 +----
 support/nfs/conffile.c           | 41 ++++++++++++++++++++++------------------
 systemd/rpc-pipefs-generator.c   |  3 +--
 utils/blkmapd/device-discovery.c |  4 +---
 utils/exportfs/exportfs.c        |  3 +--
 utils/gssd/gssd.c                |  3 +--
 utils/gssd/svcgssd.c             |  4 +---
 utils/idmapd/idmapd.c            | 10 ++++------
 utils/mount/configfile.c         |  4 ----
 utils/mount/mount_config.h       |  6 +++++-
 utils/mountd/mountd.c            |  4 +---
 utils/nfsd/nfsd.c                |  4 +---
 utils/nfsdcltrack/nfsdcltrack.c  |  4 +---
 utils/statd/sm-notify.c          |  3 +--
 utils/statd/statd.c              |  3 +--
 15 files changed, 43 insertions(+), 58 deletions(-)

diff --git a/support/include/conffile.h b/support/include/conffile.h
index 3fe3a78..20b1a32 100644
--- a/support/include/conffile.h
+++ b/support/include/conffile.h
@@ -48,8 +48,6 @@ struct conf_list {
 	TAILQ_HEAD(conf_list_fields_head, conf_list_node) fields;
 };
 
-extern char    *conf_path;
-
 extern int      conf_begin(void);
 extern int      conf_decode_base64(uint8_t *, uint32_t *, unsigned char *);
 extern int      conf_end(int, int);
@@ -61,9 +59,8 @@ extern int      conf_get_num(char *, char *, int);
 extern _Bool    conf_get_bool(char *, char *, _Bool);
 extern char    *conf_get_str(char *, char *);
 extern char    *conf_get_section(char *, char *, char *);
-extern void     conf_init(void);
+extern void     conf_init(const char *);
 extern int      conf_match_num(char *, char *, int);
-extern void     conf_reinit(void);
 extern int      conf_remove(int, char *, char *);
 extern int      conf_remove_section(int, char *);
 extern void     conf_report(void);
diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index 203efd2..1bc8c01 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -30,6 +30,10 @@
  * This code was written under funding by Ericsson Radio Systems.
  */
 
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
 #include <sys/param.h>
 #include <sys/mman.h>
 #include <sys/socket.h>
@@ -52,7 +56,7 @@
 #pragma GCC visibility push(hidden)
 
 static void conf_load_defaults(void);
-static int conf_load(int trans, char *path);
+static int conf_load(int trans, const char *path);
 static int conf_set(int , char *, char *, char *, 
 	char *, int , int );
 
@@ -105,7 +109,6 @@ struct conf_binding {
   int is_default;
 };
 
-char *conf_path;
 LIST_HEAD (conf_bindings, conf_binding) conf_bindings[256];
 
 static __inline__ uint8_t
@@ -369,20 +372,8 @@ conf_load_defaults(void)
 	return;
 }
 
-void
-conf_init (void)
-{
-	unsigned int i;
-
-	for (i = 0; i < sizeof conf_bindings / sizeof conf_bindings[0]; i++)
-		LIST_INIT (&conf_bindings[i]);
-
-	TAILQ_INIT (&conf_trans_queue);
-	conf_reinit();
-}
-
 static int
-conf_load(int trans, char *path)
+conf_load(int trans, const char *path)
 {
 	struct stat sb;
 	if ((stat (path, &sb) == 0) || (errno != ENOENT)) {
@@ -421,15 +412,15 @@ conf_load(int trans, char *path)
 }
 
 /* Open the config file and map it into our address space, then parse it.  */
-void
-conf_reinit(void)
+static void
+conf_reinit(const char *conf_file)
 {
 	struct conf_binding *cb = 0;
 	int trans;
 	unsigned int i;
 
 	trans = conf_begin();
-	if (conf_load(trans, conf_path) < 0)
+	if (conf_load(trans, conf_file) < 0)
 		return;
 
 	/* Load default configuration values.  */
@@ -446,6 +437,20 @@ conf_reinit(void)
 	return;
 }
 
+void
+conf_init (const char *conf_file)
+{
+	unsigned int i;
+
+	for (i = 0; i < sizeof conf_bindings / sizeof conf_bindings[0]; i++)
+		LIST_INIT (&conf_bindings[i]);
+
+	TAILQ_INIT (&conf_trans_queue);
+
+	if (conf_file == NULL) conf_file=NFS_CONFFILE;
+	conf_reinit(conf_file);
+}
+
 /*
  * Return the numeric value denoted by TAG in section SECTION or DEF
  * if that tag does not exist.
diff --git a/systemd/rpc-pipefs-generator.c b/systemd/rpc-pipefs-generator.c
index 66addb9..59eee87 100644
--- a/systemd/rpc-pipefs-generator.c
+++ b/systemd/rpc-pipefs-generator.c
@@ -22,7 +22,6 @@
 #include "systemd.h"
 
 #define RPC_PIPEFS_DEFAULT "/var/lib/nfs/rpc_pipefs"
-char *conf_path = NFS_CONFFILE;
 
 static int generate_mount_unit(const char *pipefs_path, const char *pipefs_unit,
 			       const char *dirname)
@@ -122,7 +121,7 @@ int main(int argc, char *argv[])
 		exit(1);
 	}
 
-	conf_init();
+	conf_init(NFS_CONFFILE);
 	s = conf_get_str("general", "pipefs-directory");
 	if (!s)
 		exit(0);
diff --git a/utils/blkmapd/device-discovery.c b/utils/blkmapd/device-discovery.c
index d2da764..c66669d 100644
--- a/utils/blkmapd/device-discovery.c
+++ b/utils/blkmapd/device-discovery.c
@@ -78,7 +78,6 @@ static char rpcpipe_dir[PATH_MAX];
 struct bl_disk *visible_disk_list;
 int    bl_watch_fd, bl_pipe_fd, nfs_pipedir_wfd, rpc_pipedir_wfd;
 int    pidfd = -1;
-char   *conf_path = NULL;
 
 
 struct bl_disk_path *bl_get_path(const char *filepath,
@@ -456,8 +455,7 @@ int main(int argc, char **argv)
 	char *xrpcpipe_dir = NULL;
 
 	strncpy(rpcpipe_dir, RPCPIPE_DIR, sizeof(rpcpipe_dir));
-	conf_path = NFS_CONFFILE;
-	conf_init();
+	conf_init(NFS_CONFFILE);
 	CONF_SAVE(xrpcpipe_dir, conf_get_str("general", "pipefs-directory"));
 	if (xrpcpipe_dir != NULL)
 		strlcpy(rpcpipe_dir, xrpcpipe_dir, sizeof(rpcpipe_dir));
diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 02d5b6d..beed1b3 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -50,7 +50,6 @@ static void release_lockfile(void);
 
 static const char *lockfile = EXP_LOCKFILE;
 static int _lockfd = -1;
-char *conf_path = NFS_CONFFILE;
 
 struct state_paths etab;
 
@@ -108,7 +107,7 @@ main(int argc, char **argv)
 	xlog_stderr(1);
 	xlog_syslog(0);
 
-	conf_init();
+	conf_init(NFS_CONFFILE);
 	xlog_from_conffile("exportfs");
 
 	/* NOTE: following uses "mountd" section of nfs.conf !!!! */
diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 28f9649..053a223 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -79,7 +79,6 @@ static int pipefs_fd;
 static int inotify_fd;
 struct event inotify_ev;
 
-char *conf_path = NFS_CONFFILE;
 char *keytabfile = GSSD_DEFAULT_KEYTAB_FILE;
 char **ccachesearch;
 int  use_memcache = 0;
@@ -843,7 +842,7 @@ read_gss_conf(void)
 {
 	char *s;
 
-	conf_init();
+	conf_init(NFS_CONFFILE);
 	use_memcache = conf_get_bool("gssd", "use-memcache", use_memcache);
 	root_uses_machine_creds = conf_get_bool("gssd", "use-machine-creds",
 						root_uses_machine_creds);
diff --git a/utils/gssd/svcgssd.c b/utils/gssd/svcgssd.c
index 1fb579a..3514ae1 100644
--- a/utils/gssd/svcgssd.c
+++ b/utils/gssd/svcgssd.c
@@ -63,8 +63,6 @@
 #include "err_util.h"
 #include "conffile.h"
 
-char *conf_path = NFS_CONFFILE;
-
 void
 sig_die(int signal)
 {
@@ -103,7 +101,7 @@ main(int argc, char *argv[])
 	char *principal = NULL;
 	char *s;
 
-	conf_init();
+	conf_init(NFS_CONFFILE); 
 
 	s = conf_get_str("svcgssd", "principal");
 	if (!s)
diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
index 56bf67e..c12e878 100644
--- a/utils/idmapd/idmapd.c
+++ b/utils/idmapd/idmapd.c
@@ -165,9 +165,6 @@ static char *nobodyuser, *nobodygroup;
 static uid_t nobodyuid;
 static gid_t nobodygid;
 
-/* Used by conffile.c in libnfs.a */
-char *conf_path = NULL;
-
 static int
 flush_nfsd_cache(char *path, time_t now)
 {
@@ -219,6 +216,7 @@ main(int argc, char **argv)
 	int serverstart = 1, clientstart = 1;
 	int ret;
 	char *progname;
+	char *conf_path = NULL;
 
 	nobodyuser = NFS4NOBODY_USER;
 	nobodygroup = NFS4NOBODY_GROUP;
@@ -254,7 +252,7 @@ main(int argc, char **argv)
 			warn("Skipping configuration file \"%s\"", conf_path);
 			conf_path = NULL;
 		} else {
-			conf_init();
+			conf_init(conf_path);
 			verbose = conf_get_num("General", "Verbosity", 0);
 			cache_entry_expiration = conf_get_num("General",
 					"Cache-Expiration", DEFAULT_IDMAP_CACHE_EXPIRY);
@@ -266,13 +264,13 @@ main(int argc, char **argv)
 		}
 	} else {
 		conf_path = NFS_CONFFILE;
-		conf_init();
+		conf_init(conf_path);
 		CONF_SAVE(xpipefsdir, conf_get_str("General", "Pipefs-Directory"));
 		if (xpipefsdir != NULL)
 			strlcpy(pipefsdir, xpipefsdir, sizeof(pipefsdir));
 
 		conf_path = _PATH_IDMAPDCONF;
-		conf_init();
+		conf_init(conf_path);
 		verbose = conf_get_num("General", "Verbosity", 0);
 		cache_entry_expiration = conf_get_num("General",
 				"cache-expiration", DEFAULT_IDMAP_CACHE_EXPIRY);
diff --git a/utils/mount/configfile.c b/utils/mount/configfile.c
index 0a4cc04..dc964c7 100644
--- a/utils/mount/configfile.c
+++ b/utils/mount/configfile.c
@@ -51,10 +51,6 @@
 #define NFSMOUNT_SERVER "Server"
 #endif
 
-#ifndef MOUNTOPTS_CONFFILE
-#define MOUNTOPTS_CONFFILE "/etc/nfsmount.conf"
-#endif
-char *conf_path = MOUNTOPTS_CONFFILE;
 enum {
 	MNT_NOARG=0,
 	MNT_INTARG,
diff --git a/utils/mount/mount_config.h b/utils/mount/mount_config.h
index 69ffd1e..e4f8511 100644
--- a/utils/mount/mount_config.h
+++ b/utils/mount/mount_config.h
@@ -20,6 +20,10 @@
 #include "conffile.h"
 #include "xlog.h"
 
+#ifndef MOUNTOPTS_CONFFILE
+#define MOUNTOPTS_CONFFILE "/etc/nfsmount.conf"
+#endif
+
 extern char *conf_get_mntopts(char *, char *, char *);
 
 static inline void mount_config_init(char *program)
@@ -28,7 +32,7 @@ static inline void mount_config_init(char *program)
 	/*
 	 * Read the the default mount options
 	 */
-	conf_init();
+	conf_init(MOUNTOPTS_CONFFILE);
 }
 
 static inline char *mount_config_opts(char *spec,
diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index bbadfaf..829f803 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -44,8 +44,6 @@ int use_ipaddr = -1;
 struct state_paths etab;
 struct state_paths rmtab;
 
-char *conf_path = NFS_CONFFILE;
-
 /* PRC: a high-availability callout program can be specified with -H
  * When this is done, the program will receive callouts whenever clients
  * send mount or unmount requests -- the callout is not needed for 2.6 kernel */
@@ -681,7 +679,7 @@ main(int argc, char **argv)
 	else
 		progname = argv[0];
 
-	conf_init();
+	conf_init(NFS_CONFFILE);
 	xlog_from_conffile("mountd");
 	manage_gids = conf_get_bool("mountd", "manage-gids", manage_gids);
 	descriptors = conf_get_num("mountd", "descriptors", descriptors);
diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index cea850d..111058f 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -34,8 +34,6 @@
 #define NFSD_NPROC 8
 #endif
 
-char *conf_path = NFS_CONFFILE;
-
 static void	usage(const char *);
 
 static struct option longopts[] =
@@ -82,7 +80,7 @@ main(int argc, char **argv)
 	xlog_syslog(0);
 	xlog_stderr(1);
 
-	conf_init();
+	conf_init(NFS_CONFFILE); 
 	xlog_from_conffile("nfsd");
 	count = conf_get_num("nfsd", "threads", count);
 	grace = conf_get_num("nfsd", "grace-time", grace);
diff --git a/utils/nfsdcltrack/nfsdcltrack.c b/utils/nfsdcltrack/nfsdcltrack.c
index 7af9efb..124c923 100644
--- a/utils/nfsdcltrack/nfsdcltrack.c
+++ b/utils/nfsdcltrack/nfsdcltrack.c
@@ -56,8 +56,6 @@
 /* defined by RFC 3530 */
 #define NFS4_OPAQUE_LIMIT	1024
 
-char *conf_path = NFS_CONFFILE;
-
 /* private data structures */
 struct cltrack_cmd {
 	char *name;
@@ -566,7 +564,7 @@ main(int argc, char **argv)
 	xlog_syslog(1);
 	xlog_stderr(0);
 
-	conf_init();
+	conf_init(NFS_CONFFILE); 
 	xlog_from_conffile("nfsdcltrack");
 	val = conf_get_str("nfsdcltrack", "storagedir");
 	if (val)
diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 0c6766f..d216ddb 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -69,7 +69,6 @@ static _Bool		opt_update_state = true;
 static unsigned int	opt_max_retry = 15 * 60;
 static char *		opt_srcaddr = NULL;
 static char *		opt_srcport = NULL;
-char *			conf_path = NFS_CONFFILE;
 
 static void		notify(const int sock);
 static int		notify_host(int, struct nsm_host *);
@@ -491,7 +490,7 @@ main(int argc, char **argv)
 	else
 		progname = argv[0];
 
-	conf_init();
+	conf_init(NFS_CONFFILE);
 	xlog_from_conffile("sm-notify");
 	opt_max_retry = conf_get_num("sm-notify", "retry-time", opt_max_retry / 60) * 60;
 	opt_srcport = conf_get_str("sm-notify", "outgoing-port");
diff --git a/utils/statd/statd.c b/utils/statd/statd.c
index d333b29..1443715 100644
--- a/utils/statd/statd.c
+++ b/utils/statd/statd.c
@@ -37,7 +37,6 @@
 #include <sys/socket.h>
 
 int	run_mode = 0;		/* foreground logging mode */
-char	*conf_path = NFS_CONFFILE;
 
 /* LH - I had these local to main, but it seemed silly to have 
  * two copies of each - one in main(), one static in log.c... 
@@ -274,7 +273,7 @@ int main (int argc, char **argv)
 	/* Set hostname */
 	MY_NAME = NULL;
 
-	conf_init();
+	conf_init(NFS_CONFFILE);
 	xlog_from_conffile("statd");
 	out_port = conf_get_num("statd", "outgoing-port", out_port);
 	port = conf_get_num("statd", "port", port);
-- 
1.8.3.1



