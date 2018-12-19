Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFEECC43387
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 16:00:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9BFF9217D9
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 16:00:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kFKe1T7a"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729577AbeLSQAg (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 11:00:36 -0500
Received: from mail-io1-f65.google.com ([209.85.166.65]:36258 "EHLO
        mail-io1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729503AbeLSQAf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Dec 2018 11:00:35 -0500
Received: by mail-io1-f65.google.com with SMTP id m19so16003378ioh.3;
        Wed, 19 Dec 2018 08:00:34 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=6e831iAyEvL7fncpppgV0vuBdc5zA07EQhaFKLVSxrI=;
        b=kFKe1T7a6u9iSGQfEi8/SKGrJjCzC5aJtFCW8xmpNbwSjCQWvhhy0Mjl7QaeKbT8bT
         PSsvVIcKOpMlqDAP1BhCbAIG7rhgL8Ii4IjTQCnoS34/H5NkcRLzxcF/gG5B16hEnA5G
         hJgPjZWoEW7sBYkGN4D32A9H3sJohffrBQsdBfHYlVCkyQzhHP+S3Q1C3G1z7JyxQCBe
         aWQnWRLRi9soByT89p2aNocyuJtGbCN4lVCF/yj35ggWxY38r6+cg2W5Jth/jzhpOJN7
         26XCcGG7Cd7mpqO1uBkPZ9fH7CxzQlce1v9MzOP4m5D3NP921j14jIsd5+YkTa/uKY0i
         KqgQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=6e831iAyEvL7fncpppgV0vuBdc5zA07EQhaFKLVSxrI=;
        b=SDXsEbttPq4jPVk9ML8dhNmjkv7kC2lxACOMlwPOYzsbGZxunnM0L+UKQYQ/0T6+uP
         tyKHNo4MQSp3RxgAP9y0U8hRwDwCIx4NNXxOGcgDUBZUIvghh9CFhlLDiq2bsVz+RTkh
         Z/caxirqrkSAHMArLD9zoSyRR+G+7ap+o7BCMlwWGY93wM1kaX3WSXKnSVI6BlbcSNWw
         bRvwF7TFUHQu32PTN01L6TDf0YOhmtxomV+uf/4UpZ3+z8eUz7Cr39Dk+ChqJDhk1c8v
         5wf5Sl1uNbU2+zlYQossgVFFtDUFAxVYA6TRWtbBPWXQM9n/Be2/YPcP8r6fPSv3IVpO
         fMig==
X-Gm-Message-State: AA+aEWY0/zNWzWgPOoQZnWuBMLDuOhSDOHTFHDBGFNOh8m06KM3bN2iF
        tUjvEDgPc0LcI88ry+QhPqaCGXMf
X-Google-Smtp-Source: AFSGD/WbZjaQO05GRW7TTVhasfkShwhimqvDamce0wbn7fuYoljDkURMqZM1D+SjhnJgGLnx62CLNA==
X-Received: by 2002:a5d:8510:: with SMTP id q16mr17472310ion.204.1545235234021;
        Wed, 19 Dec 2018 08:00:34 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id h84sm8886486ioa.33.2018.12.19.08.00.33
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 08:00:33 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBJG0W4S025847;
        Wed, 19 Dec 2018 16:00:32 GMT
Subject: [PATCH v5 27/30] xprtrdma: Replace outdated comment for
 rpcrdma_ep_post
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 19 Dec 2018 11:00:32 -0500
Message-ID: <20181219160032.11602.28108.stgit@manet.1015granger.net>
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

Since commit 7c8d9e7c8863 ("xprtrdma: Move Receive posting to
Receive handler"), rpcrdma_ep_post is no longer responsible for
posting Receive buffers. Update the documenting comment to reflect
this change.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 719b69c..11976c3 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1427,10 +1427,14 @@ struct rpcrdma_regbuf *
 	kfree(rb);
 }
 
-/*
- * Prepost any receive buffer, then post send.
+/**
+ * rpcrdma_ep_post - Post WRs to a transport's Send Queue
+ * @ia: transport's device information
+ * @ep: transport's RDMA endpoint information
+ * @req: rpcrdma_req containing the Send WR to post
  *
- * Receive buffer is donated to hardware, reclaimed upon recv completion.
+ * Returns 0 if the post was successful, otherwise -ENOTCONN
+ * is returned.
  */
 int
 rpcrdma_ep_post(struct rpcrdma_ia *ia,

