From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 10/30] NFSv4: A referral is assumed to always point to a
 directory.
Date: Wed, 11 Mar 2009 14:41:07 -0400
Message-ID: <20090311184107.5578.78727.stgit@heimdal.trondhjem.org>
References: <20090311184105.5578.22131.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43206 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754623AbZCKSoL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 14:44:11 -0400
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n2BIi3YK021751
	for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2009 11:44:09 -0700 (PDT)
In-Reply-To: <20090311184105.5578.22131.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix a bug whereby we would fail to create a mount point for a referral.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4proc.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)


diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8dde84b..aa433d0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3678,6 +3678,19 @@ ssize_t nfs4_listxattr(struct dentry *dentry, char *buf, size_t buflen)
 	return len;
 }
 
+static void nfs_fixup_referral_attributes(struct nfs_fattr *fattr)
+{
+	if (!((fattr->valid & NFS_ATTR_FATTR_FILEID) &&
+		(fattr->valid & NFS_ATTR_FATTR_FSID) &&
+		(fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL)))
+		return;
+
+	fattr->valid |= NFS_ATTR_FATTR_TYPE | NFS_ATTR_FATTR_MODE |
+		NFS_ATTR_FATTR_NLINK;
+	fattr->mode = S_IFDIR | S_IRUGO | S_IXUGO;
+	fattr->nlink = 2;
+}
+
 int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 		struct nfs4_fs_locations *fs_locations, struct page *page)
 {
@@ -3704,6 +3717,7 @@ int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 	fs_locations->server = server;
 	fs_locations->nlocations = 0;
 	status = rpc_call_sync(server->client, &msg, 0);
+	nfs_fixup_referral_attributes(&fs_locations->fattr);
 	dprintk("%s: returned status = %d\n", __func__, status);
 	return status;
 }

