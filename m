Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50126 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751672AbcJKMvz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 11 Oct 2016 08:51:55 -0400
From: Andreas Gruenbacher <agruenba@redhat.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Andreas Gruenbacher <agruenba@redhat.com>,
        Christoph Hellwig <hch@infradead.org>, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Dave Chinner <david@fromorbit.com>, linux-ext4@vger.kernel.org,
        xfs@oss.sgi.com, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-api@vger.kernel.org
Subject: [PATCH v27 10/21] vfs: Add get_richacl and set_richacl inode operations
Date: Tue, 11 Oct 2016 14:50:45 +0200
Message-Id: <1476190256-1677-11-git-send-email-agruenba@redhat.com>
In-Reply-To: <1476190256-1677-1-git-send-email-agruenba@redhat.com>
References: <1476190256-1677-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These operations are similar to the get_acl and set_acl operations for
POSIX ACLs.  The distinction between access and default ACLs doesn't exist
for richacls.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
Reviewed-by: Steve French <steve.french@primarydata.com>
---
 include/linux/fs.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 3becec0..ae6fe9f 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1748,6 +1748,7 @@ struct inode_operations {
 	const char * (*get_link) (struct dentry *, struct inode *, struct delayed_call *);
 	int (*permission) (struct inode *, int);
 	struct posix_acl * (*get_acl)(struct inode *, int);
+	struct richacl * (*get_richacl)(struct inode *);
 
 	int (*readlink) (struct dentry *, char __user *,int);
 
@@ -1771,6 +1772,7 @@ struct inode_operations {
 			   umode_t create_mode, int *opened);
 	int (*tmpfile) (struct inode *, struct dentry *, umode_t);
 	int (*set_acl)(struct inode *, struct posix_acl *, int);
+	int (*set_richacl)(struct inode *, struct richacl *);
 } ____cacheline_aligned;
 
 ssize_t rw_copy_check_uvector(int type, const struct iovec __user * uvector,
-- 
2.7.4

