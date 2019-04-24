Return-Path: <SRS0=08pM=S2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC712C10F11
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:39:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7F81D21773
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:39:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="B4MmP77C"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730480AbfDXNjp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Apr 2019 09:39:45 -0400
Received: from mail-it1-f194.google.com ([209.85.166.194]:33681 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730462AbfDXNjp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2019 09:39:45 -0400
Received: by mail-it1-f194.google.com with SMTP id v8so5383935itf.0;
        Wed, 24 Apr 2019 06:39:44 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=/mL6PL08rwV4R3G11E6ax6rMV4qUz+im5sUnzyLJuLo=;
        b=B4MmP77C/14b1Vvq42C3zLNjY21Kxl4jtywcQlLYkGGhBdyYeLsh1NiG+a8fBokTOG
         lpdCOtwAg2Mq0Tm0MCkgUriMURvrA/yt6l5ImI1m2WA6TO9H8c4Q6mH052nMHkiPX5md
         5mjPL1EBM4T6RfmXkUQCNxwXTvKoROtHnvNE+szn1c6johumGlImIhTmcedkEk49QALh
         UJ4bNDqPf+tTAU7y+NHbpKWXDDIisAuwSxYHYdDtlKC277G5PszKhSYm3+ZdljVCJIuw
         y+hNWSAjB/SETKcb1hsy5L1wKG9MGPRIVFiMBFjNeaTwpElHZd9lRyw3u1PmizNQ3Ec4
         p1gQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=/mL6PL08rwV4R3G11E6ax6rMV4qUz+im5sUnzyLJuLo=;
        b=qYyRnsSp0RtU9+eyeAiMMPp3wOWz6Qpfb0aFm12Fv3Fo+yp9Ro2AgIigOdge2ft0NB
         5aJ7tPR2jPDhrjJjbBMTkuPNdyCnGfx5Ufwwq6FMUD0OgcEv7Jq7W98Zmy7ddi1u1Na8
         +EnUR08JkjKoEBWYENggSN92xbKqvDbTyDS+ZS9oc1fNyhuvweLbFVXPHb/9FVFfg5fZ
         7pmC+RxWY1Jd4CS6xXVZhEhQU7fN3QhU4BBYdwuB4dQ/V/Hl8aQxrhyT3o59Fh/s1lO4
         Vdpkyn4yl3RwPx9vKcIWQAq69KI6c5E0523QMUqO5NrFjeAJT5OJChzBmlzzcH6F6WnU
         ahrA==
X-Gm-Message-State: APjAAAWmk3s2WT3+F7+vVqzuJ4Ny6gZo0VUxQjupZeDalIPphRTztAO7
        l/Ej/mneklatqvxwcpeaegY=
X-Google-Smtp-Source: APXvYqxAhqs4PwQNouiTjBd/bcRPjDAevJvsbziBthvRkW7+51TV55ZF0DTarrnUEj/epVzCLFuMdA==
X-Received: by 2002:a24:cac2:: with SMTP id k185mr6620430itg.152.1556113184211;
        Wed, 24 Apr 2019 06:39:44 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id r21sm9057166itb.35.2019.04.24.06.39.43
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 06:39:43 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3ODdg3n011298;
        Wed, 24 Apr 2019 13:39:42 GMT
Subject: [PATCH v3 10/21] xprtrdma: Increase maximum number of backchannel
 requests
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 24 Apr 2019 09:39:42 -0400
Message-ID: <20190424133942.5077.2520.stgit@manet.1015granger.net>
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

Reflects the change introduced in commit 067c46967160 ("NFSv4.1:
Bump the default callback session slot count to 16").

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/xprt_rdma.h |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index b942c9d..7621e2d 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -103,12 +103,14 @@ struct rpcrdma_ep {
 
 /* Pre-allocate extra Work Requests for handling backward receives
  * and sends. This is a fixed value because the Work Queues are
- * allocated when the forward channel is set up.
+ * allocated when the forward channel is set up, long before the
+ * backchannel is provisioned. This value is two times
+ * NFS4_DEF_CB_SLOT_TABLE_SIZE.
  */
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
-#define RPCRDMA_BACKWARD_WRS		(8)
+#define RPCRDMA_BACKWARD_WRS (32)
 #else
-#define RPCRDMA_BACKWARD_WRS		(0)
+#define RPCRDMA_BACKWARD_WRS (0)
 #endif
 
 /* Registered buffer -- registered kmalloc'd memory for RDMA SEND/RECV

