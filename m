Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54988 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752672AbcGYOJw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Jul 2016 10:09:52 -0400
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
Subject: [PATCH v24 04/22] vfs: Make the inode passed to inode_change_ok non-const
Date: Mon, 25 Jul 2016 16:09:01 +0200
Message-Id: <1469455759-6141-5-git-send-email-agruenba@redhat.com>
In-Reply-To: <1469455759-6141-1-git-send-email-agruenba@redhat.com>
References: <1469455759-6141-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We will need to call iop->permission and iop->get_acl from
inode_change_ok() for additional permission checks, and both take a
non-const inode.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
Reviewed-by: J. Bruce Fields <bfields@redhat.com>
Reviewed-by: Andreas Dilger <adilger@dilger.ca>
Reviewed-by: Steve French <steve.french@primarydata.com>
Reviewed-by: Jeff Layton <jlayton@redhat.com>
---
 fs/attr.c          | 2 +-
 include/linux/fs.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/attr.c b/fs/attr.c
index 25b24d0..7ca7fa0 100644
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -28,7 +28,7 @@
  * Should be called as the first thing in ->setattr implementations,
  * possibly after taking additional locks.
  */
-int inode_change_ok(const struct inode *inode, struct iattr *attr)
+int inode_change_ok(struct inode *inode, struct iattr *attr)
 {
 	unsigned int ia_valid = attr->ia_valid;
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 86bfa10..208f73b 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2993,7 +2993,7 @@ extern int buffer_migrate_page(struct address_space *,
 #define buffer_migrate_page NULL
 #endif
 
-extern int inode_change_ok(const struct inode *, struct iattr *);
+extern int inode_change_ok(struct inode *, struct iattr *);
 extern int inode_newsize_ok(const struct inode *, loff_t offset);
 extern void setattr_copy(struct inode *inode, const struct iattr *attr);
 
-- 
2.5.5

