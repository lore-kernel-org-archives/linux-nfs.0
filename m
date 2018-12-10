Return-Path: <SRS0=PHUf=OT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7DD2BC04EB8
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:31:15 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4226420821
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:31:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gxquQiMQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4226420821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727014AbeLJQbO (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Dec 2018 11:31:14 -0500
Received: from mail-io1-f68.google.com ([209.85.166.68]:36047 "EHLO
        mail-io1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727496AbeLJQbN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2018 11:31:13 -0500
Received: by mail-io1-f68.google.com with SMTP id m19so9256240ioh.3;
        Mon, 10 Dec 2018 08:31:12 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=Lj75kgMT3bnmCqsU8RuwA22CewYrMg/AAfBF9REfKnA=;
        b=gxquQiMQuLDa+fUigMyV8TYFUwNkvlwJh8YctSOuKdu55B5TmrqyXqLhHppH6bUntE
         ftp+onfXDV2cazR3EhkJWAhJoF/aPSIjjQTT0IBnKi/UYAraFHfoYhrutdqUyrCm0nGZ
         n1xP1aMry1Pi9/vjPRTk1ryjVBABTrFIJcJ4pVCI6KL+oLn8KW/1/ei0xe4P5QF5M7r5
         PWrdo4qIxO3wD6123b9ZUV48Y8qff8zY06tmZH14/p26ItoMjXyE+t7CjyK/KVQLIGGJ
         X6OB7mrlMj5deoZai40nB8iaDSN73PHt6M2e4sbNP6UlmpR0pSZmV0HanFgg1ERLShoK
         dPrA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=Lj75kgMT3bnmCqsU8RuwA22CewYrMg/AAfBF9REfKnA=;
        b=bWAg2Ie8Txyesy26Yq2Nhy0Xnr0Dl4l6jzJRkitkeuhRlI8l1J36IfRxWXIaHROz5W
         fqb5mv5VJxAYYISLxqzaacMrnd601/2qtdMOdFlmuInwXNbliFWiXFM/qDTwU9C3Aa0P
         qrjwXea65HdyJTosijUnN1DuU00u7/kncdfC6fI/Uxc85MzRRtJQc1Uk2NRaivOZJ2Ul
         KJDPx5fc4Cm1gKMCFRuVFQggydOE+uZDDXLaMV3P4BV/jbtiSZIP/mThj3rD4sMco9wr
         47kQGd42Q18yWPIhOm3/bBPFPLXRcy92GaerBGIWQ3P2yxr+WAcLTKfsMXGwEpvbgoP4
         YtOA==
X-Gm-Message-State: AA+aEWaFF1TP7R0ICey8tl7tteS639BHUvGeN+iyVUdZaeVWO7o88OWi
        acMkNNReR/7sT4CKx6tJ03UhikDy
X-Google-Smtp-Source: AFSGD/UU6mil6XrtpCF9PEo+oX7tXnMydNNtaSN9WzUo4C1mfWNOWSWwPlIgvkaaX26Rp2fr9p7x6Q==
X-Received: by 2002:a6b:6309:: with SMTP id p9mr11215026iog.203.1544459472364;
        Mon, 10 Dec 2018 08:31:12 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id r139sm8023308ior.53.2018.12.10.08.31.11
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 08:31:11 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBAGVB0M031086;
        Mon, 10 Dec 2018 16:31:11 GMT
Subject: [PATCH v3 21/24] xprtrdma: Update comments in frwr_op_send
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 10 Dec 2018 11:31:11 -0500
Message-ID: <20181210163111.4198.30167.stgit@manet.1015granger.net>
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

Commit f2877623082b ("xprtrdma: Chain Send to FastReg WRs") was
written before commit ce5b37178283 ("xprtrdma: Replace all usage of
"frmr" with "frwr""), but was merged afterwards. Thus it still
refers to FRMR and MWs.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 529865a..42a18a2 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -432,7 +432,7 @@
 
 /* Post Send WR containing the RPC Call message.
  *
- * For FRMR, chain any FastReg WRs to the Send WR. Only a
+ * For FRWR, chain any FastReg WRs to the Send WR. Only a
  * single ib_post_send call is needed to register memory
  * and then post the Send WR.
  */
@@ -459,7 +459,7 @@
 	}
 
 	/* If ib_post_send fails, the next ->send_request for
-	 * @req will queue these MWs for recovery.
+	 * @req will queue these MRs for recovery.
 	 */
 	return ib_post_send(ia->ri_id->qp, post_wr, NULL);
 }

