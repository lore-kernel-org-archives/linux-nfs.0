From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 2/5] nfs-utils: break up nfssvc.c into more individually callable functions
Date: Wed, 27 May 2009 07:54:32 -0400
Message-ID: <1243425275-6284-3-git-send-email-jlayton@redhat.com>
References: <1243425275-6284-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, steved@redhat.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:40502 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761552AbZE0Lyj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 May 2009 07:54:39 -0400
In-Reply-To: <1243425275-6284-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfssvc.c contains functions for starting up knfsd. Currently, the only
non-static function in that file is nfssvc(). In order to add IPv6
support, we'll need to be able to call some of these functions in a
more granular fashion.

Reorganize these functions and add prototypes to the header so that
they can be called individually, and change the nfsd program to call
those routines individually.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 support/include/nfslib.h |    6 ++-
 support/nfs/nfssvc.c     |  107 +++++++++++++++++++++++++++------------------
 utils/nfsd/nfsd.c        |   20 ++++++++-
 3 files changed, 88 insertions(+), 45 deletions(-)

diff --git a/support/include/nfslib.h b/support/include/nfslib.h
index ae98650..4cb1dc0 100644
--- a/support/include/nfslib.h
+++ b/support/include/nfslib.h
@@ -130,7 +130,11 @@ int			wildmat(char *text, char *pattern);
  * nfsd library functions.
  */
 int			nfsctl(int, struct nfsctl_arg *, union nfsctl_res *);
-int			nfssvc(int port, int nrservs, unsigned int versbits, int minorvers4, unsigned int portbits, char *haddr);
+int			nfssvc_inuse(void);
+int			nfssvc_setfds(unsigned int ctlbits, struct sockaddr *sa,
+					socklen_t addrlen);
+void			nfssvc_setvers(unsigned int ctlbits, int minorvers4);
+int			nfssvc_threads(unsigned short port, int nrservs);
 int			nfsaddclient(struct nfsctl_client *clp);
 int			nfsdelclient(struct nfsctl_client *clp);
 int			nfsexport(struct nfsctl_export *exp);
diff --git a/support/nfs/nfssvc.c b/support/nfs/nfssvc.c
index 33c15a7..7634562 100644
--- a/support/nfs/nfssvc.c
+++ b/support/nfs/nfssvc.c
@@ -25,78 +25,101 @@
 #define NFSD_VERS_FILE    "/proc/fs/nfsd/versions"
 #define NFSD_THREAD_FILE  "/proc/fs/nfsd/threads"
 
