Return-Path: <SRS0=idK9=OF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD164C43441
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 20:07:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8E047205C9
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 20:07:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="g11vz076"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E047205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726296AbeK0HCX (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 27 Nov 2018 02:02:23 -0500
Received: from mail-io1-f66.google.com ([209.85.166.66]:37715 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727227AbeK0HCX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Nov 2018 02:02:23 -0500
Received: by mail-io1-f66.google.com with SMTP id a3so15017912ioc.4;
        Mon, 26 Nov 2018 12:07:09 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=RT9fEOnCP8fxzowXgYqOJRgbr1fLDSnkcGiwkNSrjPw=;
        b=g11vz076Ja7telDRmLwcK7BUqWY4M0bpwHHL0fXPrSHORY12qhVoIsf5MMEC1Ryp3S
         CqCz3bRYJ4uzm2O7LS8CLMoX+riqS4SqqTvBRs2gQ9lY1HBFWiqBzezr7MLd9zO7WObO
         ulny7l/++AJ6kF3hrqPTaiMEYmCzeNgoOG8CGtHekWRUOZBNZ8gabaRNFNrUAy0Kia3i
         byVQ5i0Q4ng/X+qLb+DkTwJaViId5O1OIhCDe4lQYQ4fbITxKmiq48O/gOgTNKalR7cB
         q5OIepMA1RchnnTAY7jORMWHilbh8K0DPh1drrICTZYnKbcDwUUQj57djj0eGCGHVSvg
         lt0g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=RT9fEOnCP8fxzowXgYqOJRgbr1fLDSnkcGiwkNSrjPw=;
        b=FdV1dE2bWDCoqDUjpapbglsxb5MmcKY2swzbS420/2qE8QJdnM+G0tTUoPnSMniL3b
         h6wvQRdoX2G1EZLPiB9e0TtBbsPdP0ze3bLXXzbE2OsrCabiCIQRCrxZdBDNXc7QiMj2
         AwfWDlblUDdKSSU55iV4ssDyUtZduenHH2j91lvZyPQ3I8uvjPgUrJ+OJ2SLkX4/25rj
         ODafGd+uBY3FY4B83DCn4QQwmBxsaNeD9dLmTgpHLlXBSg3sgtR5lZ2JUOZzurCaYzsC
         Cv9cOsj+O/R4awskcuESbTIy76KKVljc0tkK+O7duklY4qilY2XGmUseae6Ahfocyuxi
         Di7g==
X-Gm-Message-State: AA+aEWbguRv8NoJx0SzysTsTGqdkn1b4EzPAK/MsxIve36gE21l99e6l
        T0xhpda+g4QL717RzIPbiAXqodNs
X-Google-Smtp-Source: AFSGD/X3YbklFpTS9bjhP7ejy7pCgktXaRYAgihUSG5hbqBuhdjcSHGdUTYmAyfqHiKmTQZYvvhZWQ==
X-Received: by 2002:a6b:3fd7:: with SMTP id m206mr21569160ioa.210.1543262828858;
        Mon, 26 Nov 2018 12:07:08 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id t65-v6sm700405ita.9.2018.11.26.12.07.08
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 12:07:08 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wAQK77mL010687;
        Mon, 26 Nov 2018 20:07:07 GMT
Subject: [PATCH v2 15/20] xprtrdma: Relocate the xprtrdma_mr_map trace points
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 26 Nov 2018 15:07:07 -0500
Message-ID: <20181126200707.10321.23810.stgit@manet.1015granger.net>
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

The mr_map trace points were capturing information about the previous
use of the MR rather than about the segment that was just mapped.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index e758c0d..6d6cc80 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -394,7 +394,6 @@
 	mr->mr_nents = ib_dma_map_sg(ia->ri_device, mr->mr_sg, i, mr->mr_dir);
 	if (!mr->mr_nents)
 		goto out_dmamap_err;
-	trace_xprtrdma_mr_map(mr);
 
 	ibmr = frwr->fr_mr;
 	n = ib_map_mr_sg(ibmr, mr->mr_sg, mr->mr_nents, NULL, PAGE_SIZE);
@@ -416,6 +415,7 @@
 	mr->mr_handle = ibmr->rkey;
 	mr->mr_length = ibmr->length;
 	mr->mr_offset = ibmr->iova;
+	trace_xprtrdma_mr_map(mr);
 
 	*out = mr;
 	return seg;

