Return-Path: <SRS0=Psyw=RE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45452C4360F
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:26:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 10F102084F
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:26:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="i+bAWRK0"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725862AbfCAT05 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Mar 2019 14:26:57 -0500
Received: from mail-yw1-f65.google.com ([209.85.161.65]:33946 "EHLO
        mail-yw1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725905AbfCAT05 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Mar 2019 14:26:57 -0500
Received: by mail-yw1-f65.google.com with SMTP id u205so14959403ywe.1
        for <linux-nfs@vger.kernel.org>; Fri, 01 Mar 2019 11:26:56 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=2QvvkV1Xrxgz0nLmZ+gse3tjySRBEI2DeUAlDEnYu4c=;
        b=i+bAWRK0qHFMJhcO7k9IiFqrTI2/nllCt5T/xoKbSRJaDUV4MxCJRR4wcu1djm72x2
         VUvpxQplvk3wWEgFf/VSF/sem7wJ9mPTZTBnCodYjU/Dl5so0uVuAF48jJaipLmZiTfS
         OmCjC3USkOiE76R0/BFY1wc1WGlC2+XkZDg6yoyHsRbtt2Cc8E0zjDFAIJ4fpkIV187s
         4hKB7n0dFahNwcMqoa9DJxVFfFrGZpfTxOSGm/+ZQ/Rm4eDOi6RutCqHFFhYxD1/sY7V
         VGP4rYlIFQ28b0j3ESaeaiUYaOd3aQ2VfuyOjZMfdN1UQq/gk6w2W8uacSffyspV9+vX
         CE0A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=2QvvkV1Xrxgz0nLmZ+gse3tjySRBEI2DeUAlDEnYu4c=;
        b=JwqT3TT27BxnBBWnDBzKGK29bfrvi5kqyUQBhBuBt+0gNK6IkUn+KeLCcspzt1/6Tm
         bVRg5Cvw0sCc2BVBpKKvaL102ZET6oWXagUpTKLzTlIS9MhKWSykzmooerULEPz7rI3M
         uGGqUm48r9WLXdkDqIN01gwLpcEtGGSEWPIOxXFGTKP9Fmbt2kqEHkzLXnrTuGknQ7eH
         tLdJEye8GKZK/Uw45CHtkG93+FuJTvMoTLKj9s9ARky/UYBfKueyeZXGfdXLXqZPptRM
         u4wu+fcNQE0qDHrTpsUbm3s1Lge09tgTm8i+C4/EvRZbhakXWNdtc6FrI5JAafHZXNIz
         rFgA==
X-Gm-Message-State: APjAAAU7oMDxTk5DBSqLrnAURCIp37QuO4T1IYLRYymoa6aurOD2n/6f
        NKXtxP2A5o+syYKGhJw7yJN6Q5c=
X-Google-Smtp-Source: APXvYqz0Wk36THGaOMaVqDRUaMSoB80FQ53KiwqY7+bVjnbcgdBBz9HuCJQzbDodByHituMcELBJnA==
X-Received: by 2002:a81:5987:: with SMTP id n129mr4987991ywb.95.1551468415895;
        Fri, 01 Mar 2019 11:26:55 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id l71sm7509193ywl.65.2019.03.01.11.26.55
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Mar 2019 11:26:55 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 03/19] NFSv4/pnfs: Fix barriers in nfs4_mark_deviceid_unavailable()
Date:   Fri,  1 Mar 2019 14:24:39 -0500
Message-Id: <20190301192455.104943-4-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190301192455.104943-3-trond.myklebust@hammerspace.com>
References: <20190301192455.104943-1-trond.myklebust@hammerspace.com>
 <20190301192455.104943-2-trond.myklebust@hammerspace.com>
 <20190301192455.104943-3-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Fix the memory barriers in nfs4_mark_deviceid_unavailable() and
nfs4_test_deviceid_unavailable().

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/pnfs_dev.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
index 7fb59487ee90..ec6b607ff1d7 100644
--- a/fs/nfs/pnfs_dev.c
+++ b/fs/nfs/pnfs_dev.c
@@ -287,7 +287,9 @@ void
 nfs4_mark_deviceid_unavailable(struct nfs4_deviceid_node *node)
 {
 	node->timestamp_unavailable = jiffies;
+	smp_mb__before_atomic();
 	set_bit(NFS_DEVICEID_UNAVAILABLE, &node->flags);
+	smp_mb__after_atomic();
 }
 EXPORT_SYMBOL_GPL(nfs4_mark_deviceid_unavailable);
 
@@ -302,6 +304,7 @@ nfs4_test_deviceid_unavailable(struct nfs4_deviceid_node *node)
 		if (time_in_range(node->timestamp_unavailable, start, end))
 			return true;
 		clear_bit(NFS_DEVICEID_UNAVAILABLE, &node->flags);
+		smp_mb__after_atomic();
 	}
 	return false;
 }
-- 
2.20.1

