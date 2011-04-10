Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:55943 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753150Ab1DJQec (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 10 Apr 2011 12:34:32 -0400
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1Q8xap-00078i-16
	for linux-nfs@vger.kernel.org; Sun, 10 Apr 2011 12:34:31 -0400
Date: Sun, 10 Apr 2011 12:34:30 -0400
To: linux-nfs@vger.kernel.org
Subject: Re: server tcp performance patches
Message-ID: <20110410163430.GD26233@fieldses.org>
Reply-To: 1302131186-6578-1-git-send-email-bfields@redhat.com
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> I'm considering queueing this up for 2.6.40.

Done, but with the following fix.

--b.

commit 8985ef0b8af895c3b85a8c1b7108e0169fcbd20b
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Sat Apr 9 10:03:10 2011 -0400

    svcrpc: complete svsk processing on cb receive failure
    
    Currently when there's some failure to receive a callback (because we
    couldn't find a matching xid, for example), we exit svc_recv with
    sk_tcplen still set but without any pages saved with the socket.  This
    will cause a crash later in svc_tcp_restore_pages.
    
    Instead, make sure we reset that tcp information whether the callback
    received failed or succeeded.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 213dea8..af04f77 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1143,11 +1143,8 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 
 	p = (__be32 *)rqstp->rq_arg.head[0].iov_base;
 	calldir = p[1];
-	if (calldir) {
+	if (calldir)
 		len = receive_cb_reply(svsk, rqstp);
-		if (len < 0)
-			goto error;
-	}
 
 	/* Reset TCP read info */
 	svsk->sk_reclen = 0;
@@ -1156,6 +1153,8 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	if (svc_recv_available(svsk) > sizeof(rpc_fraghdr))
 		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 
+	if (len < 0)
+		goto error;
 
 	svc_xprt_copy_addrs(rqstp, &svsk->sk_xprt);
 	if (serv->sv_stats)
