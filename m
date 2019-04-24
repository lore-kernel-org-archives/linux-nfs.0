Return-Path: <SRS0=08pM=S2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70A14C10F11
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:39:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 40C5021773
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:39:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="L30G/Jef"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727919AbfDXNjC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Apr 2019 09:39:02 -0400
Received: from mail-it1-f193.google.com ([209.85.166.193]:51209 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727112AbfDXNjC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2019 09:39:02 -0400
Received: by mail-it1-f193.google.com with SMTP id s3so6368764itk.1;
        Wed, 24 Apr 2019 06:39:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=JKd9iNK2TVT0ttMrh4M0Vr+V0PaJkHGg3Qk02sk8z34=;
        b=L30G/JefT8lzlyB8heampWQ5gWK3xgyIJ6dwwM6Bo4EzRB+cg6xqqyL5ErT4zSiag2
         t1d1CsSaTVJHTkVqXdXDwZ83Xw3dfan0Oz0OCPQzZ+m18v9NNrKKdFsFMDfv4FB/v9HM
         UIjItxtDsOw+igOk6G6QKQVtvrR4fBhoBzr2Fa9jNr4yVyirEEQDLTfnVBQG97HgGMGP
         TQ/b6tjPvnR7y6DiE7dc3NnlJf5m605Nnl4WTvd5ovjH97ldK98Lsh8I/Y3gav7NAK4D
         ZiEJQe9YBOpYBmZxBIbHdz6CK5phwKvdhTcChxZD0FZpRJTaIUnh+Dqy9Wwr0gzH9jY7
         isvQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=JKd9iNK2TVT0ttMrh4M0Vr+V0PaJkHGg3Qk02sk8z34=;
        b=Gdzh0DHNZ1aGhDTkX4Yvc39I8LZPL87yAciIBiV25M6CpYUI6+Oa5UpXRJuVahHnpm
         PfRFZCZuLzzxex9vYBYelI5kr4VT6LlqPVShrjkykla8cMaFJI9aSdzaF9El5SkyYmV5
         NYTHL8fX/PxDdgvwF6xbU+/mY7U1DnaeUjUvNTC//qvH78gOuwTDk7W28oEDOdCP0q8s
         kZk/vWGbb7BxL1plYjF2tf0Aq3A9RZtZoJWsvxSsk5sq+2S7p9c5tzUn3njj9ETRcY07
         7uOyLqJaOal5CO69K5I0IAW9eOU+b/D7a2qAnZ6oYE2olHvxs2OfSQreJLlH2fnj5o0c
         iokQ==
X-Gm-Message-State: APjAAAXQ1+rnSzScDu0QjxMk8MTG/mmN+kLu6rLky3oqPSoZkZdcuLDm
        LlidXFNkRQ203YoLsvg8MYI=
X-Google-Smtp-Source: APXvYqywyQMWhuvnLbXcssS/Sk7COknlTNplrzIaOWruE54AuNkxkZRBpfgUfUtgIgH7BoZEWdBZig==
X-Received: by 2002:a02:896:: with SMTP id 144mr21610819jac.53.1556113141805;
        Wed, 24 Apr 2019 06:39:01 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id o16sm5185607ioo.45.2019.04.24.06.39.01
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 06:39:01 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3ODd0di011274;
        Wed, 24 Apr 2019 13:39:00 GMT
Subject: [PATCH v3 02/21] xprtrdma: Fix an frwr_map recovery nit
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 24 Apr 2019 09:39:00 -0400
Message-ID: <20190424133900.5077.23949.stgit@manet.1015granger.net>
In-Reply-To: <20190424133516.5077.67283.stgit@manet.1015granger.net>
References: <20190424133516.5077.67283.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

After a DMA map failure in frwr_map, mark the MR so that recycling
won't attempt to DMA unmap it.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Fixes: e2f34e26710b ("xprtrdma: Yet another double DMA-unmap")
---
 net/sunrpc/xprtrdma/frwr_ops.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 52cb6c1..a2a2e01 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -466,7 +466,7 @@ struct rpcrdma_mr_seg *frwr_map(struct rpcrdma_xprt *r_xprt,
 	return seg;
 
 out_dmamap_err:
-	frwr->fr_state = FRWR_IS_INVALID;
+	mr->mr_dir = DMA_NONE;
 	trace_xprtrdma_frwr_sgerr(mr, i);
 	rpcrdma_mr_put(mr);
 	return ERR_PTR(-EIO);

