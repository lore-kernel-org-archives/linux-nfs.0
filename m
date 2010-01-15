From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/6] tcpwrapper: Add support for IPv6
Date: Fri, 15 Jan 2010 12:50:24 -0500
Message-ID: <20100115175023.30104.84791.stgit@localhost.localdomain>
References: <20100115174426.30104.3492.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:23644 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753404Ab0AORun (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jan 2010 12:50:43 -0500
In-Reply-To: <20100115174426.30104.3492.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Assuming the tcp_wrappers library can actually support IPv6 addresses,
here's a crack at IPv6 support in nfs-utils' TCP wrapper shim.

Some reorganization is done to limit the number of times that @sap
is converted to a presentation address string.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/include/tcpwrapper.h  |    3 +
 support/misc/tcpwrapper.c     |  115 ++++++++++++++++++++++++++++-------------
 utils/mountd/mount_dispatch.c |    6 +-
 utils/statd/statd.c           |    5 --
 utils/statd/statd.man         |    3 -
 5 files changed, 84 insertions(+), 48 deletions(-)

diff --git a/support/include/tcpwrapper.h b/support/include/tcpwrapper.h
index 930ec6a..f735106 100644
--- a/support/include/tcpwrapper.h
+++ b/support/include/tcpwrapper.h
@@ -6,6 +6,7 @@
 #include <arpa/inet.h>
 
 extern int from_local(const struct sockaddr *sap);
-extern int check_default(char *name, struct sockaddr_in *addr, u_long prog);
+extern int check_default(char *name, struct sockaddr *sap,
+			const unsigned long program);
 
 #endif /* TCP_WRAPPER_H */
diff --git a/support/misc/tcpwrapper.c b/support/misc/tcpwrapper.c
index 03f5dc4..06b0a46 100644
--- a/support/misc/tcpwrapper.c
+++ b/support/misc/tcpwrapper.c
@@ -48,31 +48,66 @@
 #include <sys/stat.h>
 #include <tcpd.h>
 
+#include "sockaddr.h"
 #include "tcpwrapper.h"
 #include "xlog.h"
 
 #ifdef SYSV40
 #include <netinet/in.h>
 #include <rpc/rpcent.h>
-#endif
-
-static int check_files(void);
+#endif	/* SYSV40 */
 
 #define ALLOW 1
 #define DENY 0
 
+#ifdef IPV6_SUPPORTED
+static void
+present_address(const struct sockaddr *sap, char *buf, const size_t buflen)
+{
+	const struct sockaddr_in *sin = (const struct sockaddr_in *)sap;
+	const struct sockaddr_in6 *sin6 = (const struct sockaddr_in6 *)sap;
+	socklen_t len = (socklen_t)buflen;
+
+	switch (sap->sa_family) {
+	case AF_INET:
+		if (inet_ntop(AF_INET, &sin->sin_addr, buf, len) != 0)
+			return;
+	case AF_INET6:
+		if (inet_ntop(AF_INET6, &sin6->sin6_addr, buf, len) != 0)
+			return;
+	}
+
+	memset(buf, 0, buflen);
+	strncpy(buf, "unrecognized caller", buflen);
+}
+#else	/* !IPV6_SUPPORTED */
+static void
+present_address(const struct sockaddr *sap, char *buf, const size_t buflen)
+{
+	const struct sockaddr_in *sin = (const struct sockaddr_in *)sap;
+	socklen_t len = (socklen_t)buflen;
+
+	if (sap->sa_family == AF_INET)
+		if (inet_ntop(AF_INET, &sin->sin_addr, buf, len) != 0)
+			return;
+
+	memset(buf, 0, buflen);
+	strncpy(buf, "unrecognized caller", (size_t)buflen);
+}
+#endif	/* !IPV6_SUPPORTED */
+
 typedef struct _haccess_t {
 	TAILQ_ENTRY(_haccess_t)	list;
 	int			allowed;
-	struct in_addr		addr;
+	union nfs_sockaddr	address;
 } haccess_t;
 
 #define HASH_TABLE_SIZE 1021
 typedef struct _hash_head {
 	TAILQ_HEAD(host_list, _haccess_t) h_head;
 } hash_head;
-hash_head haccess_tbl[HASH_TABLE_SIZE];
-static haccess_t *haccess_lookup(struct sockaddr_in *addr, u_long);
+
+static hash_head haccess_tbl[HASH_TABLE_SIZE];
 
 static unsigned long
 strtoint(const char *str)
@@ -99,7 +134,8 @@ HASH(const char *addr, const unsigned long program)
 }
 
 static void
