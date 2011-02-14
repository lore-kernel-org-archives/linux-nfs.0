Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:11381 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751375Ab1BNV5h (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Feb 2011 16:57:37 -0500
Date: Mon, 14 Feb 2011 22:56:33 +0100 (CET)
From: Jesper Juhl <jj@chaosbits.net>
To: linux-nfs@vger.kernel.org
cc: linux-kernel@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH] NFS: Zap entire 'struct inode' in nfs_zap_caches_locked().
Message-ID: <alpine.LNX.2.00.1102142252540.4530@swampdragon.chaosbits.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

nfs_zap_caches_locked() attempts to zero all of the 'struct inode' that's 
passed in via the pointer variable 'inode'. Unfortunately it only manages 
to zero the size of a 'pointer to struct inode'. Fix that.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 inode.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

 compile tested only

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 1cc600e..6c4236e 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -145,7 +145,7 @@ static void nfs_zap_caches_locked(struct inode *inode)
 	nfsi->attrtimeo = NFS_MINATTRTIMEO(inode);
 	nfsi->attrtimeo_timestamp = jiffies;
 
-	memset(NFS_COOKIEVERF(inode), 0, sizeof(NFS_COOKIEVERF(inode)));
+	memset(NFS_COOKIEVERF(inode), 0, sizeof(*NFS_COOKIEVERF(inode)));
 	if (S_ISREG(mode) || S_ISDIR(mode) || S_ISLNK(mode))
 		nfsi->cache_validity |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL|NFS_INO_REVAL_PAGECACHE;
 	else


-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Plain text mails only, please.
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html

