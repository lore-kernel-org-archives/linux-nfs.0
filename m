Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B4EAC43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:41:50 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CFC8D2133F
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:41:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qM5uSpuP"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388330AbeLQQlt (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 11:41:49 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:54190 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388011AbeLQQlt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 11:41:49 -0500
Received: by mail-it1-f196.google.com with SMTP id g85so19469926ita.3;
        Mon, 17 Dec 2018 08:41:47 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=7uArD0olifUE5YxboWcMnzA5vma1vSehByVkKR/ay80=;
        b=qM5uSpuPWVEHpxDCBchgTVNL2RQWcZ6+RQE8jTImmLpGgG7yfJjvZQQQtb9V44QEQf
         6Wd4D6mJKb8hlwitJtY5HIRTttJ4ZgjSLKiNMjBcoCwrHtfqt+iAgwe7o2APpvuUQ9Lr
         SPlBjyM3v3xMyU0MJ4Ri5/v95fRQVCz+TTVBudXm7wlpJD1EANU4DCMdGEHL5bbpSIrP
         Wq6MeZ5GaHE3gSbmVtsQaFWnqSKae6vUOkl95h9GuzPfCu3glVerPGnexkqnFaG1Z5jb
         IdkQ7vpUbfdxClG/eBQuocOJoKxdIEUuoXedKlTDWrVAAwwavvjtHFzT66KMwiiefaEY
         H72A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=7uArD0olifUE5YxboWcMnzA5vma1vSehByVkKR/ay80=;
        b=cmyD/09Gw9NUnm6cHl9roICQKQ9sx+cecnKMYTu1sNJYf/aku+dcUgAQLHSrAFaHLh
         +BQWFcN2UmbzyEPREZQc+Fpg4xCCNuzze5fAOf7j4dc4ivyEdsGTRTaxXZdZN1aWKJPP
         g6Jg/u7tSuEpuHW7g3oIQF3poQE7/h8G5Q3mN3lXsi/DFB2uv1iU2lVuDRfutL7B6xGP
         E6cSUQnHB0xhGaIURvxBvcxbqPAJdGlPf4b93twyyxx8SVj2SE18MS2gVHxW6An9ZUF3
         BWVjhIOJqviK2XerHQyYL2MmfOcbJmJz2qS4AQ0MwdKZ8ji8o3m8sAe0LF8X2vXtiLLg
         K+NA==
X-Gm-Message-State: AA+aEWYo0u1K1tp92spny3zLdP1DUO06nJBsBuODL3PCbKbPx6klevAG
        i8kDi1dL8Zmygto1JUrbs8QLj57q
X-Google-Smtp-Source: AFSGD/UiKAvoQS3+dDF3YWIbdFmC8jITPY5yhEYFBcyW0sTYi4VieDh0BSDnLAv5E6NxrMBVXJpCUA==
X-Received: by 2002:a24:bd0e:: with SMTP id x14mr6047915ite.123.1545064906889;
        Mon, 17 Dec 2018 08:41:46 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id u3sm7141816ita.18.2018.12.17.08.41.46
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 08:41:46 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBHGfjCf018660;
        Mon, 17 Dec 2018 16:41:45 GMT
Subject: [PATCH v4 27/30] xprtrdma: Replace outdated comment for
 rpcrdma_ep_post
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 17 Dec 2018 11:41:45 -0500
Message-ID: <20181217164145.24133.74915.stgit@manet.1015granger.net>
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

Since commit 7c8d9e7c8863 ("xprtrdma: Move Receive posting to
Receive handler"), rpcrdma_ep_post is no longer responsible for
posting Receive buffers. Update the documenting comment to reflect
this change.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index b46e2f9..c69b985 100644
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

