From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 10 of 16] nfsd4: don't set WRITE_OWNER in either allow or deny bits
Date: Tue, 22 Mar 2005 16:42:01 +1100
Message-ID: <E1DDc9R-0002Ki-PS@notabene.cse.unsw.edu.au>
References: <20050322163830.8762.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDcA2-0006m2-LO
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 21:42:38 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DDcA0-0005A4-RO
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 21:42:38 -0800
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



WRITE_OWNER should be neither allowed nor denied.

This improves interoperability with Solaris clients and represents our
permissions more accurately.

It breaks compatibility with clients using the old version of the NFSv4<->POSIX
mapping.  I believe the only code that did that was older versions of
experimental client-side code available only from our website, so I prefer not
to introduce a hack just to continue support the old mapping.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4acl.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletion(-)

diff ./fs/nfsd/nfs4acl.c~current~ ./fs/nfsd/nfs4acl.c
--- ./fs/nfsd/nfs4acl.c~current~	2005-03-22 16:36:35.000000000 +1100
+++ ./fs/nfsd/nfs4acl.c	2005-03-22 16:36:35.000000000 +1100
@@ -55,6 +55,9 @@
 #define NFS4_ANYONE_MODE (NFS4_ACE_READ_ATTRIBUTES | NFS4_ACE_READ_ACL | NFS4_ACE_SYNCHRONIZE)
 #define NFS4_OWNER_MODE (NFS4_ACE_WRITE_ATTRIBUTES | NFS4_ACE_WRITE_ACL)
 
+/* We don't support these bits; insist they be neither allowed nor denied */
+#define NFS4_MASK_UNSUPP (NFS4_ACE_DELETE | NFS4_ACE_WRITE_OWNER)
+
 /* flags used to simulate posix default ACLs */
 #define NFS4_INHERITANCE_FLAGS (NFS4_ACE_FILE_INHERIT_ACE \
 		| NFS4_ACE_DIRECTORY_INHERIT_ACE | NFS4_ACE_INHERIT_ONLY_ACE)
@@ -83,7 +86,7 @@ mask_from_posix(unsigned short perm, uns
 static u32
 deny_mask(u32 allow_mask, unsigned int flags)
 {
-	u32 ret = ~allow_mask & ~NFS4_ACE_DELETE;
+	u32 ret = ~allow_mask & ~NFS4_MASK_UNSUPP;
 	if (!(flags & NFS4_ACL_DIR))
 		ret &= ~NFS4_ACE_DELETE_CHILD;
 	return ret;


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
