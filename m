Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:43404 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751802AbeBTSug (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Feb 2018 13:50:36 -0500
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.rdu2.redhat.com [10.11.54.3])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id CD344A2E6C
        for <linux-nfs@vger.kernel.org>; Tue, 20 Feb 2018 18:50:35 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id AB14410A9DE7
        for <linux-nfs@vger.kernel.org>; Tue, 20 Feb 2018 18:50:35 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/7] Removed missing-prototypes warnings.
Date: Tue, 20 Feb 2018 13:50:29 -0500
Message-Id: <20180220185034.26301-3-steved@redhat.com>
In-Reply-To: <20180220185034.26301-1-steved@redhat.com>
References: <20180220185034.26301-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Added the -Werror=missing-prototypes warning flag
then cleaned up the mess.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 configure.ac                       |  4 +++-
 support/misc/mountpoint.c          |  1 +
 support/nfs/atomicio.c             |  2 ++
 support/nfs/closeall.c             |  2 ++
 support/nfs/rpcmisc.c              |  1 +
 support/nfs/strlcat.c              |  2 ++
 support/nfs/strlcpy.c              |  2 ++
 support/nfs/svc_socket.c           |  2 ++
 support/nfs/wildmat.c              |  1 +
 support/nfsidmap/libnfsidmap.c     |  3 ++-
 support/nfsidmap/nfsidmap_plugin.h |  1 +
 support/nfsidmap/nss.c             |  2 +-
 systemd/systemd.c                  |  1 +
 utils/blkmapd/device-discovery.c   | 10 +++++-----
 utils/blkmapd/dm-device.c          |  2 +-
 utils/gssd/err_util.c              |  1 +
 utils/gssd/gss_names.c             |  1 +
 utils/gssd/gssd_proc.c             |  4 ++--
 utils/gssd/svcgssd.c               |  4 ++--
 utils/gssd/svcgssd_mech2file.c     |  1 +
 utils/idmapd/idmapd.c              |  2 +-
 utils/mount/configfile.c           |  4 ++++
 utils/mount/mount_libmount.c       |  2 ++
 utils/mountd/svc_run.c             |  1 +
 utils/nfsdcltrack/sqlite.c         |  3 ++-
 utils/nfsstat/nfsstat.c            |  2 +-
 utils/statd/svc_run.c              |  1 +
 27 files changed, 46 insertions(+), 16 deletions(-)

diff --git a/configure.ac b/configure.ac
index b3f6b97..31990c3 100644
--- a/configure.ac
+++ b/configure.ac
@@ -547,7 +547,9 @@ my_am_cflags="\
  -pipe \
  -Wall \
  -Wextra \
- -Wstrict-prototypes \
+ -Werror=strict-prototypes \
+ -Werror=missing-prototypes \
+ -Werror=missing-declarations \
 "
 
 AC_SUBST([AM_CFLAGS], ["$my_am_cflags"])
diff --git a/support/misc/mountpoint.c b/support/misc/mountpoint.c
index a72fb92..9f9ce44 100644
--- a/support/misc/mountpoint.c
+++ b/support/misc/mountpoint.c
@@ -6,6 +6,7 @@
 #include <string.h>
 #include "xcommon.h"
 #include <sys/stat.h>
+#include "misc.h"
 
 int
 is_mountpoint(char *path)
diff --git a/support/nfs/atomicio.c b/support/nfs/atomicio.c
index aa819ca..0e81838 100644
--- a/support/nfs/atomicio.c
+++ b/support/nfs/atomicio.c
@@ -28,6 +28,8 @@
 #include <unistd.h>
 #include <errno.h>
 
+#include "nfslib.h"
+
 /*
  * ensure all of data on socket comes through. f==read || f==write
  */
diff --git a/support/nfs/closeall.c b/support/nfs/closeall.c
index a69bf35..e07253e 100644
--- a/support/nfs/closeall.c
+++ b/support/nfs/closeall.c
@@ -9,6 +9,8 @@
 #include <dirent.h>
 #include <errno.h>
 
