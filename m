Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF38DC43381
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 03:04:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A7A8421738
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 03:04:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZoqAQfFk"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729770AbfBTDEw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 22:04:52 -0500
Received: from mail-it1-f195.google.com ([209.85.166.195]:40263 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727576AbfBTDEv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2019 22:04:51 -0500
Received: by mail-it1-f195.google.com with SMTP id i2so12073478ite.5
        for <linux-nfs@vger.kernel.org>; Tue, 19 Feb 2019 19:04:51 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=eJugSu0c01vasCR6/EI9+EJaQMoshPdvgntBlpnSas0=;
        b=ZoqAQfFkvk20xxvLZpi2NvQkT12GMD9/oR9sPHzPR4QoPMvgFgy2i6ConoOw2SsEfN
         BlffFsWHIfNnEbQQKAq2wd4WCD0HeZjT1vLoki2wwgNdpV/LzwD7rtXRzwKrv+fL6SE8
         6S2nTETb/JQorubnpSi+J6ComE/eYDslijf1K+HQMNWtvMiIJa+5OeH/Vn8c1xs39x99
         y2RA15lbpXffh6A/+lbhLTHTrKvhLXK3gzujoQvHe0EL72fUGz0PQmgdn422yAXKmX4e
         21rkSGwKO58k3MJc3pY+FZLoN+v8RxI5e3KvOdAT4wfB5bnWV2MnuBOKWAvePBGLEVTp
         n8nw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=eJugSu0c01vasCR6/EI9+EJaQMoshPdvgntBlpnSas0=;
        b=NizCYOk9Vg6TrVgPv1fxSwVsykH/E7Syj0+rkUpmj96hnnlp1jmRaqhIZZuR6dKXqv
         3CbvKf6Oz4vTzZ9RqHWPuJ0M+OrDlom+MRhk25g2BBv27J51SKJ2bH0Fqe9UqeAm/vNF
         MqYF6RtR+I/becQgGvL0WXkpP64O1b5RuNl9UpOvQLO3reqzkdTI7/59YSvTRNQVXe29
         g/5zX+1GVVEOLFQ+QsiyWl7e8/0sjxjGG+fl579FWCX8V1JxaFgAoaus+tCpETXDNwCB
         rI4Lc4xOEZfEL3nNbU/oJY4czcZlXQlBkGWzz/lyLyGWoIxOIRWya7CFOoz03MTCU3HL
         urYQ==
X-Gm-Message-State: AHQUAuYTMJYQMqJmjP9fSVvCBdNagYL70Wo2G8BJmU6OeBblXmW4ZUC7
        ddWdqKWiuk6jVCDwyJgZ3xpIlXE=
X-Google-Smtp-Source: AHgI3Iaa0Xx/AO4LLBASIgz7CCF3uZ1YoaUavH1mn23mmjxfSWaTLFWupKWedAcXiteY9fq7DU0EVw==
X-Received: by 2002:a5d:9818:: with SMTP id a24mr9469312iol.85.1550631890191;
        Tue, 19 Feb 2019 19:04:50 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id a192sm2036924ita.0.2019.02.19.19.04.49
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 19:04:49 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/4] SUNRPC: Convert xs_send_kvec() to use iov_iter_kvec()
Date:   Tue, 19 Feb 2019 22:03:38 -0500
Message-Id: <20190220030341.58766-2-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190220030341.58766-1-trond.myklebust@hammerspace.com>
References: <20190220030341.58766-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Prepare to the socket transmission code to use iov_iter.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xprtsock.c | 38 +++++++++++++++++++++++---------------
 1 file changed, 23 insertions(+), 15 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 618e9c255a9f..f87412464cb2 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -726,21 +726,21 @@ xs_stream_reset_connect(struct sock_xprt *transport)
 
 #define XS_SENDMSG_FLAGS	(MSG_DONTWAIT | MSG_NOSIGNAL)
 
-static int xs_send_kvec(struct socket *sock, struct sockaddr *addr, int addrlen, struct kvec *vec, unsigned int base, int more)
+static int xs_sendmsg(struct socket *sock, struct msghdr *msg, size_t seek)
 {
-	struct msghdr msg = {
-		.msg_name	= addr,
-		.msg_namelen	= addrlen,
-		.msg_flags	= XS_SENDMSG_FLAGS | (more ? MSG_MORE : 0),
-	};
-	struct kvec iov = {
-		.iov_base	= vec->iov_base + base,
-		.iov_len	= vec->iov_len - base,
-	};
+	if (seek)
+		iov_iter_advance(&msg->msg_iter, seek);
+	return sock_sendmsg(sock, msg);
+}
 
-	if (iov.iov_len != 0)
-		return kernel_sendmsg(sock, &msg, &iov, 1, iov.iov_len);
-	return kernel_sendmsg(sock, &msg, NULL, 0, 0);
+static int xs_send_kvec(struct socket *sock, struct msghdr *msg, struct kvec *vec, size_t seek)
+{
+	if (!vec) {
+		iov_iter_kvec(&msg->msg_iter, WRITE, NULL, 0, 0);
+		return sock_sendmsg(sock, msg);
+	}
+	iov_iter_kvec(&msg->msg_iter, WRITE, vec, 1, vec->iov_len);
+	return xs_sendmsg(sock, msg, seek);
 }
 
 static int xs_send_pagedata(struct socket *sock, struct xdr_buf *xdr, unsigned int base, int more, bool zerocopy, int *sent_p)
@@ -794,6 +794,11 @@ static int xs_send_pagedata(struct socket *sock, struct xdr_buf *xdr, unsigned i
  */
 static int xs_sendpages(struct socket *sock, struct sockaddr *addr, int addrlen, struct xdr_buf *xdr, unsigned int base, bool zerocopy, int *sent_p)
 {
+	struct msghdr msg = {
+		.msg_name = addr,
+		.msg_namelen = addrlen,
+		.msg_flags = XS_SENDMSG_FLAGS | MSG_MORE,
+	};
 	unsigned int remainder = xdr->len - base;
 	int err = 0;
 	int sent = 0;
@@ -809,7 +814,9 @@ static int xs_sendpages(struct socket *sock, struct sockaddr *addr, int addrlen,
 	if (base < xdr->head[0].iov_len || addr != NULL) {
 		unsigned int len = xdr->head[0].iov_len - base;
 		remainder -= len;
-		err = xs_send_kvec(sock, addr, addrlen, &xdr->head[0], base, remainder != 0);
+		if (remainder == 0)
+			msg.msg_flags &= ~MSG_MORE;
+		err = xs_send_kvec(sock, &msg, &xdr->head[0], base);
 		if (remainder == 0 || err != len)
 			goto out;
 		*sent_p += err;
@@ -830,7 +837,8 @@ static int xs_sendpages(struct socket *sock, struct sockaddr *addr, int addrlen,
 
 	if (base >= xdr->tail[0].iov_len)
 		return 0;
-	err = xs_send_kvec(sock, NULL, 0, &xdr->tail[0], base, 0);
+	msg.msg_flags &= ~MSG_MORE;
+	err = xs_send_kvec(sock, &msg, &xdr->tail[0], base);
 out:
 	if (err > 0) {
 		*sent_p += err;
-- 
2.20.1

