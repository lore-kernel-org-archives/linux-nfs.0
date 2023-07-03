Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B5C1C001B0
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Jul 2023 18:18:34 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229608AbjGCSSd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Jul 2023 14:18:33 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:42092 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229505AbjGCSSc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Jul 2023 14:18:32 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [139.178.84.217])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 44E26DC
        for <linux-nfs@vger.kernel.org>; Mon,  3 Jul 2023 11:18:32 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature RSA-PSS (2048 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 7BD5960FCD
        for <linux-nfs@vger.kernel.org>; Mon,  3 Jul 2023 18:18:31 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AB821C433C8;
        Mon,  3 Jul 2023 18:18:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1688408310;
        bh=Uh1ZzKAVJVrHBp4uPw3P/hMRpkjv7EIH4aPfbShymUY=;
        h=Subject:From:To:Cc:Date:From;
        b=Lmj+L5A7NjyDkDU/ewWZy8r6yqeyfofF7UYa/2lRNrCD6e1yBU9pKZLaBJpCUNUI7
         U+pZZClXgUIYJ53iDMTWXH22uZHtBFEjTRKoLYPjZ4ui8DXj8E7kR9NKsBrXeHYvcQ
         TONCxGBmky/4lz94RLzXNVgU0iwhyYDI/kPap+3hLuIvBDnAePqNINMImVnLJyT8xn
         tJZtkhNxGk6Szrxhlu0KB4V3PTPyeTPxkBhAU1KJMURC00v8X8S1tH85zRYZtaYWI9
         FeOEDJrHzVqq+hFhwaIBrwu96yUd8JCSoH6HAYmjDtMIdbHDcjCsyQ5bBBF7oIbR7b
         3EAn2LmWdd7AQ==
Subject: [PATCH] xprtrdma: Remap Receive buffers after a reconnect
From:   Chuck Lever <cel@kernel.org>
To:     linux-nfs@vger.kernel.org
Cc:     Chuck Lever <chuck.lever@oracle.com>, kolga@netapp.com
Date:   Mon, 03 Jul 2023 14:18:29 -0400
Message-ID: <168840826653.1579.7454746227897662505.stgit@morisot.1015granger.net>
User-Agent: StGit/1.5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Chuck Lever <chuck.lever@oracle.com>

On server-initiated disconnect, rpcrdma_xprt_disconnect() was DMA-
unmapping the Receive buffers, but rpcrdma_post_recvs() neglected
to remap them after a new connection had been established. The
result was immediate failure of the new connection with the Receives
flushing with LOCAL_PROT_ERR.

Fixes: 671c450b6fe0 ("xprtrdma: Fix oops in Receive handler after device removal")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index b098fde373ab..28c0771c4e8c 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -935,9 +935,6 @@ struct rpcrdma_rep *rpcrdma_rep_create(struct rpcrdma_xprt *r_xprt,
 	if (!rep->rr_rdmabuf)
 		goto out_free;
 
-	if (!rpcrdma_regbuf_dma_map(r_xprt, rep->rr_rdmabuf))
-		goto out_free_regbuf;
-
 	rep->rr_cid.ci_completion_id =
 		atomic_inc_return(&r_xprt->rx_ep->re_completion_ids);
 
@@ -956,8 +953,6 @@ struct rpcrdma_rep *rpcrdma_rep_create(struct rpcrdma_xprt *r_xprt,
 	spin_unlock(&buf->rb_lock);
 	return rep;
 
-out_free_regbuf:
-	rpcrdma_regbuf_free(rep->rr_rdmabuf);
 out_free:
 	kfree(rep);
 out:
@@ -1363,6 +1358,10 @@ void rpcrdma_post_recvs(struct rpcrdma_xprt *r_xprt, int needed, bool temp)
 			rep = rpcrdma_rep_create(r_xprt, temp);
 		if (!rep)
 			break;
+		if (!rpcrdma_regbuf_dma_map(r_xprt, rep->rr_rdmabuf)) {
+			rpcrdma_rep_put(buf, rep);
+			break;
+		}
 
 		rep->rr_cid.ci_queue_id = ep->re_attr.recv_cq->res.id;
 		trace_xprtrdma_post_recv(rep);


