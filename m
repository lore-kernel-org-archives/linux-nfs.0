From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 9 of 16] nfsd4_remove_unused_acl_function
Date: Tue, 22 Mar 2005 16:42:01 +1100
Message-ID: <E1DDc9R-0002Ke-Np@notabene.cse.unsw.edu.au>
References: <20050322163830.8762.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDcA1-0006lb-3O
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 21:42:37 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DDc9z-0005gA-TO
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 21:42:36 -0800
To: Andrew Morton <akpm@osdl.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


We're translating v4 ACL's to POSIX ACL's and relying on the filesystem
to check those, so there's no need for a NFSv4 ACL-checking algorithm.

Some day we'd like to find a way to implement the full v4 ACL protocol on the
server side, but for now this is dead code.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4acl.c |   27 ---------------------------
 1 files changed, 27 deletions(-)

diff ./fs/nfsd/nfs4acl.c~current~ ./fs/nfsd/nfs4acl.c
--- ./fs/nfsd/nfs4acl.c~current~	2005-03-22 16:35:20.000000000 +1100
+++ ./fs/nfsd/nfs4acl.c	2005-03-22 16:36:35.000000000 +1100
@@ -940,35 +940,8 @@ match_who(struct nfs4_ace *ace, uid_t ow
 	}
 }
 
-/* 0 = granted, -EACCES = denied; mask is an nfsv4 mask, not mode bits */
-int
-nfs4_acl_permission(struct nfs4_acl *acl, uid_t owner, gid_t group,
-			uid_t who, u32 mask)
-{
-	struct nfs4_ace *ace;
-	u32 allowed = 0;
-
-	list_for_each_entry(ace, &acl->ace_head, l_ace) {
-		if (!match_who(ace, group, owner, who))
-			continue;
-		switch (ace->type) {
-			case NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE:
-				allowed |= ace->access_mask;
-				if ((allowed & mask) == mask)
-					return 0;
-				break;
-			case NFS4_ACE_ACCESS_DENIED_ACE_TYPE:
-				if (ace->access_mask & mask)
-					return -EACCES;
-				break;
-		}
-	}
-	return -EACCES;
-}
-
 EXPORT_SYMBOL(nfs4_acl_new);
 EXPORT_SYMBOL(nfs4_acl_free);
 EXPORT_SYMBOL(nfs4_acl_add_ace);
 EXPORT_SYMBOL(nfs4_acl_get_whotype);
 EXPORT_SYMBOL(nfs4_acl_write_who);
-EXPORT_SYMBOL(nfs4_acl_permission);


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
