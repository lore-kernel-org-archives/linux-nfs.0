From: NeilBrown <neilb@suse.de>
Subject: [PATCH 002 of 9] knfsd: nfsd4: relax checking of ACL
	inheritance bits
Date: Tue, 13 Feb 2007 10:44:07 +1100
Message-ID: <1070212234407.29239@suse.de>
References: <20070213103941.28958.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HGkqk-0005WF-Am
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 15:44:46 -0800
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HGkqj-0000hY-HY
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 15:44:48 -0800
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


From: J. Bruce Fields <bfields@citi.umich.edu>
The rfc allows us to be more permissive about the ACL inheritance bits we
accept:

	"If the server supports a single "inherit ACE" flag that applies to
	both files and directories, the server may reject the request
	(i.e., requiring the client to set both the file and directory
	inheritance flags). The server may also accept the request and
	silently turn on the ACE4_DIRECTORY_INHERIT_ACE flag."

Let's take the latter option--the ACL is a complex attribute that could be
rejected for a wide variety of reasons, and the protocol gives us little
ability to explain the reason for the rejection, so erroring out is a
user-unfriendly last resort.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4acl.c |   23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff .prev/fs/nfsd/nfs4acl.c ./fs/nfsd/nfs4acl.c
--- .prev/fs/nfsd/nfs4acl.c	2007-02-13 09:50:26.000000000 +1100
+++ ./fs/nfsd/nfs4acl.c	2007-02-13 10:01:42.000000000 +1100
@@ -61,9 +61,11 @@
 
 /* flags used to simulate posix default ACLs */
 #define NFS4_INHERITANCE_FLAGS (NFS4_ACE_FILE_INHERIT_ACE \
-		| NFS4_ACE_DIRECTORY_INHERIT_ACE | NFS4_ACE_INHERIT_ONLY_ACE)
+		| NFS4_ACE_DIRECTORY_INHERIT_ACE)
 
-#define NFS4_SUPPORTED_FLAGS (NFS4_INHERITANCE_FLAGS | NFS4_ACE_IDENTIFIER_GROUP)
+#define NFS4_SUPPORTED_FLAGS (NFS4_INHERITANCE_FLAGS \
+		| NFS4_ACE_INHERIT_ONLY_ACE \
+		| NFS4_ACE_IDENTIFIER_GROUP)
 
 #define MASK_EQUAL(mask1, mask2) \
 	( ((mask1) & NFS4_ACE_MASK_ALL) == ((mask2) & NFS4_ACE_MASK_ALL) )
@@ -707,11 +709,16 @@ nfs4_acl_split(struct nfs4_acl *acl, str
 		if (ace->flag & ~NFS4_SUPPORTED_FLAGS)
 			return -EINVAL;
 
-		switch (ace->flag & NFS4_INHERITANCE_FLAGS) {
-		case 0:
+		if ((ace->flag & NFS4_INHERITANCE_FLAGS) == 0) {
 			/* Leave this ace in the effective acl: */
 			continue;
-		case NFS4_INHERITANCE_FLAGS:
+		}
+		/*
+		 * Note that when only one of FILE_INHERIT or DIRECTORY_INHERIT
+		 * is set, we're effectively turning on the other.  That's OK,
+		 * according to rfc 3530.
+		 */
+		if (ace->flag & NFS4_ACE_INHERIT_ONLY_ACE) {
 			/* Add this ace to the default acl and remove it
 			 * from the effective acl: */
 			error = nfs4_acl_add_ace(dacl, ace->type, ace->flag,
@@ -721,17 +728,13 @@ nfs4_acl_split(struct nfs4_acl *acl, str
 			list_del(h);
 			kfree(ace);
 			acl->naces--;
-			break;
-		case NFS4_INHERITANCE_FLAGS & ~NFS4_ACE_INHERIT_ONLY_ACE:
+		} else {
 			/* Add this ace to the default, but leave it in
 			 * the effective acl as well: */
 			error = nfs4_acl_add_ace(dacl, ace->type, ace->flag,
 				ace->access_mask, ace->whotype, ace->who);
 			if (error)
 				return error;
-			break;
-		default:
-			return -EINVAL;
 		}
 	}
 	return 0;

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
