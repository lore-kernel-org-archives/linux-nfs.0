Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:56629 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751360Ab1G3WnP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Jul 2011 18:43:15 -0400
Received: by iyb12 with SMTP id 12so5410256iyb.19
        for <linux-nfs@vger.kernel.org>; Sat, 30 Jul 2011 15:43:14 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] rpc.statd: Bind downcall socket to loopback address
To: linux-nfs@vger.kernel.org
Date: Sat, 30 Jul 2011 18:43:10 -0400
Message-ID: <20110730224034.30227.2179.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

In the past, rpc.statd posted SM_NOTIFY requests using the same socket
it used for sending downcalls to the kernel.  To receive replies from
remote hosts, the socket was bound to INADDR_ANY.

With commit f113db52 "Remove notify functionality from statd in
favour of sm-notify" (Mar 20, 2007), the downcall socket is no longer
used for sending requests to remote hosts.  However, the downcall
socket is still bound to INADDR_ANY.  This means that any remote host
can inject data on this socket, since it is an unconnected UDP socket
listening for RPC replies.

To prevent unwanted data injection, bind this socket to loopback
instead.

BugLink:
  https://bugzilla.linux-nfs.org/show_bug.cgi?id=177

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

This proposed fix hasn't yet been thoroughly tested.  Comments?

 utils/statd/rmtcall.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/statd/rmtcall.c b/utils/statd/rmtcall.c
index 0e52fe2..4ecb03c 100644
--- a/utils/statd/rmtcall.c
+++ b/utils/statd/rmtcall.c
@@ -85,7 +85,7 @@ statd_get_socket(void)
 
 		memset(&sin, 0, sizeof(sin));
 		sin.sin_family = AF_INET;
-		sin.sin_addr.s_addr = INADDR_ANY;
+		sin.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
 
 		if (bindresvport(sockfd, &sin) < 0) {
 			xlog(D_GENERAL, "%s: can't bind to reserved port",

