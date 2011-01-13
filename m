Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mfbichi11.ns.itscom.net ([219.110.2.189]:44791 "EHLO
	mfbichi11.ns.itscom.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751498Ab1AMNbT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Jan 2011 08:31:19 -0500
From: "J. R. Okajima" <hooanon05@yahoo.co.jp>
Subject: Re: NFS root lockups with -next 20110113
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Santosh Shilimkar <santosh.shilimkar@ti.com>,
        Nick Piggin <npiggin@kernel.dk>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
In-Reply-To: <20110113120626.GB30351@opensource.wolfsonmicro.com>
References: <20110113120626.GB30351@opensource.wolfsonmicro.com>
Date: Thu, 13 Jan 2011 22:22:07 +0900
Message-ID: <8138.1294924927@jrobl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


Mark Brown:
> With -next 20110113 I'm experiencing lockups shortly after userspace
> starts when booting with my root filesystem on NFS, log below.  I can
> boot into /bin/sh but running real userspace triggers this very easily.
> This was introduced sometime this week.
>
> I've not bisected or otherwise investigated much yet, but I do notice
> code added recently by Nick in "fs: rcu-walk for path lookup" showing up
> in the backtrace so including him in the CCs.

This and a report from Santosh Shilimkar look like the same problem
which I reported, and I am testing this patch. If you can, please try it
too.
Note: Of course this is not offcial fix.


J. R. Okajima

diff --git a/fs/namei.c b/fs/namei.c
index 5bb7588..51d052f 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -480,6 +480,7 @@ static int nameidata_dentry_drop_rcu(struct nameidata *nd, struct dentry *dentry
 {
 	struct fs_struct *fs = current->fs;
 	struct dentry *parent = nd->path.dentry;
+	int isroot;
 
 	BUG_ON(!(nd->flags & LOOKUP_RCU));
 	if (nd->root.mnt) {
@@ -489,18 +490,22 @@ static int nameidata_dentry_drop_rcu(struct nameidata *nd, struct dentry *dentry
 			goto err_root;
 	}
 	spin_lock(&parent->d_lock);
-	spin_lock_nested(&dentry->d_lock, DENTRY_D_LOCK_NESTED);
-	if (!__d_rcu_to_refcount(dentry, nd->seq))
-		goto err;
+	isroot = IS_ROOT(dentry);
+	if (!isroot) {
+		spin_lock_nested(&dentry->d_lock, DENTRY_D_LOCK_NESTED);
+		if (!__d_rcu_to_refcount(dentry, nd->seq))
+			goto err;
+	}
 	/*
 	 * If the sequence check on the child dentry passed, then the child has
 	 * not been removed from its parent. This means the parent dentry must
 	 * be valid and able to take a reference at this point.
 	 */
-	BUG_ON(!IS_ROOT(dentry) && dentry->d_parent != parent);
+	BUG_ON(!isroot && dentry->d_parent != parent);
 	BUG_ON(!parent->d_count);
 	parent->d_count++;
-	spin_unlock(&dentry->d_lock);
+	if (!isroot)
+		spin_unlock(&dentry->d_lock);
 	spin_unlock(&parent->d_lock);
 	if (nd->root.mnt) {
 		path_get(&nd->root);
@@ -513,7 +518,8 @@ static int nameidata_dentry_drop_rcu(struct nameidata *nd, struct dentry *dentry
 	nd->flags &= ~LOOKUP_RCU;
 	return 0;
 err:
-	spin_unlock(&dentry->d_lock);
+	if (!isroot)
+		spin_unlock(&dentry->d_lock);
 	spin_unlock(&parent->d_lock);
 err_root:
 	if (nd->root.mnt)

