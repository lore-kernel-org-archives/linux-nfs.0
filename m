Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mxout1.mail.janestreet.com ([38.105.200.112]:43157 "EHLO
	mxout1.mail.janestreet.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751237AbaIEUDR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2014 16:03:17 -0400
Received: from tot-smtp.delacy.com ([172.27.22.15] helo=tot-smtp)
	by mxout1.mail.janestreet.com with esmtps (TLSv1.2:DHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.82)
	(envelope-from <cperl@janestreet.com>)
	id 1XPzMr-0004tg-Pi
	for linux-nfs@vger.kernel.org; Fri, 05 Sep 2014 15:40:21 -0400
From: Chris Perl <chris.perl@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Chris Perl <chris.perl@gmail.com>
Subject: [PATCH] rpc: xs_bind - do not bind when requesting a random ephemeral port
Date: Fri,  5 Sep 2014 15:40:21 -0400
Message-Id: <1409946021-839-1-git-send-email-chris.perl@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When attempting to establish a local ephemeral endpoint for a TCP or UDP
socket, do not explicitly call bind, instead let it happen implicilty when the
socket is first used.

The main motivating factor for this change is when TCP runs out of unique
ephemeral ports (i.e.  cannot find any ephemeral ports which are not a part of
*any* TCP connection).  In this situation if you explicitly call bind, then the
call will fail with EADDRINUSE.  However, if you allow the allocation of an
ephemeral port to happen implicitly as part of connect (or other functions),
then ephemeral ports can be reused, so long as the combination of (local_ip,
local_port, remote_ip, remote_port) is unique for TCP sockets on the system.

This doesn't matter for UDP sockets, but it seemed easiest to treat TCP and UDP
sockets the same.

This can allow mount.nfs(8) to continue to function successfully, even in the
face of misbehaving applications which are creating a large number of TCP
connections.

Signed-off-by: Chris Perl <chris.perl@gmail.com>
---
 net/sunrpc/xprtsock.c | 20 ++++++++++++++++++--
 1 file changed, 18 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 43cd89e..7ed47b4 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1746,13 +1746,29 @@ static int xs_bind(struct sock_xprt *transport, struct socket *sock)
 	unsigned short port = xs_get_srcport(transport);
 	unsigned short last;
 
+	/*
+	 * If we are asking for any ephemeral port (i.e. port == 0 &&
+	 * transport->xprt.resvport == 0), don't bind.  Let the local
+	 * port selection happen implicitly when the socket is used
+	 * (for example at connect time).
+	 *
+	 * This ensures that we can continue to establish TCP
+	 * connections even when all local ephemeral ports are already
+	 * a part of some TCP connection.  This makes no difference
+	 * for UDP sockets, but also doens't harm them.
+	 *
+	 * If we're asking for any reserved port (i.e. port == 0 &&
+	 * transport->xprt.resvport == 1) xs_get_srcport above will
+	 * ensure that port is non-zero and we will bind as needed.
+	 */
+	if (port == 0)
+		return 0;
+
 	memcpy(&myaddr, &transport->srcaddr, transport->xprt.addrlen);
 	do {
 		rpc_set_port((struct sockaddr *)&myaddr, port);
 		err = kernel_bind(sock, (struct sockaddr *)&myaddr,
 				transport->xprt.addrlen);
-		if (port == 0)
-			break;
 		if (err == 0) {
 			transport->srcport = port;
 			break;
-- 
1.8.3.1

