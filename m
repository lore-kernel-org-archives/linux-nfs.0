Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B7F7C001B0
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Jul 2023 18:31:33 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229604AbjGSSbc (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Jul 2023 14:31:32 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:53924 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230133AbjGSSbc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Jul 2023 14:31:32 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [IPv6:2604:1380:4641:c500::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 4B9F7B6
        for <linux-nfs@vger.kernel.org>; Wed, 19 Jul 2023 11:31:31 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature RSA-PSS (2048 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id CEA5F617CF
        for <linux-nfs@vger.kernel.org>; Wed, 19 Jul 2023 18:31:30 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EFAB7C433C8;
        Wed, 19 Jul 2023 18:31:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1689791490;
        bh=1DccyJH/V5mxxc3FHyGNfZqC5N/PPxlYjCJJzbgu52I=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=ruExub29BrFO6myWNunbMqMxyX4SlXG5DR+7Rt2l9rusjMekSHuulCtVlWjQBFtrQ
         5l5y7pLVfXaWpgLbC1hDfP4uQVGCmir09oQ2mp3nQXySlqwM2xbmPTn/ByLoSI/dzR
         BoHcBygdEsGJ2lzDebCPEyVDOAmofvINtQyDod9YKrb0KC3DFohGKY4hLwisP+f0Lr
         m9m8f74PYn+E3r01xDzEIVlzPjh4/kCexJuBj5wu2EAKNGn83QitqvWuxtQy3YRTB1
         gHimkPj1UwsQblOqhTJ0N1WmPbM/Ii2FrxkNXRX6QwJsnfu9PcfDeYrK/LGulNXLzQ
         ++GcQBWjDNyPw==
Subject: [PATCH v3 5/5] SUNRPC: Reduce thread wake-up rate when receiving
 large RPC messages
From:   Chuck Lever <cel@kernel.org>
To:     linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Cc:     Chuck Lever <chuck.lever@oracle.com>, dhowells@redhat.com
Date:   Wed, 19 Jul 2023 14:31:29 -0400
Message-ID: <168979148906.1905271.2650584507923874010.stgit@morisot.1015granger.net>
In-Reply-To: <168979108540.1905271.9720708849149797793.stgit@morisot.1015granger.net>
References: <168979108540.1905271.9720708849149797793.stgit@morisot.1015granger.net>
User-Agent: StGit/1.5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Chuck Lever <chuck.lever@oracle.com>

With large NFS WRITE requests on TCP, I measured 5-10 thread wake-
ups to receive each request. This is because the socket layer
calls ->sk_data_ready() frequently, and each call triggers a
thread wake-up. Each recvmsg() seems to pull in less than 100KB.

Have the socket layer hold ->sk_data_ready() calls until the full
incoming message has arrived to reduce the wake-up rate.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/svcsock.c |   12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 7b7358908a21..36e5070132ea 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1088,6 +1088,9 @@ static void svc_tcp_fragment_received(struct svc_sock *svsk)
 	/* If we have more data, signal svc_xprt_enqueue() to try again */
 	svsk->sk_tcplen = 0;
 	svsk->sk_marker = xdr_zero;
+
+	smp_wmb();
+	tcp_set_rcvlowat(svsk->sk_sk, 1);
 }
 
 /**
@@ -1177,10 +1180,17 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		goto err_delete;
 	if (len == want)
 		svc_tcp_fragment_received(svsk);
-	else
+	else {
+		/* Avoid more ->sk_data_ready() calls until the rest
+		 * of the message has arrived. This reduces service
+		 * thread wake-ups on large incoming messages. */
+		tcp_set_rcvlowat(svsk->sk_sk,
+				 svc_sock_reclen(svsk) - svsk->sk_tcplen);
+
 		trace_svcsock_tcp_recv_short(&svsk->sk_xprt,
 				svc_sock_reclen(svsk),
 				svsk->sk_tcplen - sizeof(rpc_fraghdr));
+	}
 	goto err_noclose;
 error:
 	if (len != -EAGAIN)


