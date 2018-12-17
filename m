Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4EAAC43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:40:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 733EF2133F
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:40:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EPyE7XPV"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388263AbeLQQkH (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 11:40:07 -0500
Received: from mail-io1-f68.google.com ([209.85.166.68]:42439 "EHLO
        mail-io1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388108AbeLQQkG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 11:40:06 -0500
Received: by mail-io1-f68.google.com with SMTP id x6so10450074ioa.9;
        Mon, 17 Dec 2018 08:40:05 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=fZt2sJtHBzkz3cxTvQxkd76ytJ2+vEepYSr4HQtV1IE=;
        b=EPyE7XPVhbv4ZEcl02tSgznq7tnu2gPrag8Dx0BDasZXbprzCoUkldrSKYv0wkyAaL
         WW3fVlkVoIYGdA1c/CjcO76S89DXnJUQbsfMnwnLeL6VL+tyyV5W3N7BykGyM72iglcv
         mgSpzBIIOm00DUBfNdsDJtc1NChtEAJFR5SsPXnNSVq3L77J85MO6sp3YCn80PVj9xDf
         9ZxNJtpvUSOyd4oit1HWPFPbWoNsvua1euWxgVg4tOgkRcFQbIUxaqgT2qwH2mJ1ZsB+
         HI6seIanCU3/zwwGkPHCF2zSnd0OHmBJQQYVGc9u7/wLukzosxMvmNtuMGOk6/qwsnh0
         2phQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=fZt2sJtHBzkz3cxTvQxkd76ytJ2+vEepYSr4HQtV1IE=;
        b=SQbvKyyXAH0M14elpP9TEHKAVznscKwVUGCb86S9W4ZyuSupg396FR2wYA7exatwK4
         PIWYmF+CdEiRhEUPcdHCethNcr4UTfA0MQJEGz1rSv3NdioUvdxeHQbzI5cSpwXdWWj+
         fxsT+f0YYh9IH4KBHr0QqaHILPCqYlNjZNRNTxEi2iswibbsJEcLxtw3C7+yS+Kg7dyx
         HxpIXuVoIJMe8LJWYuRQQVHhaxOQ/DH/5dSh12+/KJ78rr77YEy3HQWCUK/hRYky98TR
         GHOQnvvq3pQ0WpcvCw4nxKLYGZuEcCKn5dXkyyabFibEgfv0CfQqB2MonpkVSxEhWxpi
         jzvg==
X-Gm-Message-State: AA+aEWbp+eTdlUSclLTY6uojzlTV2LP1zkCkS6V4i9WrkIVksfubVkfe
        fM/ZVWs7Xj+3bZZXh0LVzsxRFU32
X-Google-Smtp-Source: AFSGD/X+zmFU3r6RDu9TjmyTfjZmzr31UrqtDd4ZrQbLnaVqxLw2TMchvMhSQxQgd5a055IXyKJtMg==
X-Received: by 2002:a6b:b8c3:: with SMTP id i186mr11006380iof.8.1545064805328;
        Mon, 17 Dec 2018 08:40:05 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id j1sm4953119iok.79.2018.12.17.08.40.04
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 08:40:04 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBHGe4bA018602;
        Mon, 17 Dec 2018 16:40:04 GMT
Subject: [PATCH v4 08/30] xprtrdma: Reduce max_frwr_depth
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 17 Dec 2018 11:40:04 -0500
Message-ID: <20181217164003.24133.23440.stgit@manet.1015granger.net>
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

Some devices advertise a large max_fast_reg_page_list_len
capability, but perform optimally when MRs are significantly smaller
than that depth -- probably when the MR itself is no larger than a
page.

By default, the RDMA R/W core API uses max_sge_rd as the maximum
page depth for MRs. For some devices, the value of max_sge_rd is
1, which is also not optimal. Thus, when max_sge_rd is larger than
1, use that value. Otherwise use the value of the
max_fast_reg_page_list_len attribute.

I've tested this with CX-3 Pro, FastLinq, and CX-5 devices. It
reproducibly improves the throughput of large I/Os by several
percent.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c |   15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index f587e44..16976b0 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -193,10 +193,17 @@
 	if (attrs->device_cap_flags & IB_DEVICE_SG_GAPS_REG)
 		ia->ri_mrtype = IB_MR_TYPE_SG_GAPS;
 
-	ia->ri_max_frwr_depth =
-			min_t(unsigned int, RPCRDMA_MAX_DATA_SEGS,
-			      attrs->max_fast_reg_page_list_len);
-	dprintk("RPC:       %s: device's max FR page list len = %u\n",
+	/* Quirk: Some devices advertise a large max_fast_reg_page_list_len
+	 * capability, but perform optimally when the MRs are not larger
+	 * than a page.
+	 */
+	if (attrs->max_sge_rd > 1)
+		ia->ri_max_frwr_depth = attrs->max_sge_rd;
+	else
+		ia->ri_max_frwr_depth = attrs->max_fast_reg_page_list_len;
+	if (ia->ri_max_frwr_depth > RPCRDMA_MAX_DATA_SEGS)
+		ia->ri_max_frwr_depth = RPCRDMA_MAX_DATA_SEGS;
+	dprintk("RPC:       %s: max FR page list depth = %u\n",
 		__func__, ia->ri_max_frwr_depth);
 
 	/* Add room for frwr register and invalidate WRs.

