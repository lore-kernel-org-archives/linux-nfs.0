From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/6] tcp_wrapper: Clean up logit()
Date: Fri, 15 Jan 2010 12:49:58 -0500
Message-ID: <20100115174957.30104.87508.stgit@localhost.localdomain>
References: <20100115174426.30104.3492.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:53727 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753404Ab0AORux (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jan 2010 12:50:53 -0500
In-Reply-To: <20100115174426.30104.3492.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Eliminate these compiler warnings:

tcpwrapper.c: In function =E2=80=98logit=E2=80=99:
tcpwrapper.c:225: warning: unused parameter =E2=80=98procnum=E2=80=99
tcpwrapper.c:225: warning: unused parameter =E2=80=98prognum=E2=80=99

Actually, @procnum is not used anywhere in our tcpwrapper.c, so let's
just get rid of it.

Since there is only one logit() call site in tcpwrapper.c, the macro
wrapper just adds needless clutter.  Let's get rid of that too.

=46inally, both mountd and statd now use xlog(), which adds an
appropriate program name prefix to every message.  Replace the
open-coded syslog(2) call with an xlog() call in order to consistently
identify the RPC service reporting the intrusion.

Since logit() no longer references "deny_severity" and no nfs-utils
caller sets either allow_severity or deny_severity, we remove them.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/include/tcpwrapper.h  |    8 +-----
 support/misc/tcpwrapper.c     |   56 ++++++++++++++++++---------------=
--------
 utils/mountd/mount_dispatch.c |    2 +
 utils/statd/statd.c           |    2 +
 4 files changed, 27 insertions(+), 41 deletions(-)

diff --git a/support/include/tcpwrapper.h b/support/include/tcpwrapper.=
h
index f1145bd..941394e 100644
--- a/support/include/tcpwrapper.h
+++ b/support/include/tcpwrapper.h
@@ -5,14 +5,8 @@
 #include <netinet/in.h>
 #include <arpa/inet.h>
=20
-extern int verboselog;
-
-extern int allow_severity;
-extern int deny_severity;
-
 extern int good_client(char *daemon, struct sockaddr_in *addr);
 extern int from_local(const struct sockaddr *sap);
-extern int check_default(char *daemon, struct sockaddr_in *addr,
-			 u_long proc, u_long prog);
+extern int check_default(char *daemon, struct sockaddr_in *addr, u_lon=
g prog);
=20
 #endif /* TCP_WRAPPER_H */
diff --git a/support/misc/tcpwrapper.c b/support/misc/tcpwrapper.c
index af626ad..b981d58 100644
--- a/support/misc/tcpwrapper.c
+++ b/support/misc/tcpwrapper.c
@@ -34,13 +34,12 @@
 #ifdef HAVE_CONFIG_H
 #include <config.h>
 #endif
+
 #ifdef HAVE_LIBWRAP
-#include <tcpwrapper.h>
 #include <unistd.h>
 #include <string.h>
 #include <rpc/rpc.h>
 #include <rpc/pmap_prot.h>
-#include <syslog.h>
 #include <netdb.h>
 #include <pwd.h>
 #include <sys/types.h>
@@ -49,6 +48,7 @@
 #include <sys/stat.h>
 #include <tcpd.h>
=20
+#include "tcpwrapper.h"
 #include "xlog.h"
=20
 #ifdef SYSV40
@@ -56,21 +56,8 @@
 #include <rpc/rpcent.h>
 #endif
=20
-static void logit(int severity, struct sockaddr_in *addr,
-		  u_long procnum, u_long prognum, char *text);
 static int check_files(void);
=20
-/*
- * These need to exist since they are externed=20
- * public header files.
- */
-int     verboselog =3D 0;
-int     allow_severity =3D LOG_INFO;
-int     deny_severity =3D LOG_WARNING;
-
-#define log_bad_host(addr, proc, prog) \
-  logit(deny_severity, addr, proc, prog, "request from unauthorized ho=
st")
-
 #define ALLOW 1
 #define DENY 0
=20
@@ -143,6 +130,16 @@ haccess_t *haccess_lookup(struct sockaddr_in *addr=
, u_long prog)
 	return NULL;
 }
=20
+static void
+logit(const struct sockaddr_in *sin)
+{
+	char buf[INET_ADDRSTRLEN];
+
+	xlog_warn("connect from %s denied: request from unauthorized host",
+			inet_ntop(AF_INET, &sin->sin_addr, buf, sizeof(buf)));
+	=09
+}
+
 int
 good_client(daemon, addr)
 char *daemon;
@@ -186,14 +183,17 @@ static int check_files()
 	return changed;
 }
=20
-/* check_default - additional checks for NULL, DUMP, GETPORT and unkno=
wn */
-
+/**
+ * check_default - additional checks for NULL, DUMP, GETPORT and unkno=
wn
+ * @daemon: pointer to '\0'-terminated ASCII string containing name of=
 the
+ *		daemon requesting the access check
+ * @addr: pointer to socket address containing address of caller
+ * @prog: RPC program number caller is attempting to access
+ *
+ * Returns TRUE if the caller is allowed access; otherwise FALSE is re=
turned.
+ */
 int
-check_default(daemon, addr, proc, prog)
-char *daemon;
-struct sockaddr_in *addr;
-u_long  proc;
-u_long  prog;
+check_default(char *daemon, struct sockaddr_in *addr, u_long prog)
 {
 	haccess_t *acc =3D NULL;
 	int changed =3D check_files();
@@ -203,7 +203,7 @@ u_long  prog;
 		return (acc->access);
=20
 	if (!(from_local((struct sockaddr *)addr) || good_client(daemon, addr=
))) {
-		log_bad_host(addr, proc, prog);
+		logit(addr);
 		if (acc)
 			acc->access =3D FALSE;
 		else=20
@@ -219,12 +219,4 @@ u_long  prog;
     return (TRUE);
 }
=20
-/* logit - report events of interest via the syslog daemon */
-
-static void logit(int severity, struct sockaddr_in *addr,
-		  u_long procnum, u_long prognum, char *text)
-{
-	syslog(severity, "connect from %s denied: %s",
-	       inet_ntoa(addr->sin_addr), text);
-}
-#endif
+#endif	/* HAVE_LIBWRAP */
diff --git a/utils/mountd/mount_dispatch.c b/utils/mountd/mount_dispatc=
h.c
index 199fcec..d2802ef 100644
--- a/utils/mountd/mount_dispatch.c
+++ b/utils/mountd/mount_dispatch.c
@@ -75,7 +75,7 @@ mount_dispatch(struct svc_req *rqstp, SVCXPRT *transp=
)
=20
 	/* remote host authorization check */
 	if (sin->sin_family =3D=3D AF_INET &&
-	    !check_default("mountd", sin, rqstp->rq_proc, MOUNTPROG)) {
+	    !check_default("mountd", sin, MOUNTPROG)) {
 		svcerr_auth (transp, AUTH_FAILED);
 		return;
 	}
diff --git a/utils/statd/statd.c b/utils/statd/statd.c
index 7be6454..fa3c6d5 100644
--- a/utils/statd/statd.c
+++ b/utils/statd/statd.c
@@ -79,7 +79,7 @@ sm_prog_1_wrapper (struct svc_req *rqstp, register SV=
CXPRT *transp)
=20
 	/* remote host authorization check */
 	if (sin->sin_family =3D=3D AF_INET &&
-	    !check_default("statd", sin, rqstp->rq_proc, SM_PROG)) {
+	    !check_default("statd", sin, SM_PROG)) {
 		svcerr_auth (transp, AUTH_FAILED);
 		return;
 	}

