From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/10] mount.nfs: Shorter timeout for TCP connects
Date: Fri, 03 Aug 2007 13:23:49 -0400
Message-ID: <20070803172349.3357.55907.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IH0so-00024I-Tg
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 10:24:15 -0700
Received: from flpvm23.prodigy.net ([207.115.20.53])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IH0sr-0000VB-4z
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 10:24:18 -0700
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

The standard TCP connect timeout on Linux is 75 seconds, which can be
too long in some cases.  The timeout itself can be altered on a system-wide
basis, but we'd like mount to have it's own connect timeout that's tunable,
and defaults to a shorter value.

The get_socket() function is a utility function that does TCP connects for
getport, clnt_ping, and other functions.  Add logic there to use a
non-blocking connect() and select() in order to time out a connect
operation that's taking too long.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |   64 +++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 59 insertions(+), 5 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 220bbce..89cb976 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -52,6 +52,10 @@
 #define NFS_PORT 2049
 #endif
 
+#define PMAP_TIMEOUT	(10)
+#define CONNECT_TIMEOUT	(20)
+#define MOUNT_TIMEOUT	(30)
+
 #if SIZEOF_SOCKLEN_T - 0 == 0
 #define socklen_t unsigned int
 #endif
@@ -158,12 +162,60 @@ int nfs_gethostbyname(const char *hostname, struct sockaddr_in *saddr)
 }
 
 /*
+ * Attempt to connect a socket, but time out after "timeout" seconds.
+ *
+ * On error return, caller closes the socket.
+ */
+static int connect_to(int fd, struct sockaddr *addr,
+			socklen_t addrlen, int timeout)
+{
+	int ret, saved;
+	fd_set rset, wset;
+	struct timeval tv = {
+		.tv_sec = timeout,
+	};
+
+	saved = fcntl(fd, F_GETFL, 0);
+	fcntl(fd, F_SETFL, saved | O_NONBLOCK);
+
+	ret = connect(fd, addr, addrlen);
+	if (ret < 0 && errno != EINPROGRESS)
+		return -1;
+	if (ret == 0)
+		goto out;
+
+	FD_ZERO(&rset);
+	FD_SET(fd, &rset);
+	wset = rset;
+	ret = select(fd + 1, &rset, &wset, NULL, &tv);
+	if (ret == 0) {
+		errno = ETIMEDOUT;
+		return -1;
+	}
+	if (FD_ISSET(fd, &rset) || FD_ISSET(fd, &wset)) {
+		int error;
+		socklen_t len = sizeof(error);
+		if (getsockopt(fd, SOL_SOCKET, SO_ERROR, &error, &len) < 0)
+			return -1;
+		if (error) {
+			errno = error;
+			return -1;
+		}
+	} else
+		return -1;
+
+out:
+	fcntl(fd, F_SETFL, saved);
+	return 0;
+}
+
+/*
  * Create a socket that is locally bound to a reserved or non-reserved
  * port. For any failures, RPC_ANYSOCK is returned which will cause 
  * the RPC code to create the socket instead. 
  */
 static int get_socket(struct sockaddr_in *saddr, unsigned int p_prot,
-			int resvp, int conn)
+			unsigned int timeout, int resvp, int conn)
 {
 	int so, cc, type;
 	struct sockaddr_in laddr;
@@ -185,7 +237,8 @@ static int get_socket(struct sockaddr_in *saddr, unsigned int p_prot,
 			goto err_bind;
 	}
 	if (type == SOCK_STREAM || (conn && type == SOCK_DGRAM)) {
-		cc = connect(so, (struct sockaddr *)saddr, namelen);
+		cc = connect_to(so, (struct sockaddr *)saddr, namelen,
+				timeout);
 		if (cc < 0)
 			goto err_connect;
 	}
@@ -262,7 +315,7 @@ static unsigned short getport(struct sockaddr_in *saddr,
 	 * clnt*create() will create one anyway if this
 	 * fails.
 	 */
-	socket = get_socket(saddr, proto, FALSE, FALSE);
+	socket = get_socket(saddr, proto, PMAP_TIMEOUT, FALSE, FALSE);
 	if (socket == RPC_ANYSOCK) {
 		if (proto == IPPROTO_TCP && errno == ETIMEDOUT) {
 			/*
@@ -552,7 +605,8 @@ CLIENT *mnt_openclnt(clnt_addr_t *mnt_server, int *msock)
 	CLIENT *clnt = NULL;
 
 	mnt_saddr->sin_port = htons((u_short)mnt_pmap->pm_port);
-	*msock = get_socket(mnt_saddr, mnt_pmap->pm_prot, TRUE, FALSE);
+	*msock = get_socket(mnt_saddr, mnt_pmap->pm_prot, MOUNT_TIMEOUT,
+				TRUE, FALSE);
 	if (*msock == RPC_ANYSOCK) {
 		if (rpc_createerr.cf_error.re_errno == EADDRINUSE)
 			/*
@@ -608,7 +662,7 @@ int clnt_ping(struct sockaddr_in *saddr, const unsigned long prog,
 	struct sockaddr dissolve;
 
 	rpc_createerr.cf_stat = stat = errno = 0;
-	sock = get_socket(saddr, prot, FALSE, TRUE);
+	sock = get_socket(saddr, prot, CONNECT_TIMEOUT, FALSE, TRUE);
 	if (sock == RPC_ANYSOCK) {
 		if (errno == ETIMEDOUT) {
 			/*


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
