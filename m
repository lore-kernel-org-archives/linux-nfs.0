Return-Path: <SRS0=idK9=OF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0BADEC43441
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 20:06:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C63CE20672
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 20:06:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="l0GzuoBC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C63CE20672
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727107AbeK0HBW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 27 Nov 2018 02:01:22 -0500
Received: from mail-it1-f194.google.com ([209.85.166.194]:54140 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726296AbeK0HBW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Nov 2018 02:01:22 -0500
Received: by mail-it1-f194.google.com with SMTP id g85so30388366ita.3;
        Mon, 26 Nov 2018 12:06:08 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=BmKqQITA9+HczFoMEnMmMy5pN7xLdPWjE1xyV4c2S6k=;
        b=l0GzuoBCw5eHCO064Du0YmCtfyqejenp9D84yd8kRz83myNGmRf79MHi+hJIVkJZe8
         FNoG+AHrFhpk0kJCwdd97O+u1UEYahokAr1W8wuDaj7Aa0ynjD4ZEjkfl7SD83X/95dY
         RMUmaKXCZob5M0fnTRAKyiMwhwN7QWAOzb3byabvNA+Dj22OW1QOEdIoBMXqtWs7l/00
         FKU/VVyrefyJfi+AWe96pUAU5mif/LCIRI290jyxr4NoEWW8VthAnvT1gaVTTo/VVYc9
         G4kTz1U50b0d0jJvsvJyBEAoRZEnlHl/DLtvgxbAQ41+puiQvF44HulQQvbIfdzFt+hc
         SSTA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=BmKqQITA9+HczFoMEnMmMy5pN7xLdPWjE1xyV4c2S6k=;
        b=M0+vKUM01a3gq0Dwf+8Cc3oWGlBKE3FhY0ixTKLjtgb0/akreeM2u9INryjBWubSp3
         4/XrXi/QPnY0GtBdVbT2SiU5BhWwHof20wvQ8UqY0gCapM/EjyDw0EYJnpY83CNnLiJ/
         S1hJE/AV4KWYE1BXmQ4KZS1v4iBT+R4D9kkB1McgftmX2GnVEl+yuQjln5UejpyYSrza
         bx4J0S/vl5Rk4RAKTNYHkTZhEoTm+UxAGt9S8i4jIr6JeGniT4IyVN4AQ3bgT7bZUA0p
         1KsJMkVlPGXVrGAJNifil9Bq2oQv220AU6ALYqu5JfWvOgnLSnR+CBj9z8dBbq2qTHPu
         IUkQ==
X-Gm-Message-State: AGRZ1gIFzMP/1Uu9bQLUawxPdhMbrSY4Kv7T4ZcTED0bX0d1fCm+6SME
        qNOJb3xKk8WNDiX/VHXmaR7y6Dhg
X-Google-Smtp-Source: AFSGD/WPB4aAYHGKa09wzR3+VeLXt4wz4d7X66cHEM+wOldyuMXScRgC4+XuFiHJyjv2rkRxHZL+Dg==
X-Received: by 2002:a24:710:: with SMTP id f16mr22152046itf.121.1543262766535;
        Mon, 26 Nov 2018 12:06:06 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id m11sm1942289itb.24.2018.11.26.12.06.03
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 12:06:04 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wAQK632s010651;
        Mon, 26 Nov 2018 20:06:03 GMT
Subject: [PATCH v2 03/20] xprtrdma: Fix ri_max_segs and the result of
 ro_maxpages
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 26 Nov 2018 15:06:03 -0500
Message-ID: <20181126200603.10321.13879.stgit@manet.1015granger.net>
In-Reply-To: <20181126194611.10321.71714.stgit@manet.1015granger.net>
References: <20181126194611.10321.71714.stgit@manet.1015granger.net>
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

