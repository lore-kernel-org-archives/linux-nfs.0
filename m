Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04D81C43387
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 15:58:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C9169217D9
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 15:58:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TMSbqiee"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728889AbeLSP6s (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 10:58:48 -0500
Received: from mail-io1-f67.google.com ([209.85.166.67]:33679 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727829AbeLSP6r (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Dec 2018 10:58:47 -0500
Received: by mail-io1-f67.google.com with SMTP id t24so15998372ioi.0;
        Wed, 19 Dec 2018 07:58:47 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=tYYd+d/3w8thIUzENvVD06hgPLxIXGsKVk7XNtDGXEo=;
        b=TMSbqieenCunwJTLAuSLJjYvgiSQ+7IZ5pZZry/h61ESI/KK6Xd4mOikQNhJ2IgBS0
         j1y0NUiN4gcikZU8ZFpZMK3kyAK9pgGcAGk8q+ic1/5sf1cybpJJKxnELrBZoW5hTz1l
         VgVrZGGQz4FNd9rZ5dYxkS5FhonQzhcf0HOf8d+Hl8c07gw1sw8nO7T61ItfPOZXAzPz
         vCgAbF10qDw5WxXTYrMpdsaIa0H3o+eIi/sRT2FAkGz0dViJ+31NyDWNrnhdf8JyADfO
         VqZai3wSasKDG6UzyZ3XCTF12zGx49SlSaShV5Bx7IfI8+uJvRRWfD6/+dt/UlMFb0e3
         V/Zw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=tYYd+d/3w8thIUzENvVD06hgPLxIXGsKVk7XNtDGXEo=;
        b=uLJT8P4R0KVuNCGcsJDcRGT+QpWLD6Tgy6pep07KVHFwgRbhd2qUvhYPTYrrBf77hA
         olntiXS+Zfj+uuMTDw/bS3l4aVzxXL632/aryrClPuvWjfWfjDOaAgxHxt66PBrKwP89
         pids9Vh2ULrOtn3Sg51Yyy4XmVtSDDLlkaFzKSY0hwrYbF2E+7JQau85AsqYxucgMxfX
         Dtjia0q14TDvneg/XAu32IlNtq0bz/2mFbywiE5ZZPXPnQPL8lWdYA7Cqp+5v06CPUhf
         /hiHPujmy+4EYGlOCxbFmNQQFE5BrwsAY7F8V0BKsWQY5ItxDfFdwbHu20vTPLMAK/gV
         uvSw==
X-Gm-Message-State: AA+aEWZDroPBoBfu0cz9jXu4q8sR8d9xLFAP4sa0qlq9pUxl0jX1hbeQ
        rDKuVzVvCajzh6idR+bmFYX80ZkD
X-Google-Smtp-Source: AFSGD/UTnKew7I481wUMibEL13uW1YYRyAxxU6EIhtzKepYG9MjVJ09qRV+eJB0mFj5Uqpw8taveHw==
X-Received: by 2002:a6b:14c6:: with SMTP id 189mr18122972iou.179.1545235127122;
        Wed, 19 Dec 2018 07:58:47 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id u13sm11204iop.78.2018.12.19.07.58.46
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 07:58:46 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBJFwjCl025777;
        Wed, 19 Dec 2018 15:58:45 GMT
Subject: [PATCH v5 07/30] xprtrdma: Fix ri_max_segs and the result of
 ro_maxpages
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 19 Dec 2018 10:58:45 -0500
Message-ID: <20181219155845.11602.42218.stgit@manet.1015granger.net>
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

With certain combinations of krb5i/p, MR size, and r/wsize, I/O can
fail with EMSGSIZE. This is because the calculated value of
ri_max_segs (the max number of MRs per RPC) exceeded
RPCRDMA_MAX_HDR_SEGS, which caused Read or Write list encoding to
walk off the end of the transport header.

Once that was addressed, the ro_maxpages result has to be corrected
to account for the number of MRs needed for Reply chunks, which is
2 MRs smaller than a normal Read or Write chunk.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c   |    7 +++++--
 net/sunrpc/xprtrdma/frwr_ops.c  |    7 +++++--
 net/sunrpc/xprtrdma/transport.c |    6 ++++--
 3 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 7f5632c..dd1e91b 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -176,7 +176,10 @@ enum {
 
 	ia->ri_max_segs = max_t(unsigned int, 1, RPCRDMA_MAX_DATA_SEGS /
 				RPCRDMA_MAX_FMR_SGES);
-	ia->ri_max_segs += 2;	/* segments for head and tail buffers */
+	/* Reply chunks require segments for head and tail buffers */
+	ia->ri_max_segs += 2;
+	if (ia->ri_max_segs > RPCRDMA_MAX_HDR_SEGS)
+		ia->ri_max_segs = RPCRDMA_MAX_HDR_SEGS;
 	return 0;
 }
 
@@ -186,7 +189,7 @@ enum {
 fmr_op_maxpages(struct rpcrdma_xprt *r_xprt)
 {
 	return min_t(unsigned int, RPCRDMA_MAX_DATA_SEGS,
-		     RPCRDMA_MAX_HDR_SEGS * RPCRDMA_MAX_FMR_SGES);
+		     (r_xprt->rx_ia.ri_max_segs - 2) * RPCRDMA_MAX_FMR_SGES);
 }
 
 /* Use the ib_map_phys_fmr() verb to register a memory region
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 27222c0..f587e44 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -244,7 +244,10 @@
 
 	ia->ri_max_segs = max_t(unsigned int, 1, RPCRDMA_MAX_DATA_SEGS /
 				ia->ri_max_frwr_depth);
-	ia->ri_max_segs += 2;	/* segments for head and tail buffers */
+	/* Reply chunks require segments for head and tail buffers */
+	ia->ri_max_segs += 2;
+	if (ia->ri_max_segs > RPCRDMA_MAX_HDR_SEGS)
+		ia->ri_max_segs = RPCRDMA_MAX_HDR_SEGS;
 	return 0;
 }
 
@@ -257,7 +260,7 @@
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 
 	return min_t(unsigned int, RPCRDMA_MAX_DATA_SEGS,
-		     RPCRDMA_MAX_HDR_SEGS * ia->ri_max_frwr_depth);
+		     (ia->ri_max_segs - 2) * ia->ri_max_frwr_depth);
 }
 
 static void
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 134aae2..d3f26c5 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -703,8 +703,10 @@ void xprt_rdma_close(struct rpc_xprt *xprt)
  *	%-ENOTCONN if the caller should reconnect and call again
  *	%-EAGAIN if the caller should call again
  *	%-ENOBUFS if the caller should call again after a delay
- *	%-EIO if a permanent error occurred and the request was not
- *		sent. Do not try to send this message again.
+ *	%-EMSGSIZE if encoding ran out of buffer space. The request
+ *		was not sent. Do not try to send this message again.
+ *	%-EIO if an I/O error occurred. The request was not sent.
+ *		Do not try to send this message again.
  */
 static int
 xprt_rdma_send_request(struct rpc_rqst *rqst)

