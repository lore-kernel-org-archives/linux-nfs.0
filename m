From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 4 of 9] nfsd4: Support acl_support attribute
Date: Fri, 03 Sep 2004 12:34:26 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1C33uE-00042y-9l@notabene.cse.unsw.edu.au>
References: <20040903122815.15453.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C33uN-000051-It
	for nfs@lists.sourceforge.net; Thu, 02 Sep 2004 19:34:35 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C33uM-0004T2-SV
	for nfs@lists.sourceforge.net; Thu, 02 Sep 2004 19:34:35 -0700
To: Andrew Morton <akpm@osdl.org>
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



The nfs4 attributes supported_attrs and aclsupport should not be
static; they need to depend on the exported filesystem's acl support.  Test the
latter by attempting to get an acl, and adjust the returned attributes
apropriately.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4xdr.c |   25 +++++++++++++++----------
 1 files changed, 15 insertions(+), 10 deletions(-)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-09-03 11:56:48.000000000 +1000
+++ ./fs/nfsd/nfs4xdr.c	2004-09-03 11:57:04.000000000 +1000
@@ -1414,6 +1414,7 @@ nfsd4_encode_fattr(struct svc_fh *fhp, s
 	u64 dummy64;
 	u32 *p = buffer;
 	int status;
+	int aclsupport = 0;
 	struct nfs4_acl *acl = NULL;
 
 	BUG_ON(bmval1 & NFSD_WRITEONLY_ATTRS_WORD1);
@@ -1437,12 +1438,16 @@ nfsd4_encode_fattr(struct svc_fh *fhp, s
 			goto out;
 		fhp = &tempfh;
 	}
-	if (bmval0 & FATTR4_WORD0_ACL) {
+	if (bmval0 & (FATTR4_WORD0_ACL | FATTR4_WORD0_ACLSUPPORT
+			| FATTR4_WORD0_SUPPORTED_ATTRS)) {
 		status = nfsd4_get_nfs4_acl(rqstp, dentry, &acl);
-		if (status == -EOPNOTSUPP)
-			bmval0 &= ~FATTR4_WORD0_ACL;
-		else if (status < 0)
-			goto out_nfserr;
+		aclsupport = (status == 0);
+		if (bmval0 & FATTR4_WORD0_ACL) {
+			if (status == -EOPNOTSUPP)
+				bmval0 &= ~FATTR4_WORD0_ACL;
+			else if (status != 0)
+				goto out_nfserr;
+		}
 	}
 	if ((buflen -= 16) < 0)
 		goto out_resource;
@@ -1456,9 +1461,9 @@ nfsd4_encode_fattr(struct svc_fh *fhp, s
 		if ((buflen -= 12) < 0)
 			goto out_resource;
 		WRITE32(2);
-		/* XXX Should depend on exported filesystem (e.g.
-		 * for acl support) */
-		WRITE32(NFSD_SUPPORTED_ATTRS_WORD0);
+		WRITE32(aclsupport ?
+			NFSD_SUPPORTED_ATTRS_WORD0 :
+			NFSD_SUPPORTED_ATTRS_WORD0 & ~FATTR4_WORD0_ACL);
 		WRITE32(NFSD_SUPPORTED_ATTRS_WORD1);
 	}
 	if (bmval0 & FATTR4_WORD0_TYPE) {
@@ -1565,8 +1570,8 @@ out_acl:
 	if (bmval0 & FATTR4_WORD0_ACLSUPPORT) {
 		if ((buflen -= 4) < 0)
 			goto out_resource;
-		/* XXX: should depend on exported filesystem: */
-		WRITE32(ACL4_SUPPORT_ALLOW_ACL|ACL4_SUPPORT_DENY_ACL);
+		WRITE32(aclsupport ?
+			ACL4_SUPPORT_ALLOW_ACL|ACL4_SUPPORT_DENY_ACL : 0);
 	}
 	if (bmval0 & FATTR4_WORD0_CANSETTIME) {
 		if ((buflen -= 4) < 0)


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
