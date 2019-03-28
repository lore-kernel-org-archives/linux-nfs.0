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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60762C43381
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3198E21850
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sf78+BTY"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726290AbfC1U4W (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 28 Mar 2019 16:56:22 -0400
Received: from mail-it1-f195.google.com ([209.85.166.195]:39033 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726410AbfC1U4W (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Mar 2019 16:56:22 -0400
Received: by mail-it1-f195.google.com with SMTP id 139so464867ita.4
        for <linux-nfs@vger.kernel.org>; Thu, 28 Mar 2019 13:56:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=mwfeG0Gf7M/QU7b8u/ldks9fFNeQ/gAOdGtccXlhHH0=;
        b=sf78+BTYX3PLCDzj7Zj55MfzQCA/PaZBdmLvZP2zLMm5YlBserI6fG0ojHb26AA7yp
         mh6mYvAcfSSDJ4veSL13f6zX+1x35CD1WxQkG/5eCQaWZpuj0xBLG2QOwlNAfKryPbIL
         EryJ/b9rj2zm7d2Ob6RNWaitqV3pM1ZNzMUd7Pq6oQnnvTH4wC1AQZvujgVtMpb+DkwG
         XB613I9zkPSdDVNocIdaBW/ULDQkJYrbMfdsSdmWeTwtwalWOJXUbZOA31/GaC/Dlh1c
         YgOG6NFRPc58Shz/f+E1Xkr77Ceiptd3hI2t3NxPaTaDelpjN624/wSZBGUBry/3Pdm9
         rvJw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=mwfeG0Gf7M/QU7b8u/ldks9fFNeQ/gAOdGtccXlhHH0=;
        b=IJiLTaZ38xL6xBHwL6KXC/T2Vpg/bBNn/jT2/a/U57sGgmQUCfv59cLL1Dpcsp66Xr
         F/0JmNTSvNk8ueJhtccau1miLAOjy9NVN0yvNS762mMAzfB5Ib1c5LNJSfOdfnbCuWs/
         Mz5GrPLyoXsb5RKzxYvfFvYN8yI+XUGyTRk4oHUve9Sy0IONefyUWitPDP1sQNgXAWWM
         vYFYz9liSpn+2y5z1mUFxIDzk+9FxKXGQVikxo2DClJmw4bLcJmsxvltCeV296/S/dhU
         Lmr9adwqrLq2mluAVMI7OFye0hsijKlHsrK+5knQxfmLqM2BqpoaBi155ZA/PAlL2ZWo
         v/Lw==
X-Gm-Message-State: APjAAAWIO2ghUw9qLFerkaj3m7y5k7KXWyOBzaaiMsA7/oMaYzEdyxME
        mR0HdETj+hd8logHAMqF7XIGiuc=
X-Google-Smtp-Source: APXvYqyaCQqG2vS4Fc8T2Va9Da+e0C9iODZw1nrAwpfJZ4jf3fEBjOWIf2b4AWM/+9Lq86fQ0sgwTQ==
X-Received: by 2002:a24:df87:: with SMTP id r129mr1726270itg.178.1553806581274;
        Thu, 28 Mar 2019 13:56:21 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id t67sm1084750ita.35.2019.03.28.13.56.20
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Mar 2019 13:56:20 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 14/25] NFS: Move internal constants out of uapi/linux/nfs_mount.h
Date:   Thu, 28 Mar 2019 16:52:28 -0400
Message-Id: <20190328205239.29674-15-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190328205239.29674-14-trond.myklebust@hammerspace.com>
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

