Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55342 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752743AbcB2ISQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Feb 2016 03:18:16 -0500
From: Andreas Gruenbacher <agruenba@redhat.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        "Theodore Ts'o" <tytso@mit.edu>, linux-cifs@vger.kernel.org,
        linux-api@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-kernel@vger.kernel.org, xfs@oss.sgi.com,
        Christoph Hellwig <hch@infradead.org>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        linux-fsdevel@vger.kernel.org, Jeff Layton <jlayton@poochiereds.net>,
        linux-ext4@vger.kernel.org, Anna Schumaker <anna.schumaker@netapp.com>
Subject: [PATCH v18 12/22] vfs: Add get_richacl and set_richacl inode operations
Date: Mon, 29 Feb 2016 09:17:17 +0100
Message-Id: <1456733847-17982-13-git-send-email-agruenba@redhat.com>
In-Reply-To: <1456733847-17982-1-git-send-email-agruenba@redhat.com>
References: <1456733847-17982-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These operations are similar to the get_acl and set_acl operations for
POSIX ACLs.  The distinction between access and default ACLs doesn't exist
for richacls.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 include/linux/fs.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 3db7729..e04dbb4 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1682,6 +1682,7 @@ struct inode_operations {
 	const char * (*get_link) (struct dentry *, struct inode *, struct delayed_call *);
 	int (*permission) (struct inode *, int);
 	struct posix_acl * (*get_acl)(struct inode *, int);
+	struct richacl * (*get_richacl)(struct inode *);
 
 	int (*readlink) (struct dentry *, char __user *,int);
 
@@ -1710,6 +1711,7 @@ struct inode_operations {
 			   umode_t create_mode, int *opened);
 	int (*tmpfile) (struct inode *, struct dentry *, umode_t);
 	int (*set_acl)(struct inode *, struct posix_acl *, int);
+	int (*set_richacl)(struct inode *, struct richacl *);
 } ____cacheline_aligned;
 
 ssize_t rw_copy_check_uvector(int type, const struct iovec __user * uvector,
-- 
2.4.3

