Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:10040 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754138Ab1DJP4q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 10 Apr 2011 11:56:46 -0400
Date: Sun, 10 Apr 2011 17:57:07 +0200 (CEST)
From: Jesper Juhl <jj@chaosbits.net>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] NFS: Remove dead code from nfs_fs_mount()
Message-ID: <alpine.LNX.2.00.1104101750220.17454@swampdragon.chaosbits.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

In fs/nfs/super.c::nfs_fs_mount() we test for a NULL 'data':

...
 		if (data == NULL || mntfh == NULL)
 			goto out_free_fh;
...

and then further down in the function we test 'data' again:

...
 			nfs_fscache_get_super_cookie(
 				s, data ? data->fscache_uniq : NULL, NULL);
...

this second check is just dead code since there is no way 'data' could 
possibly be NULL here.
We also rely on a non-NULL 'data' in more than one location between these 
two tests, further proving the point that the second test is bogus.

This patch removes the dead code.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 super.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 2b8e9a5..685a8a7 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2235,8 +2235,7 @@ static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 	if (!s->s_root) {
 		/* initial superblock/root creation */
 		nfs_fill_super(s, data);
-		nfs_fscache_get_super_cookie(
-			s, data ? data->fscache_uniq : NULL, NULL);
+		nfs_fscache_get_super_cookie(s, data->fscache_uniq, NULL);
 	}
 
 	mntroot = nfs_get_root(s, mntfh, dev_name);


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.

