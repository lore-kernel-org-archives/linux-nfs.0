Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:4743 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752324AbaKCTq4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Nov 2014 14:46:56 -0500
From: Olga Kornievskaia <kolga@netapp.com>
To: <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] [nfs4-acl-tools] handle DENY ace for DELETE, WRITE_OWNER, and NAMED_ATTRS
Date: Mon, 3 Nov 2014 14:46:51 -0500
Message-ID: <1415044011-35671-1-git-send-email-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't ignore setting or viewing DENY ace for DELETE, WRITE_OWNER, and
NAMED_ATTRS.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 include/libacl_nfs4.h     | 8 ++------
 libnfs4acl/nfs4_new_ace.c | 3 ---
 2 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/include/libacl_nfs4.h b/include/libacl_nfs4.h
index 2f7cc28..7b19c6f 100644
--- a/include/libacl_nfs4.h
+++ b/include/libacl_nfs4.h
@@ -95,15 +95,11 @@
 #define NFS4_INHERITANCE_FLAGS (NFS4_ACE_FILE_INHERIT_ACE \
 		| NFS4_ACE_DIRECTORY_INHERIT_ACE | NFS4_ACE_INHERIT_ONLY_ACE)
 
-#define NFS4_ACE_MASK_IGNORE (NFS4_ACE_DELETE | NFS4_ACE_WRITE_OWNER \
-		| NFS4_ACE_READ_NAMED_ATTRS | NFS4_ACE_WRITE_NAMED_ATTRS)
 /* XXX not sure about the following.  Note that e.g. DELETE_CHILD is wrong in
  * general (should only be ignored on files). */
 #define MASK_EQUAL(mask1, mask2) \
-	(((mask1) & NFS4_ACE_MASK_ALL & ~NFS4_ACE_MASK_IGNORE & \
-	  					~NFS4_ACE_DELETE_CHILD) \
-	 == ((mask2) & NFS4_ACE_MASK_ALL & ~NFS4_ACE_MASK_IGNORE & \
-		 				~NFS4_ACE_DELETE_CHILD))
+	(((mask1) & NFS4_ACE_MASK_ALL & ~NFS4_ACE_DELETE_CHILD) \
+	 == ((mask2) & NFS4_ACE_MASK_ALL & ~NFS4_ACE_DELETE_CHILD))
 
 /*
  * NFS4_MAX_ACESIZE -- the number of bytes in the string representation we
diff --git a/libnfs4acl/nfs4_new_ace.c b/libnfs4acl/nfs4_new_ace.c
index a93f74a..0c875b1 100644
--- a/libnfs4acl/nfs4_new_ace.c
+++ b/libnfs4acl/nfs4_new_ace.c
@@ -51,9 +51,6 @@ struct nfs4_ace * nfs4_new_ace(int is_directory, u32 type, u32 flag, u32 access_
 	ace->type = type;
 	ace->flag = flag;
 
-	if( type == NFS4_ACE_ACCESS_DENIED_ACE_TYPE )
-		access_mask = access_mask & ~(NFS4_ACE_MASK_IGNORE);
-
 	/* Castrate delete_child if we aren't a directory */
 	if (!is_directory)
 		access_mask &= ~NFS4_ACE_DELETE_CHILD;
-- 
1.9.3

