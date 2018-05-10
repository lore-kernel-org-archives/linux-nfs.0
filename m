Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:37403 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751899AbeEJT3W (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 10 May 2018 15:29:22 -0400
Received: by mail-it0-f67.google.com with SMTP id 70-v6so4538810ity.2
        for <linux-nfs@vger.kernel.org>; Thu, 10 May 2018 12:29:22 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id i12-v6sm713921iod.85.2018.05.10.12.29.20
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 10 May 2018 12:29:20 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] NFS: If the VFS sets LOOKUP_REVAL then force a lookup of the dentry
Date: Thu, 10 May 2018 15:28:57 -0400
Message-Id: <20180510192858.18539-2-trond.myklebust@hammerspace.com>
In-Reply-To: <20180510192858.18539-1-trond.myklebust@hammerspace.com>
References: <20180510192858.18539-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If nfs_lookup_revalidate() is called with LOOKUP_REVAL because a
previous path lookup failed, then we ought to force a full lookup
of the component name.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/dir.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 4a73bd8b4517..9dde88334c9c 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1118,7 +1118,7 @@ static int nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 		goto out_set_verifier;
 
 	/* Force a full look up iff the parent directory has changed */
-	if (!nfs_is_exclusive_create(dir, flags) &&
+	if (!(flags & (LOOKUP_EXCL | LOOKUP_REVAL)) &&
 	    nfs_check_verifier(dir, dentry, flags & LOOKUP_RCU)) {
 		error = nfs_lookup_verify_inode(inode, flags);
 		if (error) {
-- 
2.17.0

