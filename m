Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55733 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751844AbbKCPWo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Nov 2015 10:22:44 -0500
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
Subject: [PATCH v13 44/51] xfs: Don't allow unmapped identifiers in richacls
Date: Tue,  3 Nov 2015 16:17:20 +0100
Message-Id: <1446563847-14005-45-git-send-email-agruenba@redhat.com>
In-Reply-To: <1446563847-14005-1-git-send-email-agruenba@redhat.com>
References: <1446563847-14005-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't allow acls which contain unmapped identifiers: they are meaningful
for remote file systems only.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/xfs/xfs_richacl.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/xfs/xfs_richacl.c b/fs/xfs/xfs_richacl.c
index f8f5a62..4a2e21a 100644
--- a/fs/xfs/xfs_richacl.c
+++ b/fs/xfs/xfs_richacl.c
@@ -78,6 +78,10 @@ __xfs_set_richacl(struct inode *inode, struct richacl *acl, int xflags)
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

