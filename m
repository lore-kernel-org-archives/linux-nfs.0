Return-Path: <SRS0=9F0h=R2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F846C43381
	for <linux-nfs@archiver.kernel.org>; Sat, 23 Mar 2019 16:11:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 21DA42087F
	for <linux-nfs@archiver.kernel.org>; Sat, 23 Mar 2019 16:11:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RdL+MdXw"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727482AbfCWQLF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 23 Mar 2019 12:11:05 -0400
Received: from mail-io1-f67.google.com ([209.85.166.67]:42488 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727457AbfCWQLF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 23 Mar 2019 12:11:05 -0400
Received: by mail-io1-f67.google.com with SMTP id c4so4169708ioh.9
        for <linux-nfs@vger.kernel.org>; Sat, 23 Mar 2019 09:11:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=p26Z7Z+FmRU5ZRlLmn8ApFSgWRmUiFCNTk7z8m3c6bg=;
        b=RdL+MdXwtzf0WvqapFzmbzzi5duexIAmhg5IXce/+70FiI/hC4CGJgs8WtlljX2aMP
         T4FGLucCrFhR6G+N2oUfbXZWrF33Ca/Mqcr56/id2splYlrK2RE+PyDngS76tr2OiMUA
         /6sYZw+A33EvoiMxiaVgc5kasItiw8IIsY63czxGcqyCP4hBINf35xGHRorBGggwpsYU
         vV15ikTqNhDewCaQbyWu0cJsAbbF0zJMyfGWfbNjaaUe2iIyxx0mxqmvxwR+Vp7s7zLN
         zPvYXqVPSl40nhO+7OB1zoapQf2mN4uLqGz+qRLuXgRqt1SV03KGeQh8vMeMJsjyEpjM
         XASw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=p26Z7Z+FmRU5ZRlLmn8ApFSgWRmUiFCNTk7z8m3c6bg=;
        b=XYIk61RMx5ROQ3m7lz98P1lFFGDtNSNJmQnOexFXdFeQrFsCDErr1fUzcYw4xRvcls
         cx8KfetYnysBq6HfFwXX0mok2v6Js1NxJ5iqLIzRlsU7Y2y5XsLRfkPvHKz6dN+OzXBX
         PJaA6XUgWKxMcP9AIhKwGQKGU+gA2O7ILvmzbCGhMNjxbYxxQlE7NJWrj8oG/aLLOmh/
         jrNP2ccr5IyURDoxCeRFJscnu7XWUxeY8KALrt4Yu65ykLu75R+cJUKvsQoVnMT8FsR/
         8gdghxIYtztQ1mGbNdtmvHlZOnobSlht6mSuZh0AQI06+NsVx0QeHDhyH/kyf/lffqYn
         R4mg==
X-Gm-Message-State: APjAAAVd1QQBKdMq95xJ7gLbgfXjMCU4p2VSWSLTcG9SAGv8zK0OgNJD
        dudLlw3G+ix210VPZM95clT2xQA=
X-Google-Smtp-Source: APXvYqwmnECudYclNj1d1z511yPF4LyzZqrncUPXl/KJAYF9w2DLBDRSaZJ7UStsgozFUVkdaEGyPA==
X-Received: by 2002:a6b:f419:: with SMTP id i25mr11342909iog.216.1553357464109;
        Sat, 23 Mar 2019 09:11:04 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id o9sm3035586itb.23.2019.03.23.09.11.03
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 23 Mar 2019 09:11:03 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Fix a typo in nfs_init_timeout_values()
Date:   Sat, 23 Mar 2019 12:07:37 -0400
Message-Id: <20190323160737.23609-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Specifying a retrans=0 mount parameter to a NFS/TCP mount, is
inadvertently causing the NFS client to rewrite any specified
timeout parameter to the default of 60 seconds.

Fixes: a956beda19a6 ("NFS: Allow the mount option retrans=0")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/client.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index fb1cf1a4bda2..90d71fda65ce 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -453,7 +453,7 @@ void nfs_init_timeout_values(struct rpc_timeout *to, int proto,
 	case XPRT_TRANSPORT_RDMA:
 		if (retrans == NFS_UNSPEC_RETRANS)
 			to->to_retries = NFS_DEF_TCP_RETRANS;
-		if (timeo == NFS_UNSPEC_TIMEO || to->to_retries == 0)
+		if (timeo == NFS_UNSPEC_TIMEO || to->to_initval == 0)
 			to->to_initval = NFS_DEF_TCP_TIMEO * HZ / 10;
 		if (to->to_initval > NFS_MAX_TCP_TIMEOUT)
 			to->to_initval = NFS_MAX_TCP_TIMEOUT;
-- 
2.20.1

