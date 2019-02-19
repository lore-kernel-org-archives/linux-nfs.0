Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A553AC10F00
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 16:23:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 760E62147A
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 16:23:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="KzIzV8Co"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729018AbfBSQXM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 11:23:12 -0500
Received: from mail-it1-f194.google.com ([209.85.166.194]:53455 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726342AbfBSQXM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2019 11:23:12 -0500
Received: by mail-it1-f194.google.com with SMTP id x131so7391045itc.3
        for <linux-nfs@vger.kernel.org>; Tue, 19 Feb 2019 08:23:12 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=72oU/TkKqTiqq7cVg+AUBpRPupcx4Rw4nRfDtgXws1E=;
        b=KzIzV8CofJsX43OrvRk9/tCsZ4zIf3mzWEBr6t+ViaaRNbQgFfPrx6AdhcO8SldpaD
         BWItGrJhCLlMObH+QxWrsJAGk8/7eDiZOvEP5t/ebdeaK60tVnsG1PXW8JM7JqnrjDbu
         KcXoSb1/WjLqBDrD2h3ha+lI7wmdcCeDE8ta/tNMfyIJDDP+XrjvNyi6gC06s/eNB0oP
         FW77nR9uwkeSbHUh4q19K9zmBcDGtGEIBcj0QO/4cHxQ1H9kZiIunslWPCcwwUY5Lknc
         mHMl8V7gZdCpHuIIVgyVBBH1veXRl9WvUClLAlhZ7qxxyX5GruXqMgF+DrBjPsCYnqoj
         3u+Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=72oU/TkKqTiqq7cVg+AUBpRPupcx4Rw4nRfDtgXws1E=;
        b=dB8ZoJBNjXysaiyO6a4Pdqw8bIKSfacmXzCr41vUSErZCgvCqrO8cD1O2x5VAxVu5j
         AmNywuE7qqGimAvSa46aRGuLina65OsIQvDSDY/jYxTMdc+DxFCirhBDnWorNKe/rZ18
         F+SVIcSgZHDHCHYSTBDiN0WeiUSu7xOGHjMCpvg+/7pbecuyNX9Wve6ILnxsYdLLoEeT
         A7qbLHNKCREKV4iIPJpz7sElcFezTwiTpiGcifOmZLMczqP3pDDYdwBzwUs5KAPw0eXc
         BaVepWE2JWz6GYFhro9RB4Lt2RL5TOTUaw6CDK5cJP/livRZvV92NFWc9dk4M0kDnhwy
         2CXQ==
X-Gm-Message-State: AHQUAuYaxUC4CRCSCoRRwBDTz2rxDGwzxZ451QabSVFO0tTNApbuLVIg
        d1RPB1JWysAt0XzNAXs7JpupuiU=
X-Google-Smtp-Source: AHgI3IYO3zB5Oh2t2ovxYExdets846mHeSWyRTFSIU0+b6Vg5/xqvHujoH3316unLZ4ceD9W4jQ1Zw==
X-Received: by 2002:a02:9d07:: with SMTP id n7mr14822856jak.36.1550593391308;
        Tue, 19 Feb 2019 08:23:11 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id o9sm882683itb.23.2019.02.19.08.23.10
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 08:23:10 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] SUNRPC: Handle zero length fragments correctly
Date:   Tue, 19 Feb 2019 11:22:01 -0500
Message-Id: <20190219162202.68013-2-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190219162202.68013-1-trond.myklebust@hammerspace.com>
References: <20190219162202.68013-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

A zero length fragment is really a bug, but let's ensure we don't
go nuts when one turns up.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xprtsock.c | 32 ++++++++++++++++++++++----------
 1 file changed, 22 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 52c98dc480ec..89bcab53848a 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -405,8 +405,8 @@ xs_read_xdr_buf(struct socket *sock, struct msghdr *msg, int flags,
 	size_t want, seek_init = seek, offset = 0;
 	ssize_t ret;
 
-	if (seek < buf->head[0].iov_len) {
-		want = min_t(size_t, count, buf->head[0].iov_len);
+	want = min_t(size_t, count, buf->head[0].iov_len);
+	if (seek < want) {
 		ret = xs_read_kvec(sock, msg, flags, &buf->head[0], want, seek);
 		if (ret <= 0)
 			goto sock_err;
@@ -417,8 +417,8 @@ xs_read_xdr_buf(struct socket *sock, struct msghdr *msg, int flags,
 			goto out;
 		seek = 0;
 	} else {
-		seek -= buf->head[0].iov_len;
-		offset += buf->head[0].iov_len;
+		seek -= want;
+		offset += want;
 	}
 
 	want = xs_alloc_sparse_pages(buf,
@@ -443,8 +443,8 @@ xs_read_xdr_buf(struct socket *sock, struct msghdr *msg, int flags,
 		offset += want;
 	}
 
-	if (seek < buf->tail[0].iov_len) {
-		want = min_t(size_t, count - offset, buf->tail[0].iov_len);
+	want = min_t(size_t, count - offset, buf->tail[0].iov_len);
+	if (seek < want) {
 		ret = xs_read_kvec(sock, msg, flags, &buf->tail[0], want, seek);
 		if (ret <= 0)
 			goto sock_err;
@@ -454,7 +454,7 @@ xs_read_xdr_buf(struct socket *sock, struct msghdr *msg, int flags,
 		if (ret != want)
 			goto out;
 	} else
-		offset += buf->tail[0].iov_len;
+		offset = seek_init;
 	ret = -EMSGSIZE;
 out:
 	*read = offset - seek_init;
@@ -482,6 +482,14 @@ xs_read_stream_request_done(struct sock_xprt *transport)
 	return transport->recv.fraghdr & cpu_to_be32(RPC_LAST_STREAM_FRAGMENT);
 }
 
+static void
+xs_read_stream_check_eor(struct sock_xprt *transport,
+		struct msghdr *msg)
+{
+	if (xs_read_stream_request_done(transport))
+		msg->msg_flags |= MSG_EOR;
+}
+
 static ssize_t
 xs_read_stream_request(struct sock_xprt *transport, struct msghdr *msg,
 		int flags, struct rpc_rqst *req)
@@ -493,14 +501,18 @@ xs_read_stream_request(struct sock_xprt *transport, struct msghdr *msg,
 	xs_read_header(transport, buf);
 
 	want = transport->recv.len - transport->recv.offset;
+	if (want == 0) {
+		xs_read_stream_check_eor(transport, msg);
+		return 0;
+	}
+
 	ret = xs_read_xdr_buf(transport->sock, msg, flags, buf,
 			transport->recv.copied + want, transport->recv.copied,
 			&read);
 	transport->recv.offset += read;
 	transport->recv.copied += read;
-	if (transport->recv.offset == transport->recv.len &&
-	    xs_read_stream_request_done(transport))
-		msg->msg_flags |= MSG_EOR;
+	if (transport->recv.offset == transport->recv.len)
+		xs_read_stream_check_eor(transport, msg);
 
 	switch (ret) {
 	default:
-- 
2.20.1

