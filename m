Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp02.citrix.com ([66.165.176.63]:56306 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752924Ab1KUSOT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Nov 2011 13:14:19 -0500
Message-ID: <4ECA94F9.4090503@citrix.com>
Date: Mon, 21 Nov 2011 18:14:17 +0000
From: Andrew Cooper <andrew.cooper3@citrix.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Subject: Re: NFS TCP race condition with SOCK_ASYNC_NOSPACE
References: <4EC6A681.30902@citrix.com>  <1321642368.2653.35.camel@lade.trondhjem.org> <4EC6AC47.60404@citrix.com> <1321643673.2653.41.camel@lade.trondhjem.org> <4EC6B82B.3000701@citrix.com>
In-Reply-To: <4EC6B82B.3000701@citrix.com>
Content-Type: multipart/mixed;
	boundary="------------070301090808030903040905"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--------------070301090808030903040905
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

Following some debugging, I believe that the attached patch fixes the
problem.

Simply returning EAGAIN is not sufficient, as the task does not get
requeued, and times out 13 seconds later (as per our mount options). 
Setting the SOCK_ASYNC_NOSPACE bit causes the requeue to happen.

I realize that this is a gross hack and I should probably not be using
SOCK_ASYNC_NOSPACE in that way.  Is there a better way to achieve the
same solution?

-- 
Andrew Cooper - Dom0 Kernel Engineer, Citrix XenServer
T: +44 (0)1223 225 900, http://www.citrix.com


--------------070301090808030903040905
Content-Type: text/x-patch; name="NFS-fix-async-nospace-race.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="NFS-fix-async-nospace-race.patch"

diff -r 69bd2176baf9 net/sunrpc/xprtsock.c
--- a/net/sunrpc/xprtsock.c	Mon Nov 07 13:00:06 2011 +0000
+++ b/net/sunrpc/xprtsock.c	Mon Nov 21 18:00:14 2011 +0000
@@ -503,17 +503,16 @@ static int xs_nospace(struct rpc_task *t
 
 	/* Don't race with disconnect */
 	if (xprt_connected(xprt)) {
-		if (test_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags)) {
-			ret = -EAGAIN;
-			/*
-			 * Notify TCP that we're limited by the application
-			 * window size
-			 */
-			set_bit(SOCK_NOSPACE, &transport->sock->flags);
-			transport->inet->sk_write_pending++;
-			/* ...and wait for more buffer space */
-			xprt_wait_for_buffer_space(task, xs_nospace_callback);
-		}
+		set_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
+		ret = -EAGAIN;
+		/*
+		 * Notify TCP that we're limited by the application
+		 * window size
+		 */
+		set_bit(SOCK_NOSPACE, &transport->sock->flags);
+		transport->inet->sk_write_pending++;
+		/* ...and wait for more buffer space */
+		xprt_wait_for_buffer_space(task, xs_nospace_callback);
 	} else {
 		clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
 		ret = -ENOTCONN;

--------------070301090808030903040905--
