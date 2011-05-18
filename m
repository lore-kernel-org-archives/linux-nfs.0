Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38851 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933623Ab1ERTTv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 May 2011 15:19:51 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [RFC PATCH 2/2] locks: break lease on unlink
Date: Wed, 18 May 2011 15:19:48 -0400
Message-Id: <1305746388-18241-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1305746388-18241-1-git-send-email-bfields@redhat.com>
References: <1305746388-18241-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

NFSv4 uses leases (delegations) to allow clients to do opens locally.
An open takes a component name, so to do a local open a client needs to
know that at least that last component name points at the same time as
long as they hold the delegation.  For that reason, the NFSv4 spec
requires that delegations be broken on unlink.

Waiting for a lease to be broken may mean waiting for an nfs client or a
user process to give it up, so doing that while holding the i_mutex
would risk deadlocks.  So instead we do a non-blocking lease break, then
drop the i_mutex and do a blocking lease break if necessary.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/namei.c    |   32 ++++++++++++++++++++++++++++----
 fs/nfsd/vfs.c |    6 +++++-
 2 files changed, 33 insertions(+), 5 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 079e68c..4661469 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2799,6 +2799,7 @@ static long do_unlinkat(int dfd, const char __user *pathname)
 
 	nd.flags &= ~LOOKUP_PARENT;
 
+retry:
 	mutex_lock_nested(&nd.path.dentry->d_inode->i_mutex, I_MUTEX_PARENT);
 	dentry = lookup_hash(&nd);
 	error = PTR_ERR(dentry);
@@ -2806,15 +2807,27 @@ static long do_unlinkat(int dfd, const char __user *pathname)
 		/* Why not before? Because we want correct error value */
 		if (nd.last.name[nd.last.len])
 			goto slashes;
-		inode = dentry->d_inode;
-		if (inode)
-			ihold(inode);
+		if (inode && inode != dentry->d_inode) {
+			reallow_leases(inode, O_WRONLY);
+			iput(inode);
+			inode = NULL;
+		}
+		if (!inode) {
+			inode = dentry->d_inode;
+			if (inode)
+				ihold(inode);
+			disallow_leases(inode, O_WRONLY);
+		}
 		error = mnt_want_write(nd.path.mnt);
 		if (error)
 			goto exit2;
 		error = security_path_unlink(&nd.path, dentry);
 		if (error)
 			goto exit3;
+		if (inode)
+			error = break_lease(inode, O_WRONLY|O_NONBLOCK);
+		if (error)
+			goto exit3;
 		error = vfs_unlink(nd.path.dentry->d_inode, dentry);
 exit3:
 		mnt_drop_write(nd.path.mnt);
@@ -2822,8 +2835,19 @@ exit3:
 		dput(dentry);
 	}
 	mutex_unlock(&nd.path.dentry->d_inode->i_mutex);
-	if (inode)
+	if (inode) {
+		/* XXX: safe to use EWOULDBLOCK==EAGAIN to do this?: */
+		if (error == -EWOULDBLOCK) {
+			/*
+			 * Wait this time, then retry with leases left
+			 * disabled:
+			 */
+			break_lease(inode, O_WRONLY);
+			goto retry;
+		}
+		reallow_leases(inode, O_WRONLY);
 		iput(inode);	/* truncate the inode here */
+	}
 exit1:
 	path_put(&nd.path);
 	putname(name);
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index f4e056a..ef01b98 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1826,13 +1826,17 @@ nfsd_unlink(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
 	if (host_err)
 		goto out_put;
 
+	disallow_leases(rdentry->d_inode, O_WRONLY);
 	host_err = nfsd_break_lease(rdentry->d_inode);
-	if (host_err)
+	if (host_err) {
+		reallow_leases(rdentry->d_inode, O_WRONLY);
 		goto out_drop_write;
+	}
 	if (type != S_IFDIR)
 		host_err = vfs_unlink(dirp, rdentry);
 	else
 		host_err = vfs_rmdir(dirp, rdentry);
+	reallow_leases(rdentry->d_inode, O_WRONLY);
 	if (!host_err)
 		host_err = commit_metadata(fhp);
 out_drop_write:
-- 
1.7.4.1

