Return-Path: <SRS0=Vlol=SS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45D14C10F13
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 13:37:15 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 12841217F9
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 13:37:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="oKc+ZipZ"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726576AbfDPNhO (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 16 Apr 2019 09:37:14 -0400
Received: from mail-it1-f196.google.com ([209.85.166.196]:37691 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725861AbfDPNhO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Apr 2019 09:37:14 -0400
Received: by mail-it1-f196.google.com with SMTP id u65so32506879itc.2;
        Tue, 16 Apr 2019 06:37:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=fTNkHA9SntrXpaG1oEfTXMmMhUnHC1ermDjhZi8zbWo=;
        b=oKc+ZipZw5bTvPciw3Reg6TGvDwIzEnOc6Y+kWzTQHgu4C3Oyu4+GlTEuzkSdI6l5X
         56itFrGp5YLqWA9q62kJeuUkKSH0gFaGIszh5T938lF/nR6N9Ld6WDl0EaR9iVZDcvPu
         wP8CgltziYLvECwbd6eqs/HwzSeKwFlymOuQoWkVnKosqNxlOMSBihqTZv8WiPn6RjX/
         rMncd2CCGjyHWYX7w4HhcaBCQrOJvA3uWOUFXAmat+kw+99yhoGKFuDsjsGXRWpdW46z
         gWLRhe+Od8tqaIw2vaFTeJhJqIct9FM2yR58+GVec+U30l3++Le9yWrr7m2ubGhLJXnI
         oWcQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=fTNkHA9SntrXpaG1oEfTXMmMhUnHC1ermDjhZi8zbWo=;
        b=JlzyhpT6ehEbFTYPtDkBU9DGydcurhCJwSJRHStvcQH8PUeyIsdcbX77aWB3AWNYNU
         9M198vibGbCqneuo+oyM+0nzsIo9FhgGSvYPI0nHICkgEABnNHa2yJPZ/JTcTPZfG8l2
         vNwWJSulvYF4xKuB18vNHiXyoc6kBOwpop6ZYe5HYZvaGvbqCj1qbnz2W3gICcKklduA
         N20KSqKMhD5oDCWAZCnBEvK9bvYiACGShigwNyIanPeUGAjot3GzhF4Sm80E9lOim4XG
         mJQYIjZfCnVvnDicyx/LPX8Z5MeLDP+gifR+AR3SVhHZ9z61zCejs0aNAIcgcZkG3mjz
         qhtg==
X-Gm-Message-State: APjAAAWcAUuYxuiV51ZQXapnurOkzPwHyREze4WbV8w0QzPGXKkgiidm
        OutIKTOaBs9m3tO3nBOpLaTs2wjR
X-Google-Smtp-Source: APXvYqz7SnWQXvp6g5PUKnurwU/S7y3Cm8ifeV8qI9TtU6rV85VyZuk8UC1EUX5Xyq+dNckjr7Ui2Q==
X-Received: by 2002:a24:3d94:: with SMTP id n142mr27552402itn.147.1555421833473;
        Tue, 16 Apr 2019 06:37:13 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id n184sm14885056itc.28.2019.04.16.06.37.12
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:37:13 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3GDbC7P021208;
        Tue, 16 Apr 2019 13:37:12 GMT
Subject: [PATCH v2 04/21] xprtrdma: Clean up rpcrdma_create_rep() and
 rpcrdma_destroy_rep()
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Tue, 16 Apr 2019 09:37:12 -0400
Message-ID: <20190416133712.23113.29186.stgit@manet.1015granger.net>
In-Reply-To: <20190416133156.23113.91846.stgit@manet.1015granger.net>
References: <20190416133156.23113.91846.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

For code legibility, clean up the function names to be consistent
with the pattern: "rpcrdma" _ object-type _ action

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |   25 +++++++++----------------
 1 file changed, 9 insertions(+), 16 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 71fc41f..caa6a5d 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -76,7 +76,6 @@
 static void rpcrdma_sendctx_put_locked(struct rpcrdma_sendctx *sc);
 static void rpcrdma_mrs_create(struct rpcrdma_xprt *r_xprt);
 static void rpcrdma_mrs_destroy(struct rpcrdma_buffer *buf);
-static int rpcrdma_create_rep(struct rpcrdma_xprt *r_xprt, bool temp);
 static void rpcrdma_dma_unmap_regbuf(struct rpcrdma_regbuf *rb);
 static void rpcrdma_post_recvs(struct rpcrdma_xprt *r_xprt, bool temp);
 
@@ -1029,25 +1028,20 @@ struct rpcrdma_req *rpcrdma_req_create(struct rpcrdma_xprt *r_xprt, gfp_t flags)
 	return req;
 }
 
-static int
-rpcrdma_create_rep(struct rpcrdma_xprt *r_xprt, bool temp)
+static bool rpcrdma_rep_create(struct rpcrdma_xprt *r_xprt, bool temp)
 {
 	struct rpcrdma_create_data_internal *cdata = &r_xprt->rx_data;
 	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
 	struct rpcrdma_rep *rep;
-	int rc;
 
-	rc = -ENOMEM;
 	rep = kzalloc(sizeof(*rep), GFP_KERNEL);
 	if (rep == NULL)
 		goto out;
 
 	rep->rr_rdmabuf = rpcrdma_alloc_regbuf(cdata->inline_rsize,
 					       DMA_FROM_DEVICE, GFP_KERNEL);
-	if (IS_ERR(rep->rr_rdmabuf)) {
-		rc = PTR_ERR(rep->rr_rdmabuf);
+	if (IS_ERR(rep->rr_rdmabuf))
 		goto out_free;
-	}
 	xdr_buf_init(&rep->rr_hdrbuf, rep->rr_rdmabuf->rg_base,
 		     rdmab_length(rep->rr_rdmabuf));
 
@@ -1063,12 +1057,12 @@ struct rpcrdma_req *rpcrdma_req_create(struct rpcrdma_xprt *r_xprt, gfp_t flags)
 	spin_lock(&buf->rb_lock);
 	list_add(&rep->rr_list, &buf->rb_recv_bufs);
 	spin_unlock(&buf->rb_lock);
-	return 0;
+	return true;
 
 out_free:
 	kfree(rep);
 out:
-	return rc;
+	return false;
 }
 
 int
@@ -1124,8 +1118,7 @@ struct rpcrdma_req *rpcrdma_req_create(struct rpcrdma_xprt *r_xprt, gfp_t flags)
 	return rc;
 }
 
