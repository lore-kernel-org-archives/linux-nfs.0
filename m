Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from szxga04-in.huawei.com ([45.249.212.190]:13114 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727114AbeIYRUs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 25 Sep 2018 13:20:48 -0400
From: YueHaibing <yuehaibing@huawei.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>
CC: YueHaibing <yuehaibing@huawei.com>, <linux-nfs@vger.kernel.org>,
        <kernel-janitors@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Subject: [PATCH -next] nfsd: remove set but not used variable 'dirp'
Date: Tue, 25 Sep 2018 11:22:53 +0000
Message-ID: <1537874573-182553-1-git-send-email-yuehaibing@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fixes gcc '-Wunused-but-set-variable' warning:

fs/nfsd/vfs.c: In function 'nfsd_create':
fs/nfsd/vfs.c:1279:16: warning:
 variable 'dirp' set but not used [-Wunused-but-set-variable]

Signed-off-by: YueHaibing <yuehaibing@huawei.com>
---
 fs/nfsd/vfs.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index b53e763..d74583f 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1276,7 +1276,6 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		int type, dev_t rdev, struct svc_fh *resfhp)
 {
 	struct dentry	*dentry, *dchild = NULL;
-	struct inode	*dirp;
 	__be32		err;
 	int		host_err;
 
@@ -1288,7 +1287,6 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		return err;
 
 	dentry = fhp->fh_dentry;
-	dirp = d_inode(dentry);
 
 	host_err = fh_want_write(fhp);
 	if (host_err)
