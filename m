Return-Path: <SRS0=xyvj=N6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18B0CC43441
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 15:46:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D1FC520851
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 15:46:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fBhGrfOs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1FC520851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729815AbeKTCKC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 19 Nov 2018 21:10:02 -0500
Received: from mail-io1-f66.google.com ([209.85.166.66]:40226 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729795AbeKTCKC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Nov 2018 21:10:02 -0500
Received: by mail-io1-f66.google.com with SMTP id n9so2747149ioh.7;
        Mon, 19 Nov 2018 07:46:04 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=HqcODX+A1n2pydPjdkQVsTZzJlH1leSrrjE43zovOZ8=;
        b=fBhGrfOsw3RPcMc5ddbgYc9cwugeB3HkoeAzXuC0P5XZPxJXMbCFlB8AYVc/MFyhBf
         nstfylena4hiYGhtQX3YnN0LNyyeX3Ia6GEHlZOfkrDd4Kk2J9ZOLkOPTcFpUFGbGejM
         dnqVBt2qi7U4HIzf6SKSz0iLT80ik8k9t16NA/IA70+ikkd/KhjWD13zwW0lF3DnP/OQ
         6bIOuiRqKDqBGcCRKUked2lrjGaLy0Yw+e/XXX3qXN6gvHVYKtStn9AUKH4LV8yKKqWT
         1QCn6qG5bmxekD83QsZF2Jrofmra+Bdx/iMvG2QFASIjtY2Akkg8BOPv+MCn1XAINFo7
         TuDA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=HqcODX+A1n2pydPjdkQVsTZzJlH1leSrrjE43zovOZ8=;
        b=JVu4Jgi9lBbluO1EIEHOUXrcibjnExkcftRfx5wivayxsKK/tuoHj8ESSnrXlYx1Z6
         SHs4J8mul+L4q0StQICrVepyiW0FY0kaVDU/UpGS38haQFXrFd/c1yK0CINtHm2dPmDK
         Cww6T6GGXdbN7DrhC/eHADS+1F4Htrkw7prnlBPE4fUo8ZxoDoBJrnNoA762kA3vdvHP
         UnA4FcPaIiPEB4L6PkVA5SpRrNfRamd1q03Xb8y5/E/RQCRhV1WygfW9PlSQAYAUbLPl
         S1SkuHxkDdxrioX9HlgNp5xGGKm4b0XpN0xFrt4So03fXteNM/HnEpBdg/jGr6poAXf+
         sCoA==
X-Gm-Message-State: AA+aEWYG477YLKyDwYZmUTVvduxtJkdpeapRQdtLnnWOhpfFRNF9A0bR
        GhvUwnpSuCKoDBDbDDHOa66N/HnY
X-Google-Smtp-Source: AFSGD/WYfX2LeFVNjq++ESJ1Z9F92NRF+BDKJgpJiBxcp85bdWxdAU5jRxodKnf5yrbcUbAXzt2B1w==
X-Received: by 2002:a6b:930b:: with SMTP id v11mr13571852iod.148.1542642363322;
        Mon, 19 Nov 2018 07:46:03 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id h84sm5371495ioa.33.2018.11.19.07.46.02
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 07:46:02 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wAJFk1nm023005;
        Mon, 19 Nov 2018 15:46:01 GMT
Subject: [PATCH v1 3/4] xprtrdma: Reduce max_frwr_depth
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org
Cc:     linux-nfs@vger.kernel.org
Date:   Mon, 19 Nov 2018 10:46:01 -0500
Message-ID: <20181119154601.10832.97570.stgit@manet.1015granger.net>
In-Reply-To: <20181119153707.10832.42881.stgit@manet.1015granger.net>
References: <20181119153707.10832.42881.stgit@manet.1015granger.net>
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
index 448e063..49b314d 100644
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

