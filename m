Return-Path: <SRS0=idK9=OF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D9ADC43441
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 20:06:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E84F9205C9
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 20:06:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="aZM24eTr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E84F9205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727209AbeK0HBh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 27 Nov 2018 02:01:37 -0500
Received: from mail-it1-f194.google.com ([209.85.166.194]:50282 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726296AbeK0HBh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Nov 2018 02:01:37 -0500
Received: by mail-it1-f194.google.com with SMTP id z7so12820875iti.0;
        Mon, 26 Nov 2018 12:06:23 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=V+dXKpnWgITShHAK2a7GSJpCCqK0XWtYjAuIxxYky/o=;
        b=aZM24eTrLCJHM2fSkreVrMRBmZYDsJyuLVhvgxXfGyPVXi3QDXB9iRZwZeQBXfE1uE
         J7/vTGsj4HkiOYkrahX4UdXwlxUoRX7HDy4O4RoiQtZToiQr/fVmukglAsjJWAvb/Ogz
         SFN2DKbs7oeGi60U8BaEB8S64n4Bto2jKn1a6ITw3RgggzYtRe9oBGXmXU6dxs/XNz4u
         vIeoUbtyMKG+MMpD3W3dZrNEmjooDlxk3Bh9SNNjxrt3TcImzVGqb2Fmqpy5F4M+zG6s
         L7iV3GMvJ0ccP2gpwtvyFfKHSCiACShJBVDPD1zWID4NAvC6eM0l66ixu9slzXBtEGLp
         9j+A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=V+dXKpnWgITShHAK2a7GSJpCCqK0XWtYjAuIxxYky/o=;
        b=r6FyNr1eEqhN4nKUdjSdWAoJyez2bQmBV33eWMnnipPqr6T78umLKqlrr5DK3kRa5U
         dtGeAx5wV0WkIdOZPH1Tux41wBnQMknIdts05Vnw2uph7mQayRmPP+C2ZhFsWwfc4aeZ
         oCjzEas5IEPNRlz1sEXp2NeIJvQS79JR032JlMptE/m5RFoiRyv0e8Q0fGoi9jNVHwAn
         znnnEwVIaei+iaAml8qNuQdMHpnlvhSPtAcdBczIU1H1TUvqP/k+pCcBmviDn0AUAlFE
         4ibGpJ4sbPDEA2zbYj6vYzVRiGxvl9tpb2oqyN/IDWhxETjY2ZiUoPDNky8HwMwVbnE2
         wOjA==
X-Gm-Message-State: AGRZ1gIkk85krxjv/3zFgt7ibHAx9bwlg8GToJ7tneoWkQN3xHaAj8AM
        Vm6rPSGkn0ZmzYGQ+NzIUyzhi0Qv
X-Google-Smtp-Source: AJdET5cRg2uQ+PPvT+MCa2nkuZm1nmlBFJHzQWYDD2CPsJi678dybaC9mi903elKOU527XpLzaJ+CQ==
X-Received: by 2002:a24:7fce:: with SMTP id r197mr24060240itc.4.1543262781884;
        Mon, 26 Nov 2018 12:06:21 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id w18sm433416iom.25.2018.11.26.12.06.20
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 12:06:20 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wAQK6Jf7010660;
        Mon, 26 Nov 2018 20:06:19 GMT
Subject: [PATCH v2 06/20] xprtrdma: Recognize XDRBUF_SPARSE_PAGES
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 26 Nov 2018 15:06:19 -0500
Message-ID: <20181126200619.10321.66505.stgit@manet.1015granger.net>
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

Commit 431f6eb3570f ("SUNRPC: Add a label for RPC calls that require
allocation on receive") didn't update similar logic in rpc_rdma.c.
I don't think this is a bug, per-se; the commit just adds more
careful checking for broken upper layer behavior.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 89a2db2..c87e0c1 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -218,11 +218,12 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	ppages = xdrbuf->pages + (xdrbuf->page_base >> PAGE_SHIFT);
 	page_base = offset_in_page(xdrbuf->page_base);
 	while (len) {
-		if (unlikely(!*ppages)) {
-			/* XXX: Certain upper layer operations do
-			 *	not provide receive buffer pages.
-			 */
-			*ppages = alloc_page(GFP_ATOMIC);
+		/* ACL likes to be lazy in allocating pages - ACLs
+		 * are small by default but can get huge.
+		 */
+		if (unlikely(xdrbuf->flags & XDRBUF_SPARSE_PAGES)) {
+			if (!*ppages)
+				*ppages = alloc_page(GFP_ATOMIC);
 			if (!*ppages)
 				return -ENOBUFS;
 		}

