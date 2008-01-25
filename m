From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 061/112] NFS: Address a couple of nits in
	nfs_follow_referral()
Date: Fri, 25 Jan 2008 11:37:44 -0500
Message-ID: <20080125163743.31887.94331.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14364 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755583AbYAYRAC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:02 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxsem010226
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:01 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Clean up: fix an outdated block comment, and address a comparison
between a signed and unsigned integer.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
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
