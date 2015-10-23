Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58760 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752678AbbJWSqz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Oct 2015 14:46:55 -0400
From: Andreas Gruenbacher <agruenba@redhat.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Dave Chinner <david@fromorbit.com>, linux-ext4@vger.kernel.org,
        xfs@oss.sgi.com, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-api@vger.kernel.org
Cc: Andreas Gruenbacher <agruenba@redhat.com>
Subject: [PATCH v12 42/49] xfs: Don't allow unmapped identifiers in richacls
Date: Fri, 23 Oct 2015 20:41:55 +0200
Message-Id: <1445625722-13791-43-git-send-email-agruenba@redhat.com>
In-Reply-To: <1445625722-13791-1-git-send-email-agruenba@redhat.com>
References: <1445625722-13791-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't allow acls which contain unmapped identifiers: they are meaningful
for remote file systems only.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/xfs/xfs_richacl.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/xfs/xfs_richacl.c b/fs/xfs/xfs_richacl.c
index 92a036e..6870679 100644
--- a/fs/xfs/xfs_richacl.c
+++ b/fs/xfs/xfs_richacl.c
@@ -78,6 +78,10 @@ xfs_set_richacl(struct inode *inode, struct richacl *acl)
 	if (!acl)
 		return xfs_remove_richacl(inode);
 
+	/* Don't allow acls with unmapped identifiers. */
+	if (richacl_has_unmapped_identifiers(acl))
+		return -EINVAL;
+
 	if (richacl_equiv_mode(acl, &mode) == 0) {
 		xfs_set_mode(inode, mode);
 		return xfs_remove_richacl(inode);
-- 
2.5.0

