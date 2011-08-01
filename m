Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:38699 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752821Ab1HAUNr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Aug 2011 16:13:47 -0400
Received: by gxk21 with SMTP id 21so3676799gxk.19
        for <linux-nfs@vger.kernel.org>; Mon, 01 Aug 2011 13:13:46 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] rpc.statd: Bind downcall socket to loopback address
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 01 Aug 2011 16:13:43 -0400
Message-ID: <20110801201129.3503.99913.stgit@seurat.1015granger.net>
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
socket is still bound to INADDR_ANY.

Thus a remote host can inject data on this socket since it is an
unconnected UDP socket listening for RPC replies.  Thanks to f113db52,
the port number of this socket is no longer controlled by a command
line option, making it difficult to firewall.

We have demonstrated that data injection on this socket can result in
a DoS by causing rpc.statd to consume CPU and log bandwidth, but so
far we have not found a breach.

To prevent unwanted data injection, bind this socket to the loopback
address.

BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=177

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Confirmed that reboot recovery still works, and that data injection
is no longer possible.  This is an updated and final version of this
patch.

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

