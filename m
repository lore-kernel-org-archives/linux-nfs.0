Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:36412 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150AbbHXQFl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Aug 2015 12:05:41 -0400
Received: by qgeb6 with SMTP id b6so89360711qge.3
        for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2015 09:05:40 -0700 (PDT)
Subject: [PATCH] statd: statd_get_socket() should return open fds
From: Chuck Lever <chuck.lever@oracle.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 24 Aug 2015 09:05:38 -0700
Message-ID: <20150824160538.1402.26833.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tastky <tastky@gmail.com> reports:
> There appears to be a bug in nfs-utils exposed by musl, which
> makes rpc.statd loop with:
>
> my_svc_run() - select: Bad file descriptor

OpenGroup says getservbyport(3) is supposed to return NULL when
no entry exists for the specified port. But musl's getservbyport(3)
never returns NULL (likely a bug).

Thus statd_get_socket() tries bindresvport(3) 100 times, then gives
up and returns the last socket it created. This should work fine,
but there's a bug in the retry loop:

Rich Felker <dalias@libc.org> says:
> The logic bug is the count-down loop that closes all the temp
> sockets. In the case where the loop terminates via break, it
> leaves the last one open and only closes the extras. But in the
> case where where the loop terminates via the end condition in the
> for statement, the close loop closes all the sockets _including_
> the one it intends to use.

(emphasis mine). The closed socket fd is then passed to select(2).

See also: http://www.openwall.com/lists/musl/2015/08

The fix is to perform the loop termination test before adding sockfd
to the set of fds to be closed. As additional clean ups, remove the
use of the variable-length stack array, and switch to variable names
that better document the purpose of this logic.

Reported-by: Tastky <tastky@gmail.com>
Fixes: eb8229338f06 ("rpc.statd: Fix socket binding loop.")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 utils/statd/rmtcall.c |   27 ++++++++++++++++++---------
 1 file changed, 18 insertions(+), 9 deletions(-)

diff --git a/utils/statd/rmtcall.c b/utils/statd/rmtcall.c
index dc620a9..d2255a1 100644
--- a/utils/statd/rmtcall.c
+++ b/utils/statd/rmtcall.c
@@ -52,6 +52,9 @@
 
 static int		sockfd = -1;	/* notify socket */
 
+/* How many times to try looking for an unused privileged port */
+#define MAX_BRP_RETRIES	100
+
 /*
  * Initialize socket used to notify lockd of peer reboots.
  *
@@ -68,14 +71,14 @@ statd_get_socket(void)
 {
 	struct sockaddr_in	sin;
 	struct servent *se;
-	const int loopcnt = 100;
-	int i, tmp_sockets[loopcnt];
+	static int prevsocks[MAX_BRP_RETRIES];
+	unsigned int retries;
 
 	if (sockfd >= 0)
 		return sockfd;
 
-	for (i = 0; i < loopcnt; ++i) {
-
+	retries = 0;
+	do {
 		if ((sockfd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0) {
 			xlog(L_ERROR, "%s: Can't create socket: %m", __func__);
 			break;
@@ -96,13 +99,19 @@ statd_get_socket(void)
 		se = getservbyport(sin.sin_port, "udp");
 		if (se == NULL)
 			break;
-		/* rather not use that port, try again */
 
-		tmp_sockets[i] = sockfd;
-	}
+		if (retries == MAX_BRP_RETRIES) {
+			xlog(D_GENERAL, "%s: No unused privileged ports",
+					__func__);
+			break;
+		}
+
+		/* rather not use that port, try again */
+		prevsocks[retries++] = sockfd;
+	} while (1);
 
-	while (--i >= 0)
-		close(tmp_sockets[i]);
+	while (retries)
+		close(prevsocks[--retries]);
 
 	if (sockfd < 0)
 		return -1;

