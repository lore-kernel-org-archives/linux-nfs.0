From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 2/4] nfs: replace while loop by for loops in nfs_follow_referral
Date: Wed, 20 Aug 2008 16:10:21 -0400
Message-ID: <1219263023-22592-2-git-send-email-bfields@citi.umich.edu>
References: <20080820200827.GC21226@fieldses.org>
 <1219263023-22592-1-git-send-email-bfields@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:37976 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751526AbYHTUKZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Aug 2008 16:10:25 -0400
In-Reply-To: <1219263023-22592-1-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Whoever wrote this had a bizarre allergy to for loops.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfs/nfs4namespace.c |   17 +++++------------
 1 files changed, 5 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 956cbbc..6bcc569 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -116,24 +116,22 @@ static struct vfsmount *try_location(struct nfs_clone_mount *mountdata,
 {
 	struct vfsmount *mnt = ERR_PTR(-ENOENT);
 	char *mnt_path;
-	unsigned int s = 0;
+	unsigned int s;
 
 	mnt_path = nfs4_pathname_string(&location->rootpath, page2, PAGE_SIZE);
 	if (IS_ERR(mnt_path))
 		return mnt;
 	mountdata->mnt_path = mnt_path;
 
-	while (s < location->nservers) {
+	for (s = 0; s < location->nservers; s++) {
 		struct sockaddr_in addr = {
 			.sin_family	= AF_INET,
 			.sin_port	= htons(NFS_PORT),
 		};
 
 		if (location->servers[s].len <= 0 ||
-		    valid_ipaddr4(location->servers[s].data) < 0) {
-			s++;
+		    valid_ipaddr4(location->servers[s].data) < 0)
 			continue;
-		}
 
 		mountdata->hostname = location->servers[s].data;
 		addr.sin_addr.s_addr = in_aton(mountdata->hostname),
@@ -147,7 +145,6 @@ static struct vfsmount *try_location(struct nfs_clone_mount *mountdata,
 		mnt = vfs_kern_mount(&nfs4_referral_fs_type, 0, page, mountdata);
 		if (!IS_ERR(mnt))
 			break;
-		s++;
 	}
 	return mnt;
 }
@@ -193,20 +190,16 @@ static struct vfsmount *nfs_follow_referral(const struct vfsmount *mnt_parent,
 		goto out;
 	}
 
-	loc = 0;
-	while (loc < locations->nlocations) {
+	for (loc = 0; loc < locations->nlocations; loc++) {
 		const struct nfs4_fs_location *location = &locations->locations[loc];
 
 		if (location == NULL || location->nservers <= 0 ||
-		    location->rootpath.ncomponents == 0) {
-			loc++;
+		    location->rootpath.ncomponents == 0)
 			continue;
-		}
 
 		mnt = try_location(&mountdata, page, page2, location);
 		if (!IS_ERR(mnt))
 			break;
-		loc++;
 	}
 
 out:
-- 
1.5.5.rc1

