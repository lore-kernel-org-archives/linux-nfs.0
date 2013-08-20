Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:16636 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751789Ab3HTTfS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Aug 2013 15:35:18 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 03/16] NFS: Pass in lookup flags from nfs_atomic_open to nfs_lookup
Date: Tue, 20 Aug 2013 15:34:59 -0400
Message-ID: <1377027312-45957-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1377027312-45957-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1377027312-45957-1-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-2-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-3-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When doing an open of a directory, ensure that we do pass the lookup flags
from nfs_atomic_open into nfs_lookup.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index a27b2d2..4b822b7 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1407,6 +1407,7 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 	struct dentry *res;
 	struct iattr attr = { .ia_valid = ATTR_OPEN };
 	struct inode *inode;
+	unsigned int lookup_flags = 0;
 	int err;
 
 	/* Expect a negative dentry */
@@ -1429,6 +1430,7 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 			 */
 			return -ENOENT;
 		}
+		lookup_flags = LOOKUP_OPEN|LOOKUP_DIRECTORY;
 		goto no_open;
 	}
 
@@ -1479,7 +1481,7 @@ out:
 	return err;
 
 no_open:
-	res = nfs_lookup(dir, dentry, 0);
+	res = nfs_lookup(dir, dentry, lookup_flags);
 	err = PTR_ERR(res);
 	if (IS_ERR(res))
 		goto out;
-- 
1.8.3.1

