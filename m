Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:34895 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753929AbbC0QwW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 12:52:22 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [RFC 30/39] nfsd: Remove dead declarations
Date: Fri, 27 Mar 2015 17:50:28 +0100
Message-Id: <0267cf325e4b13f674340064c391da254822203d.1427471526.git.agruenba@redhat.com>
In-Reply-To: <cover.1427471526.git.agruenba@redhat.com>
References: <cover.1427471526.git.agruenba@redhat.com>
In-Reply-To: <cover.1427471526.git.agruenba@redhat.com>
References: <cover.1427471526.git.agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/nfsd/nfs4acl.c | 12 ------------
 1 file changed, 12 deletions(-)

diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
index 59fd766..c630651 100644
--- a/fs/nfsd/nfs4acl.c
+++ b/fs/nfsd/nfs4acl.c
@@ -52,10 +52,6 @@
 #define NFS4_ANYONE_MODE (NFS4_ACE_READ_ATTRIBUTES | NFS4_ACE_READ_ACL | NFS4_ACE_SYNCHRONIZE)
 #define NFS4_OWNER_MODE (NFS4_ACE_WRITE_ATTRIBUTES | NFS4_ACE_WRITE_ACL)
 
-/* We don't support these bits; insist they be neither allowed nor denied */
-#define NFS4_MASK_UNSUPP (NFS4_ACE_DELETE | NFS4_ACE_WRITE_OWNER \
-		| NFS4_ACE_READ_NAMED_ATTRS | NFS4_ACE_WRITE_NAMED_ATTRS)
-
 /* flags used to simulate posix default ACLs */
 #define NFS4_INHERITANCE_FLAGS (NFS4_ACE_FILE_INHERIT_ACE \
 		| NFS4_ACE_DIRECTORY_INHERIT_ACE)
@@ -64,9 +60,6 @@
 		| NFS4_ACE_INHERIT_ONLY_ACE \
 		| NFS4_ACE_IDENTIFIER_GROUP)
 
-#define MASK_EQUAL(mask1, mask2) \
-	( ((mask1) & NFS4_ACE_MASK_ALL) == ((mask2) & NFS4_ACE_MASK_ALL) )
-
 static u32
 mask_from_posix(unsigned short perm, unsigned int flags)
 {
@@ -126,11 +119,6 @@ low_mode_from_nfs4(u32 perm, unsigned short *mode, unsigned int flags)
 		*mode |= ACL_EXECUTE;
 }
 
-struct ace_container {
-	struct nfs4_ace  *ace;
-	struct list_head  ace_l;
-};
-
 static short ace2type(struct nfs4_ace *);
 static void _posix_to_nfsv4_one(struct posix_acl *, struct nfs4_acl *,
 				unsigned int);
-- 
2.1.0

