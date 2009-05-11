From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/3] nfs-utils: rearrange nfssvc.c
Date: Mon, 11 May 2009 13:58:15 -0400
Message-ID: <1242064697-32520-2-git-send-email-jlayton@redhat.com>
References: <1242064697-32520-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.120]:60321 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758699AbZEKR6S (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 May 2009 13:58:18 -0400
In-Reply-To: <1242064697-32520-1-git-send-email-jlayton@redhat.com>
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
 support/include/nfslib.h |    5 +++-
 support/nfs/nfssvc.c     |   65 ++++++++++++++++++++++++---------------------
 utils/nfsd/nfsd.c        |   17 +++++++++++-
 3 files changed, 55 insertions(+), 32 deletions(-)

diff --git a/support/include/nfslib.h b/support/include/nfslib.h
index 9d0d39d..30baa85 100644
--- a/support/include/nfslib.h
+++ b/support/include/nfslib.h
@@ -130,7 +130,10 @@ int			wildmat(char *text, char *pattern);
  * nfsd library functions.
  */
 int			nfsctl(int, struct nfsctl_arg *, union nfsctl_res *);
-int			nfssvc(int port, int nrservs, unsigned int versbits, unsigned int portbits, char *haddr);
+void			nfssvc_setfds(unsigned int ctlbits, struct sockaddr *sa,
+					socklen_t addrlen);
+void			nfssvc_setvers(unsigned int ctlbits);
+int			nfssvc_threads(unsigned short port, int nrservs);
 int			nfsaddclient(struct nfsctl_client *clp);
 int			nfsdelclient(struct nfsctl_client *clp);
 int			nfsexport(struct nfsctl_export *exp);
diff --git a/support/nfs/nfssvc.c b/support/nfs/nfssvc.c
index 9bbc9a5..c9b09dd 100644
--- a/support/nfs/nfssvc.c
+++ b/support/nfs/nfssvc.c
@@ -25,34 +25,45 @@
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
+nfssvc_inuse()
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
-	 */
+		return 1;
+
+	return 0;
+}
+
+void
+nfssvc_setfds(unsigned int ctlbits, struct sockaddr *sa, socklen_t addrlen)
+{
+	int fd, on = 1;
+	char buf[BUFSIZ];
+	int udpfd = -1, tcpfd = -1;
+
 	fd = open(NFSD_PORTS_FILE, O_WRONLY);
 	if (fd < 0)
 		return;
-	sin.sin_family = AF_INET;
-	sin.sin_port   = htons(port);
-	sin.sin_addr.s_addr =  inet_addr(haddr);
 
 	if (NFSCTL_UDPISSET(ctlbits)) {
 		udpfd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
@@ -61,7 +72,7 @@ nfssvc_setfds(int port, unsigned int ctlbits, char *haddr)
 				"errno %d (%s)\n", errno, strerror(errno));
 			exit(1);
 		}
-		if (bind(udpfd, (struct  sockaddr  *)&sin, sizeof(sin)) < 0){
+		if (bind(udpfd, sa, addrlen) < 0) {
 			syslog(LOG_ERR, "nfssvc: unable to bind UPD socket: "
 				"errno %d (%s)\n", errno, strerror(errno));
 			exit(1);
@@ -80,7 +91,7 @@ nfssvc_setfds(int port, unsigned int ctlbits, char *haddr)
 				"errno %d (%s)\n", errno, strerror(errno));
 			exit(1);
 		}
-		if (bind(tcpfd, (struct  sockaddr  *)&sin, sizeof(sin)) < 0){
+		if (bind(tcpfd, sa, addrlen) < 0) {
 			syslog(LOG_ERR, "nfssvc: unable to bind TCP socket: "
 				"errno %d (%s)\n", errno, strerror(errno));
 			exit(1);
@@ -115,8 +126,9 @@ nfssvc_setfds(int port, unsigned int ctlbits, char *haddr)
 
 	return;
 }
-static void
-nfssvc_versbits(unsigned int ctlbits)
+
+void
+nfssvc_setvers(unsigned int ctlbits)
 {
 	int fd, n, off;
 	char buf[BUFSIZ], *ptr;
@@ -142,20 +154,13 @@ nfssvc_versbits(unsigned int ctlbits)
 
 	return;
 }
+
 int
-nfssvc(int port, int nrservs, unsigned int versbits, unsigned protobits,
-	char *haddr)
+nfssvc_threads(unsigned short port, int nrservs)
 {
 	struct nfsctl_arg	arg;
 	int fd;
 
-	/* Note: must set versions before fds so that
-	 * the ports get registered with portmap against correct
-	 * versions
-	 */
-	nfssvc_versbits(versbits);
-	nfssvc_setfds(port, protobits, haddr);
-
 	fd = open(NFSD_THREAD_FILE, O_WRONLY);
 	if (fd < 0)
 		fd = open("/proc/fs/nfs/threads", O_WRONLY);
diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index c97c81f..25babe1 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -49,6 +49,7 @@ main(int argc, char **argv)
 	int	count = 1, c, error, port, fd, found_one;
 	struct servent *ent;
 	struct hostent *hp;
+	struct sockaddr_in sin;
 
 	ent = getservbyname ("nfs", "udp");
 	if (ent != NULL)
@@ -157,8 +158,22 @@ main(int argc, char **argv)
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
+		nfssvc_setvers(versbits);
+		nfssvc_setfds(protobits, (struct sockaddr *) &sin, sizeof(sin));
+	}
+
 	openlog("nfsd", LOG_PID, LOG_DAEMON);
-	if ((error = nfssvc(port, count, versbits, protobits, haddr)) < 0) {
+	if ((error = nfssvc_threads(port, count)) < 0) {
 		int e = errno;
 		syslog(LOG_ERR, "nfssvc: %s", strerror(e));
 		closelog();
-- 
1.6.0.6

