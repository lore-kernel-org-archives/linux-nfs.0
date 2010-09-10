Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24958 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752976Ab0IJT1W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Sep 2010 15:27:22 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o8AJRMdO017483
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 10 Sep 2010 15:27:22 -0400
Received: from dantu.rdu.redhat.com (dantu.rdu.redhat.com [10.11.228.66])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o8AJRIBX018810
	for <linux-nfs@vger.kernel.org>; Fri, 10 Sep 2010 15:27:21 -0400
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 6/9] nfs: eliminate qsilly var from nfs_sillyrename
Date: Fri, 10 Sep 2010 15:27:15 -0400
Message-Id: <1284146838-1468-7-git-send-email-jlayton@redhat.com>
In-Reply-To: <1284146838-1468-1-git-send-email-jlayton@redhat.com>
References: <1284146838-1468-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The sdentry should already have the same info in d_name.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/unlink.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 42cadd1..b9e8b36 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -328,7 +328,6 @@ nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 	const int      countersize = sizeof(sillycounter)*2;
 	const int      slen        = sizeof(".nfs")+fileidsize+countersize-1;
 	char           silly[slen+1];
-	struct qstr    qsilly;
 	struct dentry *sdentry;
 	int            error = -EIO;
 
@@ -371,9 +370,8 @@ nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 			goto out;
 	} while(sdentry->d_inode != NULL); /* need negative lookup */
 
-	qsilly.name = silly;
-	qsilly.len  = strlen(silly);
-	error = NFS_PROTO(dir)->rename(dir, &dentry->d_name, dir, &qsilly);
+	error = NFS_PROTO(dir)->rename(dir, &dentry->d_name, dir,
+					&sdentry->d_name);
 	if (dentry->d_inode)
 		nfs_mark_for_revalidate(dentry->d_inode);
 	if (!error) {
-- 
1.7.1

