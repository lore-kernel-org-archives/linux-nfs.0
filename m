From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/6] nfs-utils: Provide type-checked version of svc_getcaller()
Date: Wed, 04 Mar 2009 19:02:49 -0500
Message-ID: <20090305000249.28749.90016.stgit@ingres.1015granger.net>
References: <20090304234711.28749.7018.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:57011 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751794AbZCEADh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Mar 2009 19:03:37 -0500
In-Reply-To: <20090304234711.28749.7018.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

TI-RPC's version of the svc_getcaller() macro points to a sockaddr_in6,
not a sockaddr_in, though for AF_INET callers, an AF_INET address
resides there.  To squelch compiler warnings when the TI-RPC version of
the svc_req structure is used, add inline helpers with appropriate
type casting.

Note that tcp_wrappers support only AF_INET addresses for now.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/include/rpcmisc.h     |    9 +++++++++
 utils/mountd/mount_dispatch.c |    7 ++++---
 utils/mountd/mountd.c         |   20 +++++++-------------
 utils/statd/callback.c        |    9 ++++++---
 utils/statd/monitor.c         |    5 ++++-
 utils/statd/simu.c            |   12 ++++++++++--
 utils/statd/statd.c           |    6 ++++--
 7 files changed, 44 insertions(+), 24 deletions(-)

diff --git a/support/include/rpcmisc.h b/support/include/rpcmisc.h
index 5814a63..f551a85 100644
--- a/support/include/rpcmisc.h
+++ b/support/include/rpcmisc.h
@@ -53,5 +53,14 @@ extern int	_rpcpmstart;
 extern int	_rpcfdtype;
 extern int	_rpcsvcdirty;
 
+static inline struct sockaddr_in *nfs_getrpccaller_in(SVCXPRT *xprt)
+{
+	return (struct sockaddr_in *)svc_getcaller(xprt);
+}
+
+static inline struct sockaddr *nfs_getrpccaller(SVCXPRT *xprt)
+{
+	return (struct sockaddr *)svc_getcaller(xprt);
+}
 
 #endif /* RPCMISC_H */
