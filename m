From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 15 of 18] nfsd4: encode_dirent: simplify error handling
Date: Tue, 16 Nov 2004 15:50:50 +1100
Message-ID: <E1CTvIo-0004qE-QK@notabene.cse.unsw.edu.au>
References: <20041116154601.18412.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CTvF6-0005s1-3T
	for nfs@lists.sourceforge.net; Mon, 15 Nov 2004 20:47:00 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CTvF1-0007Hk-5w
	for nfs@lists.sourceforge.net; Mon, 15 Nov 2004 20:46:59 -0800
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



Minor simplification of error handling in encode_dirent.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4xdr.c |   23 ++++++++++++-----------
 1 files changed, 12 insertions(+), 11 deletions(-)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-11-16 14:41:41.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2004-11-16 14:41:42.000000000 +1100
@@ -1830,7 +1830,7 @@ nfsd4_encode_dirent(struct readdir_cd *c
 	struct nfsd4_readdir *cd = container_of(ccd, struct nfsd4_readdir, common);
 	int buflen;
 	u32 *p = cd->buffer;
-	int nfserr = 0;
+	int nfserr = nfserr_toosmall;
 
 	/* In nfsv4, "." and ".." never make it onto the wire.. */
 	if (name && isdotent(name, namlen)) {
@@ -1843,7 +1843,7 @@ nfsd4_encode_dirent(struct readdir_cd *c
 
 	buflen = cd->buflen - 4 - XDR_QUADLEN(namlen);
 	if (buflen < 0)
-		goto nospc;
+		goto fail;
 
 	*p++ = xdr_one;                             /* mark entry present */
 	cd->offset = p;                             /* remember pointer */
@@ -1858,8 +1858,10 @@ nfsd4_encode_dirent(struct readdir_cd *c
 		p += buflen;
 		goto out;
 	}
-	if (nfserr == nfserr_resource)
-		goto nospc;
+	if (nfserr == nfserr_resource) {
+		nfserr = nfserr_toosmall;
+		goto fail;
+	}
 
 	/*
 	 * If we get here, we experienced a miscellaneous
@@ -1870,13 +1872,12 @@ nfsd4_encode_dirent(struct readdir_cd *c
 	 * then in accordance with the spec, we fail the
 	 * entire READDIR operation(!)
 	 */
-	if (!(cd->rd_bmval[0] & FATTR4_WORD0_RDATTR_ERROR)) {
-		cd->common.err = nfserr;
-		return -EINVAL;
-	}
+	if (!(cd->rd_bmval[0] & FATTR4_WORD0_RDATTR_ERROR))
+		goto fail;
+	nfserr = nfserr_toosmall;
 	p = nfsd4_encode_rdattr_error(p, buflen, nfserr);
 	if (p == NULL)
-		goto out_nospc;
+		goto fail;
 
 out:
 	cd->buflen -= (p - cd->buffer);
@@ -1884,8 +1885,8 @@ out:
 	cd->common.err = nfs_ok;
 	return 0;
 
-nospc:
-	cd->common.err = nfserr_toosmall;
+fail:
+	cd->common.err = nfserr;
 	return -EINVAL;
 }
 


-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
