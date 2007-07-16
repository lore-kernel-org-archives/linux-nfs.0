From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/17] mount.nfs: Create a common source module for
	reporting	mount errors
Date: Sun, 15 Jul 2007 23:15:19 -0400
Message-ID: <20070716031519.11209.76599.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IAH3S-0001nQ-1a
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:15:22 -0700
Received: from flpvm09.prodigy.net ([207.115.20.39])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IAH3V-0005yP-8H
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:15:25 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Clean up, and pre-requisite for subsequent fixes.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/Makefile.am    |    7 +
 utils/mount/mount.c        |   33 +-----
 utils/mount/nfs4mount.c    |    1 
 utils/mount/nfs_mount.h    |    1 
 utils/mount/nfsmount.c     |  128 ------------------------
 utils/mount/nfsmount_err.c |  235 ++++++++++++++++++++++++++++++++++++++++++++
 utils/mount/nfsmount_err.h |   28 +++++
 utils/mount/nfsumount.c    |   27 -----
 8 files changed, 277 insertions(+), 183 deletions(-)

diff --git a/utils/mount/Makefile.am b/utils/mount/Makefile.am
index 07e86e4..b7d6b82 100644
--- a/utils/mount/Makefile.am
+++ b/utils/mount/Makefile.am
@@ -9,8 +9,11 @@ man5_MANS	= nfs.man
 
 sbin_PROGRAMS	= mount.nfs
 EXTRA_DIST = nfsmount.x $(man8_MANS) $(man5_MANS)
-mount_nfs_SOURCES = mount.c nfsmount.c nfs4mount.c nfsumount.c \
-		  mount_constants.h nfs4_mount.h nfs_mount4.h
+mount_nfs_SOURCES = mount.c nfsmount_err.c \
+		    nfsmount.c nfs4mount.c \
+		    nfsumount.c \
+		    mount_constants.h nfsmount_err.h \
+		    nfs4_mount.h nfs_mount4.h
 
 mount_nfs_LDADD = ../../support/nfs/libnfs.a \
 		  ../../support/export/libexport.a
diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 3df57fc..28c4718 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -40,6 +40,7 @@
 #include "nfs4_mount.h"
 #include "nfsumount.h"
 #include "mount.h"
+#include "nfsmount_err.h"
 
 char *progname;
 int nomtab;
@@ -276,44 +277,20 @@ static void parse_opts (const char *options, int *flags, char **extra_opts)
 	}
 }
 
-static void mount_error(char *mntpnt, char *node)
-{
-	switch(errno) {
-		case ENOTDIR:
-			fprintf(stderr, "%s: mount point %s is not a directory\n", 
-				progname, mntpnt);
-			break;
-		case EBUSY:
-			fprintf(stderr, "%s: %s is already mounted or busy\n", 
-				progname, mntpnt);
-			break;
-		case ENOENT:
-			if (node) {
-				fprintf(stderr, "%s: %s failed, reason given by server: %s\n",
-					progname, node, strerror(errno));
-			} else
-				fprintf(stderr, "%s: mount point %s does not exist\n", 
-					progname, mntpnt);
-			break;
-		default:
-			fprintf(stderr, "%s: %s\n", progname, strerror(errno));
-	}
-}
 static int chk_mountpoint(char *mount_point)
 {
 	struct stat sb;
 
 	if (stat(mount_point, &sb) < 0){
-		mount_error(mount_point, NULL);
+		mount_error(NULL, mount_point, errno);
 		return 1;
 	}
 	if (S_ISDIR(sb.st_mode) == 0){
-		errno = ENOTDIR;
-		mount_error(mount_point, NULL);
+		mount_error(NULL, mount_point, ENOTDIR);
 		return 1;
 	}
 	if (access(mount_point, X_OK) < 0) {
-		mount_error(mount_point, NULL);
+		mount_error(NULL, mount_point, errno);
 		return 1;
 	}
 
@@ -523,7 +500,7 @@ int main(int argc, char *argv[])
 					   mount_opts);
 
 		if (mnt_err) {
-			mount_error(mount_point, spec);
+			mount_error(spec, mount_point, errno);
 			exit(EX_FAIL);
 		}
 	}