diff --git a/utils/mountd/mount_dispatch.c b/utils/mountd/mount_dispatch.c
index f00c0c5..199fcec 100644
--- a/utils/mountd/mount_dispatch.c
+++ b/utils/mountd/mount_dispatch.c
@@ -70,11 +70,12 @@ mount_dispatch(struct svc_req *rqstp, SVCXPRT *transp)
 {
 	union mountd_arguments 	argument;
 	union mountd_results	result;
-
 #ifdef HAVE_TCP_WRAPPER
+	struct sockaddr_in *sin = nfs_getrpccaller_in(transp);
+
 	/* remote host authorization check */
-	if (!check_default("mountd", svc_getcaller(transp),
-			   rqstp->rq_proc, MOUNTPROG)) {
+	if (sin->sin_family == AF_INET &&
+	    !check_default("mountd", sin, rqstp->rq_proc, MOUNTPROG)) {
 		svcerr_auth (transp, AUTH_FAILED);
 		return;
 	}
diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index deeaa07..8084359 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -202,8 +202,7 @@ mount_mnt_1_svc(struct svc_req *rqstp, dirpath *path, fhstatus *res)
 bool_t
 mount_dump_1_svc(struct svc_req *rqstp, void *argp, mountlist *res)
 {
-	struct sockaddr_in *addr =
-		(struct sockaddr_in *) svc_getcaller(rqstp->rq_xprt);
+	struct sockaddr_in *addr = nfs_getrpccaller_in(rqstp->rq_xprt);
 
 	xlog(D_CALL, "dump request from %s.", inet_ntoa(addr->sin_addr));
 	*res = mountlist_list();
@@ -214,8 +213,7 @@ mount_dump_1_svc(struct svc_req *rqstp, void *argp, mountlist *res)
 bool_t
 mount_umnt_1_svc(struct svc_req *rqstp, dirpath *argp, void *resp)
 {
-	struct sockaddr_in *sin
-		= (struct sockaddr_in *) svc_getcaller(rqstp->rq_xprt);
+	struct sockaddr_in *sin = nfs_getrpccaller_in(rqstp->rq_xprt);
 	nfs_export	*exp;
 	char		*p = *argp;
 	char		rpath[MAXPATHLEN+1];
@@ -242,15 +240,14 @@ mount_umntall_1_svc(struct svc_req *rqstp, void *argp, void *resp)
 	/* Reload /etc/xtab if necessary */
 	auth_reload();
 
-	mountlist_del_all((struct sockaddr_in *) svc_getcaller(rqstp->rq_xprt));
+	mountlist_del_all(nfs_getrpccaller_in(rqstp->rq_xprt));
 	return 1;
 }
 
 bool_t
 mount_export_1_svc(struct svc_req *rqstp, void *argp, exports *resp)
 {
-	struct sockaddr_in *addr =
-		(struct sockaddr_in *) svc_getcaller(rqstp->rq_xprt);
+	struct sockaddr_in *addr = nfs_getrpccaller_in(rqstp->rq_xprt);
 
 	xlog(D_CALL, "export request from %s.", inet_ntoa(addr->sin_addr));
 	*resp = get_exportlist();
@@ -261,8 +258,7 @@ mount_export_1_svc(struct svc_req *rqstp, void *argp, exports *resp)
 bool_t
 mount_exportall_1_svc(struct svc_req *rqstp, void *argp, exports *resp)
 {
-	struct sockaddr_in *addr =
-		(struct sockaddr_in *) svc_getcaller(rqstp->rq_xprt);
+	struct sockaddr_in *addr = nfs_getrpccaller_in(rqstp->rq_xprt);
 
 	xlog(D_CALL, "exportall request from %s.", inet_ntoa(addr->sin_addr));
 	*resp = get_exportlist();
@@ -284,8 +280,7 @@ mount_exportall_1_svc(struct svc_req *rqstp, void *argp, exports *resp)
 bool_t
 mount_pathconf_2_svc(struct svc_req *rqstp, dirpath *path, ppathcnf *res)
 {
-	struct sockaddr_in *sin
-		= (struct sockaddr_in *) svc_getcaller(rqstp->rq_xprt);
+	struct sockaddr_in *sin = nfs_getrpccaller_in(rqstp->rq_xprt);
 	struct stat	stb;
 	nfs_export	*exp;
 	char		rpath[MAXPATHLEN+1];
@@ -383,8 +378,7 @@ static struct nfs_fh_len *
 get_rootfh(struct svc_req *rqstp, dirpath *path, nfs_export **expret,
 		mountstat3 *error, int v3)
 {
-	struct sockaddr_in *sin =
-		(struct sockaddr_in *) svc_getcaller(rqstp->rq_xprt);
+	struct sockaddr_in *sin = nfs_getrpccaller_in(rqstp->rq_xprt);
 	struct stat	stb, estb;
 	nfs_export	*exp;
 	struct nfs_fh_len *fh;
diff --git a/utils/statd/callback.c b/utils/statd/callback.c
index 505fdb3..8885238 100644
--- a/utils/statd/callback.c
+++ b/utils/statd/callback.c
@@ -9,10 +9,13 @@
 #ifdef HAVE_CONFIG_H
 #include <config.h>
 #endif
+
+#include <arpa/inet.h>
+
+#include "rpcmisc.h"
 #include "misc.h"
 #include "statd.h"
 #include "notlist.h"
-#include <arpa/inet.h>
 
 /* Callback notify list. */
 /* notify_list *cbnl = NULL; ... never used */
@@ -29,8 +32,8 @@ sm_notify_1_svc(struct stat_chge *argp, struct svc_req *rqstp)
 {
 	notify_list    *lp, *call;
 	static char    *result = NULL;
-	char *ip_addr = xstrdup(inet_ntoa(svc_getcaller(rqstp->rq_xprt)
-					  ->sin_addr));
+	struct sockaddr_in *sin = nfs_getrpccaller_in(rqstp->rq_xprt);
+	char *ip_addr = xstrdup(inet_ntoa(sin->sin_addr));
 
 	dprintf(N_DEBUG, "Received SM_NOTIFY from %s, state: %d",
 				argp->mon_name, argp->state);
diff --git a/utils/statd/monitor.c b/utils/statd/monitor.c
index 24c2531..169cd78 100644
--- a/utils/statd/monitor.c
+++ b/utils/statd/monitor.c
@@ -20,6 +20,8 @@
 #include <errno.h>
 #include <arpa/inet.h>
 #include <dirent.h>
+
+#include "rpcmisc.h"
 #include "misc.h"
 #include "statd.h"
 #include "notlist.h"
@@ -36,9 +38,10 @@ notify_list *		rtnl = NULL;	/* Run-time notify list. */
 static int
 caller_is_localhost(struct svc_req *rqstp)
 {
+	struct sockaddr_in *sin = nfs_getrpccaller_in(rqstp->rq_xprt);
 	struct in_addr	caller;
 
-	caller = svc_getcaller(rqstp->rq_xprt)->sin_addr;
+	caller = sin->sin_addr;
 	if (caller.s_addr != htonl(INADDR_LOOPBACK)) {
 		note(N_WARNING,
 			"Call to statd from non-local host %s",
diff --git a/utils/statd/simu.c b/utils/statd/simu.c
index 25e8bad..a7ecb85 100644
--- a/utils/statd/simu.c
+++ b/utils/statd/simu.c
@@ -7,8 +7,10 @@
 #ifdef HAVE_CONFIG_H
 #include <config.h>
 #endif
+
 #include <arpa/inet.h>
 
+#include "rpcmisc.h"
 #include "statd.h"
 #include "notlist.h"
 
@@ -21,17 +23,23 @@ extern void my_svc_exit (void);
 void *
 sm_simu_crash_1_svc (void *argp, struct svc_req *rqstp)
 {
+  struct sockaddr_in *sin = nfs_getrpccaller_in(rqstp->rq_xprt);
   static char *result = NULL;
   struct in_addr caller;
 
-  caller = svc_getcaller(rqstp->rq_xprt)->sin_addr;
+  if (sin->sin_family != AF_INET) {
+    note(N_WARNING, "Call to statd from non-AF_INET address");
+    goto failure;
+  }
+
+  caller = sin->sin_addr;
   if (caller.s_addr != htonl(INADDR_LOOPBACK)) {
     note(N_WARNING, "Call to statd from non-local host %s",
       inet_ntoa(caller));
     goto failure;
   }
 
-  if (ntohs(svc_getcaller(rqstp->rq_xprt)->sin_port) >= 1024) {
+  if (ntohs(sin->sin_port) >= 1024) {
     note(N_WARNING, "Call to statd-simu-crash from unprivileged port");
     goto failure;
   }
diff --git a/utils/statd/statd.c b/utils/statd/statd.c
index 321f7a9..6da2ab2 100644
--- a/utils/statd/statd.c
+++ b/utils/statd/statd.c
@@ -88,9 +88,11 @@ extern void simulator (int, char **);
 static void 
 sm_prog_1_wrapper (struct svc_req *rqstp, register SVCXPRT *transp)
 {
+	struct sockaddr_in *sin = nfs_getrpccaller_in(transp);
+
 	/* remote host authorization check */
-	if (!check_default("statd", svc_getcaller(transp),
-				 rqstp->rq_proc, SM_PROG)) {
+	if (sin->sin_family == AF_INET &&
+	    !check_default("statd", sin, rqstp->rq_proc, SM_PROG)) {
 		svcerr_auth (transp, AUTH_FAILED);
 		return;
 	}