+#include "nfslib.h"
+
 void
 closeall(int min)
 {
diff --git a/support/nfs/rpcmisc.c b/support/nfs/rpcmisc.c
index ae2c0a6..abe89ba 100644
--- a/support/nfs/rpcmisc.c
+++ b/support/nfs/rpcmisc.c
@@ -32,6 +32,7 @@
 #include <unistd.h>
 #include <time.h>
 #include "nfslib.h"
+#include "rpcmisc.h"
 
 #if SIZEOF_SOCKLEN_T - 0 == 0
 #define socklen_t int
diff --git a/support/nfs/strlcat.c b/support/nfs/strlcat.c
index daedd7a..0edee14 100644
--- a/support/nfs/strlcat.c
+++ b/support/nfs/strlcat.c
@@ -38,6 +38,8 @@ static char *rcsid = "$OpenBSD: strlcat.c,v 1.8 2001/05/13 15:40:15 deraadt Exp
 #include "config.h"
 #endif /* HAVE_CONFIG_H */
 
+#include "nfslib.h"
+
 /*
  * Appends src to string dst of size siz (unlike strncat, siz is the
  * full size of dst, not space left).  At most siz-1 characters
diff --git a/support/nfs/strlcpy.c b/support/nfs/strlcpy.c
index a2653ee..23e3ae9 100644
--- a/support/nfs/strlcpy.c
+++ b/support/nfs/strlcpy.c
@@ -38,6 +38,8 @@ static char *rcsid = "$OpenBSD: strlcpy.c,v 1.5 2001/05/13 15:40:16 deraadt Exp
 #include "config.h"
 #endif /* HAVE_CONFIG_H */
 
+#include "nfslib.h"
+
 /*
  * Copy src to string dst of size siz.  At most siz-1 characters
  * will be copied.  Always NUL terminates (unless siz == 0).
diff --git a/support/nfs/svc_socket.c b/support/nfs/svc_socket.c
index 1fa0d15..1239712 100644
--- a/support/nfs/svc_socket.c
+++ b/support/nfs/svc_socket.c
@@ -25,6 +25,8 @@
 #include <sys/fcntl.h>
 #include <errno.h>
 #include "xlog.h"
+#include "rpcmisc.h"
+#include "nfslib.h"
 
 #include "config.h"
 
diff --git a/support/nfs/wildmat.c b/support/nfs/wildmat.c
index c5b4c78..2f40358 100644
--- a/support/nfs/wildmat.c
+++ b/support/nfs/wildmat.c
@@ -41,6 +41,7 @@
 #endif
 
 #include <ctype.h>
+#include "nfslib.h"
 
 #define TRUE			1
 #define FALSE			0
diff --git a/support/nfsidmap/libnfsidmap.c b/support/nfsidmap/libnfsidmap.c
index 3b44da6..d9d44de 100644
--- a/support/nfsidmap/libnfsidmap.c
+++ b/support/nfsidmap/libnfsidmap.c
@@ -64,6 +64,7 @@
 
 #pragma GCC visibility push(hidden)
 
+void nfs4_cleanup_name_mapping(void);
 static char *default_domain;
 static struct mapping_plugin **nfs4_plugins = NULL;
 static struct mapping_plugin **gss_plugins = NULL;
@@ -327,7 +328,7 @@ out:
 	return ret;
 }
 
-char * get_default_domain(void)
+static char *get_default_domain(void)
 {
 	int ret;
 
diff --git a/support/nfsidmap/nfsidmap_plugin.h b/support/nfsidmap/nfsidmap_plugin.h
index e19efe5..708874c 100644
--- a/support/nfsidmap/nfsidmap_plugin.h
+++ b/support/nfsidmap/nfsidmap_plugin.h
@@ -51,6 +51,7 @@ struct trans_func {
 
 extern int idmap_verbosity;
 extern nfs4_idmap_log_function_t idmap_log_func;
+struct trans_func *libnfsidmap_plugin_init(void);
 
 /* Level zero always prints, others print depending on verbosity level */
 #define IDMAP_LOG(LVL, MSG) \
diff --git a/support/nfsidmap/nss.c b/support/nfsidmap/nss.c
index 6f024dc..65625a8 100644
--- a/support/nfsidmap/nss.c
+++ b/support/nfsidmap/nss.c
@@ -436,7 +436,7 @@ out:
 	return err;
 }
 