diff --git a/utils/mount/nfs4mount.c b/utils/mount/nfs4mount.c
index 4f6fc5f..ea2ac3a 100644
--- a/utils/mount/nfs4mount.c
+++ b/utils/mount/nfs4mount.c
@@ -43,6 +43,7 @@
 
 #include "nfs4_mount.h"
 #include "nfs_mount.h"
+#include "nfsmount_err.h"
 
 #if defined(VAR_LOCK_DIR)
 #define DEFAULT_DIR VAR_LOCK_DIR
diff --git a/utils/mount/nfs_mount.h b/utils/mount/nfs_mount.h
index 50ce2a8..b38aa0f 100644
--- a/utils/mount/nfs_mount.h
+++ b/utils/mount/nfs_mount.h
@@ -82,6 +82,5 @@ struct nfs_mount_data {
 
 int nfsmount(const char *, const char *, int *, char **, char **,
 	     int, int *);
-void mount_errors(char *, int, int);
 
 #endif /* _NFS_MOUNT_H */
diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index f21aaff..7c52c1c 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -64,13 +64,7 @@
 #include "nfs_mount.h"
 #include "mount_constants.h"
 #include "nls.h"
-
-#ifdef HAVE_RPCSVC_NFS_PROT_H
-#include <rpcsvc/nfs_prot.h>
-#else
-#include <linux/nfs.h>
-#define nfsstat nfs_stat
-#endif
+#include "nfsmount_err.h"
 
 #ifndef NFS_PORT
 #define NFS_PORT 2049
@@ -79,8 +73,6 @@
 #define NFS_FHSIZE 32
 #endif
 
-static char *nfs_strerror(int stat);
-
 #define MAKE_VERSION(p,q,r)	(65536*(p) + 256*(q) + (r))
 #define MAX_NFSPROT ((nfs_mount_version >= 4) ? 3 : 2)
 #define MAX_MNTPROT ((nfs_mount_version >= 4) ? 3 : 2)
@@ -101,68 +93,9 @@ typedef union {
 	mnt3res_t nfsv3;
 } mntres_t;
 
-static char errbuf[BUFSIZ];
-static char *erreob = &errbuf[BUFSIZ];
 extern int verbose;
 extern int sloppy;
 
-/* Convert RPC errors into strings */
-int rpc_strerror(int);
-int rpc_strerror(int spos)
-{
-	int cf_stat = rpc_createerr.cf_stat; 
-	int pos=0, cf_errno = rpc_createerr.cf_error.re_errno;
-	char *ptr, *estr = clnt_sperrno(cf_stat);
-	char *tmp;
-
-	if (estr) {
-		if ((ptr = index(estr, ':')))
-			estr = ++ptr;
-
-		tmp = &errbuf[spos];
-		if (cf_stat == RPC_SYSTEMERROR)
-			pos = snprintf(tmp, (erreob - tmp), 
-				"System Error: %s", strerror(cf_errno));
-		else
-			pos = snprintf(tmp, (erreob - tmp), "RPC Error:%s", estr);
-	}
-	return (pos);
-}
-void mount_errors(char *, int, int);
-void mount_errors(char *server, int will_retry, int bg)
-{
-	int pos = 0;
-	char *tmp;
-	static int onlyonce = 0;
-
-	tmp = &errbuf[pos];
-	if (bg) 
-		pos = snprintf(tmp, (erreob - tmp), 
-			"mount to NFS server '%s' failed: ", server);
-	else
-		pos = snprintf(tmp, (erreob - tmp), 
-			"mount: mount to NFS server '%s' failed: ", server);
-
-	tmp = &errbuf[pos];
-	if (rpc_createerr.cf_stat == RPC_TIMEDOUT) {
-		pos = snprintf(tmp, (erreob - tmp), "timed out %s", 
-			will_retry ? "(retrying)" : "(giving up)");
-	} else {
-		pos += rpc_strerror(pos);
-		tmp = &errbuf[pos];
-		if (bg) {
-			pos = snprintf(tmp, (erreob - tmp), " %s",
-				will_retry ? "(retrying)" : "(giving up)");
-		}
-	}
-	if (bg) {
-		if (onlyonce++ < 1)
-			openlog("mount", LOG_CONS|LOG_PID, LOG_AUTH);
-		syslog(LOG_ERR, "%s.", errbuf);
-	} else
-		fprintf(stderr, "%s.\n", errbuf);
-}
-
 /* Define the order in which to probe for UDP/TCP services */
 enum plist {
 	use_tcp = 0,
@@ -1238,62 +1171,3 @@ noauth_flavors:
 		close(fsock);
 	return retval;
 }
-
-/*
- * We need to translate between nfs status return values and
- * the local errno values which may not be the same.
- *
- * Andreas Schwab <schwab@LS5.informatik.uni-dortmund.de>: change errno:
- * "after #include <errno.h> the symbol errno is reserved for any use,
- *  it cannot even be used as a struct tag or field name".
- */
-
-#ifndef EDQUOT
-#define EDQUOT	ENOSPC
-#endif
-
-static struct {
-	enum nfsstat stat;
-	int errnum;
-} nfs_errtbl[] = {
-	{ NFS_OK,		0		},
-	{ NFSERR_PERM,		EPERM		},
-	{ NFSERR_NOENT,		ENOENT		},
-	{ NFSERR_IO,		EIO		},
-	{ NFSERR_NXIO,		ENXIO		},
-	{ NFSERR_ACCES,		EACCES		},
-	{ NFSERR_EXIST,		EEXIST		},
-	{ NFSERR_NODEV,		ENODEV		},
-	{ NFSERR_NOTDIR,	ENOTDIR		},
-	{ NFSERR_ISDIR,		EISDIR		},
-#ifdef NFSERR_INVAL
-	{ NFSERR_INVAL,		EINVAL		},	/* that Sun forgot */
-#endif
-	{ NFSERR_FBIG,		EFBIG		},
-	{ NFSERR_NOSPC,		ENOSPC		},
-	{ NFSERR_ROFS,		EROFS		},
-	{ NFSERR_NAMETOOLONG,	ENAMETOOLONG	},
-	{ NFSERR_NOTEMPTY,	ENOTEMPTY	},
-	{ NFSERR_DQUOT,		EDQUOT		},
-	{ NFSERR_STALE,		ESTALE		},
-#ifdef EWFLUSH
-	{ NFSERR_WFLUSH,	EWFLUSH		},
-#endif
-	/* Throw in some NFSv3 values for even more fun (HP returns these) */
-	{ 71,			EREMOTE		},
-
-	{ -1,			EIO		}
-};
-
-static char *nfs_strerror(int stat)
-{
-	int i;
-	static char buf[256];
-
-	for (i = 0; nfs_errtbl[i].stat != -1; i++) {
-		if (nfs_errtbl[i].stat == stat)
-			return strerror(nfs_errtbl[i].errnum);
-	}
-	sprintf(buf, _("unknown nfs status return value: %d"), stat);
-	return buf;
-}
diff --git a/utils/mount/nfsmount_err.c b/utils/mount/nfsmount_err.c
new file mode 100644
index 0000000..77b87fe
--- /dev/null
+++ b/utils/mount/nfsmount_err.c
@@ -0,0 +1,235 @@
+/*
+ * nfsmount_err.c -- Common error handling functions
+ *
+ * Copyright (C) 2007 Oracle.  All rights reserved.
+ * Copyright (C) 2007 Chuck Lever <chuck.lever@oracle.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ *
+ * To Do:
+ *  + Proper support for internationalization
+ */
+
+#include "config.h"
+#include <unistd.h>
+#include <sys/types.h>
+#include <stdio.h>
+#include <string.h>
+#include <errno.h>
+#include <fcntl.h>
+#include <syslog.h>
+#include <rpc/rpc.h>
+#include <rpc/pmap_prot.h>
+#include <rpc/pmap_clnt.h>
+
+#include "xcommon.h"
+#include "nls.h"
+#include "mount.h"
+#include "nfsmount_err.h"
+
+#ifdef HAVE_RPCSVC_NFS_PROT_H
+#include <rpcsvc/nfs_prot.h>
+#else
+#include <linux/nfs.h>
+#define nfsstat nfs_stat
+#endif
+
+extern char *progname;
+
+static char errbuf[BUFSIZ];
+static char *erreob = &errbuf[BUFSIZ];
+
+/* Convert RPC errors into strings */
+static int rpc_strerror(int spos)
+{
+	int cf_stat = rpc_createerr.cf_stat;
+	int pos = 0, cf_errno = rpc_createerr.cf_error.re_errno;
+	char *ptr, *estr = clnt_sperrno(cf_stat);
+	char *tmp;
+
+	if (estr) {
+		if ((ptr = index(estr, ':')))
+			estr = ++ptr;
+
+		tmp = &errbuf[spos];
+		if (cf_stat == RPC_SYSTEMERROR)
+			pos = snprintf(tmp, (erreob - tmp),
+				"System Error: %s", strerror(cf_errno));
+		else
+			pos = snprintf(tmp, (erreob - tmp), "RPC Error:%s", estr);
+	}
+	return pos;
+}
+
+void mount_errors(char *server, int will_retry, int bg)
+{
+	int pos = 0;
+	char *tmp;
+	static int onlyonce = 0;
+
+	tmp = &errbuf[pos];
+	if (bg)
+		pos = snprintf(tmp, (erreob - tmp),
+			"mount to NFS server '%s' failed: ", server);
+	else
+		pos = snprintf(tmp, (erreob - tmp),
+			"mount: mount to NFS server '%s' failed: ", server);
+
+	tmp = &errbuf[pos];
+	if (rpc_createerr.cf_stat == RPC_TIMEDOUT) {
+		pos = snprintf(tmp, (erreob - tmp), "timed out %s",
+			will_retry ? "(retrying)" : "(giving up)");
+	} else {
+		pos += rpc_strerror(pos);
+		tmp = &errbuf[pos];
+		if (bg) {
+			pos = snprintf(tmp, (erreob - tmp), " %s",
+				will_retry ? "(retrying)" : "(giving up)");
+		}
+	}
+	if (bg) {
+		if (onlyonce++ < 1)
+			openlog("mount", LOG_CONS|LOG_PID, LOG_AUTH);
+		syslog(LOG_ERR, "%s.", errbuf);
+	} else
+		fprintf(stderr, "%s.\n", errbuf);
+}
+
+void mount_error(const char *spec, const char *mount_point, int error)
+{
+	switch(error) {
+	case ENOTDIR:
+		nfs_error(_("%s: mount point %s is not a directory"),
+				progname, mount_point);
+		break;
+	case EBUSY:
+		nfs_error(_("%s: %s is already mounted or busy"),
+			progname, mount_point);
+		break;
+	case ENOENT:
+		if (spec)
+			nfs_error(_("%s: mounting %s failed, "
+				"reason given by server:\n  %s"),
+				progname, spec, strerror(error));
+		else
+			nfs_error(_("%s: mount point %s does not exist"),
+				progname, mount_point);
+		break;
+	default:
+		nfs_error(_("%s: %s"),
+			progname, strerror(error));
+	}
+}
+
+/*
+ * Report a failed umount
+ */
+void umount_error(int err, const char *dev)
+{
+	switch (err) {
+	case ENXIO:
+		nfs_error(_("%s: %s: invalid block device"),
+			progname, dev);
+		break;
+	case EINVAL:
+		nfs_error(_("%s: %s: not mounted"),
+			progname, dev);
+		break;
+	case EIO:
+		nfs_error(_("%s: %s: can't write superblock"),
+			progname, dev);
+		break;
+	case EBUSY:
+		nfs_error(_("%s: %s: device is busy"),
+			progname, dev);
+		break;
+	case ENOENT:
+		nfs_error(_("%s: %s: not found"),
+			progname, dev);
+		break;
+	case EPERM:
+		nfs_error(_("%s: %s: must be superuser to umount"),
+			progname, dev);
+		break;
+	case EACCES:
+		nfs_error(_("%s: %s: block devices not permitted on fs"),
+			progname, dev);
+		break;
+	default:
+		nfs_error(_("%s: %s: %s"),
+			progname, dev, strerror(err));
+		break;
+	}
+}
+
+/*
+ * We need to translate between nfs status return values and
+ * the local errno values which may not be the same.
+ *
+ * Andreas Schwab <schwab@LS5.informatik.uni-dortmund.de>: change errno:
+ * "after #include <errno.h> the symbol errno is reserved for any use,
+ *  it cannot even be used as a struct tag or field name".
+ */
+
+#ifndef EDQUOT
+#define EDQUOT	ENOSPC
+#endif
+
+static struct {
+	enum nfsstat stat;
+	int errnum;
+} nfs_errtbl[] = {
+	{ NFS_OK,		0		},
+	{ NFSERR_PERM,		EPERM		},
+	{ NFSERR_NOENT,		ENOENT		},
+	{ NFSERR_IO,		EIO		},
+	{ NFSERR_NXIO,		ENXIO		},
+	{ NFSERR_ACCES,		EACCES		},
+	{ NFSERR_EXIST,		EEXIST		},
+	{ NFSERR_NODEV,		ENODEV		},
+	{ NFSERR_NOTDIR,	ENOTDIR		},
+	{ NFSERR_ISDIR,		EISDIR		},
+#ifdef NFSERR_INVAL
+	{ NFSERR_INVAL,		EINVAL		},	/* that Sun forgot */
+#endif
+	{ NFSERR_FBIG,		EFBIG		},
+	{ NFSERR_NOSPC,		ENOSPC		},
+	{ NFSERR_ROFS,		EROFS		},
+	{ NFSERR_NAMETOOLONG,	ENAMETOOLONG	},
+	{ NFSERR_NOTEMPTY,	ENOTEMPTY	},
+	{ NFSERR_DQUOT,		EDQUOT		},
+	{ NFSERR_STALE,		ESTALE		},
+#ifdef EWFLUSH
+	{ NFSERR_WFLUSH,	EWFLUSH		},
+#endif
+	/* Throw in some NFSv3 values for even more fun (HP returns these) */
+	{ 71,			EREMOTE		},
+
+	{ -1,			EIO		}
+};
+
+char *nfs_strerror(int stat)
+{
+	int i;
+	static char buf[256];
+
+	for (i = 0; nfs_errtbl[i].stat != -1; i++) {
+		if (nfs_errtbl[i].stat == stat)
+			return strerror(nfs_errtbl[i].errnum);
+	}
+	sprintf(buf, _("unknown nfs status return value: %d"), stat);
+	return buf;
+}
diff --git a/utils/mount/nfsmount_err.h b/utils/mount/nfsmount_err.h
new file mode 100644
index 0000000..06f85e8
--- /dev/null
+++ b/utils/mount/nfsmount_err.h
@@ -0,0 +1,28 @@
+/*
+ * nfsmount_err.h:  Common error handling functions
+ *
+ * Copyright (C) 2007 Oracle.  All rights reserved.
+ * Copyright (C) 2007 Chuck Lever <chuck.lever@oracle.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ *
+ */
+
+char *nfs_strerror(int);
+
+void mount_error(const char *, const char *, int);
+void mount_errors(char *, int, int);
+void umount_error(int, const char *);
diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index b9737be..c275da8 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -34,6 +34,7 @@
 #include "mount_constants.h"
 #include "mount.h"
 #include "nfsumount.h"
+#include "nfsmount_err.h"
 
 #if !defined(MNT_FORCE)
 /* dare not try to include <linux/mount.h> -- lots of errors */
@@ -93,30 +94,6 @@ int nfs_call_umount(clnt_addr_t *mnt_server, dirpath *argp)
 	return res;
 }
 
