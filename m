From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 16 of 18] nfsd4: encode_dirent: simplify control flow
Date: Tue, 16 Nov 2004 15:50:50 +1100
Message-ID: <E1CTvIo-0004qI-Ud@notabene.cse.unsw.edu.au>
References: <20041116154601.18412.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CTvFz-0005un-7r
	for nfs@lists.sourceforge.net; Mon, 15 Nov 2004 20:47:55 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CTvFy-0007Mi-FJ
	for nfs@lists.sourceforge.net; Mon, 15 Nov 2004 20:47:55 -0800
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



Replace series of if's by a switch, remove (now unnecessary) label "out".

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4xdr.c |   41 ++++++++++++++++++++---------------------
 1 files changed, 20 insertions(+), 21 deletions(-)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-11-16 14:41:42.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2004-11-16 14:41:44.000000000 +1100
@@ -1854,32 +1854,31 @@ nfsd4_encode_dirent(struct readdir_cd *c
 	 * Now we come to the ugly part: writing the fattr for this entry.
 	 */
 	nfserr = nfsd4_encode_dirent_fattr(cd, name, namlen, p, &buflen);
-	if (!nfserr) {
+	switch (nfserr) {
+	case nfs_ok:
 		p += buflen;
-		goto out;
-	}
-	if (nfserr == nfserr_resource) {
+		break;
+	case nfserr_resource:
 		nfserr = nfserr_toosmall;
 		goto fail;
+	default:
+		/*
+		 * If we get here, we experienced a miscellaneous
+		 * failure while writing the attributes.  If the
+		 * client requested the RDATTR_ERROR attribute,
+		 * we stuff the error code into this attribute
+		 * and continue.  If this attribute was not requested,
+		 * then in accordance with the spec, we fail the
+		 * entire READDIR operation(!)
+		 */
+		if (!(cd->rd_bmval[0] & FATTR4_WORD0_RDATTR_ERROR))
+			goto fail;
+		nfserr = nfserr_toosmall;
+		p = nfsd4_encode_rdattr_error(p, buflen, nfserr);
+		if (p == NULL)
+			goto fail;
 	}
 
-	/*
-	 * If we get here, we experienced a miscellaneous
-	 * failure while writing the attributes.  If the
-	 * client requested the RDATTR_ERROR attribute,
-	 * we stuff the error code into this attribute
-	 * and continue.  If this attribute was not requested,
-	 * then in accordance with the spec, we fail the
-	 * entire READDIR operation(!)
-	 */
-	if (!(cd->rd_bmval[0] & FATTR4_WORD0_RDATTR_ERROR))
-		goto fail;
-	nfserr = nfserr_toosmall;
-	p = nfsd4_encode_rdattr_error(p, buflen, nfserr);
-	if (p == NULL)
-		goto fail;
-
-out:
 	cd->buflen -= (p - cd->buffer);
 	cd->buffer = p;
 	cd->common.err = nfs_ok;


-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
