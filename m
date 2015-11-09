Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44671 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751602AbbKINFM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Nov 2015 08:05:12 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (Postfix) with ESMTPS id C2DDA14AA9
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2015 13:05:11 +0000 (UTC)
Received: from smallhat.boston.devel.redhat.com (vpn-54-90.rdu2.redhat.com [10.10.54.90])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id tA9D59kW019518
	for <linux-nfs@vger.kernel.org>; Mon, 9 Nov 2015 08:05:11 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] gssd: use pthreads to handle upcalls
Date: Mon,  9 Nov 2015 08:05:08 -0500
Message-Id: <1447074308-15823-2-git-send-email-steved@redhat.com>
In-Reply-To: <1447074308-15823-1-git-send-email-steved@redhat.com>
References: <1447074308-15823-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, to persevere global data over multiple mounts,
the root process does not fork when handling an upcall.
Instead of not-forking, create a pthread to handle the
all upcalls since global data can be shared among threads.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 aclocal/libpthread.m4  | 13 +++++++++++++
 configure.ac           |  3 +++
 utils/gssd/Makefile.am |  3 ++-
 utils/gssd/gssd.c      | 18 ++++++++++++++++--
 utils/gssd/gssd.h      |  2 ++
 utils/gssd/gssd_proc.c | 30 ------------------------------
 utils/gssd/krb5_util.c |  3 +++
 7 files changed, 39 insertions(+), 33 deletions(-)
 create mode 100644 aclocal/libpthread.m4

diff --git a/aclocal/libpthread.m4 b/aclocal/libpthread.m4
new file mode 100644
index 0000000..e87d2a0
--- /dev/null
+++ b/aclocal/libpthread.m4
@@ -0,0 +1,13 @@
+dnl Checks for pthreads library and headers
+dnl
+AC_DEFUN([AC_LIBPTHREAD], [
+
+    dnl Check for library, but do not add -lpthreads to LIBS
+    AC_CHECK_LIB([pthread], [pthread_create], [LIBPTHREAD=-lpthread],
+                 [AC_MSG_ERROR([libpthread not found.])])
+  AC_SUBST(LIBPTHREAD)
+
+  AC_CHECK_HEADERS([pthread.h], ,
+                   [AC_MSG_ERROR([libpthread headers not found.])])
+
+])dnl
diff --git a/configure.ac b/configure.ac
index 25d2ba4..e0ecd61 100644
--- a/configure.ac
+++ b/configure.ac
@@ -385,6 +385,9 @@ if test "$enable_gss" = yes; then
   dnl Invoked after AC_KERBEROS_V5; AC_LIBRPCSECGSS needs to have KRBLIBS set
   AC_LIBRPCSECGSS
 
+  dnl Check for pthreads
+  AC_LIBPTHREAD
+
   dnl librpcsecgss already has a dependency on libgssapi,
   dnl but we need to make sure we get the right version
   if test "$enable_gss" = yes; then
diff --git a/utils/gssd/Makefile.am b/utils/gssd/Makefile.am
index cb040b3..3f5f59a 100644
--- a/utils/gssd/Makefile.am
+++ b/utils/gssd/Makefile.am
@@ -49,7 +49,8 @@ gssd_LDADD = \
 	$(RPCSECGSS_LIBS) \
 	$(KRBLIBS) \
 	$(GSSAPI_LIBS) \
-	$(LIBTIRPC)
+	$(LIBTIRPC) \
+	$(LIBPTHREAD)
 
 gssd_LDFLAGS = \
 	$(KRBLDFLAGS)
diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index e7cb07f..3c425ce 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -365,16 +365,30 @@ static void
 gssd_clnt_gssd_cb(int UNUSED(fd), short UNUSED(which), void *data)
 {
 	struct clnt_info *clp = data;
+	pthread_t th;
+	int ret; 
 
-	handle_gssd_upcall(clp);
+	ret = pthread_create(&th, NULL, (void *)handle_gssd_upcall, (void *)clp);
+	if (ret != 0) {
+		printerr(0, "pthread_create failed: ret %d: %s\n", ret, strerror(errno)); 
+		return;
+	}
+	pthread_join(th, NULL);
 }
 
 static void
 gssd_clnt_krb5_cb(int UNUSED(fd), short UNUSED(which), void *data)
 {
 	struct clnt_info *clp = data;
+	pthread_t th;
+	int ret; 
+
+	ret = pthread_create(&th, NULL, (void *)handle_krb5_upcall, (void *)clp);
+	if (ret != 0) {
+		printerr(0, "pthread_create failed: ret %d: %s\n", ret, strerror(errno)); 
+	}
 
-	handle_krb5_upcall(clp);
+	pthread_join(th, NULL);
 }
 
 static struct clnt_info *
diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
index c6937c5..8677329 100644
--- a/utils/gssd/gssd.h
+++ b/utils/gssd/gssd.h
@@ -36,6 +36,7 @@
 #include <gssapi/gssapi.h>
 #include <event.h>
 #include <stdbool.h>
+#include <pthread.h>
 
 #ifndef GSSD_PIPEFS_DIR
 #define GSSD_PIPEFS_DIR		"/var/lib/nfs/rpc_pipefs"
@@ -61,6 +62,7 @@ extern int			root_uses_machine_creds;
 extern unsigned int 		context_timeout;
 extern unsigned int rpc_timeout;
 extern char			*preferred_realm;
+extern pthread_mutex_t ple_lock;
 
 struct clnt_info {
 	TAILQ_ENTRY(clnt_info)	list;
diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 1ef68d8..616082e 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -629,36 +629,6 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 	if (uid != 0 || (uid == 0 && root_uses_machine_creds == 0 &&
 				service == NULL)) {
 
-		/* already running as uid 0 */
-		if (uid == 0)
-			goto no_fork;
-
-		pid = fork();
-		switch(pid) {
-		case 0:
-			/* Child: fall through to rest of function */
-			childpid = getpid();
-			unsetenv("KRB5CCNAME");
-			printerr(2, "CHILD forked pid %d \n", childpid);
-			break;
-		case -1:
-			/* fork() failed! */
-			printerr(0, "WARNING: unable to fork() to handle"
-				"upcall: %s\n", strerror(errno));
-			return;
-		default:
-			/* Parent: just wait on child to exit and return */
-			do {
-				pid = wait(&err);
-			} while(pid == -1 && errno != -ECHILD);
-
-			if (WIFSIGNALED(err))
-				printerr(0, "WARNING: forked child was killed"
-					 "with signal %d\n", WTERMSIG(err));
-			return;
-		}
-no_fork:
-
 		auth = krb5_not_machine_creds(clp, uid, tgtname, &downcall_err,
 						&err, &rpc_clnt);
 		if (err)
diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 8ef8184..7354dc7 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -128,6 +128,7 @@
 
 /* Global list of principals/cache file names for machine credentials */
 struct gssd_k5_kt_princ *gssd_k5_kt_princ_list = NULL;
+pthread_mutex_t ple_lock;
 
 #ifdef HAVE_SET_ALLOWABLE_ENCTYPES
 int limit_to_legacy_enctypes = 0;
@@ -586,10 +587,12 @@ get_ple_by_princ(krb5_context context, krb5_principal princ)
 
 	/* Need to serialize list if we ever become multi-threaded! */
 
+	pthread_mutex_lock(&ple_lock);
 	ple = find_ple_by_princ(context, princ);
 	if (ple == NULL) {
 		ple = new_ple(context, princ);
 	}
+	pthread_mutex_unlock(&ple_lock);
 
 	return ple;
 }
-- 
2.4.3

