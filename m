Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f45.google.com ([209.85.216.45]:39275 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751847Ab3KBK5Y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 2 Nov 2013 06:57:24 -0400
Received: by mail-qa0-f45.google.com with SMTP id ii20so1159914qab.11
        for <linux-nfs@vger.kernel.org>; Sat, 02 Nov 2013 03:57:23 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, dpquigl@davequigley.com
Subject: [PATCH] nfs: set security label when revalidating inode
Date: Sat,  2 Nov 2013 06:57:18 -0400
Message-Id: <1383389838-1858-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, we fetch the security label when revalidating an inode's
attributes, but don't apply it. This is in contrast to the readdir()
codepath where we do apply label changes.

Cc: Dave Quigley <dpquigl@davequigley.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/inode.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 4bc7538..6ae6160 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -923,6 +923,8 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 	if (nfsi->cache_validity & NFS_INO_INVALID_ACL)
 		nfs_zap_acl_cache(inode);
 
+	nfs_setsecurity(inode, fattr, label);
+
 	dfprintk(PAGECACHE, "NFS: (%s/%Ld) revalidation complete\n",
 		inode->i_sb->s_id,
 		(long long)NFS_FILEID(inode));
-- 
1.8.3.1

