Return-Path: <SRS0=cX4g=NK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2CC67C6786F
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 20:56:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E4B192080A
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 20:56:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sg813fnQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E4B192080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728062AbeJaFvr (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 31 Oct 2018 01:51:47 -0400
Received: from mail-qt1-f193.google.com ([209.85.160.193]:38909 "EHLO
        mail-qt1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728030AbeJaFvq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Oct 2018 01:51:46 -0400
Received: by mail-qt1-f193.google.com with SMTP id v1-v6so11048548qtq.5;
        Tue, 30 Oct 2018 13:56:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=fwlJnXfUGTRII/SW0YspOWGhfPFdbZ3Rgyeu7Z/VErM=;
        b=sg813fnQDp2bgDq3gMAKZcrx2LKZK9Cp3CWMsNvsmdm1TnF43cMdz9UbACpFJhlMUR
         bppLKiHFvf1KIEzGfQ0/kSYtTyrRnsWm70eyLDB7oFQAtYbkLhBwHf1bMGgOFLRnr/va
         9rsDvzk8w3fcC0a7PTFpqyRijVDbh82idvwRstoYcMLtO7sR0m3ZQnp3zOLIe4KOXqLq
         t9RNpGamPexJbNYO4cKRfT93se+iC9yjNqTYHDyNrHx9aRuQDOJvLVXAV9cO/+8auaXK
         m8PFrcs5jYucc40jdu0SZD2nasvLkLhgxYIrGe5D+lCZ2Cr/r3v21vzio200dz4SW/sT
         SK6Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=fwlJnXfUGTRII/SW0YspOWGhfPFdbZ3Rgyeu7Z/VErM=;
        b=so+iXWmdeKuiDqmvXu9DjZFsYfZ4JsLmf9seLHHrZafz4tAflhi8SyKQmC2zbmhw6E
         7g2SIwp7cBvouGvy/wSG3Feo3BmvXZF53J+YxLpUZGLd9PXh/WFmwH2AaPYNyDkgFhHX
         wbypQrIVpMdIb35QoUa7wiKFuxCcJu5wkvMSX3xbedHddMcPJ+WY5EQd/ufu4lpTde+S
         eyNcvnXXGfHaZns7122M4EJp7GpVVtde4fr+UJ5wAZAtGfWsZGBXIankpAVUdk9rPxUw
         /XT9SPq53F1ddBJhChKnatF+aiiCCBbw6VZNoVudgcTSguWlbiwHXfQEUNNUPRabFe70
         pvLQ==
X-Gm-Message-State: AGRZ1gLS6M6CXbO956lgPyCpvBPiA8woeAREXbiiMngAfZZyAe1j9mJn
        qGNJNY7ksM7Sa5c4xGec8P8=
X-Google-Smtp-Source: AJdET5cmgPKIBg2zJnUbOQ9AbMFO6Z2Mxn7nwwo7XX+lbgPZIXtCKSvc3MC+6wSvXiC/9QXMGJHG/A==
X-Received: by 2002:aed:39a9:: with SMTP id m38-v6mr311222qte.222.1540933001598;
        Tue, 30 Oct 2018 13:56:41 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id i11-v6sm23478157qtc.96.2018.10.30.13.56.40
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 Oct 2018 13:56:40 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v7 10/11] NFS: COPY handle ERR_OFFLOAD_DENIED
Date:   Tue, 30 Oct 2018 16:56:13 -0400
Message-Id: <20181030205614.40754-12-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181030205614.40754-1-olga.kornievskaia@gmail.com>
References: <20181030205614.40754-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

If server sends ERR_OFFLOAD_DENIED error, the client must fall
back on doing copy the normal way. Return ENOTSUPP to the vfs and
fallback to regular copy.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42proc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 00809b3..c7c2ffa 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -395,7 +395,8 @@ ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
 			args.sync = true;
 			dst_exception.retry = 1;
 			continue;
-		} else if (err == -ESTALE &&
+		} else if ((err == -ESTALE ||
+				err == -NFS4ERR_OFFLOAD_DENIED) &&
 				!nfs42_files_from_same_server(src, dst)) {
 			nfs42_do_offload_cancel_async(src, &args.src_stateid);
 			err = -EOPNOTSUPP;
-- 
1.8.3.1

