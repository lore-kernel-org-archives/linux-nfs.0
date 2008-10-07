From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 20/30] nfs: break up nfs_follow_referral
Date: Tue, 07 Oct 2008 18:19:53 -0400
Message-ID: <20081007221953.20945.5253.stgit@localhost.localdomain>
References: <20081007221952.20945.69529.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4712 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755913AbYJGWcq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Oct 2008 18:32:46 -0400
In-Reply-To: <20081007221952.20945.69529.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

This function is a little longer and more deeply nested than necessary.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4namespace.c |   84 ++++++++++++++++++++++++++----------------------
 1 files changed, 46 insertions(+), 38 deletions(-)

diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index b112857..956cbbc 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -110,6 +110,48 @@ static inline int valid_ipaddr4(const char *buf)
 	return 0;
 }
 
+static struct vfsmount *try_location(struct nfs_clone_mount *mountdata,
+				     char *page, char *page2,
+				     const struct nfs4_fs_location *location)
+{
+	struct vfsmount *mnt = ERR_PTR(-ENOENT);
+	char *mnt_path;
+	unsigned int s = 0;
+
+	mnt_path = nfs4_pathname_string(&location->rootpath, page2, PAGE_SIZE);
+	if (IS_ERR(mnt_path))
+		return mnt;
+	mountdata->mnt_path = mnt_path;
+
+	while (s < location->nservers) {
+		struct sockaddr_in addr = {
+			.sin_family	= AF_INET,
+			.sin_port	= htons(NFS_PORT),
+		};
+
+		if (location->servers[s].len <= 0 ||
+		    valid_ipaddr4(location->servers[s].data) < 0) {
+			s++;
+			continue;
+		}
+
+		mountdata->hostname = location->servers[s].data;
+		addr.sin_addr.s_addr = in_aton(mountdata->hostname),
+		mountdata->addr = (struct sockaddr *)&addr;
+		mountdata->addrlen = sizeof(addr);
+
+		snprintf(page, PAGE_SIZE, "%s:%s",
+				mountdata->hostname,
+				mountdata->mnt_path);
+
+		mnt = vfs_kern_mount(&nfs4_referral_fs_type, 0, page, mountdata);
+		if (!IS_ERR(mnt))
+			break;
+		s++;
+	}
+	return mnt;
+}
+
 /**
  * nfs_follow_referral - set up mountpoint when hitting a referral on moved error
  * @mnt_parent - mountpoint of parent directory
@@ -128,7 +170,6 @@ static struct vfsmount *nfs_follow_referral(const struct vfsmount *mnt_parent,
 		.authflavor = NFS_SB(mnt_parent->mnt_sb)->client->cl_auth->au_flavor,
 	};
 	char *page = NULL, *page2 = NULL;
-	unsigned int s;
 	int loc, error;
 
 	if (locations == NULL || locations->nlocations <= 0)
@@ -153,9 +194,8 @@ static struct vfsmount *nfs_follow_referral(const struct vfsmount *mnt_parent,
 	}
 
 	loc = 0;
-	while (loc < locations->nlocations && IS_ERR(mnt)) {
+	while (loc < locations->nlocations) {
 		const struct nfs4_fs_location *location = &locations->locations[loc];
-		char *mnt_path;
 
 		if (location == NULL || location->nservers <= 0 ||
 		    location->rootpath.ncomponents == 0) {
@@ -163,41 +203,9 @@ static struct vfsmount *nfs_follow_referral(const struct vfsmount *mnt_parent,
 			continue;
 		}
 
-		mnt_path = nfs4_pathname_string(&location->rootpath, page2, PAGE_SIZE);
-		if (IS_ERR(mnt_path)) {
-			loc++;
-			continue;
-		}
-		mountdata.mnt_path = mnt_path;
-
-		s = 0;
-		while (s < location->nservers) {
-			struct sockaddr_in addr = {
-				.sin_family	= AF_INET,
-				.sin_port	= htons(NFS_PORT),
-			};
-
-			if (location->servers[s].len <= 0 ||
-			    valid_ipaddr4(location->servers[s].data) < 0) {
-				s++;
-				continue;
-			}
-
-			mountdata.hostname = location->servers[s].data;
-			addr.sin_addr.s_addr = in_aton(mountdata.hostname),
-			mountdata.addr = (struct sockaddr *)&addr;
-			mountdata.addrlen = sizeof(addr);
-
-			snprintf(page, PAGE_SIZE, "%s:%s",
-					mountdata.hostname,
-					mountdata.mnt_path);
-
-			mnt = vfs_kern_mount(&nfs4_referral_fs_type, 0, page, &mountdata);
-			if (!IS_ERR(mnt)) {
-				break;
-			}
-			s++;
-		}
+		mnt = try_location(&mountdata, page, page2, location);
+		if (!IS_ERR(mnt))
+			break;
 		loc++;
 	}
 

