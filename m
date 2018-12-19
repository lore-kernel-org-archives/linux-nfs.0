Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2CD47C43387
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 16:00:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EF541217D9
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 16:00:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="d16stPPE"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729144AbeLSQAp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 11:00:45 -0500
Received: from mail-io1-f66.google.com ([209.85.166.66]:39862 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728222AbeLSQAp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Dec 2018 11:00:45 -0500
Received: by mail-io1-f66.google.com with SMTP id k7so15973321iob.6;
        Wed, 19 Dec 2018 08:00:44 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=y+F0Uls2LMF2rBl1EmOLKcQm7k0Vfrw8rkFlSfRf4pQ=;
        b=d16stPPEE6Wp42dj0J1UfUSvS6lgbRZtvYFErA+ndyxDotEi+7KPIbH/B4Hbw7w0lQ
         ihzm+8xPQtwS3aJ94iPWurVZJ5YmvbnQHUzy8H0U4pcJ8VZ+93N+1vObo8xuTd3uc/O6
         zxzzhcih55fDmcEV0zPVJaiYFMab7yOxt8H6NJtGhkMxFnawucrP3+fKV+3kkkn3/FPT
         N1dE2Rjvx6zf37MAKgk4h1U1MitIKMBRxEDPXuCuHMjnslZ49GFVzplSBB7X6vPs/xOJ
         jgLtjEd4gQdtjB4br+ek3wpjNf9OaaNJRSglzdl6M77yifAFmXGcNNPU5fXUORMgEpNP
         bxDg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=y+F0Uls2LMF2rBl1EmOLKcQm7k0Vfrw8rkFlSfRf4pQ=;
        b=ey/9IXVkAmn721JXsNMlq+2ONHiaKIM97ZY395D8UWR6+HMVfrkecYT/KMXjG2nUsg
         iFQxN8Dhoho2euFJerp0Wrf8LWzN3vjy2TdBBlkGbh3dd8hNPl6LGTwy88YJINKQuSnJ
         OnD89Ah14p6zo/vgk34obWo7RnaLQPktJwbQ5yIFlmQ/FOxQUJndvV2YmNpcDVC2qagH
         FZiOE0hgjPpIZ3LW6vWwAnmlxo60TXO26cQvQveokMiHA5aaImhZl5eugvhcjI3iJ9KO
         wqRuMMc6FmrWoabcUwzjtO1TPvzrmnbDnXBUDMyEqMTSl3vwaKtmd3cG6+E32faX2H1H
         lb7w==
X-Gm-Message-State: AA+aEWYg25PAirBwRQLA0y9k93a36sjSz5llaVeRgabQWpFq471hPw5r
        DWbapyaxZHX+dhYN0O4O3zw=
X-Google-Smtp-Source: AFSGD/VoS6yuft4qQNG8i+/z5k6tXUEwcFgr+Y2NC7hskS5TpTOeEVsfgH7l2J1zMVYlumoEdfwGaw==
X-Received: by 2002:a5d:9405:: with SMTP id v5mr19029429ion.250.1545235244214;
        Wed, 19 Dec 2018 08:00:44 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id r15sm8611557ioh.12.2018.12.19.08.00.43
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 08:00:43 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBJG0gWv025853;
        Wed, 19 Dec 2018 16:00:42 GMT
Subject: [PATCH v5 29/30] xprtrdma: Clarify comments in rpcrdma_ia_remove
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 19 Dec 2018 11:00:42 -0500
Message-ID: <20181219160042.11602.91903.stgit@manet.1015granger.net>
In-Reply-To: <20181219155152.11602.18605.stgit@manet.1015granger.net>
References: <20181219155152.11602.18605.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Comments are clarified to note how transport data structures are
protected.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |   14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 7749a2b..94af069 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -402,8 +402,7 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
  * rpcrdma_ia_remove - Handle device driver unload
  * @ia: interface adapter being removed
  *
- * Divest transport H/W resources associated with this adapter,
- * but allow it to be restored later.
+ * Callers must serialize calls to this function.
  */
 void
 rpcrdma_ia_remove(struct rpcrdma_ia *ia)
@@ -434,16 +433,23 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 	ib_free_cq(ep->rep_attr.send_cq);
 	ep->rep_attr.send_cq = NULL;
 
-	/* The ULP is responsible for ensuring all DMA
-	 * mappings and MRs are gone.
+	/* The ib_drain_qp above guarantees that all posted
+	 * Receives have flushed, which returns the transport's
+	 * rpcrdma_reps to the rb_recv_bufs list.
 	 */
 	list_for_each_entry(rep, &buf->rb_recv_bufs, rr_list)
 		rpcrdma_dma_unmap_regbuf(rep->rr_rdmabuf);
+
+	/* DMA mapping happens in ->send_request with the
+	 * transport send lock held. Our caller is holding
+	 * the transport send lock.
+	 */
 	list_for_each_entry(req, &buf->rb_allreqs, rl_all) {
 		rpcrdma_dma_unmap_regbuf(req->rl_rdmabuf);
 		rpcrdma_dma_unmap_regbuf(req->rl_sendbuf);
 		rpcrdma_dma_unmap_regbuf(req->rl_recvbuf);
 	}
+
 	rpcrdma_mrs_destroy(buf);
 	ib_dealloc_pd(ia->ri_pd);
 	ia->ri_pd = NULL;

