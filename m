Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D186C43381
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 18:15:15 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6CF872089F
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 18:15:15 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725989AbfBTSPP (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 20 Feb 2019 13:15:15 -0500
Received: from fieldses.org ([173.255.197.46]:49294 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725815AbfBTSPO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 20 Feb 2019 13:15:14 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 76FA5957; Wed, 20 Feb 2019 13:15:14 -0500 (EST)
Date:   Wed, 20 Feb 2019 13:15:14 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     James Pearson <jcpearson@gmail.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: nfsd thread limit and UDP ?
Message-ID: <20190220181514.GC4399@fieldses.org>
References: <CAK3fRr9EL-YOp3yUr5tMe5zuiERxHjkLDhAaWkxxEHjtfSwisQ@mail.gmail.com>
 <20190220174404.GB4399@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190220174404.GB4399@fieldses.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Would it be possible for you to try this?

--b.

commit b45466587b37
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Wed Feb 20 12:54:50 2019 -0500

    svcrpc: fix UDP on servers with lots of threads
    
    James Pearson found that an NFS server stopped responding to UDP
    requests if started with more than 1017 threads.
    
    sv_max_mesg is about 2^20, so that is probably where the calculation
    performed by
    
            svc_sock_setbufsize(svsk->sk_sock,
                                (serv->sv_nrthreads+3) * serv->sv_max_mesg,
                                (serv->sv_nrthreads+3) * serv->sv_max_mesg);
    
    starts to overflow an int.
    
    Reported-by: James Pearson <jcpearson@gmail.com>
    Cc: stable@vger.kernel.org
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index a6a060925e5d..43590a968b73 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -349,12 +349,16 @@ static ssize_t svc_recvfrom(struct svc_rqst *rqstp, struct kvec *iov,
 /*
  * Set socket snd and rcv buffer lengths
  */
-static void svc_sock_setbufsize(struct socket *sock, unsigned int snd,
-				unsigned int rcv)
+static void svc_sock_setbufsize(struct svc_sock *svsk, unsigned int nreqs)
 {
+	unsigned int max_mesg = svsk->sk_xprt.xpt_server->sv_max_mesg;
+	struct socket *sock = svsk->sk_sock;
+
+	nreqs = min(nreqs, INT_MAX / 2 / max_mesg);
+
 	lock_sock(sock->sk);
-	sock->sk->sk_sndbuf = snd * 2;
-	sock->sk->sk_rcvbuf = rcv * 2;
+	sock->sk->sk_sndbuf = nreqs * max_mesg * 2;
+	sock->sk->sk_rcvbuf = nreqs * max_mesg * 2;
 	sock->sk->sk_write_space(sock->sk);
 	release_sock(sock->sk);
 }
@@ -516,9 +520,7 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 	     * provides an upper bound on the number of threads
 	     * which will access the socket.
 	     */
-	    svc_sock_setbufsize(svsk->sk_sock,
-				(serv->sv_nrthreads+3) * serv->sv_max_mesg,
-				(serv->sv_nrthreads+3) * serv->sv_max_mesg);
+	    svc_sock_setbufsize(svsk, serv->sv_nrthreads + 3);
 
 	clear_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 	skb = NULL;
@@ -681,9 +683,7 @@ static void svc_udp_init(struct svc_sock *svsk, struct svc_serv *serv)
 	 * receive and respond to one request.
 	 * svc_udp_recvfrom will re-adjust if necessary
 	 */
-	svc_sock_setbufsize(svsk->sk_sock,
-			    3 * svsk->sk_xprt.xpt_server->sv_max_mesg,
-			    3 * svsk->sk_xprt.xpt_server->sv_max_mesg);
+	svc_sock_setbufsize(svsk, 3);
 
 	/* data might have come in before data_ready set up */
 	set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
