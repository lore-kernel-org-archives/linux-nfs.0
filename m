Return-Path: linux-nfs-owner@vger.kernel.org
Received: from elspeth.ephaone.org ([88.191.186.164]:42196 "EHLO
	elspeth.ephaone.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751446AbaCBJql (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 2 Mar 2014 04:46:41 -0500
From: Michael Scherer <misc@zarb.org>
To: linux-nfs@vger.kernel.org
Cc: Michael Scherer <misc@zarb.org>
Subject: [PATCH] nfsd: permit to use multiple time the -H option
Date: Sun,  2 Mar 2014 10:38:32 +0100
Message-Id: <1393753112-14879-1-git-send-email-misc@zarb.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This permit to have 1 nfsd listening on more than 1
interface for multihomed systems, without having to
listen on all interfaces and filtering later.
---
 utils/nfsd/nfsd.c   | 51 +++++++++++++++++++++++++++++++++++----------------
 utils/nfsd/nfsd.man |  3 ++-
 2 files changed, 37 insertions(+), 17 deletions(-)

diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index edeb621..7ab6fcf 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -95,9 +95,10 @@ nfsd_enable_protos(unsigned int *proto4, unsigned int *proto6)
 int
 main(int argc, char **argv)
 {
-	int	count = NFSD_NPROC, c, error = 0, portnum = 0, fd, found_one;
+	int	count = NFSD_NPROC, c, i, error = 0, portnum = 0, fd, found_one;
 	char *p, *progname, *port;
-	char *haddr = NULL;
+	char **haddr = NULL;
+	unsigned int hcounter = 0;
 	int	socket_up = 0;
 	unsigned int minorvers = 0;
 	unsigned int minorversset = 0;
@@ -118,6 +119,13 @@ main(int argc, char **argv)
 		exit(1);
 	}
 
+	haddr = malloc(sizeof(char*));
+	if (!haddr) {
+		fprintf(stderr, "%s: unable to allocate memory.\n", progname);
+		exit(1);
+	}
+	haddr[0] = NULL;
+
 	xlog_syslog(0);
 	xlog_stderr(1);
 
@@ -127,17 +135,24 @@ main(int argc, char **argv)
 			xlog_config(D_ALL, 1);
 			break;
 		case 'H':
-			/*
-			 * for now, this only handles one -H option. Use the
-			 * last one specified.
-			 */
-			free(haddr);
-			haddr = strdup(optarg);
-			if (!haddr) {
+			if (hcounter) {
+				haddr = realloc(haddr, sizeof(char*) * hcounter+1);
+
+				if(!haddr) {
+					fprintf(stderr, "%s: unable to allocate "
+							"memory.\n", progname);
+					exit(1);
+				}
+			}
+
+			haddr[hcounter] = strdup(optarg);
+			if (!haddr[hcounter]) {
 				fprintf(stderr, "%s: unable to allocate "
 					"memory.\n", progname);
 				exit(1);
 			}
+
+			hcounter++;
 			break;
 		case 'P':	/* XXX for nfs-server compatibility */
 		case 'p':
@@ -286,16 +301,18 @@ main(int argc, char **argv)
 	 * interfaces, these are a no-op.
 	 */
 	nfssvc_setvers(versbits, minorvers, minorversset);
- 
-	error = nfssvc_set_sockets(AF_INET, proto4, haddr, port);
-	if (!error)
-		socket_up = 1;
+
+	for(i=0; i <= hcounter; i++) {
+		error = nfssvc_set_sockets(AF_INET, proto4, haddr[i], port);
+		if (!error)
+			socket_up = 1;
 
 #ifdef IPV6_SUPPORTED
-	error = nfssvc_set_sockets(AF_INET6, proto6, haddr, port);
-	if (!error)
-		socket_up = 1;
+		error = nfssvc_set_sockets(AF_INET6, proto6, haddr[i], port);
+		if (!error)
+			socket_up = 1;
 #endif /* IPV6_SUPPORTED */
+	}
 
 set_threads:
 	/* don't start any threads if unable to hand off any sockets */
@@ -328,6 +345,8 @@ set_threads:
 		xlog(L_ERROR, "error starting threads: errno %d (%m)", errno);
 out:
 	free(port);
+	for(i=0; i <= hcounter; i++)
+		free(haddr[i]);
 	free(haddr);
 	free(progname);
 	return (error != 0);
diff --git a/utils/nfsd/nfsd.man b/utils/nfsd/nfsd.man
index 7de0867..cdc14ba 100644
--- a/utils/nfsd/nfsd.man
+++ b/utils/nfsd/nfsd.man
@@ -35,7 +35,8 @@ Note that
 .B lockd
 (which performs file locking services for NFS) may still accept
 request on all known network addresses.  This may change in future
-releases of the Linux Kernel.
+releases of the Linux Kernel. This option can be used multiple time 
+to listen to more than one interface.
 .TP
 .B \-p " or " \-\-port  port
 specify a different port to listen on for NFS requests. By default,
-- 
1.8.5.3