-/* complain about a failed umount */
-static void complain(int err, const char *dev) {
-  switch (err) {
-    case ENXIO:
-      nfs_error (_("umount: %s: invalid block device"), dev); break;
-    case EINVAL:
-      nfs_error (_("umount: %s: not mounted"), dev); break;
-    case EIO:
-      nfs_error (_("umount: %s: can't write superblock"), dev); break;
-    case EBUSY:
-     /* Let us hope fstab has a line "proc /proc ..."
-        and not "none /proc ..."*/
-      nfs_error (_("umount: %s: device is busy"), dev); break;
-    case ENOENT:
-      nfs_error (_("umount: %s: not found"), dev); break;
-    case EPERM:
-      nfs_error (_("umount: %s: must be superuser to umount"), dev); break;
-    case EACCES:
-      nfs_error (_("umount: %s: block devices not permitted on fs"), dev); break;
-    default:
-      nfs_error (_("umount: %s: %s"), dev, strerror (err)); break;
-  }
-}
-
 int del_mtab(const char *spec, const char *node)
 {
 	int umnt_err, res;
@@ -183,7 +160,7 @@ int del_mtab(const char *spec, const char *node)
                 return 0;
 
         if (umnt_err)
-                complain(umnt_err, node);
+                umount_error(umnt_err, node);
         return 1;
 }
 


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
