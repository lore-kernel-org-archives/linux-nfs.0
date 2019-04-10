Return-Path: <SRS0=wtRa=SM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9EFEBC10F11
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Apr 2019 20:07:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 61B6D2075B
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Apr 2019 20:07:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="oyzRsspS"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726640AbfDJUHA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 10 Apr 2019 16:07:00 -0400
Received: from mail-it1-f194.google.com ([209.85.166.194]:38147 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726623AbfDJUHA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Apr 2019 16:07:00 -0400
Received: by mail-it1-f194.google.com with SMTP id f22so5627748ita.3;
        Wed, 10 Apr 2019 13:07:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=rXenng4svk116ZknE8Ltgf0jd/jZvyNceAKxUeLckok=;
        b=oyzRsspSbMgMMXpYhX+YzY0wTpcj0sBaagXppU7a4ZuXpXENAIX7ljL2iEf9ZnYOBM
         dD956QLJA6Sh/LxjH614/m9luFprpZc+aHpW2xDA2D370k/PrSTPHfOvUAlxFD+6DHE/
         bXM9QCYkLBF4B6mb5K6ZN6qa2QMAW3LkaEaj/JX7IJE/4GF+ZBLY4jYsRn7GbyWf5HQu
         GDwebNONP4UW/RhMVm45nYM5A9/cKFv/U5To4sKemG+s48jU8EIP76ktsoRaE0AiuJDY
         hGA0rJjxNMVyC6Bj13MNlZJz9VpM2WWOPtZ8eV7pt6Tb54GTLZOwStpGeUZmlkNn/j1Q
         wk0g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=rXenng4svk116ZknE8Ltgf0jd/jZvyNceAKxUeLckok=;
        b=cKjOq9/a6MYunKSRPL5+M/4bBxMR9wYRxJcIpEP/tAuQRIygb65mJoCn61SyENuxli
         6hMDTqRxGEDV+yBP6ufvouD6RX66xQNP+vw0x2/l+BvnsR9YhdNimWBxxCWe9OwuQF2U
         aS5osSNol7dbrm4d5hkP1W1DhK+tzsKnhhVRhHjdg2V/Ayz7h4ESrwGOZCyJeL4eB8aA
         DSTUUZAahGR+PQamNG6FOeMd4U7DgHysOhghR1CWn6eORTKby7o1suO0GJeSgVYDVIkS
         9zImzjoZtDsTIxrk/rpG1JUB7WqtmgdKn9c38F+3XBOYvZcZ7860K83XZzMI8UC55qjS
         4jug==
X-Gm-Message-State: APjAAAVH9mEhoorAXYs3LyrgvlQ0ZZg1CB8X06YTK601YH23OaVPurkg
        ZY/YIth9ScA2J/FS0nMdIG5kaA5O
X-Google-Smtp-Source: APXvYqzkrLMo9scWXuYTVxy6xBRK6HK76CsFYuqRlJdA/ZkIHFPSbXFdyX1PCfJpBGE7th39WUbJGw==
X-Received: by 2002:a02:8508:: with SMTP id g8mr32935394jai.68.1554926819683;
        Wed, 10 Apr 2019 13:06:59 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id 1sm1592927ity.9.2019.04.10.13.06.59
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 13:06:59 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3AK6wje004519;
        Wed, 10 Apr 2019 20:06:58 GMT
Subject: [PATCH v1 05/19] xprtrdma: Clean up rpcrdma_create_rep() and
 rpcrdma_destroy_rep()
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 10 Apr 2019 16:06:58 -0400
Message-ID: <20190410200658.11522.59896.stgit@manet.1015granger.net>
In-Reply-To: <20190410200446.11522.21145.stgit@manet.1015granger.net>
References: <20190410200446.11522.21145.stgit@manet.1015granger.net>
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
 net/sunrpc/xprtrdma/verbs.c |   21 ++++++++-------------
 1 file changed, 8 insertions(+), 13 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 82ea298..3bc751e 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -76,7 +76,6 @@
 static void rpcrdma_sendctx_put_locked(struct rpcrdma_sendctx *sc);
 static void rpcrdma_mrs_create(struct rpcrdma_xprt *r_xprt);
 static void rpcrdma_mrs_destroy(struct rpcrdma_buffer *buf);
-static int rpcrdma_create_rep(struct rpcrdma_xprt *r_xprt, bool temp);
 static void rpcrdma_dma_unmap_regbuf(struct rpcrdma_regbuf *rb);
 static void rpcrdma_post_recvs(struct rpcrdma_xprt *r_xprt, bool temp);
 
@@ -1029,15 +1028,12 @@ struct rpcrdma_req *rpcrdma_req_create(struct rpcrdma_xprt *r_xprt, gfp_t flags)
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
@@ -1063,12 +1059,12 @@ struct rpcrdma_req *rpcrdma_req_create(struct rpcrdma_xprt *r_xprt, gfp_t flags)
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
@@ -1124,8 +1120,7 @@ struct rpcrdma_req *rpcrdma_req_create(struct rpcrdma_xprt *r_xprt, gfp_t flags)
 	return rc;
 }
 
-static void
-rpcrdma_destroy_rep(struct rpcrdma_rep *rep)
+static void rpcrdma_rep_destroy(struct rpcrdma_rep *rep)
 {
 	rpcrdma_free_regbuf(rep->rr_rdmabuf);
 	kfree(rep);
@@ -1205,7 +1200,7 @@ struct rpcrdma_req *rpcrdma_req_create(struct rpcrdma_xprt *r_xprt, gfp_t flags)
 		rep = list_first_entry(&buf->rb_recv_bufs,
 				       struct rpcrdma_rep, rr_list);
 		list_del(&rep->rr_list);
-		rpcrdma_destroy_rep(rep);
+		rpcrdma_rep_destroy(rep);
 	}
 
 	while (!list_empty(&buf->rb_send_bufs)) {
@@ -1334,7 +1329,7 @@ struct rpcrdma_req *
 	}
 	spin_unlock(&buffers->rb_lock);
 	if (rep)
-		rpcrdma_destroy_rep(rep);
+		rpcrdma_rep_destroy(rep);
 }
 
 /*
@@ -1351,7 +1346,7 @@ struct rpcrdma_req *
 		list_add(&rep->rr_list, &buffers->rb_recv_bufs);
 		spin_unlock(&buffers->rb_lock);
 	} else {
-		rpcrdma_destroy_rep(rep);
+		rpcrdma_rep_destroy(rep);
 	}
 }
 
@@ -1500,7 +1495,7 @@ struct rpcrdma_regbuf *
 			list_del(&rep->rr_list);
 		spin_unlock(&buf->rb_lock);
 		if (!rep) {
-			if (rpcrdma_create_rep(r_xprt, temp))
+			if (!rpcrdma_rep_create(r_xprt, temp))
 				break;
 			continue;
 		}

