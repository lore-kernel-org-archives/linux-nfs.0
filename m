Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from gw1a.telemetry-investments.com ([64.20.161.180]:45713 "EHLO
	sv1.telemetry-investments.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756783Ab0LIVWQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Dec 2010 16:22:16 -0500
Received: from ti93.telemetry-investments.com (ti93 [192.168.20.93])
	by sv1.telemetry-investments.com (Postfix) with ESMTP id 1A5D4904B
	for <linux-nfs@vger.kernel.org>; Thu,  9 Dec 2010 15:49:13 -0500 (EST)
Date: Thu, 9 Dec 2010 15:49:13 -0500
From: "Andrew J. Schorr" <ajschorr@alumni.princeton.edu>
To: linux-nfs@vger.kernel.org
Subject: proposed patch to rpcbind to provide finer-grained security controls
 than offered by the -i option
Message-ID: <20101209204913.GA30338@ti93.telemetry-investments.com>
Content-Type: multipart/mixed; boundary="2oS5YaxWCcQjTEyO"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--2oS5YaxWCcQjTEyO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

The current rpcbind -i option seems to relax 3 different security requirements.
If the user wants to allow any one of the three, he is forced to allow
all 3.

The attached patch introduces 3 new options (-c, -r, and -u) to break this
down to give the user control of which security requirements to relax.

This patch compiles, but has not been tested yet.  If there is any
interest in accepting this, I will of course test it. :-)  But it's fairly
basic, so I thought I'd gauge the interest level first.  Steve
Dickson from Redhat suggested that I post here to discuss this issue
regarding https://bugzilla.redhat.com/show_bug.cgi?id=481422

Thank you for considering this.  I do not follow this list, so apologize
in advance if this email violates any conventions or protocols.

Regards,
Andy

--2oS5YaxWCcQjTEyO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="rpcbind-0.2.0-security.patch"

diff -up rpcbind-0.2.0/src/rpcbind.c.orig rpcbind-0.2.0/src/rpcbind.c
--- rpcbind-0.2.0/src/rpcbind.c.orig	2009-05-29 09:38:22.000000000 -0400
+++ rpcbind-0.2.0/src/rpcbind.c	2010-12-09 15:39:14.459781896 -0500
@@ -92,8 +92,9 @@ char *rpcbinduser = NULL;
 #define RPCBINDDLOCK "/var/run/rpcbind.lock"
 
 int runasdaemon = 0;
-int insecure = 0;
-int oldstyle_local = 0;
+int allow_remote = 0;
+int allow_unprivileged = 0;
+int allow_callit = 0;
 int verboselog = 0;
 
 char **hosts = NULL;
