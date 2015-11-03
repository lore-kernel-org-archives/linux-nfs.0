Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55165 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751844AbbKCPWg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Nov 2015 10:22:36 -0500
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
Subject: [PATCH v13 43/51] ext4: Don't allow unmapped identifiers in richacls
Date: Tue,  3 Nov 2015 16:17:19 +0100
Message-Id: <1446563847-14005-44-git-send-email-agruenba@redhat.com>
In-Reply-To: <1446563847-14005-1-git-send-email-agruenba@redhat.com>
References: <1446563847-14005-1-git-send-email-agruenba@redhat.com>
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

