Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51442 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751688AbcKPQFW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 16 Nov 2016 11:05:22 -0500
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v3] Move default state-dir to a subdirectory of /var/run
Date: Wed, 16 Nov 2016 11:05:20 -0500
Message-Id: <1479312320-12359-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: NeilBrown <neilb@suse.com>

rpcbind can save state in a file to allow restart without forgetting
about running services.

The default location is currently "/tmp" which is
not ideal for system files.  It is particularly unpleasant
to put simple files there rather than creating a directory
to contain them.

On a modern Linux system it is preferable to use /run, and there it is
even more consistent with practice to use a subdirectory.

This directory needs to be create one each boot, and while there are
tools (e.g. systemd-tmpfiles) which can do that it is cleaner to keep
rpcbind self-contained and have it create the directory.

So change the default location to /var/run/rpcbind, and create that
directory.  If a different user-id is used, we need to create
and chown the directory before dropping privileges.  We do this
with care so avoid chowning the wrong thing by mistake.

Signed-off-by: NeilBrown <neilb@suse.com>
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 configure.ac    |  4 ++--
 src/rpcbind.c   |  5 +++++
 src/rpcbind.h   |  1 +
 src/warmstart.c | 37 +++++++++++++++++++++++++++++++++----
 4 files changed, 41 insertions(+), 6 deletions(-)

Hello,

I made the following changes

- Moved the stat dir from /tmp to /var/run

- Check to see if the stat dir exists before
  trying to created it. This allows ditros 
  to use systemd-tmpfiles if they choose to
  and failure messages can be logged when
  the dir can not be created. 

diff --git a/configure.ac b/configure.ac
index f84921e..acc6914 100644
--- a/configure.ac
+++ b/configure.ac
@@ -22,8 +22,8 @@ AC_ARG_ENABLE([warmstarts],
 AM_CONDITIONAL(WARMSTART, test x$enable_warmstarts = xyes)
 
 AC_ARG_WITH([statedir],
-  AS_HELP_STRING([--with-statedir=ARG], [use ARG as state dir @<:@default=/tmp@:>@])
-  ,, [with_statedir=/tmp])
+  AS_HELP_STRING([--with-statedir=ARG], [use ARG as state dir @<:@default=/var/run/rpcbind@:>@])
+  ,, [with_statedir=/var/run/rpcbind])
 AC_SUBST([statedir], [$with_statedir])
 
 AC_ARG_WITH([rpcuser],
diff --git a/src/rpcbind.c b/src/rpcbind.c
index 87ccdc2..8db8dfc 100644
--- a/src/rpcbind.c
+++ b/src/rpcbind.c
@@ -263,6 +263,11 @@ main(int argc, char *argv[])
 			syslog(LOG_ERR, "cannot get uid of '%s': %m", id);
 			exit(1);
 		}
+#ifdef WARMSTART
+		if (warmstart) {
+			mkdir_warmstart(p->pw_uid);
+		}
+#endif
                 if (setgid(p->pw_gid) == -1) {
                         syslog(LOG_ERR, "setgid to '%s' (%d) failed: %m", id, p->pw_gid);
                         exit(1);
diff --git a/src/rpcbind.h b/src/rpcbind.h
index 74f9591..5b1a9bb 100644
--- a/src/rpcbind.h
+++ b/src/rpcbind.h
@@ -129,6 +129,7 @@ int is_localroot(struct netbuf *);
 extern void pmap_service(struct svc_req *, SVCXPRT *);
 #endif
 
+void mkdir_warmstart(int uid);
 void write_warmstart(void);
 void read_warmstart(void);
 
diff --git a/src/warmstart.c b/src/warmstart.c
index 122a058..aafcb61 100644
--- a/src/warmstart.c
+++ b/src/warmstart.c
@@ -45,19 +45,23 @@
 #include <syslog.h>
 #include <unistd.h>
 #include <errno.h>
+#include <fcntl.h>
 
 #include "rpcbind.h"
 
-#ifndef RPCBIND_STATEDIR
-#define RPCBIND_STATEDIR "/tmp"
-#endif
-
 /* These files keep the pmap_list and rpcb_list in XDR format */
 #define	RPCBFILE	RPCBIND_STATEDIR "/rpcbind.xdr"
 #ifdef PORTMAP
 #define	PMAPFILE	RPCBIND_STATEDIR "/portmap.xdr"
 #endif
 
+#ifndef O_DIRECTORY
+#define O_DIRECTORY 0
+#endif
+#ifndef O_NOFOLLOW
+#define O_NOFOLLOW 0
+#endif
+
 static bool_t write_struct(char *, xdrproc_t, void *);
 static bool_t read_struct(char *, xdrproc_t, void *);
 
@@ -139,8 +143,33 @@ error:
 }
 
 void
+mkdir_warmstart(int uid)
+{
+	/* Already exists? */
+	if (access(RPCBIND_STATEDIR, X_OK) == 0)
+		return;
+
+	if (mkdir(RPCBIND_STATEDIR, 0770) == 0) {
+		int fd = open(RPCBIND_STATEDIR, O_RDONLY | O_DIRECTORY | O_NOFOLLOW);
+		if (fd >= 0) {
+			if (fchown(fd, uid, -1) < 0) {
+				syslog(LOG_ERR, 
+					"mkdir_warmstart: open failed '%s', errno %d (%s)", 
+					RPCBIND_STATEDIR, errno, strerror(errno));
+			}
+			close(fd);
+		} else
+			syslog(LOG_ERR, "mkdir_warmstart: open failed '%s', errno %d (%s)", 
+				RPCBIND_STATEDIR, errno, strerror(errno));
+	} else
+		syslog(LOG_ERR, "mkdir_warmstart: mkdir failed '%s', errno %d (%s)", 
+			RPCBIND_STATEDIR, errno, strerror(errno));
+}
+
+void
 write_warmstart()
 {
+	(void) mkdir(RPCBIND_STATEDIR, 0770);
 	(void) write_struct(RPCBFILE, (xdrproc_t)xdr_rpcblist_ptr, &list_rbl);
 #ifdef PORTMAP
 	(void) write_struct(PMAPFILE, (xdrproc_t)xdr_pmaplist_ptr, &list_pml);
-- 
2.7.4