@@ -730,13 +731,15 @@ static void
 parseargs(int argc, char *argv[])
 {
 	int c;
-	oldstyle_local = 1;
-	while ((c = getopt(argc, argv, "dwah:ils")) != -1) {
+	while ((c = getopt(argc, argv, "acdh:ilrsuw")) != -1) {
 		switch (c) {
 		case 'a':
 			doabort = 1;	/* when debugging, do an abort on */
 			break;		/* errors; for rpcbind developers */
 					/* only! */
+		case 'c':
+			allow_callit = 1;
+			break;
 		case 'd':
 			debugging = 1;
 			break;
@@ -750,21 +753,27 @@ parseargs(int argc, char *argv[])
 				errx(1, "Out of memory");
 			break;
 		case 'i':
-			insecure = 1;
+			allow_remote = allow_unprivileged = allow_callit = 1;
 			break;
 		case 'l':
 			verboselog = 1;
 			break;
+		case 'r':
+			allow_remote = 1;
+			break;
 		case 's':
 			runasdaemon = 1;
 			break;
+		case 'u':
+			allow_unprivileged = 1;
+			break;
 #ifdef WARMSTART
 		case 'w':
 			warmstart = 1;
 			break;
 #endif
 		default:	/* error */
-			fprintf(stderr,	"usage: rpcbind [-Idwils]\n");
+			fprintf(stderr,	"usage: rpcbind [-acdhilrsuw]\n");
 			exit (1);
 		}
 	}
diff -up rpcbind-0.2.0/src/rpcbind.h.orig rpcbind-0.2.0/src/rpcbind.h
--- rpcbind-0.2.0/src/rpcbind.h.orig	2009-05-29 09:38:22.000000000 -0400
+++ rpcbind-0.2.0/src/rpcbind.h	2010-12-09 15:37:47.340843901 -0500
@@ -67,8 +67,9 @@ struct r_rmtcall_args {
 extern int debugging;
 extern int doabort;
 extern int verboselog;
-extern int insecure;
-extern int oldstyle_local;
+extern int allow_remote;
+extern int allow_unprivileged;
+extern int allow_callit;
 extern rpcblist_ptr list_rbl;	/* A list of version 3 & 4 rpcbind services */
 
 #ifdef PORTMAP
@@ -123,6 +124,7 @@ int check_access(SVCXPRT *, rpcproc_t, v
 int check_callit(SVCXPRT *, struct r_rmtcall_args *, int);
 void logit(int, struct sockaddr *, rpcproc_t, rpcprog_t, const char *);
 int is_loopback(struct netbuf *);
+int is_privileged(struct netbuf *);
 int is_localroot(struct netbuf *);
 
 #ifdef PORTMAP
diff -up rpcbind-0.2.0/src/security.c.orig rpcbind-0.2.0/src/security.c
--- rpcbind-0.2.0/src/security.c.orig	2009-05-29 09:38:22.000000000 -0400
+++ rpcbind-0.2.0/src/security.c	2010-12-09 15:37:57.152719027 -0500
@@ -90,7 +90,7 @@ check_access(SVCXPRT *xprt, rpcproc_t pr
 		}
 		if (proc == RPCBPROC_GETADDR)
 			break;
-		if (!insecure && !is_loopback(caller)) {
+		if (!allow_remote && !is_loopback(caller)) {
 #ifdef RPCBIND_DEBUG
 			  if (debugging)
 			    fprintf(stderr, " declined (non-loopback sender) \n");
@@ -100,6 +100,16 @@ check_access(SVCXPRT *xprt, rpcproc_t pr
 				    " declined (non-loopback sender)");
 			return 0;
 		}
+		if (!allow_unprivileged && !is_privileged(caller)) {
+#ifdef RPCBIND_DEBUG
+			  if (debugging)
+			    fprintf(stderr, " declined (non-privileged sender) \n");
+#endif
+			if (verboselog)
+				logit(log_severity, addr, proc, prog,
+				    " declined (non-privileged sender)");
+			return 0;
+		}
 		break;
 	case RPCBPROC_CALLIT:
 	case RPCBPROC_INDIRECT:
@@ -141,32 +151,65 @@ is_loopback(struct netbuf *nbuf)
 
 	switch (addr->sa_family) {
 	case AF_INET:
-		if (!oldstyle_local)
-			return 0;
 		sin = (struct sockaddr_in *)addr;
 #ifdef RPCBIND_DEBUG
 		if (debugging)
 			  fprintf(stderr,
-				  "Checking caller's adress (port = %d)\n",
+				  "Checking caller's address (port = %d)\n",
 				  ntohs(sin->sin_port));
 #endif
-	       	return ((sin->sin_addr.s_addr == htonl(INADDR_LOOPBACK)) &&
-		    (ntohs(sin->sin_port) < IPPORT_RESERVED));
+	       	return (sin->sin_addr.s_addr == htonl(INADDR_LOOPBACK));
 #ifdef INET6
 	case AF_INET6:
-		if (!oldstyle_local)
-			return 0;
 		sin6 = (struct sockaddr_in6 *)addr;
 #ifdef RPCBIND_DEBUG
 		if (debugging)
 			  fprintf(stderr,
-				  "Checking caller's adress (port = %d)\n",
+				  "Checking caller's address (port = %d)\n",
 				  ntohs(sin6->sin6_port));
 #endif
-		return ((IN6_IS_ADDR_LOOPBACK(&sin6->sin6_addr) ||
-			 (IN6_IS_ADDR_V4MAPPED(&sin6->sin6_addr) &&
-			  sin6->sin6_addr.s6_addr32[3] == htonl(INADDR_LOOPBACK))) &&
-		        (ntohs(sin6->sin6_port) < IPV6PORT_RESERVED));
+		return (IN6_IS_ADDR_LOOPBACK(&sin6->sin6_addr) ||
+			(IN6_IS_ADDR_V4MAPPED(&sin6->sin6_addr) &&
+			 sin6->sin6_addr.s6_addr32[3] == htonl(INADDR_LOOPBACK)));
+#endif
+	case AF_LOCAL:
+		return 1;
+	default:
+		break;
+	}
+	
+	return 0;
+}
+
+int
+is_privileged(struct netbuf *nbuf)
+{
+	struct sockaddr *addr = (struct sockaddr *)nbuf->buf;
+	struct sockaddr_in *sin;
+#ifdef INET6
+	struct sockaddr_in6 *sin6;
+#endif
+
+	switch (addr->sa_family) {
+	case AF_INET:
+		sin = (struct sockaddr_in *)addr;
+#ifdef RPCBIND_DEBUG
+		if (debugging)
+			  fprintf(stderr,
+				  "Checking caller's port (%d)\n",
+				  ntohs(sin->sin_port));
+#endif
+	       	return (ntohs(sin->sin_port) < IPPORT_RESERVED);
+#ifdef INET6
+	case AF_INET6:
+		sin6 = (struct sockaddr_in6 *)addr;
+#ifdef RPCBIND_DEBUG
+		if (debugging)
+			  fprintf(stderr,
+				  "Checking caller's port (%d)\n",
+				  ntohs(sin6->sin6_port));
+#endif
+		return (ntohs(sin6->sin6_port) < IPV6PORT_RESERVED);
 #endif
 	case AF_LOCAL:
 		return 1;
@@ -192,15 +235,11 @@ is_localroot(struct netbuf *nbuf)
 
 	switch (addr->sa_family) {
 	case AF_INET:
-		if (!oldstyle_local)
-			return 0;
 		sin = (struct sockaddr_in *)addr;
 		return ((sin->sin_addr.s_addr == htonl(INADDR_LOOPBACK)) &&
 		    (ntohs(sin->sin_port) < IPPORT_RESERVED));
 #ifdef INET6
 	case AF_INET6:
-		if (!oldstyle_local)
-			return 0;
 		sin6 = (struct sockaddr_in6 *)addr;
 		return ((IN6_IS_ADDR_LOOPBACK(&sin6->sin6_addr) ||
 			 (IN6_IS_ADDR_V4MAPPED(&sin6->sin6_addr) &&
@@ -310,11 +349,7 @@ check_callit(SVCXPRT *xprt, struct r_rmt
 	 */
 	switch (args->rmt_prog) {
 	case RPCBPROG:
-		/*
-		 * Allow indirect calls to ourselves in insecure mode.
-		 * The is_loopback checks aren't useful then anyway.
-		 */
-		if (!insecure)
+		if (!allow_callit)
 			goto deny;
 		break;
 	case MOUNTPROG:

--2oS5YaxWCcQjTEyO--
