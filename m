Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44FAAC65BAE
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 21:57:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0205F20660
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 21:57:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="T04XAMcB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0205F20660
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725749AbeLAJHt (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 04:07:49 -0500
Received: from mail-io1-f65.google.com ([209.85.166.65]:46282 "EHLO
        mail-io1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726111AbeLAJHt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Dec 2018 04:07:49 -0500
Received: by mail-io1-f65.google.com with SMTP id v10so5734033ios.13
        for <linux-nfs@vger.kernel.org>; Fri, 30 Nov 2018 13:57:06 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=2OHxhQr8J7GF4YpEHredA9VOJOz0f0ZGnMc3/r924kY=;
        b=T04XAMcBB6mG+o4ee3jK0NstH1Q7ukibXn/GnxMop6SxEpEC5xw/EMy0KnD1qhSHB9
         Nd99hQ9AytEFcs+AVAfXdKpY/yfBLt4BvYOpRfnOjoRF79tQsG06dUUCkidUXdpn+9D7
         nQ6uTBdlU/Xtyn58jEvLag2NBnjze/cg4l1wzFfjOpHm5mwOZnXi4Yr7ydLLDxvt/XQS
         aVMnBxDLyoP7+5v4KtuViXXxaG0pAMtGRs8aTyNxN+wZ1XnUywB4/5qxMjEGtvc2MIGe
         eTSULNVIwnMJPHsCp32ctU17tTme1hI8JMg6KvLtmbYtGZKm5l4vKgTxY62mQTAsX+8J
         77Xg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=2OHxhQr8J7GF4YpEHredA9VOJOz0f0ZGnMc3/r924kY=;
        b=d7jpiuUicsFFTCXg4LxbXDbAI3ZDMdVEF1OHOAMF2CvRY0dmMlEvh+DNAd2eq9It9P
         VdgM7usBeRYuzldLXJaXShJfziSAyue8i8C6aWFh1ke0rnx3sP7x1mS/2nUy/vhGzlFK
         PFDkiSe7tT5lkgkHQcKUgrci/My5vCgZBwBK81AfOdssGtizH0f7viL09XlpRUeE0xRo
         reAUEuLoz0z2shAQFxlXVaAnoNGm7/7x6XePqaG5gxSVRaIN1oCuTyVOH+8pV8L6zHoX
         MvM+Soqoo4sgIEoifETNUfTQJoYFaKnm8Deexg1zV1ReQbdr8BNajO+KCiKqzZM4YgCl
         cKuA==
X-Gm-Message-State: AA+aEWY3x7+iehd1pesPM8uwfoNwJ+0rwt6j8gCDviY0uokpcMq2NGke
        Sy8tya6km7E1ZEoS/QFPveWUDtw=
X-Google-Smtp-Source: AFSGD/Xh3qkN1VVl8xu/IAwZibV8lKehpcz0WQgoRNwQnKZXk/QXWQf/1CuU57jVQHCXhB1aLG4haw==
X-Received: by 2002:a6b:c8c9:: with SMTP id y192mr5840641iof.183.1543615025950;
        Fri, 30 Nov 2018 13:57:05 -0800 (PST)
Received: from localhost.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id z23sm2659119iob.19.2018.11.30.13.57.04
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 30 Nov 2018 13:57:04 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 3/3] SUNRPC: Ensure we refresh the bvec after RPCSEC_GSS encoding
Date:   Fri, 30 Nov 2018 16:55:55 -0500
Message-Id: <20181130215555.91107-3-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.19.2
In-Reply-To: <20181130215555.91107-2-trond.myklebust@hammerspace.com>
References: <20181130215555.91107-1-trond.myklebust@hammerspace.com>
 <20181130215555.91107-2-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

A call to gss_wrap_req_priv() will end up replacing the original array
in rqstp->rq_snd_buf.pages with a new one containing the encrypted
data. In order to avoid having the rqstp->rq_snd_buf.bvec point to the
wrong page data, we need to refresh that too.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/xdr.h | 1 -
 net/sunrpc/xprt.c          | 2 ++
 net/sunrpc/xprtsock.c      | 1 +
 3 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 43106ffa6788..2ec128060239 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -72,7 +72,6 @@ xdr_buf_init(struct xdr_buf *buf, void *start, size_t len)
 	buf->head[0].iov_base = start;
 	buf->head[0].iov_len = len;
 	buf->tail[0].iov_len = 0;
-	buf->bvec = NULL;
 	buf->pages = NULL;
 	buf->page_len = 0;
 	buf->flags = 0;
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 86bea4520c4d..122c91c28e7c 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1623,6 +1623,8 @@ xprt_request_init(struct rpc_task *task)
 	req->rq_snd_buf.buflen = 0;
 	req->rq_rcv_buf.len = 0;
 	req->rq_rcv_buf.buflen = 0;
+	req->rq_snd_buf.bvec = NULL;
+	req->rq_rcv_buf.bvec = NULL;
 	req->rq_release_snd_buf = NULL;
 	xprt_reset_majortimeo(req);
 	dprintk("RPC: %5u reserved req %p xid %08x\n", task->tk_pid,
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index ae77c71c1f64..615ef2397fc5 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -843,6 +843,7 @@ static int xs_nospace(struct rpc_rqst *req)
 static void
 xs_stream_prepare_request(struct rpc_rqst *req)
 {
+	xdr_free_bvec(&req->rq_rcv_buf);
 	req->rq_task->tk_status = xdr_alloc_bvec(&req->rq_rcv_buf, GFP_NOIO);
 }
 
-- 
2.19.2

