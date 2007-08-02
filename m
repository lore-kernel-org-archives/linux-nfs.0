From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] mount.nfs: Shorter timeout for TCP connects
Date: Thu, 02 Aug 2007 12:30:57 -0400
Message-ID: <20070802163057.3201.19919.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGdZg-0006nX-5e
	for nfs@lists.sourceforge.net; Thu, 02 Aug 2007 09:30:56 -0700
Received: from flpvm09.prodigy.net ([207.115.20.39])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IGdZj-0003vR-1G
	for nfs@lists.sourceforge.net; Thu, 02 Aug 2007 09:31:00 -0700
Received: from monet.1015granger.net
	(adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpvm09.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id
	l72GUuKF026854
	for <nfs@lists.sourceforge.net>; Thu, 2 Aug 2007 09:30:57 -0700
Received: from monet.1015granger.net (monet.1015granger.net [127.0.0.1])
	by monet.1015granger.net (8.14.1/8.14.1) with ESMTP id l72GUvdd003217
	for <nfs@lists.sourceforge.net>; Thu, 2 Aug 2007 12:30:57 -0400
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
annoying long.  The timeout itself can be altered on a system-wide basis,
but we'd like mount to have it's own connect timeout that's tunable, and
defaults to a more sane value.

The get_socket() function is a utility function that does TCP connects for
getport, clnt_ping, and other functions.  Add logic there to use a
non-blocking connect() and select() in order to time out a connect
operation that's taking too long.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |   53 ++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 52 insertions(+), 1 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 220bbce..874a445 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -52,6 +52,8 @@
 #define NFS_PORT 2049
 #endif
 
+#define CONNECT_TIMEOUT	(15)
+
 #if SIZEOF_SOCKLEN_T - 0 == 0
 #define socklen_t unsigned int
 #endif
@@ -158,6 +160,54 @@ int nfs_gethostbyname(const char *hostname, struct sockaddr_in *saddr)
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
@@ -185,7 +235,8 @@ static int get_socket(struct sockaddr_in *saddr, unsigned int p_prot,
 			goto err_bind;
 	}
 	if (type == SOCK_STREAM || (conn && type == SOCK_DGRAM)) {
-		cc = connect(so, (struct sockaddr *)saddr, namelen);
+		cc = connect_to(so, (struct sockaddr *)saddr, namelen,
+				CONNECT_TIMEOUT);
 		if (cc < 0)
 			goto err_connect;
 	}


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
