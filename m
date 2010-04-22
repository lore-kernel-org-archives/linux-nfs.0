From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 4/5] nfs: testing for null instead of ERR_PTR()
Date: Thu, 22 Apr 2010 16:50:20 -0400
Message-ID: <1271969421-7443-5-git-send-email-Trond.Myklebust@netapp.com>
References: <1271969421-7443-1-git-send-email-Trond.Myklebust@netapp.com>
 <1271969421-7443-2-git-send-email-Trond.Myklebust@netapp.com>
 <1271969421-7443-3-git-send-email-Trond.Myklebust@netapp.com>
 <1271969421-7443-4-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:56493 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754975Ab0DVUu0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Apr 2010 16:50:26 -0400
Received: from localhost.localdomain (kmanoj02-lxp.hq.netapp.com [10.58.60.82] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3MKoMJ9026155
	for <linux-nfs@vger.kernel.org>; Thu, 22 Apr 2010 13:50:25 -0700 (PDT)
In-Reply-To: <1271969421-7443-4-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>

nfs_path() returns an ERR_PTR(), it doesn't return null.

Signed-off-by: Dan Carpenter <error27@gmail.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/super.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index e016372..f9327bb 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2657,7 +2657,7 @@ static void nfs_fix_devname(const struct path *path, struct vfsmount *mnt)
 	devname = nfs_path(path->mnt->mnt_devname,
 			path->mnt->mnt_root, path->dentry,
 			page, PAGE_SIZE);
-	if (devname == NULL)
+	if (IS_ERR(devname))
 		goto out_freepage;
 	tmp = kstrdup(devname, GFP_KERNEL);
 	if (tmp == NULL)
-- 
1.6.6.1

