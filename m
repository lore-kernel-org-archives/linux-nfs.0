From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 2/5] NFSv4: Don't attempt an atomic open if the file is a mountpoint
Date: Thu, 22 Apr 2010 16:50:18 -0400
Message-ID: <1271969421-7443-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1271969421-7443-1-git-send-email-Trond.Myklebust@netapp.com>
 <1271969421-7443-2-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52860 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755425Ab0DVUu0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Apr 2010 16:50:26 -0400
Received: from localhost.localdomain (kmanoj02-lxp.hq.netapp.com [10.58.60.82] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3MKoMJ7026155
	for <linux-nfs@vger.kernel.org>; Thu, 22 Apr 2010 13:50:23 -0700 (PDT)
In-Reply-To: <1271969421-7443-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix https://bugzilla.kernel.org/show_bug.cgi?id=15789

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index be46f26..fbb4cf7 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1050,7 +1050,7 @@ static int nfs_open_revalidate(struct dentry *dentry, struct nameidata *nd)
 	struct inode *dir;
 	int openflags, ret = 0;
 
-	if (!is_atomic_open(nd))
+	if (!is_atomic_open(nd) || d_mountpoint(dentry))
 		goto no_open;
 	parent = dget_parent(dentry);
 	dir = parent->d_inode;
-- 
1.6.6.1

