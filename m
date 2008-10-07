From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 21/30] nfs: replace while loop by for loops in
	nfs_follow_referral
Date: Tue, 07 Oct 2008 18:19:53 -0400
Message-ID: <20081007221953.20945.18180.stgit@localhost.localdomain>
References: <20081007221952.20945.69529.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4712 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755603AbYJGWcv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Oct 2008 18:32:51 -0400
In-Reply-To: <20081007221952.20945.69529.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

Whoever wrote this had a bizarre allergy to for loops.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
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

