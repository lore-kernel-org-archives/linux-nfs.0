Return-Path: <SRS0=ULVj=QS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90DA5C169C4
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 16:25:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5DF39218F0
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 16:25:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="uuxDZC7y"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728819AbfBKQZo (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Feb 2019 11:25:44 -0500
Received: from mail-it1-f194.google.com ([209.85.166.194]:54161 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728664AbfBKQZo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Feb 2019 11:25:44 -0500
Received: by mail-it1-f194.google.com with SMTP id g85so27766806ita.3;
        Mon, 11 Feb 2019 08:25:43 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=WasZ4ZCsfD0lpf1GgLDmIamXjZPOzY6aKnXZuu80OGA=;
        b=uuxDZC7yQZdhWsOySuGQ79axWg8RkyRhiO7r4Y3pASMLOhP7pWNTTbAWj1YCiAPuBL
         TUOLoC2pJJsL9ZwQ50CDj9caO8+9n14v89s/UoBckC74qakfS24G/8zm5g35kts5B6DD
         maY3k505vQU0g+Vjw5sIZUZAKo4Vi315qi2RhBNy1GABDTuDtMk+v3a8knyPJ11bndNx
         Nw1Z8QNgwE0XIAsIEk5GevHHMcfH/g6bisue94Y5jsSnzQ8gmyecH7XXJD1fG00zGmxo
         WVeBSkld11aq3V2ioC5wSndqprOrViZ2d11rhpgYQ+wXsw4iw1x1uFLIqrnVYXEE1srC
         znBQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=WasZ4ZCsfD0lpf1GgLDmIamXjZPOzY6aKnXZuu80OGA=;
        b=Zsw+vxnz1wzdnIngoVwXh9dckjW4b/iT/c70byZof4qbKs5FTLKvqig+yvY4jJmqw+
         HtFl525/d0K0HhX07iuz9xm/L2M37vS/KE7cWJj7cElRSpJlxciLg1yOiAoX63gJ+p0v
         2+CVfH9Sh1rIBMqoGdjTcupVPre7y0rnNaKjACDMkgUkhvosCQJAG3NAvuZj8xuHx3Ba
         fhdLvL5HGLVwwy1ncQxBy3IUXHlLSaU0t/dVmkT8/nWFwhDnZJ3FgjPWnEYIPbj3iI2q
         S9FwEfto68ps2b1CiVKf70hgxBphLu0B46I7WTU+lNh8IS2CZOJk8icsDuw+ZJgQ6Q1d
         XFkQ==
X-Gm-Message-State: AHQUAubIHSj0P+K/B7kYPveGRUmOkl5WUnnu3seCiQ9w9289k1du4CqW
        r6xXz4ArIEqN24UNiUE2BdAqL+V7
X-Google-Smtp-Source: AHgI3IZ3tzvrgkn4Ic60lWIO1+hiMZXnRCVTDmCbOGbtiCBOUMHBZaXqCPxyUGFtSZyW8EDMJ+yhvA==
X-Received: by 2002:a24:b003:: with SMTP id d3mr203182itf.55.1549902343288;
        Mon, 11 Feb 2019 08:25:43 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id m81sm5406466itb.43.2019.02.11.08.25.42
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 08:25:42 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x1BGPfHo030021;
        Mon, 11 Feb 2019 16:25:41 GMT
Subject: [PATCH v1 23/23] SUNRPC: Use au_rslack when computing reply buffer
 size
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 11 Feb 2019 11:25:41 -0500
Message-ID: <20190211162541.2817.96724.stgit@manet.1015granger.net>
In-Reply-To: <20190211161920.2817.20881.stgit@manet.1015granger.net>
References: <20190211161920.2817.20881.stgit@manet.1015granger.net>
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

