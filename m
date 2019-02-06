Return-Path: <SRS0=RSPU=QN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 644ECC282C2
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Feb 2019 16:37:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3429020811
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Feb 2019 16:37:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nhWaiLpu"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730678AbfBFQhS (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 6 Feb 2019 11:37:18 -0500
Received: from mail-it1-f195.google.com ([209.85.166.195]:38821 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730598AbfBFQhS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Feb 2019 11:37:18 -0500
Received: by mail-it1-f195.google.com with SMTP id z20so7695790itc.3
        for <linux-nfs@vger.kernel.org>; Wed, 06 Feb 2019 08:37:17 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=WasZ4ZCsfD0lpf1GgLDmIamXjZPOzY6aKnXZuu80OGA=;
        b=nhWaiLpucf3xlxuCzsc6YwNrInjqG1kcwo27zXzoH1W0gCVxDF5zLozyn5WlK31JJi
         wslEX+nPaAAIwb9MQ1EXxG8+atlh7EQRvEADQEKpdqK68dPaBLQEf01LnbOY6JG1Sv0l
         fLNqAV9oHi7/uhxdiC3vrECrj6f9vZSQ4WhVgLcb+JuIOODWkk4Ruu1+nsrapOvQ1Bs1
         xmyXUVDBOA5PYqWM/HtNtNE3T4pOnxDnzziWe9gi+cK2u8HydorHvlsgG7c0BbrtiKBl
         OfINKUvrj4/3y6ELlyuf98I0WNywHobWNPjOR7Jtfdu+a2TesllDuZnKCWFjrp61sl0s
         VdTA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=WasZ4ZCsfD0lpf1GgLDmIamXjZPOzY6aKnXZuu80OGA=;
        b=DGxQ5VjNkSHKUyvekuc2P5ydR66pVs2blkb7EZVdiWT5NMoxLKOJLN71U7vot+201w
         9tjcQZDaFrNlhP9wl+xjnzQEJArqU5/2yvlJs7jjYdvA17/Kw9j2syF29McccGPb/kKA
         v1ixVg0LtGgd4i2Qb+GVngK8+XxFjb45NzPaHdCFGENIPggZMaHXTzU4YPjN+4yburVY
         +fgfPtik+wgAedF1FVvldlevZZUDIiQCG4WO41lTJzTYgHyHSQQ5R4axeB/PrIwclx0I
         4F7wwpZ61INOv23WAf0cUCWDAIIJ5RI6Edz/F8KXnaClHVxx4jIkQ9IuXPNrUvSwUlVe
         oXQw==
X-Gm-Message-State: AHQUAube0bmKsJ9teAQI2qdWT8gdHk1qt9fNVdnMKP36Cf7POxdiah5s
        rhDsi8e1sYyG6QeMZayTFTro10Sv
X-Google-Smtp-Source: AHgI3IY3R/aAb1PHDSAnHRXwKpT8Ls8NmP09RZ/QuZ6bPFt5j4VGbupnn5hW4S1HFB3Ty8QudBlUPA==
X-Received: by 2002:a02:1885:: with SMTP id 5mr6420599jar.110.1549471037181;
        Wed, 06 Feb 2019 08:37:17 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id 137sm4144310itm.21.2019.02.06.08.37.16
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 08:37:16 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x16GbFxd015999
        for <linux-nfs@vger.kernel.org>; Wed, 6 Feb 2019 16:37:15 GMT
Subject: [PATCH RFC 5/5] SUNRPC: Use au_rslack when computing reply buffer
 size
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Wed, 06 Feb 2019 11:37:15 -0500
Message-ID: <20190206163715.16810.51300.stgit@manet.1015granger.net>
In-Reply-To: <20190206163256.16810.62516.stgit@manet.1015granger.net>
References: <20190206163256.16810.62516.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

au_rslack is significantly smaller than (au_cslack << 2). Using
that value results in smaller receive buffers. In some cases this
eliminates an extra segment in Reply chunks (RPC/RDMA).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/clnt.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 99bfeb1..241e842 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1690,7 +1690,7 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
 static void
 call_allocate(struct rpc_task *task)
 {
-	unsigned int slack = task->tk_rqstp->rq_cred->cr_auth->au_cslack;
+	const struct rpc_auth *auth = task->tk_rqstp->rq_cred->cr_auth;
 	struct rpc_rqst *req = task->tk_rqstp;
 	struct rpc_xprt *xprt = req->rq_xprt;
 	const struct rpc_procinfo *proc = task->tk_msg.rpc_proc;
@@ -1715,9 +1715,10 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
 	 * and reply headers, and convert both values
 	 * to byte sizes.
 	 */
-	req->rq_callsize = RPC_CALLHDRSIZE + (slack << 1) + proc->p_arglen;
+	req->rq_callsize = RPC_CALLHDRSIZE + (auth->au_cslack << 1) +
+			   proc->p_arglen;
 	req->rq_callsize <<= 2;
-	req->rq_rcvsize = RPC_REPHDRSIZE + slack + proc->p_replen;
+	req->rq_rcvsize = RPC_REPHDRSIZE + auth->au_rslack + proc->p_replen;
 	req->rq_rcvsize <<= 2;
 
 	status = xprt->ops->buf_alloc(task);

