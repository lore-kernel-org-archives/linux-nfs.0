Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:56072 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388403AbeGXTix (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jul 2018 15:38:53 -0400
Received: by mail-it0-f66.google.com with SMTP id 16-v6so5102101itl.5
        for <linux-nfs@vger.kernel.org>; Tue, 24 Jul 2018 11:31:07 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Olga Kornievskaia <aglo@umich.edu>
Subject: [PATCH v2 2/2] NFS: More excessive attribute revalidation in nfs_execute_ok()
Date: Tue, 24 Jul 2018 14:30:38 -0400
Message-Id: <20180724183038.12201-2-trond.myklebust@hammerspace.com>
In-Reply-To: <20180724183038.12201-1-trond.myklebust@hammerspace.com>
References: <20180724183038.12201-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

execute_ok() will only check the mode bits if the object is not a
directory, so we don't need to revalidate the attributes in that case.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/dir.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index e7bc68fcbdf4..f0e39583af7e 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2500,6 +2500,8 @@ static int nfs_execute_ok(struct inode *inode, int mask)
 	struct nfs_server *server = NFS_SERVER(inode);
 	int ret = 0;
 
+	if (S_ISDIR(inode->i_mode))
+		return 0;
 	if (nfs_check_cache_invalid(inode, NFS_INO_INVALID_OTHER)) {
 		if (mask & MAY_NOT_BLOCK)
 			return -ECHILD;
-- 
2.17.1