-haccess_add(struct sockaddr_in *addr, u_long prog, int allowed)
+haccess_add(const struct sockaddr *sap, const char *address,
+		const unsigned long program, const int allowed)
 {
 	hash_head *head;
 	haccess_t *hptr;
@@ -109,49 +145,49 @@ haccess_add(struct sockaddr_in *addr, u_long prog, int allowed)
 	if (hptr == NULL)
 		return;
 
-	hash = HASH(inet_ntoa(addr->sin_addr), prog);
+	hash = HASH(address, program);
 	head = &(haccess_tbl[hash]);
 
 	hptr->allowed = allowed;
-	hptr->addr.s_addr = addr->sin_addr.s_addr;
+	memcpy(&hptr->address, sap, (size_t)nfs_sockaddr_length(sap));
 
 	if (TAILQ_EMPTY(&head->h_head))
 		TAILQ_INSERT_HEAD(&head->h_head, hptr, list);
 	else
 		TAILQ_INSERT_TAIL(&head->h_head, hptr, list);
 }
-haccess_t *haccess_lookup(struct sockaddr_in *addr, u_long prog)
+
+static haccess_t *
+haccess_lookup(const struct sockaddr *sap, const char *address,
+		const unsigned long program)
 {
 	hash_head *head;
 	haccess_t *hptr;
 	unsigned int hash;
 
-	hash = HASH(inet_ntoa(addr->sin_addr), prog);
+	hash = HASH(address, program);
 	head = &(haccess_tbl[hash]);
 
 	TAILQ_FOREACH(hptr, &head->h_head, list) {
-		if (hptr->addr.s_addr == addr->sin_addr.s_addr)
+		if (nfs_compare_sockaddr(&hptr->address.sa, sap))
 			return hptr;
 	}
 	return NULL;
 }
 
 static void
-logit(const struct sockaddr_in *sin)
+logit(const char *address)
 {
-	char buf[INET_ADDRSTRLEN];
-
 	xlog_warn("connect from %s denied: request from unauthorized host",
-			inet_ntop(AF_INET, &sin->sin_addr, buf, sizeof(buf)));
-		
+			address);
 }
 
 static int
-good_client(char *name, struct sockaddr_in *addr)
+good_client(char *name, struct sockaddr *sap)
 {
 	struct request_info req;
 
-	request_init(&req, RQ_DAEMON, name, RQ_CLIENT_SIN, addr, 0);
+	request_init(&req, RQ_DAEMON, name, RQ_CLIENT_SIN, sap, 0);
 	sock_methods(&req);
 
 	if (hosts_access(&req)) 
@@ -160,9 +196,8 @@ good_client(char *name, struct sockaddr_in *addr)
 	return DENY;
 }
 
