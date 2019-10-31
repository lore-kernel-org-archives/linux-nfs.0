Return-Path: <SRS0=lFTb=YY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12BEECA9ECF
	for <linux-nfs@archiver.kernel.org>; Thu, 31 Oct 2019 22:43:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D9AA820873
	for <linux-nfs@archiver.kernel.org>; Thu, 31 Oct 2019 22:43:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Gv3X9sYr"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726506AbfJaWnN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 31 Oct 2019 18:43:13 -0400
Received: from mail-yw1-f65.google.com ([209.85.161.65]:34735 "EHLO
        mail-yw1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727611AbfJaWnN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Oct 2019 18:43:13 -0400
Received: by mail-yw1-f65.google.com with SMTP id z144so1170883ywd.1
        for <linux-nfs@vger.kernel.org>; Thu, 31 Oct 2019 15:43:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=UlqTHE9RJ9ECVULqQDQnX713O/HJPvYKOpACXCXCWSg=;
        b=Gv3X9sYrbGOtIElJQq9KkNDi9vyL7x9RXdyQV3I6nsKP8SeoQxXITX93r/NepiYPQo
         O97wxR8ZJ+SwKJ+2VRK4BeBSAFJNPFbi793DXFh5xlAB/P2ZA7iFIN+I9gD5lFkxhS3q
         dGlF00blonqiy+hZBgFE4Et/5/wo2ycuV6r/Ep0+2J59FAv/yBTzb+4RNJrbapV+EruH
         Goh2Kg+CyvbVu4TB+9BAB9/Qbne11T2/IgYfuSLMMyXNIzbFeSvrjMqqx52hT7uvRcpn
         lhCUMxfkfkCsEEGxZot7sUBwdxWbuSwG4po+hCt3/vaOZWxspEjz//daR/3h9p1wiVwR
         2CMw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=UlqTHE9RJ9ECVULqQDQnX713O/HJPvYKOpACXCXCWSg=;
        b=UyE8wW+TKKz4bVju/8+VMVYEIJOZ4VmAKlFCzyYJ0wmyYGhyJvkk1kl3tSeu3aC9eI
         vMgFMzXRClaUXX4HSkzoQnssyrjmdrToyowcoGoJ51IRNLa6OaGlCADWPJcMXhpf2OlQ
         1lmo/0FADlrmeUXalM+vqot0/C+SLej9lvuxDYEa8yk8SS0GIl2D/SUSvRfjHQpdm2RP
         etfggKxHL1M2kihVqAMm5eP/qp0PGmRgL8t/LA+QqAkj6OSFmm4i539QfG6yrex8NiTb
         cXkTbQJ+fZuGbgdWyR6xlDIl94egytcLXFARAX4dB3ChKnJMWx0azs7gRp8mzJ/kTs85
         zENA==
X-Gm-Message-State: APjAAAV7dSpAfpcJb2zd4xlKQyo7pOmtsTBJuXwIscrMTw/BUqeKYSou
        SFNSh7Dpw/oEq7cVGW13WE2ZKPw=
X-Google-Smtp-Source: APXvYqyIFiRPUNhx8HnrTh9n2np27vWhXL+WYpqZnYuwe1nRssQY4IoaEJmLJ3AZ2TovFflPfR2Axg==
X-Received: by 2002:a81:b188:: with SMTP id p130mr4829632ywh.482.1572561791369;
        Thu, 31 Oct 2019 15:43:11 -0700 (PDT)
Received: from localhost.localdomain ([50.105.87.1])
        by smtp.gmail.com with ESMTPSA id d192sm1720287ywb.3.2019.10.31.15.43.09
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 31 Oct 2019 15:43:10 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 06/20] NFSv4: fail nfs4_refresh_delegation_stateid() when the delegation was revoked
Date:   Thu, 31 Oct 2019 18:40:37 -0400
Message-Id: <20191031224051.8923-7-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.23.0
In-Reply-To: <20191031224051.8923-6-trond.myklebust@hammerspace.com>
References: <20191031224051.8923-1-trond.myklebust@hammerspace.com>
 <20191031224051.8923-2-trond.myklebust@hammerspace.com>
 <20191031224051.8923-3-trond.myklebust@hammerspace.com>
 <20191031224051.8923-4-trond.myklebust@hammerspace.com>
 <20191031224051.8923-5-trond.myklebust@hammerspace.com>
 <20191031224051.8923-6-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If the delegation was revoked, we don't want to retry the delegreturn.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/delegation.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index c34bb81d37e2..630167e243be 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -1190,7 +1190,8 @@ bool nfs4_refresh_delegation_stateid(nfs4_stateid *dst, struct inode *inode)
 	rcu_read_lock();
 	delegation = rcu_dereference(NFS_I(inode)->delegation);
 	if (delegation != NULL &&
-	    nfs4_stateid_match_other(dst, &delegation->stateid)) {
+	    nfs4_stateid_match_other(dst, &delegation->stateid) &&
+	    !test_bit(NFS_DELEGATION_REVOKED, &delegation->flags)) {
 		dst->seqid = delegation->stateid.seqid;
 		ret = true;
 	}
-- 
2.23.0

