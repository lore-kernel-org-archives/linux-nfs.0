From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 05/10] nfs-utils: move check for active knfsd to helper function
Date: Wed,  3 Jun 2009 15:52:38 -0400
Message-ID: <1244058763-10352-6-git-send-email-jlayton@redhat.com>
References: <1244058763-10352-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, steved@redhat.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:51457 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754689AbZFCTwu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Jun 2009 15:52:50 -0400
In-Reply-To: <1244058763-10352-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfssvc_setfds checks to see if knfsd is already running. Move this
check to a helper function. Eventually the nfsd code will call this
directly.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 support/nfs/nfssvc.c |   44 +++++++++++++++++++++++++++++++-------------
 1 files changed, 31 insertions(+), 13 deletions(-)

diff --git a/support/nfs/nfssvc.c b/support/nfs/nfssvc.c
index 3e6bd31..8b15c4d 100644
--- a/support/nfs/nfssvc.c
+++ b/support/nfs/nfssvc.c
@@ -24,28 +24,46 @@
 #define NFSD_VERS_FILE    "/proc/fs/nfsd/versions"
 #define NFSD_THREAD_FILE  "/proc/fs/nfsd/threads"
 
-static void
-nfssvc_setfds(int port, unsigned int ctlbits, char *haddr)
+/*
+ * Are there already sockets configured? If not, then it is safe to try to
+ * open some and pass them through.
+ *
+ * Note: If the user explicitly asked for 'udp', then we should probably check
+ * if that is open, and should open it if not. However we don't yet. All
+ * sockets have to be opened when the first daemon is started.
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
+		return 1;
+
+	return 0;
+}
+
+static void
+nfssvc_setfds(int port, unsigned int ctlbits, char *haddr)
+{
+	int fd, n, on=1;
+	char buf[BUFSIZ];
+	int udpfd = -1, tcpfd = -1;
+	struct sockaddr_in sin;
+
+	if (nfssvc_inuse())
 		return;
-	/* there are no ports currently open, so it is safe to
-	 * try to open some and pass them through.
-	 * Note: If the user explicitly asked for 'udp', then
-	 * we should probably check if that is open, and should
-	 * open it if not.  However we don't yet.  All sockets
-	 * have to be opened when the first daemon is started.
-	 */
+
 	fd = open(NFSD_PORTS_FILE, O_WRONLY);
 	if (fd < 0)
 		return;
-- 
1.6.2.2

