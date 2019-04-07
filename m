Return-Path: <SRS0=hGI+=SJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0B60C282DD
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 862C920896
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Ow9qvaH4"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726468AbfDGSBl (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 7 Apr 2019 14:01:41 -0400
Received: from mail-it1-f194.google.com ([209.85.166.194]:53834 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726462AbfDGSBk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Apr 2019 14:01:40 -0400
Received: by mail-it1-f194.google.com with SMTP id y204so17229754itf.3
        for <linux-nfs@vger.kernel.org>; Sun, 07 Apr 2019 11:01:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=futTz9n1Zb8qTHM6ECvOcoOZEmkx2PkZxVlTq3i2Q1M=;
        b=Ow9qvaH4qkRMaMTwNf5zfTwelMKUFSd94wvn1ndQXqRX579pO7Mye81KEc8kn9p8dM
         5WrDqxay+O/v9hDoxqeK3QEy+UN8xvkE9bqw3b8GcHsIQGhX/ETbA1PtqjAu1k6rbqPf
         UduPJs3o6taxLCuP8T7LarUvJbBx8CsIGHsPLcXdBpDgysFtvWtKQ3eyg8SIFLIN8Wst
         W9txvjWWcnIkQpiLs7Ei6f3hsKlxTy0038u6wrPLRwpmZ4QvrnSx7UBoP4/sYCuYmIpZ
         MR0qbKs6o06at2Ivt/1mJY0he80RlK9TYtR7HQQlTqXTLRp043DiL8nhcdnfEpaZFJ+W
         ov3Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=futTz9n1Zb8qTHM6ECvOcoOZEmkx2PkZxVlTq3i2Q1M=;
        b=FjxTwKZ7iwrQWb5d0kvEUe1KZCeqNnaaef8i82BAEwodlWdDGHe7agTVnzSg2H8yjz
         bLktQ6d3Gmrp2f/kGVEqYIpDGSo81ujLVOu+zsyaiYulDpTTQPFgZSc2P3+guRMVyqV4
         XZXRvFzTI7l0U/Fjbk1YUqKHvcLNG8qzq31V5qq2D38IBN2wvsO2OAQEjY7Q8B6tiQRk
         rPavI9xRdn171q4VjWDlVvOc6l5NhGZUtp3Zpcq8ACVZVmm3o1yfHYggCGSCHX9wvKvH
         7IM8JB5XtRdP8q2+ltrscda/w60RQiyGRy2MQfTrLxhSPdkD+SbfDaGo3DC59RK3JDAF
         7Kng==
X-Gm-Message-State: APjAAAU0AhoFmR0qkfmiWsB7MaYO91R3l993u+o9FDWIUeeP02uHZkXX
        vOUBebGGk+1Yhq007EXnuROVpeI=
X-Google-Smtp-Source: APXvYqxHiuDkhcMfe3JzTp6V1QZXEOi1yg27CJCjqRy1CyjWtchlhv2732Q7IomBDawJaMkNUrWD1w==
X-Received: by 2002:a24:7b4f:: with SMTP id q76mr9847298itc.142.1554660099458;
        Sun, 07 Apr 2019 11:01:39 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id m6sm10807362ioj.36.2019.04.07.11.01.38
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 07 Apr 2019 11:01:38 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 18/29] NFS: Add a mount option "softerr" to allow clients to see ETIMEDOUT errors
Date:   Sun,  7 Apr 2019 13:59:01 -0400
Message-Id: <20190407175912.23528-19-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190407175912.23528-18-trond.myklebust@hammerspace.com>
References: <20190407175912.23528-1-trond.myklebust@hammerspace.com>
 <20190407175912.23528-2-trond.myklebust@hammerspace.com>
 <20190407175912.23528-3-trond.myklebust@hammerspace.com>
 <20190407175912.23528-4-trond.myklebust@hammerspace.com>
 <20190407175912.23528-5-trond.myklebust@hammerspace.com>
 <20190407175912.23528-6-trond.myklebust@hammerspace.com>
 <20190407175912.23528-7-trond.myklebust@hammerspace.com>
 <20190407175912.23528-8-trond.myklebust@hammerspace.com>
 <20190407175912.23528-9-trond.myklebust@hammerspace.com>
 <20190407175912.23528-10-trond.myklebust@hammerspace.com>
 <20190407175912.23528-11-trond.myklebust@hammerspace.com>
 <20190407175912.23528-12-trond.myklebust@hammerspace.com>
 <20190407175912.23528-13-trond.myklebust@hammerspace.com>
 <20190407175912.23528-14-trond.myklebust@hammerspace.com>
 <20190407175912.23528-15-trond.myklebust@hammerspace.com>
 <20190407175912.23528-16-trond.myklebust@hammerspace.com>
 <20190407175912.23528-17-trond.myklebust@hammerspace.com>
 <20190407175912.23528-18-trond.myklebust@hammerspace.com>
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