-int nss_gss_princ_to_grouplist(char *secname, char *princ,
+static int nss_gss_princ_to_grouplist(char *secname, char *princ,
 			       gid_t *groups, int *ngroups,
 			       extra_mapping_params **UNUSED(ex))
 {
diff --git a/systemd/systemd.c b/systemd/systemd.c
index 17820d4..c7bdb4d 100644
--- a/systemd/systemd.c
+++ b/systemd/systemd.c
@@ -8,6 +8,7 @@
 #include <stdlib.h>
 #include <ctype.h>
 #include <string.h>
+#include "systemd.h"
 
 static const char hex[16] =
 {
diff --git a/utils/blkmapd/device-discovery.c b/utils/blkmapd/device-discovery.c
index cae8c8d..b71c949 100644
--- a/utils/blkmapd/device-discovery.c
+++ b/utils/blkmapd/device-discovery.c
@@ -81,7 +81,7 @@ int    bl_watch_fd, bl_pipe_fd, nfs_pipedir_wfd, rpc_pipedir_wfd;
 int    pidfd = -1;
 
 
-struct bl_disk_path *bl_get_path(const char *filepath,
+static struct bl_disk_path *bl_get_path(const char *filepath,
 				 struct bl_disk_path *paths)
 {
 	struct bl_disk_path *tmp = paths;
@@ -103,7 +103,7 @@ struct bl_disk_path *bl_get_path(const char *filepath,
  * exist for each multipath device. If not, active device path will be
  * chosen for device creation.
  */
-int bl_update_path(enum bl_path_state_e state, struct bl_disk *disk)
+static int bl_update_path(enum bl_path_state_e state, struct bl_disk *disk)
 {
 	struct bl_disk_path *valid_path = disk->valid_path;
 
@@ -112,7 +112,7 @@ int bl_update_path(enum bl_path_state_e state, struct bl_disk *disk)
 	return 1;
 }
 
-void bl_release_disk(void)
+static void bl_release_disk(void)
 {
 	struct bl_disk *disk;
 	struct bl_disk_path *path = NULL;
@@ -133,7 +133,7 @@ void bl_release_disk(void)
 	}
 }
 
-void bl_add_disk(char *filepath)
+static void bl_add_disk(char *filepath)
 {
 	struct bl_disk *disk = NULL;
 	int fd = 0;
@@ -435,7 +435,7 @@ static int bl_event_helper(void)
 	return ret;
 }
 
-void sig_die(int signal)
+static void sig_die(int signal)
 {
 	if (pidfd >= 0) {
 		close(pidfd);
diff --git a/utils/blkmapd/dm-device.c b/utils/blkmapd/dm-device.c
index 24ffcbf..f2d4de4 100644
--- a/utils/blkmapd/dm-device.c
+++ b/utils/blkmapd/dm-device.c
@@ -210,7 +210,7 @@ static int dm_device_remove_byname(const char *dev_name)
 	return ret;
 }
 
-int dm_device_remove(uint64_t dev)
+static int dm_device_remove(uint64_t dev)
 {
 	struct dm_task *dmt;
 	struct dm_names *dmnames;
diff --git a/utils/gssd/err_util.c b/utils/gssd/err_util.c
index fe09eda..2b1132a 100644
--- a/utils/gssd/err_util.c
+++ b/utils/gssd/err_util.c
@@ -36,6 +36,7 @@
 #include <stdarg.h>
 #include <string.h>
 #include "xlog.h"
+#include "err_util.h"
 
 static int verbosity = 0;
 static int fg = 0;
diff --git a/utils/gssd/gss_names.c b/utils/gssd/gss_names.c
index 047069d..2a7f3a1 100644
--- a/utils/gssd/gss_names.c
+++ b/utils/gssd/gss_names.c
@@ -51,6 +51,7 @@
 
 #include "svcgssd.h"
 #include "gss_util.h"
+#include "gss_names.h"
 #include "err_util.h"
 #include "context.h"
 #include "misc.h"
diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 4fc81c3..ce73777 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -473,7 +473,7 @@ change_identity(uid_t uid)
 	return 0;
 }
 
-AUTH *
+static AUTH *
 krb5_not_machine_creds(struct clnt_info *clp, uid_t uid, char *tgtname,
 			int *downcall_err, int *chg_err, CLIENT **rpc_clnt)
 {
@@ -519,7 +519,7 @@ out:
 	return auth;
 }
 
-AUTH *
+static AUTH *
 krb5_use_machine_creds(struct clnt_info *clp, uid_t uid, char *tgtname,
 		    char *service, CLIENT **rpc_clnt)
 {
diff --git a/utils/gssd/svcgssd.c b/utils/gssd/svcgssd.c
index 23f0c0b..8e918cc 100644
--- a/utils/gssd/svcgssd.c
+++ b/utils/gssd/svcgssd.c
@@ -65,7 +65,7 @@
 
 struct state_paths etab;
 
-void
+static void
 sig_die(int signal)
 {
 	/* destroy krb5 machine creds */
@@ -73,7 +73,7 @@ sig_die(int signal)
 	exit(0);
 }
 
-void
+static void
 sig_hup(int signal)
 {
 	/* don't exit on SIGHUP */
diff --git a/utils/gssd/svcgssd_mech2file.c b/utils/gssd/svcgssd_mech2file.c
index ecd908b..c26b435 100644
--- a/utils/gssd/svcgssd_mech2file.c
+++ b/utils/gssd/svcgssd_mech2file.c
@@ -41,6 +41,7 @@
 #include <gssapi/gssapi.h>
 #include <string.h>
 
+char * mech2file(gss_OID mech);
 
 #define g_OID_equal(o1,o2) \
    (((o1)->length == (o2)->length) && \
diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
index 2b9ecea..c7e75bd 100644
--- a/utils/idmapd/idmapd.c
+++ b/utils/idmapd/idmapd.c
@@ -196,7 +196,7 @@ flush_nfsd_idmap_cache(void)
 	return ret;
 }
 
-void usage(char *progname)
+static void usage(char *progname)
 {
 	fprintf(stderr, "Usage: %s [-hfvCS] [-p path] [-c path]\n",
 		basename(progname));
diff --git a/utils/mount/configfile.c b/utils/mount/configfile.c
index 64688bf..b48b25e 100644
--- a/utils/mount/configfile.c
+++ b/utils/mount/configfile.c
@@ -35,6 +35,10 @@
 #include "network.h"
 #include "conffile.h"
 
+char *mountopts_convert(char *value);
+char *is_alias(char *opt);
+char *conf_get_mntopts(char *spec, char *mount_point, char *mount_opts);
+
 #define KBYTES(x)     ((x) * (1024))
 #define MEGABYTES(x)  ((x) * (1048576))
 #define GIGABYTES(x)  ((x) * (1073741824))
diff --git a/utils/mount/mount_libmount.c b/utils/mount/mount_libmount.c
index 2d40657..aa4ac5c 100644
--- a/utils/mount/mount_libmount.c
+++ b/utils/mount/mount_libmount.c
@@ -45,6 +45,8 @@
 #include "error.h"
 #include "utils.h"
 
+char *retrieve_mount_options(struct libmnt_fs *fs);
+
 char *progname;
 int nfs_mount_data_version;
 int verbose;
diff --git a/utils/mountd/svc_run.c b/utils/mountd/svc_run.c
index a572441..41b96d7 100644
--- a/utils/mountd/svc_run.c
+++ b/utils/mountd/svc_run.c
@@ -57,6 +57,7 @@
 #include <rpc/rpc_com.h>
 #endif
 
+void my_svc_run(void);
 void cache_set_fds(fd_set *fdset);
 int cache_process_req(fd_set *readfds);
 
diff --git a/utils/nfsdcltrack/sqlite.c b/utils/nfsdcltrack/sqlite.c
index 1552eba..c59f777 100644
--- a/utils/nfsdcltrack/sqlite.c
+++ b/utils/nfsdcltrack/sqlite.c
@@ -51,6 +51,7 @@
 #include <linux/limits.h>
 
 #include "xlog.h"
+#include "sqlite.h"
 
 #define CLTRACK_SQLITE_LATEST_SCHEMA_VERSION 2
 
@@ -203,7 +204,7 @@ rollback:
  * then insert schema version into the parameters table and commit the
  * transaction. On any error, rollback the transaction.
  */
-int
+static int
 sqlite_maindb_init_v2(void)
 {
 	int ret, ret2;
diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index eddbe9a..43fe0a8 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -300,7 +300,7 @@ int versions[] = {
 	PRNT_V4
 };
 
-void usage(char *name)
+static void usage(char *name)
 {
 	printf("Usage: %s [OPTION]...\n\
 \n\
diff --git a/utils/statd/svc_run.c b/utils/statd/svc_run.c
index 28c1ad6..d1dbd74 100644
--- a/utils/statd/svc_run.c
+++ b/utils/statd/svc_run.c
@@ -56,6 +56,7 @@
 #include "statd.h"
 #include "notlist.h"
 
+void my_svc_exit(void);
 static int	svc_stop = 0;
 
 /*
-- 
2.14.3

