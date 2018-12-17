Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 792E1C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:40:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 470012133F
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:40:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OJuXHt7Y"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388108AbeLQQko (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 11:40:44 -0500
Received: from mail-it1-f194.google.com ([209.85.166.194]:53962 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2387905AbeLQQkn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 11:40:43 -0500
Received: by mail-it1-f194.google.com with SMTP id g85so19464174ita.3;
        Mon, 17 Dec 2018 08:40:43 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=PXLIaALci2knYQ1gMtWCij3L4mHSL0l8lqusuVMPb0k=;
        b=OJuXHt7YnmhJdGdCIqGcbzpCJNjAYpPGcIJwtKd5bdAjDQxCvkt6jDAjXkowFA2gqL
         ldC6MNUWnEltASIb/MkIVv4aVIXtXGV034GCultyjJPqHNdZ3Eo5JcQHqdlBPSIhcBgs
         XLXGzTxMHZBbBxNuSPkHi8XFdz9AFJjo4pdJXn24cyvqr7tjROD2G99pnXQWgiqEIaFL
         CgsYaE7uku+4sbWjMPJJ2dMPq8Za/W/ArGwnYA+iUklSH4s2/WNqpzFB79Fq+BOzBZMv
         1Wwma1GlZeJRwQOeHZKzJ91Vt422Yhegm9UDov244/8z4gUD+ewQouwVc4l2hkuUSANw
         AuPg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=PXLIaALci2knYQ1gMtWCij3L4mHSL0l8lqusuVMPb0k=;
        b=jaJ+Aj17PoTOd7X9ntfaJdZxKSmmhGPCuxIwdVmSgcJCqO/rKePOV/yBFCy2D5ECNU
         5w0rF0EIe5+8JoYuD+DNEpADHcdZzBqKHqmL1MVnsam3KydejcQnpP/h1J6VyuBfueIs
         aUYDDMVY2jf5qUMhQNLpFo6IccPNH3jghLueg0om7KVffwZOhL9M68K+Q7A/huZ0bZ/2
         2Wvmq89RIOc6fwj9BExGsfBB+d5FNTmGN5cOGaN+VFZw9JZfwWaj2BLMZ0hqIATahmh7
         VPK7sy2FozxR++Ltl8NYhCs3hToh2QC6wQQ5btYcAxtwcUn1StLRPN92wf8huMoCZGhy
         W2Sw==
X-Gm-Message-State: AA+aEWYmpvrT9mM1O61Bv5yJQhlXPIZlEugNcL+njLnWMgJUgFkd80wm
        dZtrV/XnyWZP0V3+Kdz1zbvp49Al
X-Google-Smtp-Source: AFSGD/XHCFrM7ETvENr7cIroH1sACs3Kx+RsdgCM8OitrcjtUvmMH3oCzwhwbpwsJZkbyrWgRWb0dQ==
X-Received: by 2002:a02:2b2d:: with SMTP id h45mr11068165jaa.75.1545064843028;
        Mon, 17 Dec 2018 08:40:43 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id t194sm6572955iof.3.2018.12.17.08.40.42
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 08:40:42 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBHGeff6018623;
        Mon, 17 Dec 2018 16:40:41 GMT
Subject: [PATCH v4 15/30] xprtrdma: Expose transport header errors
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 17 Dec 2018 11:40:41 -0500
Message-ID: <20181217164041.24133.94561.stgit@manet.1015granger.net>
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

For better observability of parsing errors, return the error code
generated in the decoders to the upper layer consumer.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 939f84a..8de0b9f 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -1246,7 +1246,6 @@ void rpcrdma_complete_rqst(struct rpcrdma_rep *rep)
 out_badheader:
 	trace_xprtrdma_reply_hdr(rep);
 	r_xprt->rx_stats.bad_reply_count++;
-	status = -EIO;
 	goto out;
 }
 

