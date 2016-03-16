Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36623 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966987AbcCPWTx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Mar 2016 18:19:53 -0400
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
Subject: [PATCH v20 10/23] posix_acl: Unexport acl_by_type and make it static
Date: Wed, 16 Mar 2016 23:18:50 +0100
Message-Id: <1458166743-18488-11-git-send-email-agruenba@redhat.com>
In-Reply-To: <1458166743-18488-1-git-send-email-agruenba@redhat.com>
References: <1458166743-18488-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

acl_by_type(inode, type) returns a pointer to either inode->i_acl or
inode->i_default_acl depending on type.  This is useful in
fs/posix_acl.c, but should never have been visible outside that file.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/posix_acl.c            | 3 +--
 include/linux/posix_acl.h | 1 -
 2 files changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index 711dd51..55f2445 100644
--- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@ -21,7 +21,7 @@
 #include <linux/export.h>
 #include <linux/user_namespace.h>
 
-struct posix_acl **acl_by_type(struct inode *inode, int type)
+static struct posix_acl **acl_by_type(struct inode *inode, int type)
 {
 	switch (type) {
 	case ACL_TYPE_ACCESS:
@@ -32,7 +32,6 @@ struct posix_acl **acl_by_type(struct inode *inode, int type)
 		BUG();
 	}
 }
-EXPORT_SYMBOL(acl_by_type);
 
 struct posix_acl *get_cached_acl(struct inode *inode, int type)
 {
diff --git a/include/linux/posix_acl.h b/include/linux/posix_acl.h
index 3e96a6a..5b5a80c 100644
--- a/include/linux/posix_acl.h
+++ b/include/linux/posix_acl.h
@@ -99,7 +99,6 @@ extern int posix_acl_create(struct inode *, umode_t *, struct posix_acl **,
 extern int simple_set_acl(struct inode *, struct posix_acl *, int);
 extern int simple_acl_create(struct inode *, struct inode *);
 
-struct posix_acl **acl_by_type(struct inode *inode, int type);
 struct posix_acl *get_cached_acl(struct inode *inode, int type);
 struct posix_acl *get_cached_acl_rcu(struct inode *inode, int type);
 void set_cached_acl(struct inode *inode, int type, struct posix_acl *acl);
-- 
2.5.0

