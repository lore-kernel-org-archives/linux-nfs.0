Return-Path: <SRS0=08pM=S2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1BA1C282E1
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 21:49:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6E55B2183E
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 21:49:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FNMr9ai0"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730434AbfDXVtJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Apr 2019 17:49:09 -0400
Received: from mail-it1-f194.google.com ([209.85.166.194]:50384 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730607AbfDXVtJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2019 17:49:09 -0400
Received: by mail-it1-f194.google.com with SMTP id q14so9113498itk.0
        for <linux-nfs@vger.kernel.org>; Wed, 24 Apr 2019 14:49:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=ty6B3a3wO4NvpHZKdTr6vsruhMjoatPvtvJg2g1C7jY=;
        b=FNMr9ai0ZtmaD6wo4KJ89rEooJL70Ly5ZOfp9gHbTAt3yqIZG+pvT5+cZyNDrrJITt
         /mDNt/BExzWUOdDoOr5t2HfBBob1DcfT5rsYqt0Dt/kp4oVaid+MNjsxNnO/em3nn67G
         5BiV9DkQ8vgqVIBoIg1WwGjrYfjbft6a5TTBayCPGKHUKxWeTsKxkZo/whA2PwirHJaI
         HRNJbXhDZvzjIjFd86LiMVUzW38GLzDaCEJNJ3iF4azh6NEcbgKj/ZvU6wpyws0eFsVY
         GrmSwS0u3+iCCJ28ABhI+oWmqpGJijTSNF5C1i5yb+yEOm0T3nkL5gJigog1MH+v/aMz
         uDPw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=ty6B3a3wO4NvpHZKdTr6vsruhMjoatPvtvJg2g1C7jY=;
        b=IV8SgwA2XnY3PpOTnY5jD8s/1pvjCL2O7CXeQ4AJT0RPn4Rl9h+hON776LFIEPLqHS
         t4ZE6itcCTKrCyPyEoLtGiihF6MYDnvFRqLYDFoQlxrDsq+MpL9RCAvBVEPTN0pTi1v9
         NE4F1dksXmFzdDDcQ6e0ub6GUpAAvbMQsw8aHkYdOnawgb5PiIpS68zVCXuw9PJf/Hwr
         Fd5WQamkHBjNmUQPtIG9kxJavx9OOgVVRxSnYcSZkzf5YEDMT8HUzbpcPFlczHyNarV/
         +n4cDldmnaas3Xq92i5jnkiVQmTsJ2R6JhRbhyP2PtiGiJQdMg7VuqTZtroa4sWdrqUF
         aLpw==
X-Gm-Message-State: APjAAAXgBf11dnMPxajr2OEpflrcnYOCicHKUpKIyazWbEnMNbTcQc8y
        aVlRZCWE8yM8Klec3vViw/CTqjc=
X-Google-Smtp-Source: APXvYqwOOdr0YaXooBq/nBBZyuEI3lWUOAjW7r7W1iNUlb/gro8AuewwGfZ87+UMsIn0Lt+B0eOGiw==
X-Received: by 2002:a24:7b8a:: with SMTP id q132mr1091866itc.169.1556142548406;
        Wed, 24 Apr 2019 14:49:08 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id x10sm9838282ita.4.2019.04.24.14.49.07
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Apr 2019 14:49:07 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 8/9] NFS: When mounting, don't share filesystems between different user namespaces
Date:   Wed, 24 Apr 2019 17:46:49 -0400
Message-Id: <20190424214650.4658-9-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190424214650.4658-8-trond.myklebust@hammerspace.com>
References: <20190424214650.4658-1-trond.myklebust@hammerspace.com>
 <20190424214650.4658-2-trond.myklebust@hammerspace.com>
 <20190424214650.4658-3-trond.myklebust@hammerspace.com>
 <20190424214650.4658-4-trond.myklebust@hammerspace.com>
 <20190424214650.4658-5-trond.myklebust@hammerspace.com>
 <20190424214650.4658-6-trond.myklebust@hammerspace.com>
 <20190424214650.4658-7-trond.myklebust@hammerspace.com>
 <20190424214650.4658-8-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If two different containers that share the same network namespace attempt
to mount the same filesystem, we should not allow them to share the same
super block if they do not share the same user namespace, since the
user mappings on the wire will need to differ.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/super.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index c27ac96a95bd..1730abc1e9ed 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2476,6 +2476,21 @@ static int nfs_compare_super_address(struct nfs_server *server1,
 	return 1;
 }
 
+static int nfs_compare_userns(const struct nfs_server *old,
+		const struct nfs_server *new)
+{
+	const struct user_namespace *oldns = &init_user_ns;
+	const struct user_namespace *newns = &init_user_ns;
+
+	if (old->client && old->client->cl_cred)
+		oldns = old->client->cl_cred->user_ns;
+	if (new->client && new->client->cl_cred)
+		newns = new->client->cl_cred->user_ns;
+	if (oldns != newns)
+		return 0;
+	return 1;
+}
+
 static int nfs_compare_super(struct super_block *sb, void *data)
 {
 	struct nfs_sb_mountdata *sb_mntdata = data;
@@ -2489,6 +2504,8 @@ static int nfs_compare_super(struct super_block *sb, void *data)
 		return 0;
 	if (memcmp(&old->fsid, &server->fsid, sizeof(old->fsid)) != 0)
 		return 0;
+	if (!nfs_compare_userns(old, server))
+		return 0;
 	return nfs_compare_mount_options(sb, server, mntflags);
 }
 
-- 
2.21.0

