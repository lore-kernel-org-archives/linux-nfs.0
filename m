Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:33329 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933786AbbHDLzp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Aug 2015 07:55:45 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-api@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        Andreas Gruenbacher <agruenba@redhat.com>
Subject: [RFC v6 34/40] ext4: Don't allow unmapped identifiers in richacls
Date: Tue,  4 Aug 2015 13:53:32 +0200
Message-Id: <1438689218-6921-35-git-send-email-agruenba@redhat.com>
In-Reply-To: <1438689218-6921-1-git-send-email-agruenba@redhat.com>
References: <1438689218-6921-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't allow acls which contain unmapped identifiers: they are meaningful
for remote file systems only.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/ext4/richacl.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/ext4/richacl.c b/fs/ext4/richacl.c
index 4385f6d..9d80299 100644
--- a/fs/ext4/richacl.c
+++ b/fs/ext4/richacl.c
@@ -68,8 +68,13 @@ ext4_set_richacl(handle_t *handle, struct inode *inode, struct richacl *acl)
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

