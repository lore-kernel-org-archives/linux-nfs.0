Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35468 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751616AbcBVPYH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Feb 2016 10:24:07 -0500
From: Deepa Dinamani <deepa.kernel@gmail.com>
To: linux-fsdevel@vger.kernel.org, y2038@lists.linaro.org
Cc: Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Subject: [PATCH 8/8] net: sunrpc: Replace CURRENT_TIME by current_fs_time()
Date: Mon, 22 Feb 2016 07:17:54 -0800
Message-Id: <1456154274-30487-9-git-send-email-deepa.kernel@gmail.com>
In-Reply-To: <1456154274-30487-1-git-send-email-deepa.kernel@gmail.com>
References: <1456154274-30487-1-git-send-email-deepa.kernel@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

CURRENT_TIME macro is not appropriate for filesystems as it
doesn't use the right granularity for filesystem timestamps.
Use current_fs_time() instead.

Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@poochiereds.net>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: linux-nfs@vger.kernel.org
Cc: netdev@vger.kernel.org
---
 net/sunrpc/rpc_pipe.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 31789ef..bab3187 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -477,7 +477,9 @@ rpc_get_inode(struct super_block *sb, umode_t mode)
 		return NULL;
 	inode->i_ino = get_next_ino();
 	inode->i_mode = mode;
-	inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+	inode->i_atime = current_fs_time(sb);
+	inode->i_mtime = inode->i_atime;
+	inode->i_ctime = inode->i_atime;
 	switch (mode & S_IFMT) {
 	case S_IFDIR:
 		inode->i_fop = &simple_dir_operations;
-- 
1.9.1

