Return-Path: <SRS0=hGI+=SJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17099C10F0E
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DCB2E20896
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AkugGtGO"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726457AbfDGSBj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 7 Apr 2019 14:01:39 -0400
Received: from mail-it1-f195.google.com ([209.85.166.195]:38978 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726462AbfDGSBi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Apr 2019 14:01:38 -0400
Received: by mail-it1-f195.google.com with SMTP id 139so17333635ita.4
        for <linux-nfs@vger.kernel.org>; Sun, 07 Apr 2019 11:01:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=mwfeG0Gf7M/QU7b8u/ldks9fFNeQ/gAOdGtccXlhHH0=;
        b=AkugGtGO8YrAkwOTk+0hkMDGUF2KvpKmSkfz1wWtj8+syB0AiR9u1zFozMNryaprTg
         +qm2BeUzhZfnYlEKHjOh+fvp9sPPgBJ5lF7+rUj/T+dNrnYK7bTZOsTyIDgA009drQhF
         0U8hSADikpxg9GA8oadpP1VZqxQ2PkbjwsQiXaSQp86tkCnJ35Lg+xTmHEpiQicYXhVm
         ariDdz69tHZGffiyW5wOGqh8zNyJg1F0Fryybb/RbS5UjhG23OnmihL6s2oBjwNW7VZA
         UgZdi8n3/9FvqVKLxyBvDMpeVb5WO+BTwLnk2dQU7pY6O+ebBvgVZRCBQbafeDwE4Nue
         MN7w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=mwfeG0Gf7M/QU7b8u/ldks9fFNeQ/gAOdGtccXlhHH0=;
        b=banq3dCBVP2xGvxyblbeiZNQjU/aH3w5uoxxtseE/6zU+qSncUZryMBF/XcWJ97fRB
         lvTEawbFOh7blsDDcIvMbV4V+/jKQ+LB4ZkK2H80qH6eC5WrsCf5bL45H9VgCbTYss0A
         F688I/r3duBzQFVGmGnpbjaRXBxZFjLZZcexfzup36+5GR4xRqihBbaR5uaf/irjn0q7
         8I5MEE87YEavAP8zBoT15Tbzs3A38nqIzAsluzDhaOsmnMFDsGnqOy/qvh1lcFa+UJVW
         W2Pb9YB0X+TEcPUjkNVfpAPzCdnfDaRbOxszERbTdwh3Cay9mrcULWh0mbKt3cRkanvY
         REdw==
X-Gm-Message-State: APjAAAXm8FK//Hhf4Ybru0qCbXLJi5SEWfw//gdRa01zARjW+MxZxlBx
        UO0cBmaDX4UDdYf/Ki+hLi29q3M=
X-Google-Smtp-Source: APXvYqwWwYLg6qlqRkAFRQ49yQuZ1kfGO0a8otlu91G8mXQX41du4u0rqTJk/pGS8pRm726TA4V9KA==
X-Received: by 2002:a24:3201:: with SMTP id j1mr17520012ita.107.1554660097982;
        Sun, 07 Apr 2019 11:01:37 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id m6sm10807362ioj.36.2019.04.07.11.01.37
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 07 Apr 2019 11:01:37 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 17/29] NFS: Move internal constants out of uapi/linux/nfs_mount.h
Date:   Sun,  7 Apr 2019 13:59:00 -0400
Message-Id: <20190407175912.23528-18-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190407175912.23528-17-trond.myklebust@hammerspace.com>
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
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When the label says "for internal use only", then it doesn't belong
in the 'uapi' subtree.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/nfs_fs_sb.h      | 9 +++++++++
 include/uapi/linux/nfs_mount.h | 9 ---------
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index c827d31298cc..013ac5b54a09 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -139,6 +139,15 @@ struct nfs_server {
 	struct nfs_iostats __percpu *io_stats;	/* I/O statistics */
 	atomic_long_t		writeback;	/* number of writeback pages */
 	int			flags;		/* various flags */
+
+/* The following are for internal use only. Also see uapi/linux/nfs_mount.h */
+#define NFS_MOUNT_LOOKUP_CACHE_NONEG	0x10000
+#define NFS_MOUNT_LOOKUP_CACHE_NONE	0x20000
+#define NFS_MOUNT_NORESVPORT		0x40000
+#define NFS_MOUNT_LEGACY_INTERFACE	0x80000
+#define NFS_MOUNT_LOCAL_FLOCK		0x100000
+#define NFS_MOUNT_LOCAL_FCNTL		0x200000
+
 	unsigned int		caps;		/* server capabilities */
 	unsigned int		rsize;		/* read size */
 	unsigned int		rpages;		/* read size (in pages) */
diff --git a/include/uapi/linux/nfs_mount.h b/include/uapi/linux/nfs_mount.h
index e44e00616ab5..e3bcfc6aa3b0 100644
--- a/include/uapi/linux/nfs_mount.h
+++ b/include/uapi/linux/nfs_mount.h
@@ -66,13 +66,4 @@ struct nfs_mount_data {
 #define NFS_MOUNT_UNSHARED	0x8000	/* 5 */
 #define NFS_MOUNT_FLAGMASK	0xFFFF
 
-/* The following are for internal use only */
-#define NFS_MOUNT_LOOKUP_CACHE_NONEG	0x10000
-#define NFS_MOUNT_LOOKUP_CACHE_NONE	0x20000
-#define NFS_MOUNT_NORESVPORT		0x40000
-#define NFS_MOUNT_LEGACY_INTERFACE	0x80000
-
-#define NFS_MOUNT_LOCAL_FLOCK	0x100000
-#define NFS_MOUNT_LOCAL_FCNTL	0x200000
-
 #endif
-- 
2.20.1

