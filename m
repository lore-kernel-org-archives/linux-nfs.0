Return-Path: <SRS0=moVq=XB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4635DC43331
	for <linux-nfs@archiver.kernel.org>; Fri,  6 Sep 2019 23:36:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 212C920854
	for <linux-nfs@archiver.kernel.org>; Fri,  6 Sep 2019 23:36:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="p4gYu4tV"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2393130AbfIFXgX (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 6 Sep 2019 19:36:23 -0400
Received: from mail-io1-f65.google.com ([209.85.166.65]:45271 "EHLO
        mail-io1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2393113AbfIFXgX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Sep 2019 19:36:23 -0400
Received: by mail-io1-f65.google.com with SMTP id f12so16550611iog.12
        for <linux-nfs@vger.kernel.org>; Fri, 06 Sep 2019 16:36:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=hWCbgs2TvLtMFp6c5lthjgJ76ToZslEzXYk/je7mpBM=;
        b=p4gYu4tVrPrxn/BXD+t9mJRQDZSnjoonrx2XQsvwQX73F16W51w4n4a64i01B3ijHA
         Z/kN7cjHAXR3tUaq8xAb/IfnZ9spkhbtixQy+9FZIRuOCIn95C5Yr6oFU3ghv3pYp1vi
         RefQFpsJwvgHe5pTU3EYVBFKO0ImF8WG0fR8FXI1V0dbBPMFOAwtBQt2IheHZb5HgvCt
         MPWsB76TICqg1F3kqX8KhsEsYnLkzYBe/nVw/yL6PkYICBpIzbfZEmOHtvrmPDHSFd1t
         /9in+gEw4kuxD8tyT7ZaWoG3IlnbSjdwb2Y7dAf6DR6ckZthYqSvWjOQ17hcS4RUccYy
         K7QQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=hWCbgs2TvLtMFp6c5lthjgJ76ToZslEzXYk/je7mpBM=;
        b=eh2ZKyxQsFdc2WAxqgJLkeMrQWWEpaWKNnuVCbxuGvkf5zUkTGyNrgvUFitLl6nX08
         trVlNaiaUXrY+lnTTxUb2i1iMCziGKwQVyhGEDKZIvC3qFbdLdmlnyjo/tkqT6O/6Qzv
         U2/xtnqqcQ39mWddzEZna9pi6nzw0qokGGZ0ocJLcVSLCIzcQMJ8OZdlDMYsquRiJ2RR
         bh5VEGKOfq6ppTZK9i4ERaBnyqCx5VshQFgdpbZMnoHd3DQfXCBuNoLPYZ+PKry6VIY+
         VaBF5bR6DAuRtcjB9JnIw26bpPWCZJbVtlKMJaGIsH8j50IJEWdWSptV90gjDQzCIqkz
         7YOw==
X-Gm-Message-State: APjAAAUANxdNRTs0JyMJs39hOKA1QOTKtjBM4sWpVoN2ItzBV9Agc72n
        97esi4zglxtXPxGdhcz2c64=
X-Google-Smtp-Source: APXvYqzGdDhHb5z4vubO/IjveTRXUDHqwSNsFQwS3n1FnytVFvKAmxPu9BbSQZmxFcsMnbv+dJuGnA==
X-Received: by 2002:a02:b395:: with SMTP id p21mr13467015jan.52.1567812981965;
        Fri, 06 Sep 2019 16:36:21 -0700 (PDT)
Received: from Olgas-MBP-201.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id r138sm10439360iod.59.2019.09.06.16.36.21
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Sep 2019 16:36:21 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        bfields@redhat.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v7 09/21] NFS handle NFS4ERR_PARTNER_NO_AUTH error
Date:   Fri,  6 Sep 2019 19:35:59 -0400
Message-Id: <20190906233611.4031-10-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20190906233611.4031-1-olga.kornievskaia@gmail.com>
References: <20190906233611.4031-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

When a destination server sends a READ to the source server it can
get a NFS4ERR_PARTNER_NO_AUTH, which means a copy needs to be
restarted.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4proc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7ea446bd6b2a..d7381b893718 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -475,6 +475,7 @@ static int nfs4_do_handle_exception(struct nfs_server *server,
 		case -NFS4ERR_ADMIN_REVOKED:
 		case -NFS4ERR_EXPIRED:
 		case -NFS4ERR_BAD_STATEID:
+		case -NFS4ERR_PARTNER_NO_AUTH:
 			if (inode != NULL && stateid != NULL) {
 				nfs_inode_find_state_and_recover(inode,
 						stateid);
-- 
2.18.1

