From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/17] mount: rename local variable to avoid collision with
	library function
Date: Mon, 18 Feb 2008 13:36:22 -0500
Message-ID: <20080218183622.19060.30365.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:56590 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752965AbYBRSgX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2008 13:36:23 -0500
Received: from manray.1015granger.net (adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi101.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id m1IIaMW5019081
	for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2008 10:36:23 -0800
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id m1IIaMCw019366
	for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2008 13:36:22 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: The local variable name "socket" is overloaded, so rename it.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 9f8d1d4..5e6d17d 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -875,18 +875,18 @@ int clnt_ping(struct sockaddr_in *saddr, const unsigned long prog,
 int get_client_address(struct sockaddr_in *saddr, struct sockaddr_in *caddr)
 {
 	socklen_t len = sizeof(*caddr);
-	int socket, err;
+	int sock, err;
 
-	socket = nfs_getsocket((struct sockaddr *)saddr, IPPROTO_UDP,
+	sock = nfs_getsocket((struct sockaddr *)saddr, IPPROTO_UDP,
 				CONNECT_TIMEOUT, FALSE, TRUE);
-	if (socket == RPC_ANYSOCK)
+	if (sock == RPC_ANYSOCK)
 		return 0;
 
-	err = getsockname(socket, caddr, &len);
+	err = getsockname(sock, caddr, &len);
 	if (err && verbose)
 		nfs_error(_("%s: error acquiring client's local address: %s"),
 				progname, strerror(errno));
 
-	close(socket);
+	close(sock);
 	return err ? 0 : 1;
 }

