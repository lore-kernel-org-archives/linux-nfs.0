From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 18/23] libnfs.a: move clnt_ping() to utils/mount
Date: Sat, 28 Jul 2007 17:50:40 -0400
Message-ID: <20070728215040.21871.70327.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IFGOq-0003iM-Tf
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 14:34:07 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IFGOu-0005i2-LN
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 14:34:08 -0700
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

Continue clean up of mount functionality in libnfs.a by moving clnt_ping()
to utils/mount/network.c.  Note that socklen_t is an unsigned int... the
i386 gcc compiler threw a signedness warning about the 3rd argument of
getsockname().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/include/conn.h  |    2 -
 support/nfs/conn.c      |   75 ---------------------------------------------
 utils/mount/network.c   |   79 +++++++++++++++++++++++++++++++++++++++++++++++
 utils/mount/network.h   |    3 ++
 utils/mount/nfs4mount.c |    1 +
 5 files changed, 83 insertions(+), 77 deletions(-)

diff --git a/support/include/conn.h b/support/include/conn.h
index 48f5a1c..ee1b686 100644
--- a/support/include/conn.h
+++ b/support/include/conn.h
@@ -28,8 +28,6 @@ typedef struct {
 static const struct timeval TIMEOUT = { 20, 0 };
 static const struct timeval RETRY_TIMEOUT = { 3, 0 };
 
-int clnt_ping(struct sockaddr_in *, const u_long, const u_long, const u_int,
-	      struct sockaddr_in *);
 int get_socket(struct sockaddr_in *, u_int, int, int);
 
 #endif /* _CONN_H */
diff --git a/support/nfs/conn.c b/support/nfs/conn.c
index 970abfe..d153aa2 100644
--- a/support/nfs/conn.c
+++ b/support/nfs/conn.c
@@ -97,78 +97,3 @@ int get_socket(struct sockaddr_in *saddr, u_int p_prot, int resvp, int conn)
 	}
 	return so;
 }
-
-/*
- * Sigh... getport() doesn't actually check the version number.
- * In order to make sure that the server actually supports the service
- * we're requesting, we open and RPC client, and fire off a NULL
- * RPC call.
- */
-int
-clnt_ping(struct sockaddr_in *saddr, const u_long prog, const u_long vers,
-	  const u_int prot, struct sockaddr_in *caddr)
-{
-	CLIENT *clnt=NULL;
-	int sock, stat;
-	static char clnt_res;
-	struct sockaddr dissolve;
-
-	rpc_createerr.cf_stat = stat = errno = 0;
-	sock = get_socket(saddr, prot, FALSE, TRUE);
-	if (sock == RPC_ANYSOCK) {
-		if (errno == ETIMEDOUT) {
-			/*
-			 * TCP timeout. Bubble up the error to see 
-			 * how it should be handled.
-			 */
-			rpc_createerr.cf_stat = RPC_TIMEDOUT;
-		}
-		return 0;
-	}
-
-	if (caddr) {
-		/* Get the address of our end of this connection */
-		socklen_t len = sizeof(*caddr);
-		if (getsockname(sock, caddr, &len) != 0)
-			caddr->sin_family = 0;
-	}
-
-	switch(prot) {
-	case IPPROTO_UDP:
-		/* The socket is connected (so we could getsockname successfully),
-		 * but some servers on multi-homed hosts reply from
-		 * the wrong address, so if we stay connected, we lose the reply.
-		 */
-		dissolve.sa_family = AF_UNSPEC;
-		connect(sock, &dissolve, sizeof(dissolve));
-
-		clnt = clntudp_bufcreate(saddr, prog, vers,
-					 RETRY_TIMEOUT, &sock,
-					 RPCSMALLMSGSIZE, RPCSMALLMSGSIZE);
-		break;
-	case IPPROTO_TCP:
-		clnt = clnttcp_create(saddr, prog, vers, &sock,
-				      RPCSMALLMSGSIZE, RPCSMALLMSGSIZE);
-		break;
-	}
-	if (!clnt) {
-		close(sock);
-		return 0;
-	}
-	memset(&clnt_res, 0, sizeof(clnt_res));
-	stat = clnt_call(clnt, NULLPROC,
-			 (xdrproc_t)xdr_void, (caddr_t)NULL,
-			 (xdrproc_t)xdr_void, (caddr_t)&clnt_res,
-			 TIMEOUT);
-	if (stat) {
-		clnt_geterr(clnt, &rpc_createerr.cf_error);
-		rpc_createerr.cf_stat = stat;
-	}
-	clnt_destroy(clnt);
-	close(sock);
-
-	if (stat == RPC_SUCCESS)
-		return 1;
-	else
-		return 0;
-}
diff --git a/utils/mount/network.c b/utils/mount/network.c
index c092571..a5b0b71 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -53,6 +53,10 @@
 #define NFS_PORT 2049
 #endif
 
