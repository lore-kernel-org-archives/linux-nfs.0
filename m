Return-Path: <SRS0=26It=SA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C905BC10F05
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8D68F218A5
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jdDWNP6l"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730356AbfC2WCN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 29 Mar 2019 18:02:13 -0400
Received: from mail-it1-f195.google.com ([209.85.166.195]:55534 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730345AbfC2WCM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Mar 2019 18:02:12 -0400
Received: by mail-it1-f195.google.com with SMTP id z126so6167427itd.5
        for <linux-nfs@vger.kernel.org>; Fri, 29 Mar 2019 15:02:11 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=mwfeG0Gf7M/QU7b8u/ldks9fFNeQ/gAOdGtccXlhHH0=;
        b=jdDWNP6lcBPJvSonbOBjtWkXBFOGHkpQEcuHZBDR6WbkS8qa/BbeONb3sx2i8zd787
         YPXAml7Sq8Yp+W02lEPifT+HKYQsnUkNwS0J8TEcaXFKemLIxO8ejBjHjIv+1YWbY4fQ
         WZy8hMeUS1OLBLqvWsczDEEheShhd+UvROK0tmEj6rnKgiYr4/uIYWcRkdkFQfRqFaIG
         GmMJ8aYtneOuTg1olJGUxZcKqt5oLJz+vg8U1hgmasueqD97i6flUt9n+/YvqM6W8UZI
         mOA2A5cltEQqwK/DKZtOCwCioD4R35El0s6nCAGj6zeuS2dLfvK8k9yM6MwYvRQJlycR
         gNxg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=mwfeG0Gf7M/QU7b8u/ldks9fFNeQ/gAOdGtccXlhHH0=;
        b=RcF1Cs2ARcgdYLVR5AC1B7G3/+gqdeJWXch5vUYpPfmI0+ptGOn+/hCEX4IKAsXVpa
         QU9LqlokuaGnn4z4Gxjk1CQz+qVRMEIPHENFkQWsZPGKGD3BINRQ50JPX76iLB0pqtF8
         8LpXqceXhBDx5UgGwB3uDaRkPpmL4O60dxvmh4+XLED9OQhJbbnpVUW+eoZ03GSRJOLP
         m6YsG4FZA62UF2NCbOgC8sM7UTFTrAk+OXQG2XFzZS4kL3QiNvaJp2wPEw6TWIx3dI4d
         oV2Qxqz3SXuLkghWdgXBq59dAVB4HzJOEm/dIQdO4j61FRHG8iDMi0pWr1a6MdA1fAnm
         h8Aw==
X-Gm-Message-State: APjAAAVqM1aprw1VFcHtlmluH1iWkITxRvREL3hLbISvImscFZpsFGvC
        a8K9M0QEKmzJAwu0JHyBYApCEeM=
X-Google-Smtp-Source: APXvYqwuPDl65I9rQeEjlHELakJLQT7ITbA2+yakuikIt0wH5JO0ozikiLt8JcvKL9SkpGd2D2V0Qg==
X-Received: by 2002:a02:9108:: with SMTP id a8mr16553192jag.107.1553896930853;
        Fri, 29 Mar 2019 15:02:10 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id v20sm1376796ioh.17.2019.03.29.15.02.10
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 15:02:10 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 17/28] NFS: Move internal constants out of uapi/linux/nfs_mount.h
Date:   Fri, 29 Mar 2019 17:59:37 -0400
Message-Id: <20190329215948.107328-18-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190329215948.107328-17-trond.myklebust@hammerspace.com>
References: <20190329215948.107328-1-trond.myklebust@hammerspace.com>
 <20190329215948.107328-2-trond.myklebust@hammerspace.com>
 <20190329215948.107328-3-trond.myklebust@hammerspace.com>
 <20190329215948.107328-4-trond.myklebust@hammerspace.com>
 <20190329215948.107328-5-trond.myklebust@hammerspace.com>
 <20190329215948.107328-6-trond.myklebust@hammerspace.com>
 <20190329215948.107328-7-trond.myklebust@hammerspace.com>
 <20190329215948.107328-8-trond.myklebust@hammerspace.com>
 <20190329215948.107328-9-trond.myklebust@hammerspace.com>
 <20190329215948.107328-10-trond.myklebust@hammerspace.com>
 <20190329215948.107328-11-trond.myklebust@hammerspace.com>
 <20190329215948.107328-12-trond.myklebust@hammerspace.com>
 <20190329215948.107328-13-trond.myklebust@hammerspace.com>
 <20190329215948.107328-14-trond.myklebust@hammerspace.com>
 <20190329215948.107328-15-trond.myklebust@hammerspace.com>
 <20190329215948.107328-16-trond.myklebust@hammerspace.com>
 <20190329215948.107328-17-trond.myklebust@hammerspace.com>
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

