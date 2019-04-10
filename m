Return-Path: <SRS0=wtRa=SM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 767EBC10F11
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Apr 2019 20:06:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4626F2075B
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Apr 2019 20:06:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kMO5dokk"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726536AbfDJUGj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 10 Apr 2019 16:06:39 -0400
Received: from mail-io1-f67.google.com ([209.85.166.67]:44956 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726014AbfDJUGj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Apr 2019 16:06:39 -0400
Received: by mail-io1-f67.google.com with SMTP id u12so3262555iop.11;
        Wed, 10 Apr 2019 13:06:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=WHZ+h/q/YGUHYxMZ5j/Bf+5zZq+eqcPhO1i86doUWqA=;
        b=kMO5dokkFh6s7q95BBq4Om4+HR2PNugD+9OoQOLJaHTQN5UGFSHvBpq0hrcM5quQ7Y
         Uz7tZ4nv3HM5Nytknw/vU2qaHPzwQe4OLMxnYiqU+qQdzTl13GDWZ1aSeB4LO/FsIh2S
         gRcCOd5482YRCHWZQsVB2Lo9ZqkzX4ehWeXcir5VZCUlRwb54+eGnpv5nVus+/LVzYir
         dMpOTrEav3eao6zt233tqo8LccyAzGUhYCxalgq6mVQjtr/ZLRqrVxfXpYpt0dGV1FFK
         1QN8wq+dTgkeECk03YuYRzcResRZUcxlhMVON7xgMQVANy/29EL85rlM3RCroy2BIcHD
         3aIg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=WHZ+h/q/YGUHYxMZ5j/Bf+5zZq+eqcPhO1i86doUWqA=;
        b=uQwzY8I/VrTeUwbtqXvAN6RtoavdmiiT8eveIEyD8vEOiBSsUpAon4zRZguWxfIXwl
         Y3phBZ3D3UzKc7IJxfXd3TOEJLdkosJiFXn997CvAPomJhjOZeVhnfvzjY04SxzllokZ
         GlqP3AevrOfDJhR54OSK4hLvFFbxiLUw6+9as/NEJ2r+7fdLyM7opBVx5pLzeObty+S0
         lNDIn1gFYF1+5TE1zulHw64pGjlG7aCwVf130yfAjl3GfODDtb1T4IrE1E9B8+JuJiDW
         oRHoWgIyub5R0poqbr4MI8Uuh9w1K2d4M2vo4BGx3Nah6wjvw2TaTvnuN/DJmyaz24mA
         D19Q==
X-Gm-Message-State: APjAAAU/Wfszmms3wNRl4gPr+Efe+dpVptXbMuCs26miVRaabowgmu02
        4L9BFuvQkqYg3vIisRdI8YuxcB3s
X-Google-Smtp-Source: APXvYqyh/bX3Y6fbyGE46vsc2yUJh8Qh+5wDFvkOjwWoiP8+mTV7f/tpPI29SSvs+A/91xYqoXGZPg==
X-Received: by 2002:a6b:8b90:: with SMTP id n138mr12665753iod.75.1554926798303;
        Wed, 10 Apr 2019 13:06:38 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id g1sm13622993ion.2.2019.04.10.13.06.37
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 13:06:37 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3AK6aUV004506;
        Wed, 10 Apr 2019 20:06:36 GMT
Subject: [PATCH v1 01/19] SUNRPC: Avoid digging into the ATOMIC pool
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 10 Apr 2019 16:06:36 -0400
Message-ID: <20190410200636.11522.99685.stgit@manet.1015granger.net>
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

Page allocation requests made when the SPARSE_PAGES flag is set are
allowed to fail, and are not critical. No need to spend a rare
resource.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/socklib.c           |    2 +-
 net/sunrpc/xprtrdma/rpc_rdma.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/socklib.c b/net/sunrpc/socklib.c
index 7e55cfc..9faea12 100644
--- a/net/sunrpc/socklib.c
+++ b/net/sunrpc/socklib.c
@@ -106,7 +106,7 @@ static size_t xdr_skb_read_and_csum_bits(struct xdr_skb_reader *desc, void *to,
 		/* ACL likes to be lazy in allocating pages - ACLs
 		 * are small by default but can get huge. */
 		if ((xdr->flags & XDRBUF_SPARSE_PAGES) && *ppage == NULL) {
-			*ppage = alloc_page(GFP_ATOMIC);
+			*ppage = alloc_page(GFP_NOWAIT | __GFP_NOWARN);
 			if (unlikely(*ppage == NULL)) {
 				if (copied == 0)
 					copied = -ENOMEM;
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 6c1fb27..b759b16 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -238,7 +238,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 		 */
 		if (unlikely(xdrbuf->flags & XDRBUF_SPARSE_PAGES)) {
 			if (!*ppages)
-				*ppages = alloc_page(GFP_ATOMIC);
+				*ppages = alloc_page(GFP_NOWAIT | __GFP_NOWARN);
 			if (!*ppages)
 				return -ENOBUFS;
 		}

