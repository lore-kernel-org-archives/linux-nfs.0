Return-Path: <SRS0=AtwM=YK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00A76FA3735
	for <linux-nfs@archiver.kernel.org>; Thu, 17 Oct 2019 13:05:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CADDA2089C
	for <linux-nfs@archiver.kernel.org>; Thu, 17 Oct 2019 13:05:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nGV+SDNs"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2394098AbfJQNFy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 17 Oct 2019 09:05:54 -0400
Received: from mail-qk1-f196.google.com ([209.85.222.196]:39275 "EHLO
        mail-qk1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2390908AbfJQNFx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Oct 2019 09:05:53 -0400
Received: by mail-qk1-f196.google.com with SMTP id 4so1762149qki.6
        for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2019 06:05:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=f4CXZMOsoJLn43utTVJO4GHlgyGENzJaiSYFpXxAT8U=;
        b=nGV+SDNs6c7kqY5bYEYi1+P1IM+QIeYMu8M7yIFHipJ4ndTStOYuOmDOSeU75VgJG0
         OA25zNEXJHHpQj6AYfRANB8Qy4OMuBoUbGYpahEKR4BZPOnv7WkfAf1BSRAedWWCyskj
         jTEWL6qLep64ZMtZOtZB37bRvl4f5naabBPfS+Of2cvzyVunmDM+OD+lIte9nL3YHjtg
         Jd0asTydgEwF+tAw373lt1IkxQId/3YbrMlN7BFuhen+MeabQFq2wmbt4t1D1pJ4sS+A
         xCRxHdK0CQOebDTL+kcYCM4RjUQ+jTIFNPxqPO2aZ1dgQwCIseQ2HxYg6TEyymbTssVG
         sRiA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=f4CXZMOsoJLn43utTVJO4GHlgyGENzJaiSYFpXxAT8U=;
        b=mxfCFkEDggeSVu8g5Z6qG2ujlGUBL9AR9yZBovoa5Q1Evpk4SUIgkpXqOyv0mDzOeT
         GjLwpDTxVNZHRuJZdai09ATM8ZUJZ7HepgpJalqS3ULV6/bapUdJg6ZVcBWcjjdru6wP
         Wy9TWO0/1EJYaHnuZ0yZh5blYzxfzsCElZ+IQ2aUkCZcDV0Ll6VFkWljDwN/KKU29V/I
         qA/169p9WgCQ5swHFnOhYDFOgMqCwEzqimIlyS2efCad+4kMU/kjLl1gIkSmUR4DcG7S
         VT+Cce6w2vdf++bq+sKK6IbVEYsjvD8TyOWml7XzRGJAG8aiz+aImwOuvqbZgbIglZXt
         8UrQ==
X-Gm-Message-State: APjAAAWqv8ooLmI5sXJ3eUzEEzjXC6RM3nvmfdy0bQWz8p5m9PEpnRxq
        xfFQQZ16Nga0O3JMpwIndDu40cw=
X-Google-Smtp-Source: APXvYqxDRGHaksQ7+L/7M3KkJAz03XoN845IWvOwmf/0VrMR6pWDcGdn1DsemF3z1/nIl+cbGIybZA==
X-Received: by 2002:a05:620a:b07:: with SMTP id t7mr3079994qkg.382.1571317552337;
        Thu, 17 Oct 2019 06:05:52 -0700 (PDT)
Received: from localhost.localdomain ([66.187.232.65])
        by smtp.gmail.com with ESMTPSA id g194sm1326648qke.46.2019.10.17.06.05.51
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 17 Oct 2019 06:05:51 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Cc:     Neil Brown <neilb@suse.de>, Chuck Lever <chuck.lever@oracle.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH v2 2/3] SUNRPC: The RDMA back channel mustn't disappear while requests are outstanding
Date:   Thu, 17 Oct 2019 09:02:20 -0400
Message-Id: <20191017130221.7924-3-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20191017130221.7924-2-trond.myklebust@hammerspace.com>
References: <20191017130221.7924-1-trond.myklebust@hammerspace.com>
 <20191017130221.7924-2-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If there are RDMA back channel requests being processed by the
server threads, then we should hold a reference to the transport
to ensure it doesn't get freed from underneath us.

Reported-by: Neil Brown <neilb@suse.de>
Fixes: 63cae47005af ("xprtrdma: Handle incoming backward direction RPC calls")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xprtrdma/backchannel.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 50e075fcdd8f..b458bf53ca69 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -163,6 +163,7 @@ void xprt_rdma_bc_free_rqst(struct rpc_rqst *rqst)
 	spin_lock(&xprt->bc_pa_lock);
 	list_add_tail(&rqst->rq_bc_pa_list, &xprt->bc_pa_list);
 	spin_unlock(&xprt->bc_pa_lock);
+	xprt_put(xprt);
 }
 
 static struct rpc_rqst *rpcrdma_bc_rqst_get(struct rpcrdma_xprt *r_xprt)
@@ -259,6 +260,7 @@ void rpcrdma_bc_receive_call(struct rpcrdma_xprt *r_xprt,
 
 	/* Queue rqst for ULP's callback service */
 	bc_serv = xprt->bc_serv;
+	xprt_get(xprt);
 	spin_lock(&bc_serv->sv_cb_lock);
 	list_add(&rqst->rq_bc_list, &bc_serv->sv_cb_list);
 	spin_unlock(&bc_serv->sv_cb_lock);
-- 
2.21.0

