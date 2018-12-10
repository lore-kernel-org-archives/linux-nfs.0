Return-Path: <SRS0=PHUf=OT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F31BC5CFFE
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:30:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D6BCE20821
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:30:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="MRp88nRq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D6BCE20821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727705AbeLJQaJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Dec 2018 11:30:09 -0500
Received: from mail-io1-f67.google.com ([209.85.166.67]:46586 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728348AbeLJQaJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2018 11:30:09 -0500
Received: by mail-io1-f67.google.com with SMTP id v10so9187201ios.13;
        Mon, 10 Dec 2018 08:30:08 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=el4Nj6sOeMgctzOMmva52oktZLjjXXpFVluGH5FPJik=;
        b=MRp88nRqymCceNHe4tikl4DkawtCO3lX9MRQa0eG4974X4r1nNs/hfYPN43xTu0/xx
         kofOjv5xn67Jyx7x68phAAg/gDtpm2kCziN3YSBIxUkTSpqOtvXC5102xrWldBKhu37M
         ltJvfWL3A1us0GgPlNJ+v3iptopJTJRfAIfCBZK3mE8y0qdA19bcEuAV6dOqFPxAVm+Z
         GkrdJ7aYLT4Fbd+pMXGH7oGKb6g/G1i4eJrvfQdT26b1111nR+KWiHDDbvyAZZ/3GpwE
         VH1RwrQpTOhqBl+kGhP2JbwZVfFqmU+jqyhQr/RSkLaOddEfDEcdwfp/lZ7V/aoUnsAy
         aoaw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=el4Nj6sOeMgctzOMmva52oktZLjjXXpFVluGH5FPJik=;
        b=VXJS5UMC/WSxQaHJL5ybsNjiHm5FY26ndnIHs2E5fGIBpjM022cUgJ6cn93DQJekwZ
         jwTu2o0cU/5SP7ifTxCU2VIUYvGsZslb0StTkWNE2I0BnzszSXBNHIyqUu+n2hetAHm4
         qc8xvdgfzFMGvz9oD43qryk3OoPkTQoSnhPqPG4djSL6JfAJpeLy91JOhSWddxEkKVUX
         2yjPoBWzAMjU68lbkLJ8yftYRCUQh/viTB/sA10XOTCn0enovuZnikx0Vq42Tu7wmVKZ
         U6R8TCsIKNyVRC/7IGsUEtJhJsAHrJpNV0YwJmZFBmoFtH0dfpkdlaBBoMHOUzCWNoNf
         209A==
X-Gm-Message-State: AA+aEWbYgIcr5ezCIAVL0KVXEyRfRrgTXuGJ+qEpXl6PI0oztvuAP7cz
        yII6+3MOIS++lRL4dAwKydQ=
X-Google-Smtp-Source: AFSGD/WBC4hMeo73/KiJi1m82J4a8TgzSKS2G9NKI+JaGtc6BWvNA9fIUqzXd8g83C5q5S+yZfymLg==
X-Received: by 2002:a6b:b556:: with SMTP id e83mr10725942iof.195.1544459408352;
        Mon, 10 Dec 2018 08:30:08 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id 79sm6822229itx.11.2018.12.10.08.30.07
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 08:30:07 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBAGU6gJ031049;
        Mon, 10 Dec 2018 16:30:06 GMT
Subject: [PATCH v3 09/24] xprtrdma: Expose transport header errors
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 10 Dec 2018 11:30:06 -0500
Message-ID: <20181210163006.4198.79039.stgit@manet.1015granger.net>
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

For better observability of parsing errors, return the error code
generated in the decoders to the upper layer consumer.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 601dbe5..2bb9052 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -1249,7 +1249,6 @@ void rpcrdma_complete_rqst(struct rpcrdma_rep *rep)
 out_badheader:
 	trace_xprtrdma_reply_hdr(rep);
 	r_xprt->rx_stats.bad_reply_count++;
-	status = -EIO;
 	goto out;
 }
 