+#if SIZEOF_SOCKLEN_T - 0 == 0
+#define socklen_t unsigned int
+#endif
+
 extern int nfs_mount_data_version;
 extern char *progname;
 extern int verbose;
@@ -510,3 +514,78 @@ void mnt_closeclnt(CLIENT *clnt, int msock)
 	clnt_destroy(clnt);
 	close(msock);
 }
+
+/*
+ * Sigh... getport() doesn't actually check the version number.
+ * In order to make sure that the server actually supports the service
+ * we're requesting, we open and RPC client, and fire off a NULL
+ * RPC call.
+ */
+int clnt_ping(struct sockaddr_in *saddr, const unsigned long prog,
+		const unsigned long vers, const unsigned int prot,
+		struct sockaddr_in *caddr)
+{
+	CLIENT *clnt = NULL;
+	int sock, stat;
+	static char clnt_res;
+	struct sockaddr dissolve;
+
+	rpc_createerr.cf_stat = stat = errno = 0;
+	sock = get_socket(saddr, prot, FALSE, TRUE);
+	if (sock == RPC_ANYSOCK) {
+		if (errno == ETIMEDOUT) {
+			/*
+			 * TCP timeout. Bubble up the error to see 
+			 * how it should be handled.
+			 */
+			rpc_createerr.cf_stat = RPC_TIMEDOUT;
+		}
+		return 0;
+	}
+
+	if (caddr) {
+		/* Get the address of our end of this connection */
+		socklen_t len = sizeof(*caddr);
+		if (getsockname(sock, caddr, &len) != 0)
+			caddr->sin_family = 0;
+	}
+
+	switch(prot) {
+	case IPPROTO_UDP:
+		/* The socket is connected (so we could getsockname successfully),
+		 * but some servers on multi-homed hosts reply from
+		 * the wrong address, so if we stay connected, we lose the reply.
+		 */
+		dissolve.sa_family = AF_UNSPEC;
+		connect(sock, &dissolve, sizeof(dissolve));
+
+		clnt = clntudp_bufcreate(saddr, prog, vers,
+					 RETRY_TIMEOUT, &sock,
+					 RPCSMALLMSGSIZE, RPCSMALLMSGSIZE);
+		break;
+	case IPPROTO_TCP:
+		clnt = clnttcp_create(saddr, prog, vers, &sock,
+				      RPCSMALLMSGSIZE, RPCSMALLMSGSIZE);
+		break;
+	}
+	if (!clnt) {
+		close(sock);
+		return 0;
+	}
+	memset(&clnt_res, 0, sizeof(clnt_res));
+	stat = clnt_call(clnt, NULLPROC,
+			 (xdrproc_t)xdr_void, (caddr_t)NULL,
+			 (xdrproc_t)xdr_void, (caddr_t)&clnt_res,
+			 TIMEOUT);
+	if (stat) {
+		clnt_geterr(clnt, &rpc_createerr.cf_error);
+		rpc_createerr.cf_stat = stat;
+	}
+	clnt_destroy(clnt);
+	close(sock);
+
+	if (stat == RPC_SUCCESS)
+		return 1;
+	else
+		return 0;
+}
diff --git a/utils/mount/network.h b/utils/mount/network.h
index b3a5525..0f24a32 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -30,6 +30,9 @@
 int probe_bothports(clnt_addr_t *, clnt_addr_t *);
 int nfs_gethostbyname(const char *, struct sockaddr_in *);
 int nfs_call_umount(clnt_addr_t *, dirpath *);
+int clnt_ping(struct sockaddr_in *, const unsigned long,
+		const unsigned long, const unsigned int,
+		struct sockaddr_in *);
 
 int start_statd(void);
 
diff --git a/utils/mount/nfs4mount.c b/utils/mount/nfs4mount.c
index 4868c08..de97bd6 100644
--- a/utils/mount/nfs4mount.c
+++ b/utils/mount/nfs4mount.c
@@ -46,6 +46,7 @@
 #include "nfs4_mount.h"
 #include "nfs_mount.h"
 #include "error.h"
+#include "network.h"
 
 #if defined(VAR_LOCK_DIR)
 #define DEFAULT_DIR VAR_LOCK_DIR


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
