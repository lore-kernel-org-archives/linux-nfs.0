From: NeilBrown <neilb@suse.de>
Subject: [PATCH 007 of 9] knfsd: nfsd4: acls: don't return explicit
	mask
Date: Tue, 13 Feb 2007 10:44:37 +1100
Message-ID: <1070212234437.29316@suse.de>
References: <20070213103941.28958.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HGkrd-0005do-6I
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 15:45:41 -0800
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HGkre-0002IG-MR
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 15:45:43 -0800
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


From: J. Bruce Fields <bfields@snoopy.citi.umich.edu>
Return just the effective permissions, and forget about the mask.  It isn't
worth the complexity.

WARNING: This breaks backwards compatibility with overly-picky nfsv4->posix acl
translation, as may has been included in some patched versions of libacl.  To
our knowledge no such version was every distributed by anyone outside citi.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4acl.c |   25 +++++++------------------
 1 file changed, 7 insertions(+), 18 deletions(-)

diff .prev/fs/nfsd/nfs4acl.c ./fs/nfsd/nfs4acl.c
--- .prev/fs/nfsd/nfs4acl.c	2007-02-13 10:23:49.000000000 +1100
+++ ./fs/nfsd/nfs4acl.c	2007-02-13 10:37:27.000000000 +1100
@@ -180,7 +180,8 @@ _posix_to_nfsv4_one(struct posix_acl *pa
 						unsigned int flags)
 {
 	struct posix_acl_entry *pa, *pe, *group_owner_entry;
-	u32 mask, mask_mask;
+	u32 mask;
+	unsigned short mask_mask;
 	int eflag = ((flags & NFS4_ACL_TYPE_DEFAULT) ?
 					NFS4_INHERITANCE_FLAGS : 0);
 
@@ -188,9 +189,9 @@ _posix_to_nfsv4_one(struct posix_acl *pa
 	pe = pacl->a_entries + pacl->a_count;
 	pa = pe - 2; /* if mask entry exists, it's second from the last. */
 	if (pa->e_tag == ACL_MASK)
-		mask_mask = deny_mask(mask_from_posix(pa->e_perm, flags), flags);
+		mask_mask = pa->e_perm;
 	else
-		mask_mask = 0;
+		mask_mask = S_IRWXO;
 
 	pa = pacl->a_entries;
 	BUG_ON(pa->e_tag != ACL_USER_OBJ);
@@ -199,10 +200,7 @@ _posix_to_nfsv4_one(struct posix_acl *pa
 	pa++;
 
 	while (pa->e_tag == ACL_USER) {
-		mask = mask_from_posix(pa->e_perm, flags);
-		nfs4_acl_add_ace(acl, NFS4_ACE_ACCESS_DENIED_ACE_TYPE,
-				eflag,  mask_mask, NFS4_ACL_WHO_NAMED, pa->e_id);
-
+		mask = mask_from_posix(pa->e_perm & mask_mask, flags);
 		nfs4_acl_add_pair(acl, eflag, mask,
 				NFS4_ACL_WHO_NAMED, pa->e_id, flags);
 		pa++;
@@ -213,24 +211,15 @@ _posix_to_nfsv4_one(struct posix_acl *pa
 
 	/* allow ACEs */
 
-	if (pacl->a_count > 3) {
-		BUG_ON(pa->e_tag != ACL_GROUP_OBJ);
-		nfs4_acl_add_ace(acl, NFS4_ACE_ACCESS_DENIED_ACE_TYPE,
-				NFS4_ACE_IDENTIFIER_GROUP | eflag, mask_mask,
-				NFS4_ACL_WHO_GROUP, 0);
-	}
 	group_owner_entry = pa;
-	mask = mask_from_posix(pa->e_perm, flags);
+	mask = mask_from_posix(pa->e_perm & mask_mask, flags);
 	nfs4_acl_add_ace(acl, NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE,
 			NFS4_ACE_IDENTIFIER_GROUP | eflag, mask,
 			NFS4_ACL_WHO_GROUP, 0);
 	pa++;
 
 	while (pa->e_tag == ACL_GROUP) {
-		mask = mask_from_posix(pa->e_perm, flags);
-		nfs4_acl_add_ace(acl, NFS4_ACE_ACCESS_DENIED_ACE_TYPE,
-				NFS4_ACE_IDENTIFIER_GROUP | eflag, mask_mask,
-				NFS4_ACL_WHO_NAMED, pa->e_id);
+		mask = mask_from_posix(pa->e_perm & mask_mask, flags);
 		nfs4_acl_add_ace(acl, NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE,
 		    		NFS4_ACE_IDENTIFIER_GROUP | eflag, mask,
 		    		NFS4_ACL_WHO_NAMED, pa->e_id);

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
