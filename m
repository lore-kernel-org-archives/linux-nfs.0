From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 06/11] nfs-utils: move check for active knfsd to helper function
Date: Mon,  8 Jun 2009 14:00:39 -0400
Message-ID: <1244484044-21355-7-git-send-email-jlayton@redhat.com>
References: <1244484044-21355-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, steved@redhat.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48143 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751456AbZFHSAy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2009 14:00:54 -0400
In-Reply-To: <1244484044-21355-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfssvc_setfds checks to see if knfsd is already running. Move this
check to a helper function. Eventually the nfsd code will call this
directly.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/nfsd/nfssvc.c |   44 ++++++++++++++++++++++++++++++--------------
 1 files changed, 30 insertions(+), 14 deletions(-)

diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
index 025554d..7ecaea9 100644
--- a/utils/nfsd/nfssvc.c
+++ b/utils/nfsd/nfssvc.c
@@ -32,27 +32,43 @@
  */
 char buf[128];
 
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
-	int udpfd = -1, tcpfd = -1;
-	struct sockaddr_in sin;
+	int fd, n;
 
 	fd = open(NFSD_PORTS_FILE, O_RDONLY);
+
+	/* problem opening file, assume that nothing is configured */
 	if (fd < 0)
-		return;
+		return 0;
+
 	n = read(fd, buf, sizeof(buf));
 	close(fd);
-	if (n != 0)
+
+	xlog(D_GENERAL, "knfsd is currently %s", (n > 0) ? "up" : "down");
+
+	return (n > 0);
+}
+
+static void
+nfssvc_setfds(int port, unsigned int ctlbits, char *haddr)
+{
+	int fd, on=1;
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
1.6.0.6

