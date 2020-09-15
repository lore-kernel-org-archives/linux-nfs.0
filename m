Return-Path: <SRS0=S9kK=CY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.5 required=3.0 tests=BAYES_00,
	DKIM_ADSP_CUSTOM_MED,DKIM_INVALID,DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E889C43461
	for <linux-nfs@archiver.kernel.org>; Tue, 15 Sep 2020 22:58:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id C851F20770
	for <linux-nfs@archiver.kernel.org>; Tue, 15 Sep 2020 22:58:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="qyuZI04Z"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727340AbgIOW6c (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 15 Sep 2020 18:58:32 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:57450 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726418AbgIOW5z (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Sep 2020 18:57:55 -0400
Received: from mail-yb1-xb49.google.com (mail-yb1-xb49.google.com [IPv6:2607:f8b0:4864:20::b49])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id F12B9C061788
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2020 15:57:54 -0700 (PDT)
Received: by mail-yb1-xb49.google.com with SMTP id j20so5056864ybt.10
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2020 15:57:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=sender:date:message-id:mime-version:subject:from:to:cc;
        bh=GbEYlGiQU5dPzFhiYeMOq8enMUbU6ivz9OjjRiaMQaI=;
        b=qyuZI04ZdZ6O+ylRxRptQeEM5MQiA/Gw+ItC9/XnP6AWdQeiIZLXG+0iN66Put9MFX
         ZeqoUzQagxKRXtb5Uo2rFdzUsckyo/GfbbkByHNkiQRF4pNh/qNCMP9bt7jHY2E9H8jW
         BSVO5zvhrDy70beNbWsN+DDx3n4Z06zE1grpEtjE+whsoPRODqWkb3fLbv5Ikh0oFwnI
         spzeoVUImbVLgVF6sklXpxtGLxJjQ+5U39z8VDozAV4Cm+bP7PieXvuaEv9dNcFdHxBB
         tZ5E+ROSWr9cG7bNpPgXJMEgga/h+iH8hu5gWt++SErMBn0uFvF8yhB4xw3hIhdO43B/
         E0JA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:date:message-id:mime-version:subject:from
         :to:cc;
        bh=GbEYlGiQU5dPzFhiYeMOq8enMUbU6ivz9OjjRiaMQaI=;
        b=guAxXlzmepZp4A56o6C1JWwGRi7gHhOOsMqW+BHSA2M/ODFrCTQxMk9JRaWAAjjbUc
         /LksEDbkFgrP97w/rUOSi9fITNGnGJfuDzWjNkplrTEtQusRxaYUoEWvJnjmoDkrGO88
         gXX/lF8Dv4+h0l3MJNndRlDiIzhRdQnQryBdqfzj+dj1FB3Kz7sHZpH/pyUN99oq1zYl
         zcj7Yt3MHXs81bjAIb8sAtxzGmkOqNVvDHK5TR0Oj0FK9ps87UBwWBMaWiYRn8Jh/12p
         rhAc40O8ykO4d7jfz1CDWBlLIz4Nf5VjtvvB76cmona8PsJlEgoNgCkqQLePaiTH9kSu
         v5oQ==
X-Gm-Message-State: AOAM530hpfWTVRiV7kr1YcZOn/AvtyFIHEcfMqmNxAzWrA6bqDTZz3es
        9slNB6dQM8+2siwPdBhwlbmg13ph+z1j8SnJPVc=
X-Google-Smtp-Source: ABdhPJzklPzjBdwFwagsx1j0BJVPOolAFb+q29cI9UUblXp8L02aslKhDquxj6JdqFLlM4n4E6bXgwK0+HoHH26p6vg=
X-Received: from ndesaulniers1.mtv.corp.google.com ([2620:15c:211:202:f693:9fff:fef4:4d25])
 (user=ndesaulniers job=sendgmr) by 2002:a25:3453:: with SMTP id
 b80mr32029892yba.237.1600210674093; Tue, 15 Sep 2020 15:57:54 -0700 (PDT)
Date:   Tue, 15 Sep 2020 15:57:50 -0700
Message-Id: <20200915225751.274531-1-ndesaulniers@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.28.0.618.gf4bc123cb7-goog
Subject: [PATCH] nfs: remove incorrect fallthrough label
From:   Nick Desaulniers <ndesaulniers@google.com>
To:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc:     "Gustavo A . R . Silva" <gustavo@embeddedor.com>,
        Joe Perches <joe@perches.com>,
        Nick Desaulniers <ndesaulniers@google.com>,
        Nathan Chancellor <natechancellor@gmail.com>,
        Miaohe Lin <linmiaohe@huawei.com>,
        Hongxiang Lou <louhongxiang@huawei.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        clang-built-linux@googlegroups.com
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

There is no case after the default from which to fallthrough to. Clang
will error in this case (unhelpfully without context, see link below)
and GCC will with -Wswitch-unreachable.

The previous commit should have just removed the comment.

Fixes: 2a1390c95a69 ("nfs: Convert to use the preferred fallthrough macro")
Link: https://bugs.llvm.org/show_bug.cgi?id=47539
Signed-off-by: Nick Desaulniers <ndesaulniers@google.com>
---
 fs/nfs/super.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index d20326ee0475..7de4e0b03be0 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -889,7 +889,6 @@ static struct nfs_server *nfs_try_mount_request(struct fs_context *fc)
 		default:
 			if (rpcauth_get_gssinfo(flavor, &info) != 0)
 				continue;
-			fallthrough;
 		}
 		dfprintk(MOUNT, "NFS: attempting to use auth flavor %u\n", flavor);
 		ctx->selected_flavor = flavor;
-- 
2.28.0.618.gf4bc123cb7-goog

