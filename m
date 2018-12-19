Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99B47C43387
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 15:58:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6B335217D9
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 15:58:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="l8RL7YV+"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728063AbeLSP6Q (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 10:58:16 -0500
Received: from mail-io1-f68.google.com ([209.85.166.68]:41582 "EHLO
        mail-io1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726652AbeLSP6Q (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Dec 2018 10:58:16 -0500
Received: by mail-io1-f68.google.com with SMTP id s22so15968078ioc.8;
        Wed, 19 Dec 2018 07:58:15 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=YnmL2QcytZ7nDWQP0b2qARfKenfoawrMQNmn+bhvVt8=;
        b=l8RL7YV+1UhyA0irxqLHI78jGSt5iWdGjis36YA+akI3D24hgHi/jXUws4Bq6Iq+c0
         gLB5bVjTUhwB28cA9yXuIvNpedtJT25a07CadSNimSDBl4HUAdE+GlcpEHGHnXxS2W/X
         k9zIgZxaMR3i4Mr51p/YS7D69luNccVm85KX8Wp9yl8DpcIBzYNbHfkF990trlMoi71s
         aN1dW9/V7GSdnb49mqsMLqR4zDdSLs+jliLN5kwPxkRAq7P3vV7K/QhVQcrLkMlv9kOW
         kuj0i0Yz8EmzH7c5vhRiI5SbiYIKHkDVhLHN8DGqJ7B3rhSE9Yp0B1c71j5QZtyW0qi/
         gs/g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=YnmL2QcytZ7nDWQP0b2qARfKenfoawrMQNmn+bhvVt8=;
        b=eGER4phQmGmA/yHgD5hW7AmsngDMsCmEOdAKTr8GE8gN4O4hJgxtZbmxztINORPX/F
         q26Xh2eSv1xdNcMvna/fVIEllDQRmms7GmHsttqR9eF6Hfzbh9wvkel4LUWK5BGSq58k
         Y43lnpJhBnpj+2P8JbXupwJLGYrDn9fnWgWgZV8cIJP1f4B8/6ipuIIohT53/MdP1Znw
         HvW4q83wvpHuN/C2LgspKQk4uyTuOWqk+Cf9FlBOnSCOeax+CM7cdWSDZrpcV7Zqb8XL
         yo8bTOhiTCrfaqv1Tza0LssaMPkfDQ0rM5pBy88Qx1HwA9THVQw1OkW1qnNOCZyfFPYb
         fpyw==
X-Gm-Message-State: AA+aEWa/Nle536fJK9RSn093um4JzMwsdSbfMQzEd8+qEW4ClpzfbCEx
        cSfjBOo3B8RKnOdNEeV6MqQ=
X-Google-Smtp-Source: AFSGD/Woxa1yh1tMUIaDCc58GHFMFqUDs1WLhUgmHGG8nkAvGLUnBRKZ3c4epIVcBpAXtMzG6C3ysg==
X-Received: by 2002:a6b:7d42:: with SMTP id d2mr8762309ioq.150.1545235095338;
        Wed, 19 Dec 2018 07:58:15 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id s15sm8890640ioe.52.2018.12.19.07.58.14
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 07:58:14 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBJFwDcq025759;
        Wed, 19 Dec 2018 15:58:13 GMT
Subject: [PATCH v5 01/30] xprtrdma: Yet another double DMA-unmap
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 19 Dec 2018 10:58:13 -0500
Message-ID: <20181219155813.11602.13506.stgit@manet.1015granger.net>
In-Reply-To: <20181219155152.11602.18605.stgit@manet.1015granger.net>
References: <20181219155152.11602.18605.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

While chasing yet another set of DMAR fault reports, I noticed that
the frwr recycler conflates whether or not an MR has been DMA
unmapped with frwr->fr_state. Actually the two have only an indirect
relationship. It's in fact impossible to guess reliably whether the
MR has been DMA unmapped based on its fr_state field, especially as
the surrounding code and its assumptions have changed over time.

A better approach is to track the DMA mapping status explicitly so
that the recycler is less brittle to unexpected situations, and
attempts to DMA-unmap a second time are prevented.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: stable@vger.kernel.org # v4.20
---
 net/sunrpc/xprtrdma/frwr_ops.c |    6 ++++--
 net/sunrpc/xprtrdma/verbs.c    |    9 ++++++---
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index fc6378cc..20ced24 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -117,15 +117,15 @@
 frwr_mr_recycle_worker(struct work_struct *work)
 {
 	struct rpcrdma_mr *mr = container_of(work, struct rpcrdma_mr, mr_recycle);
-	enum rpcrdma_frwr_state state = mr->frwr.fr_state;
 	struct rpcrdma_xprt *r_xprt = mr->mr_xprt;
 
 	trace_xprtrdma_mr_recycle(mr);
 
-	if (state != FRWR_FLUSHED_LI) {
+	if (mr->mr_dir != DMA_NONE) {
 		trace_xprtrdma_mr_unmap(mr);
 		ib_dma_unmap_sg(r_xprt->rx_ia.ri_device,
 				mr->mr_sg, mr->mr_nents, mr->mr_dir);
+		mr->mr_dir = DMA_NONE;
 	}
 
 	spin_lock(&r_xprt->rx_buf.rb_mrlock);
@@ -150,6 +150,8 @@
 	if (!mr->mr_sg)
 		goto out_list_err;
 
+	frwr->fr_state = FRWR_IS_INVALID;
+	mr->mr_dir = DMA_NONE;
 	INIT_LIST_HEAD(&mr->mr_list);
 	INIT_WORK(&mr->mr_recycle, frwr_mr_recycle_worker);
 	sg_init_table(mr->mr_sg, depth);
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 3ddba94..b9bc7f9 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1329,9 +1329,12 @@ struct rpcrdma_mr *
 {
 	struct rpcrdma_xprt *r_xprt = mr->mr_xprt;
 
-	trace_xprtrdma_mr_unmap(mr);
-	ib_dma_unmap_sg(r_xprt->rx_ia.ri_device,
-			mr->mr_sg, mr->mr_nents, mr->mr_dir);
+	if (mr->mr_dir != DMA_NONE) {
+		trace_xprtrdma_mr_unmap(mr);
+		ib_dma_unmap_sg(r_xprt->rx_ia.ri_device,
+				mr->mr_sg, mr->mr_nents, mr->mr_dir);
+		mr->mr_dir = DMA_NONE;
+	}
 	__rpcrdma_mr_put(&r_xprt->rx_buf, mr);
 }
 

