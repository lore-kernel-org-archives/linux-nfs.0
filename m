Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47070 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933152AbbJPPW7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Oct 2015 11:22:59 -0400
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
Subject: [PATCH v11 40/48] ext4: Don't allow unmapped identifiers in richacls
Date: Fri, 16 Oct 2015 17:18:18 +0200
Message-Id: <1445008706-15115-41-git-send-email-agruenba@redhat.com>
In-Reply-To: <1445008706-15115-1-git-send-email-agruenba@redhat.com>
References: <1445008706-15115-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't allow acls which contain unmapped identifiers: they are meaningful
for remote file systems only.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/ext4/richacl.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/ext4/richacl.c b/fs/ext4/richacl.c
index 906d048..2115385 100644
--- a/fs/ext4/richacl.c
+++ b/fs/ext4/richacl.c
@@ -74,6 +74,10 @@ __ext4_set_richacl(handle_t *handle, struct inode *inode, struct richacl *acl)
 	int retval, size;
 	void *value;
 
+	/* Don't allow acls with unmapped identifiers. */
+	if (richacl_has_unmapped_identifiers(acl))
+		return -EINVAL;
+
 	if (richacl_equiv_mode(acl, &mode) == 0) {
 		inode->i_ctime = ext4_current_time(inode);
 		inode->i_mode = mode;
-- 
2.5.0

