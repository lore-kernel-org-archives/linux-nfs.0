From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 11/24] Removed warnings from nfssvc.c
Date: Tue, 20 Jul 2010 19:37:24 -0400
Message-ID: <1279669057-17509-12-git-send-email-steved@redhat.com>
References: <1279669057-17509-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:60376 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1761907Ab0GUAnH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 20:43:07 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1ObMNY-0004K5-A1
	for linux-nfs@vger.kernel.org; Tue, 20 Jul 2010 19:37:40 -0400
In-Reply-To: <1279669057-17509-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfssvc.c:184: warning: comparison between signed and unsigned integer expressions
nfssvc.c: In function 'nfssvc_setvers':
nfssvc.c:254: warning: comparison between signed and unsigned integer expressions
nfssvc.c: In function 'nfssvc_threads':
nfssvc.c:280: warning: comparison between signed and unsigned integer expressions

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/nfsd/nfssvc.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
index 60232b8..34c67ca 100644
--- a/utils/nfsd/nfssvc.c
+++ b/utils/nfsd/nfssvc.c
@@ -181,7 +181,7 @@ nfssvc_setfds(const struct addrinfo *hints, const char *node, const char *port)
 		}
 
 		snprintf(buf, sizeof(buf), "%d\n", sockfd); 
-		if (write(fd, buf, strlen(buf)) != strlen(buf)) {
+		if (write(fd, buf, strlen(buf)) != (ssize_t)strlen(buf)) {
 			/*
 			 * this error may be common on older kernels that don't
 			 * support IPv6, so turn into a debug message.
@@ -251,7 +251,7 @@ nfssvc_setvers(unsigned int ctlbits, int minorvers4)
 	}
 	xlog(D_GENERAL, "Writing version string to kernel: %s", buf);
 	snprintf(ptr+off, sizeof(buf) - off, "\n");
-	if (write(fd, buf, strlen(buf)) != strlen(buf))
+	if (write(fd, buf, strlen(buf)) != (ssize_t)strlen(buf))
 		xlog(L_ERROR, "Setting version failed: errno %d (%m)", errno);
 
 	close(fd);
@@ -277,7 +277,7 @@ nfssvc_threads(unsigned short port, const int nrservs)
 		snprintf(buf, sizeof(buf), "%d\n", nrservs);
 		n = write(fd, buf, strlen(buf));
 		close(fd);
-		if (n != strlen(buf))
+		if (n != (ssize_t)strlen(buf))
 			return -1;
 		else
 			return 0;
-- 
1.7.0.1

