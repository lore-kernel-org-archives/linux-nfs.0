From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 11 of 18] nfsd4: encode_dirent: superfluous local variables
Date: Tue, 16 Nov 2004 15:50:50 +1100
Message-ID: <E1CTvIo-0004py-Ew@notabene.cse.unsw.edu.au>
References: <20041116154601.18412.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CTvF4-0005rn-Fp
	for nfs@lists.sourceforge.net; Mon, 15 Nov 2004 20:46:58 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CTvF1-0000hb-6e
	for nfs@lists.sourceforge.net; Mon, 15 Nov 2004 20:46:58 -0800
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



The local variables bmval0 and bmval1 turn out not to really help much.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4xdr.c |   13 +++----------
 1 files changed, 3 insertions(+), 10 deletions(-)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-11-16 14:41:35.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2004-11-16 14:41:36.000000000 +1100
@@ -1779,7 +1779,6 @@ nfsd4_encode_dirent(struct readdir_cd *c
 	u32 *attrlenp;
 	struct dentry *dentry;
 	struct svc_export *exp = cd->rd_fhp->fh_export;
-	u32 bmval0, bmval1;
 	int nfserr = 0;
 
 	/* In nfsv4, "." and ".." never make it onto the wire.. */
@@ -1803,9 +1802,6 @@ nfsd4_encode_dirent(struct readdir_cd *c
 	/*
 	 * Now we come to the ugly part: writing the fattr for this entry.
 	 */
-	bmval0 = cd->rd_bmval[0];
-	bmval1 = cd->rd_bmval[1];
-
 	dentry = lookup_one_len(name, cd->rd_fhp->fh_dentry, namlen);
 	if (IS_ERR(dentry)) {
 		nfserr = nfserrno(PTR_ERR(dentry));
@@ -1852,19 +1848,16 @@ error:
 	 * then in accordance with the spec, we fail the
 	 * entire READDIR operation(!)
 	 */
-	if (!(bmval0 & FATTR4_WORD0_RDATTR_ERROR)) {
+	if (!(cd->rd_bmval[0] & FATTR4_WORD0_RDATTR_ERROR)) {
 		cd->common.err = nfserr;
 		return -EINVAL;
 	}
 
-	bmval0 = FATTR4_WORD0_RDATTR_ERROR;
-	bmval1 = 0;
-
 	if (buflen < 6)
 		goto nospc;
 	*p++ = htonl(2);
-	*p++ = htonl(bmval0);
-	*p++ = htonl(bmval1);
+	*p++ = htonl(FATTR4_WORD0_RDATTR_ERROR); /* bmval0 */
+	*p++ = htonl(0);			 /* bmval1 */
 
 	attrlenp = p++;
 	*p++ = nfserr;       /* no htonl */


-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
