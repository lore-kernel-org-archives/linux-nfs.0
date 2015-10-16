Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47120 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933152AbbJPPXG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Oct 2015 11:23:06 -0400
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
Subject: [PATCH v11 41/48] xfs: Don't allow unmapped identifiers in richacls
Date: Fri, 16 Oct 2015 17:18:19 +0200
Message-Id: <1445008706-15115-42-git-send-email-agruenba@redhat.com>
In-Reply-To: <1445008706-15115-1-git-send-email-agruenba@redhat.com>
References: <1445008706-15115-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't allow acls which contain unmapped identifiers: they are meaningful
for remote file systems only.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/xfs/xfs_richacl.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/xfs/xfs_richacl.c b/fs/xfs/xfs_richacl.c
index 73c2d24..4f938b7 100644
--- a/fs/xfs/xfs_richacl.c
+++ b/fs/xfs/xfs_richacl.c
@@ -77,6 +77,10 @@ xfs_set_richacl(struct inode *inode, struct richacl *acl)
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

