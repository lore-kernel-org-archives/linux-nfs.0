From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 11 of 16] nfsd4: acl don't set named attrs
Date: Tue, 22 Mar 2005 16:42:01 +1100
Message-ID: <E1DDc9R-0002Km-S0@notabene.cse.unsw.edu.au>
References: <20050322163830.8762.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDcA1-0006ll-RN
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 21:42:37 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DDc9z-00059x-PC
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 21:42:37 -0800
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



We were expecting {read,write}_named_attributes to be set in sync with the read
and write bits.  But we don't actually support named attributes, and when we
eventually do, it's unlikely that we'll want to use these ACL mode bits to
control access to them.  So let's just stop supporting these two bits.

This also updates our mapping to the latest ietf draft.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4acl.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff ./fs/nfsd/nfs4acl.c~current~ ./fs/nfsd/nfs4acl.c
--- ./fs/nfsd/nfs4acl.c~current~	2005-03-22 16:36:35.000000000 +1100
+++ ./fs/nfsd/nfs4acl.c	2005-03-22 16:36:36.000000000 +1100
@@ -49,14 +49,15 @@
 
 
 /* mode bit translations: */
-#define NFS4_READ_MODE (NFS4_ACE_READ_DATA | NFS4_ACE_READ_NAMED_ATTRS)
-#define NFS4_WRITE_MODE (NFS4_ACE_WRITE_DATA | NFS4_ACE_WRITE_NAMED_ATTRS | NFS4_ACE_APPEND_DATA)
+#define NFS4_READ_MODE (NFS4_ACE_READ_DATA)
+#define NFS4_WRITE_MODE (NFS4_ACE_WRITE_DATA | NFS4_ACE_APPEND_DATA)
 #define NFS4_EXECUTE_MODE NFS4_ACE_EXECUTE
 #define NFS4_ANYONE_MODE (NFS4_ACE_READ_ATTRIBUTES | NFS4_ACE_READ_ACL | NFS4_ACE_SYNCHRONIZE)
 #define NFS4_OWNER_MODE (NFS4_ACE_WRITE_ATTRIBUTES | NFS4_ACE_WRITE_ACL)
 
 /* We don't support these bits; insist they be neither allowed nor denied */
-#define NFS4_MASK_UNSUPP (NFS4_ACE_DELETE | NFS4_ACE_WRITE_OWNER)
+#define NFS4_MASK_UNSUPP (NFS4_ACE_DELETE | NFS4_ACE_WRITE_OWNER \
+		| NFS4_ACE_READ_NAMED_ATTRS | NFS4_ACE_WRITE_NAMED_ATTRS)
 
 /* flags used to simulate posix default ACLs */
 #define NFS4_INHERITANCE_FLAGS (NFS4_ACE_FILE_INHERIT_ACE \


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