-static void
-rpcrdma_destroy_rep(struct rpcrdma_rep *rep)
+static void rpcrdma_rep_destroy(struct rpcrdma_rep *rep)
 {
 	rpcrdma_free_regbuf(rep->rr_rdmabuf);
 	kfree(rep);
@@ -1205,7 +1198,7 @@ struct rpcrdma_req *rpcrdma_req_create(struct rpcrdma_xprt *r_xprt, gfp_t flags)
 		rep = list_first_entry(&buf->rb_recv_bufs,
 				       struct rpcrdma_rep, rr_list);
 		list_del(&rep->rr_list);
-		rpcrdma_destroy_rep(rep);
+		rpcrdma_rep_destroy(rep);
 	}
 
 	while (!list_empty(&buf->rb_send_bufs)) {
@@ -1334,7 +1327,7 @@ struct rpcrdma_req *
 	}
 	spin_unlock(&buffers->rb_lock);
 	if (rep)
-		rpcrdma_destroy_rep(rep);
+		rpcrdma_rep_destroy(rep);
 }
 
 /*
@@ -1351,7 +1344,7 @@ struct rpcrdma_req *
 		list_add(&rep->rr_list, &buffers->rb_recv_bufs);
 		spin_unlock(&buffers->rb_lock);
 	} else {
-		rpcrdma_destroy_rep(rep);
+		rpcrdma_rep_destroy(rep);
 	}
 }
 
@@ -1500,7 +1493,7 @@ struct rpcrdma_regbuf *
 			list_del(&rep->rr_list);
 		spin_unlock(&buf->rb_lock);
 		if (!rep) {
-			if (rpcrdma_create_rep(r_xprt, temp))
+			if (!rpcrdma_rep_create(r_xprt, temp))
 				break;
 			continue;
 		}

