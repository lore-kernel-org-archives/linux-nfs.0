From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 19/23] libnfs.a: move get_socket() function
	to	utils/mount/network.c
Date: Sat, 28 Jul 2007 17:50:45 -0400
Message-ID: <20070728215045.21871.43734.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IFGOs-0003jG-2F
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 14:34:07 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IFGOv-0003xh-NX
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 14:34:10 -0700
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

Now we can address the real problem: that get_socket() depends on the
global variable "verbose" which is only available in the mount command.

Move get_socket() into utils/mount/network.c, and make it static.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/include/conn.h |    2 -
 support/nfs/conn.c     |   78 ------------------------------------------------
 utils/mount/network.c  |   73 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 73 insertions(+), 80 deletions(-)

diff --git a/support/include/conn.h b/support/include/conn.h
index ee1b686..2b1f07d 100644
--- a/support/include/conn.h
+++ b/support/include/conn.h
@@ -28,7 +28,5 @@ typedef struct {
 static const struct timeval TIMEOUT = { 20, 0 };
 static const struct timeval RETRY_TIMEOUT = { 3, 0 };
 
-int get_socket(struct sockaddr_in *, u_int, int, int);
-
 #endif /* _CONN_H */
 
diff --git a/support/nfs/conn.c b/support/nfs/conn.c
index d153aa2..db9185d 100644
--- a/support/nfs/conn.c
+++ b/support/nfs/conn.c
@@ -19,81 +19,3 @@
 
 #include "conn.h"
 
-#if SIZEOF_SOCKLEN_T - 0 == 0
-#define socklen_t int
-#endif
-
-extern int verbose;
-
-/*
- * Create a socket that is locally bound to a 
- * reserve or non-reserve port. For any failures,
- * RPC_ANYSOCK is returned which will cause 
- * the RPC code to create the socket instead. 
- */
-int get_socket(struct sockaddr_in *saddr, u_int p_prot, int resvp, int conn)
-{
-	int so, cc, type;
-	struct sockaddr_in laddr;
-	socklen_t namelen = sizeof(laddr);
-
-	type = (p_prot == IPPROTO_UDP ? SOCK_DGRAM : SOCK_STREAM);
-	if ((so = socket (AF_INET, type, p_prot)) < 0) {
-		rpc_createerr.cf_stat = RPC_SYSTEMERROR;
-		rpc_createerr.cf_error.re_errno = errno;
-		if (verbose) {
-			fprintf(stderr, 
-				"mount: Unable to create %s socket: errno %d (%s)\n",
-				p_prot == IPPROTO_UDP ? "UDP" : "TCP", 
-				errno, strerror(errno));
-		}
-		return RPC_ANYSOCK;
-	}
-	laddr.sin_family = AF_INET;
-	laddr.sin_port = 0;
-	laddr.sin_addr.s_addr = htonl(INADDR_ANY);
-	if (resvp) {
-		if (bindresvport(so, &laddr) < 0) {
-			rpc_createerr.cf_stat = RPC_SYSTEMERROR;
-			rpc_createerr.cf_error.re_errno = errno;
-			if (verbose) {
-				fprintf(stderr, 
-					"mount: Unable to bindresvport %s socket: errno %d (%s)\n",
-					p_prot == IPPROTO_UDP ? "UDP" : "TCP", 
-					errno, strerror(errno));
-			}
-			close(so);
-			return RPC_ANYSOCK;
-		}
-	} else {
-		cc = bind(so, (struct sockaddr *)&laddr, namelen);
-		if (cc < 0) {
-			rpc_createerr.cf_stat = RPC_SYSTEMERROR;
-			rpc_createerr.cf_error.re_errno = errno;
-			if (verbose) {
-				fprintf(stderr, 
-					"mount: Unable to bind to %s socket: errno %d (%s)\n",
-					p_prot == IPPROTO_UDP ? "UDP" : "TCP", 
-					errno, strerror(errno));
-			}
-			close(so);
-			return RPC_ANYSOCK;
-		}
-	}
-	if (type == SOCK_STREAM || (conn && type == SOCK_DGRAM)) {
-		cc = connect(so, (struct sockaddr *)saddr, namelen);
-		if (cc < 0) {
-			rpc_createerr.cf_stat = RPC_SYSTEMERROR;
-			rpc_createerr.cf_error.re_errno = errno;
-			if (verbose) {
-				fprintf(stderr, 
-					"mount: Unable to connect to %s:%d, errno %d (%s)\n",
-					inet_ntoa(saddr->sin_addr), ntohs(saddr->sin_port),
-					errno, strerror(errno));
-			}
-			close(so);
-			return RPC_ANYSOCK;
-		}
-	}
-	return so;
-}
diff --git a/utils/mount/network.c b/utils/mount/network.c
index a5b0b71..4831990 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -159,6 +159,79 @@ int nfs_gethostbyname(const char *hostname, struct sockaddr_in *saddr)
 }
 
 /*
+ * Create a socket that is locally bound to a reserved or non-reserved
+ * port. For any failures, RPC_ANYSOCK is returned which will cause 
+ * the RPC code to create the socket instead. 
+ */
+static int get_socket(struct sockaddr_in *saddr, unsigned int p_prot,
+			int resvp, int conn)
+{
+	int so, cc, type;
+	struct sockaddr_in laddr;
+	socklen_t namelen = sizeof(laddr);
+
+	type = (p_prot == IPPROTO_UDP ? SOCK_DGRAM : SOCK_STREAM);
+	if ((so = socket (AF_INET, type, p_prot)) < 0) {
+		rpc_createerr.cf_stat = RPC_SYSTEMERROR;
+		rpc_createerr.cf_error.re_errno = errno;
+		if (verbose) {
+			fprintf(stderr, 
+				"mount: Unable to create %s socket: errno %d (%s)\n",
+				p_prot == IPPROTO_UDP ? "UDP" : "TCP", 
+				errno, strerror(errno));
+		}
+		return RPC_ANYSOCK;
+	}
+	laddr.sin_family = AF_INET;
+	laddr.sin_port = 0;
+	laddr.sin_addr.s_addr = htonl(INADDR_ANY);
+	if (resvp) {
+		if (bindresvport(so, &laddr) < 0) {
+			rpc_createerr.cf_stat = RPC_SYSTEMERROR;
+			rpc_createerr.cf_error.re_errno = errno;
+			if (verbose) {
+				fprintf(stderr, 
+					"mount: Unable to bindresvport %s socket: errno %d (%s)\n",
+					p_prot == IPPROTO_UDP ? "UDP" : "TCP", 
+					errno, strerror(errno));
+			}
+			close(so);
+			return RPC_ANYSOCK;
+		}
+	} else {
+		cc = bind(so, (struct sockaddr *)&laddr, namelen);
+		if (cc < 0) {
+			rpc_createerr.cf_stat = RPC_SYSTEMERROR;
+			rpc_createerr.cf_error.re_errno = errno;
+			if (verbose) {
+				fprintf(stderr, 
+					"mount: Unable to bind to %s socket: errno %d (%s)\n",
+					p_prot == IPPROTO_UDP ? "UDP" : "TCP", 
+					errno, strerror(errno));
+			}
+			close(so);
+			return RPC_ANYSOCK;
+		}
+	}
+	if (type == SOCK_STREAM || (conn && type == SOCK_DGRAM)) {
+		cc = connect(so, (struct sockaddr *)saddr, namelen);
+		if (cc < 0) {
+			rpc_createerr.cf_stat = RPC_SYSTEMERROR;
+			rpc_createerr.cf_error.re_errno = errno;
+			if (verbose) {
+				fprintf(stderr, 
+					"mount: Unable to connect to %s:%d, errno %d (%s)\n",
+					inet_ntoa(saddr->sin_addr), ntohs(saddr->sin_port),
+					errno, strerror(errno));
+			}
+			close(so);
+			return RPC_ANYSOCK;
+		}
+	}
+	return so;
+}
+
+/*
  * getport() is very similar to pmap_getport() with the exception that
  * this version tries to use an ephemeral port, since reserved ports are
  * not needed for GETPORT queries.  This conserves the very limited


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
