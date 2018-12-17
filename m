Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6930BC43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:40:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 34EEE2133F
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:40:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XQZVUo/E"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388146AbeLQQkB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 11:40:01 -0500
Received: from mail-io1-f65.google.com ([209.85.166.65]:39072 "EHLO
        mail-io1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388108AbeLQQkB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 11:40:01 -0500
Received: by mail-io1-f65.google.com with SMTP id k7so10454159iob.6;
        Mon, 17 Dec 2018 08:40:00 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=zFE3Q/AHFqEM9K7QikRDZ+AdCIpLEYyC9xdEuneC6j0=;
        b=XQZVUo/EN+Minx7F0vYtjmrixoM5N3G8N6fsc69UDgK+jKFyw3UU8wibAbWcsDW6wg
         amoA8h4Vj7akv/UHajrNXkUOb1U46CCHJ2F8HbmnN2pe0aqSgGheKWTB/B9IrKCRU9Ro
         N4AYfOi12JXB+xz6lolp6tRVgxdys69c9Ckbktn/6aXC0/KPSM5EDVhQqtheLTYP9uFk
         5SlS0kk50C/J6Y7YXgI/KGlbxFRp5IhZ+5Hv1qQ5gd4uHXwFHwTsmehcU0xISBOJ5kle
         aeKyuAVArUS2UN06mWdH7Pge/+Ybv49SZQDe2d7DbeXSZTRXU9yGVCT7CkhBhW3sLYIg
         lKXA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=zFE3Q/AHFqEM9K7QikRDZ+AdCIpLEYyC9xdEuneC6j0=;
        b=ESVPKqvZ48yW1gjIzQCyEbSZXhjuggRoMDdq72YvA6EHcsCn5tayV+YgykQSy5AFMk
         6TRxGv8PPIFuCK3qThrsirzLYmxiXDJvCMIGYUYbDmv9CW/HaxiBeUpI66vQAN4WjbqV
         H9JNz6M94nu9eNU76reT+5evhUG4pefDASyZuxSEheriptldgLE52xxySmyNghN24Kv0
         B8SYWdHu8mDPBSIgKBOEj38COoHMhMMjFEAtpUlQmAJDrZilY+pYUvfZ2CDtPaUWBdtM
         9eXrJiFFpG7lPpA2ZrTBKZ8Bke2GtfqGRXwrWvOJzDkFn3DQXR5MGAiuXEbMW8sJsCpv
         IdBg==
X-Gm-Message-State: AA+aEWbUQR62KXqACEr3nXfHod2dv4BjEXwOIJkE5yTsY8U59x59ar1g
        Ya6ehNRLeOaVjeJ0e4JrxcWFNsE4
X-Google-Smtp-Source: AFSGD/U5VMQExksmYMOO+S5W5M4uSArPVNTriwLXODgjuo6WQAiR6GPB8Vp66T0KYrNdD8ipk+OFSw==
X-Received: by 2002:a6b:8d8a:: with SMTP id p132mr12166619iod.290.1545064800159;
        Mon, 17 Dec 2018 08:40:00 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id w3sm4173836ior.28.2018.12.17.08.39.59
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 08:39:59 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBHGdwSU018591;
        Mon, 17 Dec 2018 16:39:58 GMT
Subject: [PATCH v4 07/30] xprtrdma: Fix ri_max_segs and the result of
 ro_maxpages
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 17 Dec 2018 11:39:58 -0500
Message-ID: <20181217163958.24133.16923.stgit@manet.1015granger.net>
In-Reply-To: <20181217162406.24133.27356.stgit@manet.1015granger.net>
References: <20181217162406.24133.27356.stgit@manet.1015granger.net>
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
index 7f5632c..78a0224 100644
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
+		     (ia->ri_max_segs - 2) * RPCRDMA_MAX_FMR_SGES);
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
index a16296b..fbb14bf 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -704,8 +704,10 @@
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

