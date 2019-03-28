Return-Path: <SRS0=umLH=R7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20D6DC43381
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E0BD22184E
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Mj2wWWGg"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727537AbfC1U4Y (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 28 Mar 2019 16:56:24 -0400
Received: from mail-it1-f193.google.com ([209.85.166.193]:55244 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726410AbfC1U4Y (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Mar 2019 16:56:24 -0400
Received: by mail-it1-f193.google.com with SMTP id w18so443805itj.4
        for <linux-nfs@vger.kernel.org>; Thu, 28 Mar 2019 13:56:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=futTz9n1Zb8qTHM6ECvOcoOZEmkx2PkZxVlTq3i2Q1M=;
        b=Mj2wWWGglkKRQhucyad31gMI3+u/CtgZBFTOcZw8IM2Uk7mh0kiIWnEZcjx6Faklrz
         Pcl1nwNS0byI6nRgCDLfZiZGST4M3kbAk63VKWNNOzv/fGgvXhU6JecINfH2k+2MzAqB
         fkFz2+rL/4/iw21HFvqZjkZwrPrVQSoHIs3yPrR4+ZXREJEp8JPbrb4zG2t7XIHVoi4Z
         hnNk/Bchw8uPXnWrRDGrBnCJdZlHWS1SGqtxLwadQlUvw9vejqAG3aUPVTgnuGbxSMO4
         ovtsv0ib9PvdQiaAQstLEgAHTd3s8PyiE0PfPddOJEgK8Mf2bU4/I5Qu8u4XAjsOBG7E
         byKg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=futTz9n1Zb8qTHM6ECvOcoOZEmkx2PkZxVlTq3i2Q1M=;
        b=KCHmK2dvZ6moFrPNhxv/ev/JNXehVWEVVWI42ZBNF4F2dxHYuJP/dt2jltBwOWYSwN
         euRoC6WIJJ0EFw+np8+ZKdIl8yOLXRkKBK3T0IUOQeBwE2biFK/ku1pNJPWH005nwkcO
         JoNKTCI3sOfkyiwjPtLv433IOuRBO9hF9dnrkrlPxIdGKjvmUyEYpyzuwZikstVfGvHd
         3n28Uvdd3FCVUYlv6q3HqzKqJDY+MFgIhPxxwQK/TZNMkS0FnF3qyPLYTplRFhSqa13P
         w2vtHlIwf9y1aynrT3DQ3vlhpnbvXI39jSPKabQnxrdXLA3NXLLtEhcn6h/QSOrHaYRf
         pKow==
X-Gm-Message-State: APjAAAUUH16Li1RiB/s9nYKSlsvPbY/ElnOVPKTFjQa+VIzUiLw7ND/7
        +ZKb9tQlvhF8DPRf5Mw/qp/aZhM=
X-Google-Smtp-Source: APXvYqxTtopYgirPK2LEsY6uzpmHq/Px9NegmISq2tg5YqvLXRDfv71ASbSNAanoko5R9n0mlobc1A==
X-Received: by 2002:a02:a40b:: with SMTP id c11mr20301421jal.50.1553806582423;
        Thu, 28 Mar 2019 13:56:22 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id t67sm1084750ita.35.2019.03.28.13.56.21
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Mar 2019 13:56:21 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 15/25] NFS: Add a mount option "softerr" to allow clients to see ETIMEDOUT errors
Date:   Thu, 28 Mar 2019 16:52:29 -0400
Message-Id: <20190328205239.29674-16-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190328205239.29674-15-trond.myklebust@hammerspace.com>
References: <20190328205239.29674-1-trond.myklebust@hammerspace.com>
 <20190328205239.29674-2-trond.myklebust@hammerspace.com>
 <20190328205239.29674-3-trond.myklebust@hammerspace.com>
 <20190328205239.29674-4-trond.myklebust@hammerspace.com>
 <20190328205239.29674-5-trond.myklebust@hammerspace.com>
 <20190328205239.29674-6-trond.myklebust@hammerspace.com>
 <20190328205239.29674-7-trond.myklebust@hammerspace.com>
 <20190328205239.29674-8-trond.myklebust@hammerspace.com>
 <20190328205239.29674-9-trond.myklebust@hammerspace.com>
 <20190328205239.29674-10-trond.myklebust@hammerspace.com>
 <20190328205239.29674-11-trond.myklebust@hammerspace.com>
 <20190328205239.29674-12-trond.myklebust@hammerspace.com>
 <20190328205239.29674-13-trond.myklebust@hammerspace.com>
 <20190328205239.29674-14-trond.myklebust@hammerspace.com>
 <20190328205239.29674-15-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Add a mount option that exposes the ETIMEDOUT errors that occur during
soft timeouts to the application. This allows aware applications to
distinguish between server disk IO errors and client timeout errors.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/client.c           |  2 ++
 fs/nfs/super.c            | 15 ++++++++++++---
 include/linux/nfs_fs_sb.h |  1 +
 3 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 90d71fda65ce..f74638c5e5b4 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -598,6 +598,8 @@ int nfs_init_server_rpcclient(struct nfs_server *server,
 			sizeof(server->client->cl_timeout_default));
 	server->client->cl_timeout = &server->client->cl_timeout_default;
 	server->client->cl_softrtry = 0;
+	if (server->flags & NFS_MOUNT_SOFTERR)
+		server->client->cl_softerr = 1;
 	if (server->flags & NFS_MOUNT_SOFT)
 		server->client->cl_softrtry = 1;
 
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 23790c7b2289..61cae26dbf78 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -78,7 +78,7 @@
 
 enum {
 	/* Mount options that take no arguments */
-	Opt_soft, Opt_hard,
+	Opt_soft, Opt_softerr, Opt_hard,
 	Opt_posix, Opt_noposix,
 	Opt_cto, Opt_nocto,
 	Opt_ac, Opt_noac,
@@ -125,6 +125,7 @@ static const match_table_t nfs_mount_option_tokens = {
 	{ Opt_sloppy, "sloppy" },
 
 	{ Opt_soft, "soft" },
+	{ Opt_softerr, "softerr" },
 	{ Opt_hard, "hard" },
 	{ Opt_deprecated, "intr" },
 	{ Opt_deprecated, "nointr" },
@@ -628,7 +629,8 @@ static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
 		const char *str;
 		const char *nostr;
 	} nfs_info[] = {
-		{ NFS_MOUNT_SOFT, ",soft", ",hard" },
+		{ NFS_MOUNT_SOFT, ",soft", "" },
+		{ NFS_MOUNT_SOFTERR, ",softerr", "" },
 		{ NFS_MOUNT_POSIX, ",posix", "" },
 		{ NFS_MOUNT_NOCTO, ",nocto", "" },
 		{ NFS_MOUNT_NOAC, ",noac", "" },
@@ -658,6 +660,8 @@ static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
 		seq_printf(m, ",acdirmin=%u", nfss->acdirmin/HZ);
 	if (nfss->acdirmax != NFS_DEF_ACDIRMAX*HZ || showdefaults)
 		seq_printf(m, ",acdirmax=%u", nfss->acdirmax/HZ);
+	if (!(nfss->flags & (NFS_MOUNT_SOFT|NFS_MOUNT_SOFTERR)))
+			seq_puts(m, ",hard");
 	for (nfs_infop = nfs_info; nfs_infop->flag; nfs_infop++) {
 		if (nfss->flags & nfs_infop->flag)
 			seq_puts(m, nfs_infop->str);
@@ -1239,10 +1243,15 @@ static int nfs_parse_mount_options(char *raw,
 		 */
 		case Opt_soft:
 			mnt->flags |= NFS_MOUNT_SOFT;
+			mnt->flags &= ~NFS_MOUNT_SOFTERR;
 			break;
-		case Opt_hard:
+		case Opt_softerr:
+			mnt->flags |= NFS_MOUNT_SOFTERR;
 			mnt->flags &= ~NFS_MOUNT_SOFT;
 			break;
+		case Opt_hard:
+			mnt->flags &= ~(NFS_MOUNT_SOFT|NFS_MOUNT_SOFTERR);
+			break;
 		case Opt_posix:
 			mnt->flags |= NFS_MOUNT_POSIX;
 			break;
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 013ac5b54a09..0fbc5d3c5e53 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -147,6 +147,7 @@ struct nfs_server {
 #define NFS_MOUNT_LEGACY_INTERFACE	0x80000
 #define NFS_MOUNT_LOCAL_FLOCK		0x100000
 #define NFS_MOUNT_LOCAL_FCNTL		0x200000
+#define NFS_MOUNT_SOFTERR		0x400000
 
 	unsigned int		caps;		/* server capabilities */
 	unsigned int		rsize;		/* read size */
-- 
2.20.1

