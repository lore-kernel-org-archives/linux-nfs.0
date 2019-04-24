Return-Path: <SRS0=08pM=S2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7BDCDC10F11
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:39:15 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4205121773
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:39:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ueljrRk9"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730444AbfDXNjO (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Apr 2019 09:39:14 -0400
Received: from mail-io1-f65.google.com ([209.85.166.65]:33220 "EHLO
        mail-io1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730419AbfDXNjN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2019 09:39:13 -0400
Received: by mail-io1-f65.google.com with SMTP id u12so5266366iop.0;
        Wed, 24 Apr 2019 06:39:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=fTNkHA9SntrXpaG1oEfTXMmMhUnHC1ermDjhZi8zbWo=;
        b=ueljrRk98mQLfeGqHf/tRFjd+vhFTjScEwY2d3uS0FuRIhhb3iE85WrZPuOvJ6f0rX
         zXpjV9zA4XYKQHfBV+LKg1XKEIQeYqCYAcQr/wZ3fgkI9VvH3oUzmiv5hQeRDlfKTUO7
         6zsSQT2hDi310IeHqvQUHxSD0tNaI4hNYrwmVLws2hHLiv7qXDu9O31cs2dTyUgw9+QU
         HZHZ9xdiDb+gpfDQJ9CSeklJSpnzoMgTbkgVeY2glECvKlhccxQp0+oAR3LMFr++lSfT
         tsWUvvrw3yQWm5amJbYcMnAdW3P7okhduEQP1mdyQX06G+ZnMAE5fRg5uJ0BvwNt+qkb
         7/zg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=fTNkHA9SntrXpaG1oEfTXMmMhUnHC1ermDjhZi8zbWo=;
        b=Gykr2+FwJOWfeodSsciShps6jahaP4+162DZsmwq9A5ttWQEywJrivhYjjCaVAg08X
         hccsrEimw8ovXnw+X2zCgQmnr6hMXRH0nxG0gs5Tbw7pWs9pvMIGEv542yPYdntI+VPR
         kOiUpTsskud2vIo0fIofRb+30RNIqKFRhNO1PMfz+ZckXSHXIdPusfa9esAWXDns9sZG
         /yZvLnJZvXKBEEj36J4nIhxKhn3WL61kxEZhs4eCt09PySMl0MW+fGLyLbgxopGUk17d
         uPEjL7ebXlE8TuO/zT9bk8ei1b/qMA3PNoie4UQ0Qw1opGCRxeG/cf/VkHMwKL8g5g8L
         hAPw==
X-Gm-Message-State: APjAAAVNIAsfja9sWr25CVBC56JqxYaL9G9h2d7Pvm3SqGsoDtk+XUxU
        bW/cjajx0gka1ljqNb7f69M=
X-Google-Smtp-Source: APXvYqxSLnC3sQNDkvSkSw4JGkdZUca81DqQcr/VjoB2eWYSwmEN+No9iUl229z9w7V6nY7txyC79A==
X-Received: by 2002:a5d:9584:: with SMTP id a4mr5689876ioo.17.1556113152461;
        Wed, 24 Apr 2019 06:39:12 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id u204sm8963863ita.33.2019.04.24.06.39.11
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 06:39:12 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3ODdBNV011280;
        Wed, 24 Apr 2019 13:39:11 GMT
Subject: [PATCH v3 04/21] xprtrdma: Clean up rpcrdma_create_rep() and
 rpcrdma_destroy_rep()
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 24 Apr 2019 09:39:11 -0400
Message-ID: <20190424133911.5077.94429.stgit@manet.1015granger.net>
In-Reply-To: <20190424133516.5077.67283.stgit@manet.1015granger.net>
References: <20190424133516.5077.67283.stgit@manet.1015granger.net>
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

