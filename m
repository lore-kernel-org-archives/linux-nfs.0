Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5651C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:40:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 854CE2133F
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:40:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="W0Q4OpgB"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727771AbeLQQkl (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 11:40:41 -0500
Received: from mail-io1-f67.google.com ([209.85.166.67]:38471 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2387905AbeLQQkk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 11:40:40 -0500
Received: by mail-io1-f67.google.com with SMTP id l14so10467769ioj.5;
        Mon, 17 Dec 2018 08:40:39 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=z+FAU7x0pu2cR4+7sT5Y8flHVTgOYIrNWNeq22LHUsc=;
        b=W0Q4OpgBomIWa8/yt+XPFn+k18aeQAjSnHBDgNZRoeL9q34XgokBa2PsLfpDiZPkqF
         k6QSWBM96P4mxHMoKG84CZKKbwuQkt2LE3LMVHkSv1TaYaEpzqESETYlWmy4lg3ak6so
         qrMHDSUF/6LwIEKv1VP3vx73LvwxStUV+ZEv8AxT1OE7Jklw9VACGH4st3kcqPT4gY53
         E5jBJ51kXbSFscW79EWXXKY2wyYakDO5+//yXk83HYwokBmGaQjim24PzFbxUc/D3580
         62vnQoaRA3geEwK9yjqQM9qkjit+LUWtc4paiFO2u4XV7URuWmRrDwdseWr+t2o/6H5q
         rEAA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=z+FAU7x0pu2cR4+7sT5Y8flHVTgOYIrNWNeq22LHUsc=;
        b=f0JaUUsOc6jzSdUFTV45r1H17rDNbzq+FUCVJnHFML6mad2Ue18tWfIMeR1t1khfaR
         eqPL+Z/izrB8bVOnPT0U2+duSG9VVch7dWHRbLGcoJAc4L4yumpr5n3MVmsN6bhJatlC
         JLMMeRGTloMEbgsKRTv9rlVLsUZzz3Tyuo9+mvZ2mmTh464+tz5HIPnrlWfTzKI4YKrv
         5EF7NOT4CPEq4pq3WRAfOVVY1FNj9E/iZnf3u71ymbtlzfEkgddImq/g7quBNVMIo549
         TpfneyluE4sJbEhoyLHZIZR6qy4WXToB2bf1p6vVlYqFu2Fwk6+Q7sTB6VKBNIKPXYex
         xmtg==
X-Gm-Message-State: AA+aEWYIzc03fS1ZIbpqmTN4GuYf/3Jeg8gKBgvzTFE/ZpbY14G6NMql
        CuGftMmPhRY7BGs+2qvnB968akGz
X-Google-Smtp-Source: AFSGD/WifFqsJA64UpgjvLHBgd4uU2B73LEVIcNkqZKFXzz5G2PIFm3a0CXBg5wrofBfLcyrj6n9DQ==
X-Received: by 2002:a5d:9341:: with SMTP id i1mr11375086ioo.162.1545064838279;
        Mon, 17 Dec 2018 08:40:38 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id o63sm7894475ita.8.2018.12.17.08.40.36
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 08:40:37 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBHGeajD018620;
        Mon, 17 Dec 2018 16:40:36 GMT
Subject: [PATCH v4 14/30] xprtrdma: Remove request_module from backchannel
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 17 Dec 2018 11:40:36 -0500
Message-ID: <20181217164036.24133.28066.stgit@manet.1015granger.net>
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

Since commit ffe1f0df5862 ("rpcrdma: Merge svcrdma and xprtrdma
modules into one"), the forward and backchannel components are part
of the same kernel module. A separate request_module() call in the
backchannel code is no longer necessary.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/backchannel.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 5d462e8..9cb96a5 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -5,7 +5,6 @@
  * Support for backward direction RPCs on RPC/RDMA.
  */
 
-#include <linux/module.h>
 #include <linux/sunrpc/xprt.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/svc_xprt.h>
@@ -101,7 +100,6 @@ int xprt_rdma_bc_setup(struct rpc_xprt *xprt, unsigned int reqs)
 		goto out_free;
 
 	r_xprt->rx_buf.rb_bc_srv_max_requests = reqs;
-	request_module("svcrdma");
 	trace_xprtrdma_cb_setup(r_xprt, reqs);
 	return 0;
 

