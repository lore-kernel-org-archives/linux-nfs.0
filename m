Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57336 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752173AbbJETkl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Oct 2015 15:40:41 -0400
From: Andreas Gruenbacher <agruenba@redhat.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-ext4@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org
Subject: [PATCH v9 36/43] ext4: Don't allow unmapped identifiers in richacls
Date: Mon,  5 Oct 2015 21:37:03 +0200
Message-Id: <1444073830-21854-37-git-send-email-agruenba@redhat.com>
In-Reply-To: <1444073830-21854-1-git-send-email-agruenba@redhat.com>
References: <1444073830-21854-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't allow acls which contain unmapped identifiers: they are meaningful
for remote file systems only.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/ext4/richacl.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/ext4/richacl.c b/fs/ext4/richacl.c
index 83b7a95..4ef140e 100644
--- a/fs/ext4/richacl.c
+++ b/fs/ext4/richacl.c
@@ -63,8 +63,13 @@ __ext4_set_richacl(handle_t *handle, struct inode *inode, struct richacl *acl)
 	int retval;
 
 	if (acl) {
-		mode_t mode = inode->i_mode;
+		mode_t mode;
 
+		/* Don't allow acls with unmapped identifiers. */
+		if (richacl_has_unmapped_identifiers(acl))
+			return -EINVAL;
+
+		mode = inode->i_mode;
 		if (richacl_equiv_mode(acl, &mode) == 0) {
 			inode->i_mode = mode;
 			ext4_mark_inode_dirty(handle, inode);
-- 
2.5.0

