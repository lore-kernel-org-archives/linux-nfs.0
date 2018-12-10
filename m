Return-Path: <SRS0=PHUf=OT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DFB86C04EB8
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:30:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9F90220821
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:30:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qqJKKawj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F90220821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728335AbeLJQaE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Dec 2018 11:30:04 -0500
Received: from mail-io1-f66.google.com ([209.85.166.66]:42317 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728332AbeLJQaD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2018 11:30:03 -0500
Received: by mail-io1-f66.google.com with SMTP id x6so9203696ioa.9;
        Mon, 10 Dec 2018 08:30:03 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=Yg+KpYerdb4ZgC+4/9tk/p+8dDsazTNW2qtu6AT1QBU=;
        b=qqJKKawjw0DHvw2xQySX8ZFDzKwfVTp/4o/VXlOCbXuBK9t4jcBIYLzjaNqUIgIYFO
         sNXSeJSdBMQIh80+9ex+cPtIvibDXh3UJ/Vk+kBYZb2WaMLO0kC8HmaRgkC8lEknYH54
         /iJzWnId3V1ObNTICa570dbjOR/lle7281LFDG/ZheJuC2AvBlnqe/ccM+WIUPrghQNq
         kTdFQe0nWC5tvd+yRPOiOguz4A1/kkMjEmt8JQaR90RV5ParAmHw+siSzDJRHd7F0pO/
         kiBrbiNHaocNMkBxuAq6cz9s6p0EuWbi5M3a92SfX9XcDeeqiV3MP99encIa3dPALqfh
         CN+g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=Yg+KpYerdb4ZgC+4/9tk/p+8dDsazTNW2qtu6AT1QBU=;
        b=Y1/wT7GqSfMXm3DvEjBtv2sL01Z5x9+NB/lRcQ+8WHEJyRSAYu/ZhuM8moIkans7ok
         EEM2K8APUAVY/z7EtQuSGxO0BMZUtoObeldfTMQ7WDAYiBANaaRJE7GSPDJABbcF3pos
         poPuh1JTQeRnAi95YH/cCt34y9A9rEFUxUj0L8FC8yAHfKWbVHjmTWP72/WqKRCmOZ8+
         pCQuP3TSqzZvSQyRkBVK11NDPVj16FNjhwe5uM2Oo6aKYbwTv9Tpp4rK3TBf5j+e4+NV
         u9BlO2ONCCix820N7zMucuJth1rBR2ZxqLrXQSkXLdVs4KFmbClzxhqZZpTgU8VUqG1B
         ufnA==
X-Gm-Message-State: AA+aEWZ1cnk1j4SPPgYhbumTQnF6kaqa5UIkDYk8XA/A8Km0xCce4+oy
        lmFcDgMIEGqEq8dta1sUHFIta5W6
X-Google-Smtp-Source: AFSGD/VINypR2qie8XooKO6IaBr5npGam23V1vO9heaHoOrySpGr/KDZShfh6j/F7u7rGYXRoZybug==
X-Received: by 2002:a6b:b490:: with SMTP id d138mr10285366iof.61.1544459402713;
        Mon, 10 Dec 2018 08:30:02 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id e2sm3616742iok.34.2018.12.10.08.30.02
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 08:30:02 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBAGU1Tm031046;
        Mon, 10 Dec 2018 16:30:01 GMT
Subject: [PATCH v3 08/24] xprtrdma: Remove request_module from backchannel
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 10 Dec 2018 11:30:01 -0500
Message-ID: <20181210163001.4198.40801.stgit@manet.1015granger.net>
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

Since commit ffe1f0df5862 ("rpcrdma: Merge svcrdma and xprtrdma
modules into one"), the forward and backchannel components are part
of the same kernel module. A separate request_module() call in the
backchannel code is no longer necessary.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/backchannel.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index e5b367a..e31cf26 100644
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
 

