Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38318 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752101AbbIEK2m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 Sep 2015 06:28:42 -0400
From: Andreas Gruenbacher <agruenba@redhat.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-security-module@vger.kernel.org
Subject: [RFC v7 34/41] ext4: Don't allow unmapped identifiers in richacls
Date: Sat,  5 Sep 2015 12:27:29 +0200
Message-Id: <1441448856-13478-35-git-send-email-agruenba@redhat.com>
In-Reply-To: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
References: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't allow acls which contain unmapped identifiers: they are meaningful
for remote file systems only.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/ext4/richacl.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/ext4/richacl.c b/fs/ext4/richacl.c
index 6758def..ca6e0cb 100644
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
2.4.3

