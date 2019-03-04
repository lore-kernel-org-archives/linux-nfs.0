Return-Path: <SRS0=iDPq=RH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 845B3C43381
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Mar 2019 15:32:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 50C68208E4
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Mar 2019 15:32:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fknB7J8g"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726543AbfCDPcr (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 4 Mar 2019 10:32:47 -0500
Received: from mail-io1-f67.google.com ([209.85.166.67]:34560 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726095AbfCDPcr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Mar 2019 10:32:47 -0500
Received: by mail-io1-f67.google.com with SMTP id e1so4270999iok.1
        for <linux-nfs@vger.kernel.org>; Mon, 04 Mar 2019 07:32:46 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=WHZ+h/q/YGUHYxMZ5j/Bf+5zZq+eqcPhO1i86doUWqA=;
        b=fknB7J8g0mjDE5K81iU2dolkfTdh5T4pWlDNpwtaQDL3RP5i9oEd1jwBAq7fxJwbpR
         KIhvoUJmcPmik1y38V+qRz20nEGDkU1XA2NDidcM+Aw/+2ij3AT3CkYvCmYS3ZkVUm8V
         oIhGKteqAxG59CUSoaRDJSEmF1snUXIZ53dVR5zBOjdT9GuWqKR9bJM9H8FLcYp02hFn
         6bl2IsJPaVqi/N0KslCNaH+6qSBp3eAjy8UodPhRDuWS49FpEDwspvday2i5dlHi61uh
         BaWHg6UYXSrXY4LLXXEOCRKYhQpbxwVgatABlg1UL+87xWEzNcUsMFGldQJMZsFS1WGX
         u70g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=WHZ+h/q/YGUHYxMZ5j/Bf+5zZq+eqcPhO1i86doUWqA=;
        b=jnpIssTNFsL8pUQO92WuQo0/zBWJ7SC6LX1UcOUUuWcTQGfT8YSkWZWiikKxOWfbhd
         ZKAeahsQQZzBH7dBl98zsWXLJ44zRWi7cPkeudZChAM+LkXTm+3nmyLR38RD7KmhjWin
         FxwneaSi0JGTaoFQuGKe7SFlSXs+ECCx62OGyfRFNXUpAoqiCADoXD5443JoIGJU1RCN
         +3MtqW/vSY4fvZmwr7zzPTC72IV7BkwypSZr1os8aVu0w86lkkz6xXMiFsDDW9EnXGII
         XeAsJcH9ttWHkVNmYZ6tt6NZ7Bgo43Sx+K9wCm9MRWXXa5ZWQiGAE/LCZUTQhq0B0PFJ
         KIYg==
X-Gm-Message-State: APjAAAXRifHPSXIw4nUYBuY7GE7pLBi5II3ZJXjhmdCQx3A/YOjpqxDs
        JVJhyzbSEWK778dIekVwcalm1xEY
X-Google-Smtp-Source: APXvYqwFwqR1TQrLsoViDCuxFsrMWwx5Azd6wgcpUTdZjSvZmBIKhfaGYJg/wMy86vBUxSKJpddBDw==
X-Received: by 2002:a6b:d004:: with SMTP id x4mr9816858ioa.79.1551713566109;
        Mon, 04 Mar 2019 07:32:46 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id v5sm2377656iof.39.2019.03.04.07.32.45
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Mar 2019 07:32:45 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x24FWiw6031118
        for <linux-nfs@vger.kernel.org>; Mon, 4 Mar 2019 15:32:44 GMT
Subject: [PATCH RFC] SUNRPC: Avoid digging into the ATOMIC pool
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Mon, 04 Mar 2019 10:32:44 -0500
Message-ID: <20190304153222.27638.90558.stgit@manet.1015granger.net>
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

