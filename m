Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:42685 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752567AbcBVP3E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Feb 2016 10:29:04 -0500
From: Olga Kornievskaia <kolga@netapp.com>
To: <steved@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/3] gssd: use pthreads to handle upcalls
Date: Mon, 22 Feb 2016 10:28:57 -0500
Message-ID: <1456154939-26926-2-git-send-email-kolga@netapp.com>
In-Reply-To: <1456154939-26926-1-git-send-email-kolga@netapp.com>
References: <1456154939-26926-1-git-send-email-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, to persevere global data over multiple mounts,
the root process does not fork when handling an upcall.
Instead on not-forking create a pthread to handle the
upcall since global data can be shared among threads.

Signed-off-by: Steve Dickson <steved@redhat.com>
Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 configure.ac           |  3 +++
 utils/gssd/Makefile.am |  3 ++-
 utils/gssd/gssd.c      | 34 +++++++++++++++++++++++++++++++---
 utils/gssd/gssd.h      |  2 ++
 utils/gssd/gssd_proc.c | 30 ------------------------------
 utils/gssd/krb5_util.c |  3 +++
 6 files changed, 41 insertions(+), 34 deletions(-)

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
index e7cb07f..a480417 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -361,20 +361,48 @@ gssd_destroy_client(struct clnt_info *clp)
 
 static void gssd_scan(void);
 
+/* For each upcall create a thread, detach from the main process so that
+ * resources are released back into the system without the need for a join.
+ * pthread_yield() is needed to allow the child thread to run right away
+ * and consume the upcall from the file descriptor. otherwise, if the main
+ * thread goes back into libevent code it will trigger another callback as
+ * the file descriptor is still "ready" and not consumed"
+ */
 static void
 gssd_clnt_gssd_cb(int UNUSED(fd), short UNUSED(which), void *data)
 {
 	struct clnt_info *clp = data;
-
-	handle_gssd_upcall(clp);
+	pthread_t th;
+	int ret;
+
+	ret = pthread_create(&th, NULL, (void *)handle_gssd_upcall,
+				(void *)clp);
+	if (ret != 0) {
+		printerr(0, "ERROR: pthread_create failed: ret %d: %s\n",
+			 ret, strerror(errno));
+		return;
+	}
+	pthread_detach(th);
+	pthread_yield();
 }
 
 static void
 gssd_clnt_krb5_cb(int UNUSED(fd), short UNUSED(which), void *data)
 {
 	struct clnt_info *clp = data;
+	pthread_t th;
+	int ret;
+
+	ret = pthread_create(&th, NULL, (void *)handle_krb5_upcall,
+				(void *)clp);
+	if (ret != 0) {
+		printerr(0, "ERROR: pthread_create failed: ret %d: %s\n",
+			 ret, strerror(errno));
+		return;
+	}
 
-	handle_krb5_upcall(clp);
+	pthread_detach(th);
+	pthread_yield();
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
index 8ef8184..3328696 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -128,6 +128,7 @@
 
 /* Global list of principals/cache file names for machine credentials */
 struct gssd_k5_kt_princ *gssd_k5_kt_princ_list = NULL;
+pthread_mutex_t ple_lock = PTHREAD_MUTEX_INITIALIZER;
 
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
1.8.3.1