-/* check_files - check to see if either access files have changed */
-
-static int check_files()
+static int
+check_files(void)
 {
 	static time_t allow_mtime, deny_mtime;
 	struct stat astat, dstat;
@@ -191,36 +226,44 @@ static int check_files()
  * check_default - additional checks for NULL, DUMP, GETPORT and unknown
  * @name: pointer to '\0'-terminated ASCII string containing name of the
  *		daemon requesting the access check
- * @addr: pointer to socket address containing address of caller
- * @prog: RPC program number caller is attempting to access
+ * @sap: pointer to sockaddr containing network address of caller
+ * @program: RPC program number caller is attempting to access
  *
  * Returns TRUE if the caller is allowed access; otherwise FALSE is returned.
  */
 int
-check_default(char *name, struct sockaddr_in *addr, u_long prog)
+check_default(char *name, struct sockaddr *sap, const unsigned long program)
 {
 	haccess_t *acc = NULL;
 	int changed = check_files();
+	char buf[INET6_ADDRSTRLEN];
+
+	present_address(sap, buf, sizeof(buf));
 
-	acc = haccess_lookup(addr, prog);
-	if (acc && changed == 0)
+	acc = haccess_lookup(sap, buf, program);
+	if (acc != NULL && changed == 0) {
+		xlog(D_GENERAL, "%s: access by %s %s (cached)", __func__,
+			buf, acc->allowed ? "ALLOWED" : "DENIED");
 		return acc->allowed;
+	}
 
-	if (!(from_local((struct sockaddr *)addr) || good_client(name, addr))) {
-		logit(addr);
-		if (acc)
+	if (!(from_local(sap) || good_client(name, sap))) {
+		logit(buf);
+		if (acc != NULL)
 			acc->allowed = FALSE;
-		else 
-			haccess_add(addr, prog, FALSE);
+		else
+			haccess_add(sap, buf, program, FALSE);
+		xlog(D_GENERAL, "%s: access by %s DENIED", __func__, buf);
 		return (FALSE);
 	}
 
-	if (acc)
+	if (acc != NULL)
 		acc->allowed = TRUE;
-	else 
-		haccess_add(addr, prog, TRUE);
+	else
+		haccess_add(sap, buf, program, TRUE);
+	xlog(D_GENERAL, "%s: access by %s ALLOWED", __func__, buf);
 
-    return (TRUE);
+	return (TRUE);
 }
 
 #endif	/* HAVE_LIBWRAP */
diff --git a/utils/mountd/mount_dispatch.c b/utils/mountd/mount_dispatch.c
index d2802ef..ba6981d 100644
--- a/utils/mountd/mount_dispatch.c
+++ b/utils/mountd/mount_dispatch.c
@@ -70,12 +70,10 @@ mount_dispatch(struct svc_req *rqstp, SVCXPRT *transp)
 {
 	union mountd_arguments 	argument;
 	union mountd_results	result;
-#ifdef HAVE_TCP_WRAPPER
-	struct sockaddr_in *sin = nfs_getrpccaller_in(transp);
 
+#ifdef HAVE_TCP_WRAPPER
 	/* remote host authorization check */
-	if (sin->sin_family == AF_INET &&
-	    !check_default("mountd", sin, MOUNTPROG)) {
+	if (!check_default("mountd", nfs_getrpccaller(transp), MOUNTPROG)) {
 		svcerr_auth (transp, AUTH_FAILED);
 		return;
 	}
diff --git a/utils/statd/statd.c b/utils/statd/statd.c
index fa3c6d5..01fdb41 100644
--- a/utils/statd/statd.c
+++ b/utils/statd/statd.c
@@ -75,11 +75,8 @@ extern void simulator (int, char **);
 static void 
 sm_prog_1_wrapper (struct svc_req *rqstp, register SVCXPRT *transp)
 {
-	struct sockaddr_in *sin = nfs_getrpccaller_in(transp);
-
 	/* remote host authorization check */
-	if (sin->sin_family == AF_INET &&
-	    !check_default("statd", sin, SM_PROG)) {
+	if (!check_default("statd", nfs_getrpccaller(transp), SM_PROG)) {
 		svcerr_auth (transp, AUTH_FAILED);
 		return;
 	}
diff --git a/utils/statd/statd.man b/utils/statd/statd.man
index 4ddb634..ffc5e95 100644
--- a/utils/statd/statd.man
+++ b/utils/statd/statd.man
@@ -274,9 +274,6 @@ listeners using the
 .B tcp_wrapper
 library or
 .BR iptables (8).
-Note that the
-.B tcp_wrapper
-library supports only IPv4 networking.
 To use the
 .B tcp_wrapper
 library, add the hostnames of peers that should be allowed access to

