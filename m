Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F32D2C10F00
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 03:04:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BC82221738
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 03:04:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="U6wjJY/u"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730019AbfBTDEx (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 22:04:53 -0500
Received: from mail-it1-f195.google.com ([209.85.166.195]:37096 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727576AbfBTDEw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2019 22:04:52 -0500
Received: by mail-it1-f195.google.com with SMTP id z124so12137527itc.2
        for <linux-nfs@vger.kernel.org>; Tue, 19 Feb 2019 19:04:52 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=FbSCohCPQ0/eiIoUwuTP+BqehbVxjVD5mv4FZnaDxbM=;
        b=U6wjJY/uOO64dia3PbU/KYp1eTeBpjMrJ5yUeTQw5qK0l6UDBF1PL8/faKINgqo73u
         J/IGtRJkcUfcInOUGqjWkO1/Gz6B46PMLW32JBJFtGzjCPUI+EJlxdDaQqsF6NV8q2kK
         1XPIazkQ6pkDuh15Oc8emSFHfTh+WEExR4ZfocV2UUe0C47xVOQvI9BNoh3PCl87dg3v
         g/3gubvQ48qBpFDr8Zj43+cwfRip9O6nKoDgH6wdRY8fzcwm76bw6kMiW1jMh29XFhw0
         KIyip+MI9hhL9i4EuLubLL22E7k3a/FNnRd3LajcSjSKVmjdM4o6UN3EKmdr3a/qqRUN
         /LnA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=FbSCohCPQ0/eiIoUwuTP+BqehbVxjVD5mv4FZnaDxbM=;
        b=myUy+r3bW+Y0XIvLoBHqCmFZJePhigy6NIe2SpXFfyVPx0pKcItEZdqVVNikRxuzXj
         0JrQk7GuJExksVO5kPaTJBLo9gLJm5zxbFP69Wt5zmDxNcC3lE6lgjWixiS0wrP+BGY3
         BskmpK5lEMBgEJHmtYbqr4hq0l/tJ8vrZEZDRdsdYiKNIshC3QGeg70jzuNPaQxmpFSL
         YgwYhIp9nyHTgnLmxnhPAJtFYAJxJi2aW1+XmFu2Job+jyoxHPT8wwysRlajnf7b2YOi
         wjDc5aaSqMGqBy33csz60JYw9Bq6lUFxglHNAFu2MaGeRfzriKQQ2l3OWscjOjadK/P+
         wOZw==
X-Gm-Message-State: AHQUAuZ9109umyLRfkMdok8FqHlvF8svl+djglACNsEhEmdLOJ06grf6
        qWa3EVuOIz5pCIcHDWXzbqcG4Pg=
X-Google-Smtp-Source: AHgI3IYu6gbHfeuog3gJbzF8x7LGEg8xHkWl1iiYfBB0GO+CiFTPQvIViA0RpNchaMrfcapSrnrldQ==
X-Received: by 2002:a02:1185:: with SMTP id 127mr9614078jaf.136.1550631891269;
        Tue, 19 Feb 2019 19:04:51 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id a192sm2036924ita.0.2019.02.19.19.04.50
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 19:04:50 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 2/4] SUNRPC: Convert socket page send code to use iov_iter()
Date:   Tue, 19 Feb 2019 22:03:39 -0500
Message-Id: <20190220030341.58766-3-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190220030341.58766-2-trond.myklebust@hammerspace.com>
References: <20190220030341.58766-1-trond.myklebust@hammerspace.com>
 <20190220030341.58766-2-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Simplify the page send code using iov_iter and bvecs.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xprt.c     |  1 +
 net/sunrpc/xprtsock.c | 49 ++++++++++++-------------------------------
 2 files changed, 14 insertions(+), 36 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 1587728f40d1..2af6be9d6574 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1723,6 +1723,7 @@ void xprt_release(struct rpc_task *task)
 		xprt->ops->buf_free(task);
 	xprt_inject_disconnect(xprt);
 	xdr_free_bvec(&req->rq_rcv_buf);
+	xdr_free_bvec(&req->rq_snd_buf);
 	if (req->rq_cred != NULL)
 		put_rpccred(req->rq_cred);
 	task->tk_rqstp = NULL;
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index f87412464cb2..d20b153ce19e 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -743,42 +743,18 @@ static int xs_send_kvec(struct socket *sock, struct msghdr *msg, struct kvec *ve
 	return xs_sendmsg(sock, msg, seek);
 }
 
-static int xs_send_pagedata(struct socket *sock, struct xdr_buf *xdr, unsigned int base, int more, bool zerocopy, int *sent_p)
+static int xs_send_pagedata(struct socket *sock, struct msghdr *msg, struct xdr_buf *xdr, size_t base)
 {
-	ssize_t (*do_sendpage)(struct socket *sock, struct page *page,
-			int offset, size_t size, int flags);
-	struct page **ppage;
-	unsigned int remainder;
 	int err;
 
-	remainder = xdr->page_len - base;
-	base += xdr->page_base;
-	ppage = xdr->pages + (base >> PAGE_SHIFT);
-	base &= ~PAGE_MASK;
-	do_sendpage = sock->ops->sendpage;
-	if (!zerocopy)
-		do_sendpage = sock_no_sendpage;
-	for(;;) {
-		unsigned int len = min_t(unsigned int, PAGE_SIZE - base, remainder);
-		int flags = XS_SENDMSG_FLAGS;
+	err = xdr_alloc_bvec(xdr, GFP_KERNEL);
+	if (err < 0)
+		return err;
 
-		remainder -= len;
-		if (more)
-			flags |= MSG_MORE;
-		if (remainder != 0)
-			flags |= MSG_SENDPAGE_NOTLAST | MSG_MORE;
-		err = do_sendpage(sock, *ppage, base, len, flags);
-		if (remainder == 0 || err != len)
-			break;
-		*sent_p += err;
-		ppage++;
-		base = 0;
-	}
-	if (err > 0) {
-		*sent_p += err;
-		err = 0;
-	}
-	return err;
+	iov_iter_bvec(&msg->msg_iter, WRITE, xdr->bvec,
+			xdr_buf_pagecount(xdr),
+			xdr->page_len + xdr->page_base);
+	return xs_sendmsg(sock, msg, base + xdr->page_base);
 }
 
 /**
@@ -801,7 +777,6 @@ static int xs_sendpages(struct socket *sock, struct sockaddr *addr, int addrlen,
 	};
 	unsigned int remainder = xdr->len - base;
 	int err = 0;
-	int sent = 0;
 
 	if (unlikely(!sock))
 		return -ENOTSOCK;
@@ -827,10 +802,12 @@ static int xs_sendpages(struct socket *sock, struct sockaddr *addr, int addrlen,
 	if (base < xdr->page_len) {
 		unsigned int len = xdr->page_len - base;
 		remainder -= len;
-		err = xs_send_pagedata(sock, xdr, base, remainder != 0, zerocopy, &sent);
-		*sent_p += sent;
-		if (remainder == 0 || sent != len)
+		if (remainder == 0)
+			msg.msg_flags &= ~MSG_MORE;
+		err = xs_send_pagedata(sock, &msg, xdr, base);
+		if (remainder == 0 || err != len)
 			goto out;
+		*sent_p += err;
 		base = 0;
 	} else
 		base -= xdr->page_len;
-- 
2.20.1

