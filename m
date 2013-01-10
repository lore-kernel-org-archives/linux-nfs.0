Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f51.google.com ([209.85.215.51]:61672 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751432Ab3AJOeE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jan 2013 09:34:04 -0500
Received: by mail-la0-f51.google.com with SMTP id fj20so662798lab.38
        for <linux-nfs@vger.kernel.org>; Thu, 10 Jan 2013 06:34:02 -0800 (PST)
Date: Thu, 10 Jan 2013 16:27:10 +0200
From: Hemmo Nieminen <hemmo.nieminen@iki.fi>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH] Binding a privileged port in rpc.statd.
Message-ID: <20130110142710.GA2544@fcku.lan>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="6TrnltStXW4iwmi0"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--6TrnltStXW4iwmi0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

Hi,

It seems that rpc.statd will fail to bind to a (free) port, if
the first port it receives is listed in /etc/services. The
bindresvport will keep on returning the same port if we close
the socket too early.

The attached patch should fix this.

-- 
Hemmo

--6TrnltStXW4iwmi0
Content-Type: text/plain; charset=utf-8
Content-Disposition: attachment; filename="0001-Fix-socket-binding-loop.patch"

>From abdaa0c27d66c71c9500b983fc4366cb3e514fff Mon Sep 17 00:00:00 2001
From: Hemmo Nieminen <hemmo.nieminen@iki.fi>
Date: Thu, 3 Jan 2013 10:00:17 +0200
Subject: [PATCH] Fix socket binding loop.

Instead of closing the sockets before requesting a new one, keep them
open until a suitable one is found. Otherwise bindresvport will return
the same port over and over again.
---
 utils/statd/rmtcall.c | 19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/utils/statd/rmtcall.c b/utils/statd/rmtcall.c
index 4ecb03c..fd576d9 100644
--- a/utils/statd/rmtcall.c
+++ b/utils/statd/rmtcall.c
@@ -68,21 +68,19 @@ statd_get_socket(void)
 {
 	struct sockaddr_in	sin;
 	struct servent *se;
-	int loopcnt = 100;
+	const int loopcnt = 100;
+	int i, tmp_sockets[loopcnt];
 
 	if (sockfd >= 0)
 		return sockfd;
 
-	while (loopcnt-- > 0) {
-
-		if (sockfd >= 0) close(sockfd);
+	for (i = 0; i < loopcnt; ++i) {
 
 		if ((sockfd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0) {
 			xlog(L_ERROR, "%s: Can't create socket: %m", __func__);
-			return -1;
+			break;
 		}
 
-
 		memset(&sin, 0, sizeof(sin));
 		sin.sin_family = AF_INET;
 		sin.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
@@ -96,7 +94,16 @@ statd_get_socket(void)
 		if (se == NULL)
 			break;
 		/* rather not use that port, try again */
+
+		tmp_sockets[i] = sockfd;
 	}
+
+	while (--i >= 0)
+		close(tmp_sockets[i]);
+
+	if (sockfd < 0)
+		return -1;
+
 	FD_SET(sockfd, &SVC_FDSET);
 	return sockfd;
 }
-- 
1.8.1


--6TrnltStXW4iwmi0--
