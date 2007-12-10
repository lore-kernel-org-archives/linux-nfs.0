From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/27] NFS: Address a couple of nits in nfs_follow_referral()
Date: Mon, 10 Dec 2007 14:57:31 -0500
Message-ID: <20071210195731.2823.80554.stgit@manray.1015granger.net>
References: <20071210195106.2823.43884.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:31679 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756110AbXLJUEz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2007 15:04:55 -0500
In-Reply-To: <20071210195106.2823.43884.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: fix an outdated block comment, and address a comparison
between a signed and unsigned integer.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4namespace.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index dd5fef2..bd1b161 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -114,10 +114,7 @@ static inline int valid_ipaddr4(const char *buf)
  * nfs_follow_referral - set up mountpoint when hitting a referral on moved error
  * @mnt_parent - mountpoint of parent directory
  * @dentry - parent directory
- * @fspath - fs path returned in fs_locations
- * @mntpath - mount path to new server
- * @hostname - hostname of new server
- * @addr - host addr of new server
+ * @locations - array of NFSv4 server location information
  *
  */
 static struct vfsmount *nfs_follow_referral(const struct vfsmount *mnt_parent,
@@ -131,7 +128,8 @@ static struct vfsmount *nfs_follow_referral(const struct vfsmount *mnt_parent,
 		.authflavor = NFS_SB(mnt_parent->mnt_sb)->client->cl_auth->au_flavor,
 	};
 	char *page = NULL, *page2 = NULL;
-	int loc, s, error;
+	unsigned int s;
+	int loc, error;
 
 	if (locations == NULL || locations->nlocations <= 0)
 		goto out;

