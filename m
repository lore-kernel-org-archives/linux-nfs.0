From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 41/69] NFSv4: Ensure that we set the verifier when
 revalidating delegated dentries
Date: Tue, 23 Dec 2008 18:02:17 -0500
Message-ID: <20081223230217.13743.92897.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:45954 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752620AbYLWXXs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:48 -0500
Received: from svlrsexc1-prd.hq.netapp.com ([10.57.115.30])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNbsm006182
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:42 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This ensures that we don't have to look up the dentry again after we return
the delegation if we know that the directory didn't change.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/dir.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)


diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 121b533..ff167aa 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -799,6 +799,9 @@ static int nfs_lookup_revalidate(struct dentry * dentry, struct nameidata *nd)
 		goto out_bad;
 	}
 
+	if (nfs_have_delegation(inode, FMODE_READ))
+		goto out_set_verifier;
+
 	/* Force a full look up iff the parent directory has changed */
 	if (!nfs_is_exclusive_create(dir, nd) && nfs_check_verifier(dir, dentry)) {
 		if (nfs_lookup_verify_inode(inode, nd))
@@ -817,6 +820,7 @@ static int nfs_lookup_revalidate(struct dentry * dentry, struct nameidata *nd)
 	if ((error = nfs_refresh_inode(inode, &fattr)) != 0)
 		goto out_bad;
 
+out_set_verifier:
 	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
  out_valid:
 	dput(parent);
@@ -1084,8 +1088,6 @@ out:
 no_open_dput:
 	dput(parent);
 no_open:
-	if (inode != NULL && nfs_have_delegation(inode, FMODE_READ))
-		return 1;
 	return nfs_lookup_revalidate(dentry, nd);
 }
 #endif /* CONFIG_NFSV4 */

