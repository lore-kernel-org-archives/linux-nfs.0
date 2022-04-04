Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43464C4332F
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Apr 2022 21:18:37 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1379642AbiDDVUZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 4 Apr 2022 17:20:25 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:42378 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1379824AbiDDSL2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Apr 2022 14:11:28 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [139.178.84.217])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id B1ACE393C9
        for <linux-nfs@vger.kernel.org>; Mon,  4 Apr 2022 11:09:31 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 4B0A960C85
        for <linux-nfs@vger.kernel.org>; Mon,  4 Apr 2022 18:09:31 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9D018C2BBE4
        for <linux-nfs@vger.kernel.org>; Mon,  4 Apr 2022 18:09:30 +0000 (UTC)
Subject: [PATCH v1 5/6] SUNRPC: Remove dead code in svc_tcp_release_rqst()
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Mon, 04 Apr 2022 14:09:29 -0400
Message-ID: <164909576954.3716.6597008968913964539.stgit@manet.1015granger.net>
In-Reply-To: <164909503892.3716.8666091898179474248.stgit@manet.1015granger.net>
References: <164909503892.3716.8666091898179474248.stgit@manet.1015granger.net>
User-Agent: StGit/1.5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Clean up: svc_tcp_sendto() always sets rq_xprt_ctxt to NULL.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/svcsock.c |    9 ---------
 1 file changed, 9 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 478f857cdaed..de91643eecb7 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -117,15 +117,6 @@ static void svc_reclassify_socket(struct socket *sock)
  */
 static void svc_tcp_release_rqst(struct svc_rqst *rqstp)
 {
-	struct sk_buff *skb = rqstp->rq_xprt_ctxt;
-
-	if (skb) {
-		struct svc_sock *svsk =
-			container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
-
-		rqstp->rq_xprt_ctxt = NULL;
-		skb_free_datagram_locked(svsk->sk_sk, skb);
-	}
 }
 
 /**