-static void
-nfssvc_setfds(int port, unsigned int ctlbits, char *haddr)
+/*
+ * Are there already sockets configured? If not, then it is safe to try to
+ * open some and pass them through.
+ *
+ * Note: If the user explicitly asked for 'udp', then we should probably check
+ * if that is open, and should open it if not.  However we don't yet. All
+ * sockets * have to be opened when the first daemon is started.
+ */
+int
+nfssvc_inuse(void)
 {
-	int fd, n, on=1;
+	int fd, n;
 	char buf[BUFSIZ];
-	int udpfd = -1, tcpfd = -1;
-	struct sockaddr_in sin;
 
 	fd = open(NFSD_PORTS_FILE, O_RDONLY);
+
+	/* problem opening file, assume that nothing is configured */
 	if (fd < 0)
-		return;
+		return 0;
+
 	n = read(fd, buf, BUFSIZ);
 	close(fd);
+
 	if (n != 0)
-		return;
-	/* there are no ports currently open, so it is safe to
-	 * try to open some and pass them through.
-	 * Note: If the user explicitly asked for 'udp', then
-	 * we should probably check if that is open, and should
-	 * open it if not.  However we don't yet.  All sockets
-	 * have to be opened when the first daemon is started.
+		return 1;
+
+	return 0;
+}
+
+int
+nfssvc_setfds(unsigned int ctlbits, struct sockaddr *sa, socklen_t addrlen)
+{
+	int fd, on = 1;
+	char buf[BUFSIZ];
+	int udpfd = -1, tcpfd = -1, rc = 0;
+
+	/*
+	 * if file can't be opened, then assume that it's not available and
+	 * that the caller should just fall back to the old nfsctl interface
 	 */
 	fd = open(NFSD_PORTS_FILE, O_WRONLY);
 	if (fd < 0)
-		return;
-	sin.sin_family = AF_INET;
-	sin.sin_port   = htons(port);
-	sin.sin_addr.s_addr =  inet_addr(haddr);
+		return 0;
 
 	if (NFSCTL_UDPISSET(ctlbits)) {
 		udpfd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
 		if (udpfd < 0) {
-			syslog(LOG_ERR, "nfssvc: unable to create UPD socket: "
+			syslog(LOG_ERR, "nfssvc: unable to create UDP socket: "
 				"errno %d (%s)\n", errno, strerror(errno));
-			exit(1);
+			rc = -errno;
+			goto error;
 		}
-		if (bind(udpfd, (struct  sockaddr  *)&sin, sizeof(sin)) < 0){
-			syslog(LOG_ERR, "nfssvc: unable to bind UPD socket: "
+		if (bind(udpfd, sa, addrlen) < 0) {
+			syslog(LOG_ERR, "nfssvc: unable to bind UDP socket: "
 				"errno %d (%s)\n", errno, strerror(errno));
-			exit(1);
+			rc = -errno;
+			goto error;
 		}
 	}
 
 	if (NFSCTL_TCPISSET(ctlbits)) {
 		tcpfd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
 		if (tcpfd < 0) {
-			syslog(LOG_ERR, "nfssvc: unable to createt tcp socket: "
+			syslog(LOG_ERR, "nfssvc: unable to create TCP socket: "
 				"errno %d (%s)\n", errno, strerror(errno));
-			exit(1);
+			rc = -errno;
+			goto error;
 		}
 		if (setsockopt(tcpfd, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on)) < 0) {
 			syslog(LOG_ERR, "nfssvc: unable to set SO_REUSEADDR: "
 				"errno %d (%s)\n", errno, strerror(errno));
-			exit(1);
+			rc = -errno;
+			goto error;
 		}
-		if (bind(tcpfd, (struct  sockaddr  *)&sin, sizeof(sin)) < 0){
+		if (bind(tcpfd, sa, addrlen) < 0) {
 			syslog(LOG_ERR, "nfssvc: unable to bind TCP socket: "
 				"errno %d (%s)\n", errno, strerror(errno));
-			exit(1);
+			rc = -errno;
+			goto error;
 		}
 		if (listen(tcpfd, 64) < 0){
 			syslog(LOG_ERR, "nfssvc: unable to create listening socket: "
 				"errno %d (%s)\n", errno, strerror(errno));
-			exit(1);
+			rc = -errno;
+			goto error;
 		}
 	}
 	if (udpfd >= 0) {
 		snprintf(buf, BUFSIZ,"%d\n", udpfd); 
 		if (write(fd, buf, strlen(buf)) != strlen(buf)) {
 			syslog(LOG_ERR, 
-			       "nfssvc: writing fds to kernel failed: errno %d (%s)", 
+			       "nfssvc: writing udp fd to kernel failed: errno %d (%s)", 
 			       errno, strerror(errno));
+			rc = -errno;
+			goto error;
 		}
 		close(fd);
 		fd = -1;
@@ -107,16 +130,21 @@ nfssvc_setfds(int port, unsigned int ctlbits, char *haddr)
 		snprintf(buf, BUFSIZ,"%d\n", tcpfd); 
 		if (write(fd, buf, strlen(buf)) != strlen(buf)) {
 			syslog(LOG_ERR, 
-			       "nfssvc: writing fds to kernel failed: errno %d (%s)", 
+			       "nfssvc: writing tcp fd to kernel failed: errno %d (%s)", 
 			       errno, strerror(errno));
+			rc = -errno;
 		}
 	}
-	close(fd);
 
-	return;
+error:
+	if (fd >= 0)
+		close(fd);
+
+	return rc;
 }
-static void
-nfssvc_versbits(unsigned int ctlbits, int minorvers4)
+
+void
+nfssvc_setvers(unsigned int ctlbits, int minorvers4)
 {
 	int fd, n, off;
 	char buf[BUFSIZ], *ptr;
@@ -147,20 +175,13 @@ nfssvc_versbits(unsigned int ctlbits, int minorvers4)
 
 	return;
 }
+
 int
-nfssvc(int port, int nrservs, unsigned int versbits, int minorvers4,
-	unsigned protobits, char *haddr)
+nfssvc_threads(unsigned short port, int nrservs)
 {
 	struct nfsctl_arg	arg;
 	int fd;
 
-	/* Note: must set versions before fds so that
-	 * the ports get registered with portmap against correct
-	 * versions
-	 */
-	nfssvc_versbits(versbits, minorvers4);
-	nfssvc_setfds(port, protobits, haddr);
-
 	fd = open(NFSD_THREAD_FILE, O_WRONLY);
 	if (fd < 0)
 		fd = open("/proc/fs/nfs/threads", O_WRONLY);
diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index e3c0094..2a3cd0a 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -51,6 +51,7 @@ main(int argc, char **argv)
 	struct servent *ent;
 	struct hostent *hp;
 	char *p;
+	struct sockaddr_in sin;
 
 	ent = getservbyname ("nfs", "udp");
 	if (ent != NULL)
@@ -163,13 +164,30 @@ main(int argc, char **argv)
 	}
 	closeall(3);
 
+	sin.sin_family = AF_INET;
+	sin.sin_port = htons(port);
+	sin.sin_addr.s_addr = inet_addr(haddr);
+
+	/*
+	 * must set versions before the fd's so that the right versions get
+	 * registered with rpcbind. Note that on older kernels w/o the right
+	 * interfaces, these are a no-op.
+	 */
+	if (!nfssvc_inuse()) {
+		nfssvc_setvers(versbits, minorvers4);
+		error = nfssvc_setfds(protobits, (struct sockaddr *) &sin, sizeof(sin));
+		if (error)
+			goto out;
+	}
+
 	openlog("nfsd", LOG_PID, LOG_DAEMON);
-	if ((error = nfssvc(port, count, versbits, minorvers4, protobits, haddr)) < 0) {
+	if ((error = nfssvc_threads(port, count)) < 0) {
 		int e = errno;
 		syslog(LOG_ERR, "nfssvc: %s", strerror(e));
 		closelog();
 	}
 
+out:
 	return (error != 0);
 }
 
-- 
1.6.0.6

