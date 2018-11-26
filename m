Return-Path: <SRS0=idK9=OF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B45DC43441
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 20:06:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C584A20672
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 20:06:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IDU42A5H"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C584A20672
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727114AbeK0HB0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 27 Nov 2018 02:01:26 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:38634 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726296AbeK0HB0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Nov 2018 02:01:26 -0500
Received: by mail-it1-f196.google.com with SMTP id h65so29944373ith.3;
        Mon, 26 Nov 2018 12:06:12 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=Im06Smg/oOSgSAOJJVFfR0OiJ6nn5vpSYwuHFHeZSUo=;
        b=IDU42A5H/98m0eGlUHnAgo5FPQsjBWaqjrA0cK36h4CsvSOavHnLWHSTzbQfSejvCk
         4fSVhVUAyf73Nk7+qH8phbAiSZ+MnA1uU1z0h0V6W1YSfVjDMGf6c4u98W5TJJN2wxHc
         cO8Kf0K9KyFa27RfhXtZKtD6+8+URUhtiRWpJ6Z4lNuRMW23TpeePZJuxK7OR2zs50Cq
         +ZFjdrtIRscGgEIP5nVpjGoBn/6ZE6gECF9gr0Yu1gp7KN8uHS/x4wxUSv0xClH3y+qt
         rz8ph6DbRM3JVGaORKG/LYR5nu+ziMhaSDD9MjaFReG8yA7t51axrH8GB5BeygqAHjnH
         ZhKg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=Im06Smg/oOSgSAOJJVFfR0OiJ6nn5vpSYwuHFHeZSUo=;
        b=SSW+PLcSL03NvNJjbKvTuiJG8Uz4mD3ejHKvKLBhGNFmPSlo0owc0clFZDNwy+BkK7
         FyU8HuIBdeZwlltQA/6BrSaCkWgh8dD3gv3gKfSHmmMep8FyC/iqFYw2c7puo1mvE8aB
         NfGeNJ1oJ94ztwN49gAJaeuxfaxwKxvMq/bege+HXhmUsfpnhXRPgf+eD61jFGns6luu
         9ncNjifXreBYK85gr+sH3om/mr1yt5b2pbie9x5O8KnBDQA6lhYv5kfdJSToC02lKpOI
         xm+aDXY5l4r+JiTgs5OWi6m6s5wk1eQ1OeZEiFyMxR0HvlKuAqYvdgRlsnReG83SeMR9
         HlYg==
X-Gm-Message-State: AA+aEWbqVFts1jruWnKv+iqwwtsg2nghL5Wlj30xd/XIhKVemml3Z/4q
        EUQMmhXHRvPKYIKpvdJeza0M5KA5
X-Google-Smtp-Source: AFSGD/V4jOcAcYBcK4sbchcwMTocVWislyKWtzRkAinetyqw5/ik6Zyh2HB1sC5oLGmuQgDNGrKhuw==
X-Received: by 2002:a24:7094:: with SMTP id f142mr2525780itc.90.1543262771352;
        Mon, 26 Nov 2018 12:06:11 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id l2sm449408iop.26.2018.11.26.12.06.09
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 12:06:09 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wAQK68oJ010654;
        Mon, 26 Nov 2018 20:06:08 GMT
Subject: [PATCH v2 04/20] xprtrdma: Reduce max_frwr_depth
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 26 Nov 2018 15:06:08 -0500
Message-ID: <20181126200608.10321.50608.stgit@manet.1015granger.net>
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

Some devices advertise a large max_fast_reg_page_list_len
capability, but perform optimally when MRs are significantly smaller
than that depth -- probably when the MR itself is no larger than a
page.

By default, the RDMA R/W core API uses max_sge_rd as the maximum
page depth for MRs. For some devices, the value of max_sge_rd is
1, which is also not optimal. Thus, when max_sge_rd is larger than
1, use that value. Otherwise use the value of the
max_fast_reg_page_list_len attribute.

I've tested this with a couple of devices, and it reproducibly
improves the throughput of large I/Os by several percent.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c |   15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index ae94de9..72c6d32 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -191,10 +191,17 @@
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

