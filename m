Return-Path: <SRS0=Vt5f=V7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCB89C31E40
	for <linux-nfs@archiver.kernel.org>; Sat,  3 Aug 2019 15:00:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 909A8206C1
	for <linux-nfs@archiver.kernel.org>; Sat,  3 Aug 2019 15:00:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BFjPu07N"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727843AbfHCPAg (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 3 Aug 2019 11:00:36 -0400
Received: from mail-io1-f65.google.com ([209.85.166.65]:39566 "EHLO
        mail-io1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727535AbfHCPAg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Aug 2019 11:00:36 -0400
Received: by mail-io1-f65.google.com with SMTP id f4so158748637ioh.6
        for <linux-nfs@vger.kernel.org>; Sat, 03 Aug 2019 08:00:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=H6RjXIqkymcgD1H8o7IZsZ4Q3k0CSgAlxo5Yg+M1ya8=;
        b=BFjPu07NDDNfUPvTaDKlXoUA/OcAJ58CbhLHpRriF281I8NjPYpBvUCqEp2S1VM8UN
         NGm3wvgnG7+PTNxU6pUIH4rIBVsjx5Btsz+hZZ8jV+R7Zbd2bxTXz6wZJZ/g+GTFjrKk
         0h2P9M7RPK8qvh/4omWCm+UdmDL8WTgDhPfhy07GY6D17qwinVArxexyUbz6jMnIoRPw
         AV/7tzuMptV1P9DxqUaLmYtU0Il5Vkki6Wpjlq4BogcNgmYyV0uFaXLhNYwk8QyHCpt2
         lHub4PKH91Z3tkI0x73UIvvARB8ni9IU4wzVasAB7kBHvksiiYkf4sKA1FhSKTd2L5Sk
         yAWA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=H6RjXIqkymcgD1H8o7IZsZ4Q3k0CSgAlxo5Yg+M1ya8=;
        b=WxNBxCVe6vftyW8yMTOWxohdtZqLxMIthPWSdax7tN1Otm3UWIdyzdt1rEEXtebucM
         8acUUBKLUHykfbECqPXWwbCT8LwXEWcLGKu2bnnPBwnS4nY1F/hnTdQxi/e3QMLcAmHM
         ZOkifHkvObTrfZ3/hOloQHXNbP1T0FZrukQzoGxtdJB+d/tblbpMtNPvYdSMWvoq/TJb
         8U4NuYq0KukEcpNheTQ6JOm99aKRqBbJrS6G2Aej8mOQNUD/aMAGxAeh9R0sT7nBxj+2
         +MxvT9pAbnEIQfcII8MsFLQkf2FJtQrHVAUDvojUkoB9ZW210ZL9b0CTJwHs/VxEpU6s
         8Z0w==
X-Gm-Message-State: APjAAAUf9Zg/B84pGXzYZfuX7v8c59KL9tgW1/cVp2J/2EnpNFx76lZ7
        2fssjQxIFngkrS41uNwzavtPGm4=
X-Google-Smtp-Source: APXvYqwY3s8Ga9umuIzZgdClpZIdFguKQEA7Vl2zbtbwx6dN6ALAD1pLAzOSwrqNgkLDm43jWknfkQ==
X-Received: by 2002:a02:a417:: with SMTP id c23mr25152268jal.141.1564844435372;
        Sat, 03 Aug 2019 08:00:35 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id f20sm60820416ioh.17.2019.08.03.08.00.34
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 03 Aug 2019 08:00:34 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 3/8] NFSv4: Print an error in the syslog when state is marked as irrecoverable
Date:   Sat,  3 Aug 2019 10:58:21 -0400
Message-Id: <20190803145826.15504-3-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190803145826.15504-2-trond.myklebust@hammerspace.com>
References: <20190803145826.15504-1-trond.myklebust@hammerspace.com>
 <20190803145826.15504-2-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When error recovery fails due to a fatal error on the server, ensure
we log it in the syslog.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4state.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 9afd051a4876..a71a61e5fe2c 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1463,7 +1463,7 @@ void nfs_inode_find_state_and_recover(struct inode *inode,
 		nfs4_schedule_state_manager(clp);
 }
 
-static void nfs4_state_mark_open_context_bad(struct nfs4_state *state)
+static void nfs4_state_mark_open_context_bad(struct nfs4_state *state, int err)
 {
 	struct inode *inode = state->inode;
 	struct nfs_inode *nfsi = NFS_I(inode);
@@ -1474,6 +1474,8 @@ static void nfs4_state_mark_open_context_bad(struct nfs4_state *state)
 		if (ctx->state != state)
 			continue;
 		set_bit(NFS_CONTEXT_BAD, &ctx->flags);
+		pr_warn("NFSv4: state recovery failed for open file %pd2, "
+				"error = %d\n", ctx->dentry, err);
 	}
 	rcu_read_unlock();
 }
@@ -1481,7 +1483,7 @@ static void nfs4_state_mark_open_context_bad(struct nfs4_state *state)
 static void nfs4_state_mark_recovery_failed(struct nfs4_state *state, int error)
 {
 	set_bit(NFS_STATE_RECOVERY_FAILED, &state->flags);
-	nfs4_state_mark_open_context_bad(state);
+	nfs4_state_mark_open_context_bad(state, error);
 }
 
 
-- 
2.21.0

