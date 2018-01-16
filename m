Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:55598 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750878AbeAPJds (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Jan 2018 04:33:48 -0500
From: Arnd Bergmann <arnd@arndb.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Peng Tao <tao.peng@primarydata.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] nfs: remove unused label in nfs_encode_fh()
Date: Tue, 16 Jan 2018 10:33:14 +0100
Message-Id: <20180116093340.3163090-1-arnd@arndb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The only reference to the label got removed, so we now get
a harmless compiler warning:

fs/nfs/export.c: In function 'nfs_encode_fh':
fs/nfs/export.c:58:1: error: label 'out' defined but not used [-Werror=unused-label]

Fixes: aaa150089465 ("nfs: remove dead code from nfs_encode_fh()")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 fs/nfs/export.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfs/export.c b/fs/nfs/export.c
index 2b80a6652818..ab5de3246c5c 100644
--- a/fs/nfs/export.c
+++ b/fs/nfs/export.c
@@ -55,7 +55,6 @@ nfs_encode_fh(struct inode *inode, __u32 *p, int *max_len, struct inode *parent)
 	p[len - 1] = 0; /* Padding */
 	nfs_copy_fh(clnt_fh, server_fh);
 	*max_len = len;
-out:
 	dprintk("%s: result fh fileid %llu mode %u size %d\n",
 		__func__, NFS_FILEID(inode), inode->i_mode, *max_len);
 	return *max_len;
-- 
2.9.0

