Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f50.google.com ([74.125.83.50]:44031 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753657Ab3AUOyz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2013 09:54:55 -0500
Received: by mail-ee0-f50.google.com with SMTP id e51so2993972eek.9
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jan 2013 06:54:54 -0800 (PST)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Cc: Benny Halevy <bhalevy@tonian.com>
Subject: [PATCH 7/9] pnfsd: LR_FLAG_EMPTY layout return flag
Date: Mon, 21 Jan 2013 16:54:51 +0200
Message-Id: <1358780091-6151-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <50FD5646.4020206@tonian.com>
References: <50FD5646.4020206@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4pnfsd.c             | 8 +++++++-
 include/linux/nfsd/nfsd4_pnfs.h | 1 +
 2 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 2d4f23d..0b8c502 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -921,15 +921,21 @@ struct super_block *
 		struct inode *inode = lo->lo_file->fi_inode;
 		struct nfsd4_pnfs_layoutreturn lr;
 		bool empty;
+		int lr_flags = flags;
 
 		memset(&lr, 0, sizeof(lr));
 		lr.args.lr_return_type = RETURN_FILE;
 		lr.args.lr_seg = lo->lo_seg;
 
+		spin_lock(&layout_lock);
+		if (list_empty(&lo->lo_file->fi_layouts))
+			lr_flags |= LR_FLAG_EMPTY;
+		spin_unlock(&layout_lock);
+
 		list_del(&lo->lo_perfile);
 		empty = list_empty(lo_destroy_list);
 
-		fs_layout_return(inode, &lr, flags, empty ? cb_cookie : NULL);
+		fs_layout_return(inode, &lr, lr_flags, empty ? cb_cookie : NULL);
 
 		destroy_layout(lo); /* this will put the lo_file */
 	}
diff --git a/include/linux/nfsd/nfsd4_pnfs.h b/include/linux/nfsd/nfsd4_pnfs.h
index bfea9a6..ecb412e 100644
--- a/include/linux/nfsd/nfsd4_pnfs.h
+++ b/include/linux/nfsd/nfsd4_pnfs.h
@@ -114,6 +114,7 @@ enum layoutreturn_flags {
 	LR_FLAG_INTERN = 1 << 0,	/* internal return */
 	LR_FLAG_EXPIRE = 1 << 1,	/* return on client expiration */
 	LR_FLAG_CL_EMPTY = 1 << 2,	/* No more layout for returning client */
+	LR_FLAG_EMPTY = 1 << 3,		/* No more layout for file */
 };
 
 struct nfsd4_pnfs_layoutreturn_arg {
-- 
1.7.11.7

