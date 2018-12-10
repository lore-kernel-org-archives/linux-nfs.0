Return-Path: <SRS0=PHUf=OT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9CF6AC5CFFE
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:29:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 59AAF20821
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:29:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LGHfyTlM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59AAF20821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727479AbeLJQ3m (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Dec 2018 11:29:42 -0500
Received: from mail-io1-f67.google.com ([209.85.166.67]:41303 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728226AbeLJQ3m (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2018 11:29:42 -0500
Received: by mail-io1-f67.google.com with SMTP id s22so9218746ioc.8;
        Mon, 10 Dec 2018 08:29:41 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=BmKqQITA9+HczFoMEnMmMy5pN7xLdPWjE1xyV4c2S6k=;
        b=LGHfyTlMD423ZgxEvw8u9OV/hJDrQX9+Q1Y5Xd06gWu5TODLLuug2uFhvyYTdy0ViV
         fmCC387TtU8WowwrWoFF5P3QqNwI5po5DwtSR8vSrB8jBydSU+JCoSlTNZw0iTupkfEu
         ZFM9YzXJb+xbL5hm4eaxAsMBE+8MuCzjfJMOsznbICp6eTJ8n6ldu1Dh0nW5g8cydmmz
         HxT5jQT+Ym09dxwNtHyN0LcmU6mfCyR1O1b3uxnAKd32mv+tZ2mkYCpRBOX2OtQsD6nZ
         sGHeevYD+2ya7rCmxg2yxiMOGLuZpyGBcPvVrLFQaxRmR2BXjO2L+ur01+nzOVs0C2i/
         UI+Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=BmKqQITA9+HczFoMEnMmMy5pN7xLdPWjE1xyV4c2S6k=;
        b=tkUoXvYRcWCZkv8UkgPVNdGU0yrlZAUp0PO3sWdeDPoPoUCVEV+/JQRogiBuWqrDlb
         NKKov9GqjULjhFEm/ISxaFFF1d+F5FwpCHizh2Z2JJ8MhqEmgGjk+ARv+s6QFjVeuvEz
         +K9tQK9aHE+90gXENomQLBeF/L1W5QPsz7ErRBZ/pLryIC42PesYDWAkOey7yvniqIYB
         60VUkPyPkK6F6advmMhp7RQfFlJIRU4IC614H79QzJ0jz+QczGpDrJcCyA/FL7lTUpm9
         5x3MwM5oUzFTC6+dQjywv6hazV7N0567pfD12yPPebBM/Ract+QbVJIPnjaFsG4m8gEn
         b1rg==
X-Gm-Message-State: AA+aEWYLxu4DL6ypF+eqLBO+RXnxPgWZFigVkKw1qnpk0UuW7LDXiwtm
        WkT6RkhN8dGa1mW25Zzxkug=
X-Google-Smtp-Source: AFSGD/UsbMGpBVDn5lPzz4i4gOOGzM7Mkk5vto3uxBxvFJMoQ5ckRMEb3nZoOOtNCyc/zPfW1EeuIg==
X-Received: by 2002:a5e:940c:: with SMTP id q12mr9212278ioj.228.1544459381589;
        Mon, 10 Dec 2018 08:29:41 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id d3sm4675508iom.45.2018.12.10.08.29.40
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 08:29:41 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBAGTePs031023;
        Mon, 10 Dec 2018 16:29:40 GMT
Subject: [PATCH v3 04/24] xprtrdma: Fix ri_max_segs and the result of
 ro_maxpages
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 10 Dec 2018 11:29:40 -0500
Message-ID: <20181210162940.4198.6579.stgit@manet.1015granger.net>
In-Reply-To: <20181210161723.4198.51071.stgit@manet.1015granger.net>
References: <20181210161723.4198.51071.stgit@manet.1015granger.net>
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
 net/sunrpc/xprtrdma/frwr_ops.c  |    7 +++++--
 net/sunrpc/xprtrdma/transport.c |    6 ++++--
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index fc6378cc..ae94de9 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -242,7 +242,10 @@
 
 	ia->ri_max_segs = max_t(unsigned int, 1, RPCRDMA_MAX_DATA_SEGS /
 				ia->ri_max_frwr_depth);
-	ia->ri_max_segs += 2;	/* segments for head and tail buffers */
+	/* Reply chunks require segments for head and tail buffers */
+	ia->ri_max_segs += 2;
+	if (ia->ri_max_segs > RPCRDMA_MAX_HDR_SEGS)
+		ia->ri_max_segs = RPCRDMA_MAX_HDR_SEGS;
 	return 0;
 }
 
@@ -255,7 +258,7 @@
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 
 	return min_t(unsigned int, RPCRDMA_MAX_DATA_SEGS,
-		     RPCRDMA_MAX_HDR_SEGS * ia->ri_max_frwr_depth);
+		     (ia->ri_max_segs - 2) * ia->ri_max_frwr_depth);
 }
 
 static void
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index ae2a838..2ba8be1 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -696,8 +696,10 @@
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

