From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 18 of 18] nfsd4: encode_dirent: trivial cleanup
Date: Tue, 16 Nov 2004 15:50:51 +1100
Message-ID: <E1CTvIp-0004qQ-45@notabene.cse.unsw.edu.au>
References: <20041116154601.18412.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CTvFw-0005uY-KD
	for nfs@lists.sourceforge.net; Mon, 15 Nov 2004 20:47:52 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CTvFv-0007Mf-Pd
	for nfs@lists.sourceforge.net; Mon, 15 Nov 2004 20:47:52 -0800
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



Trim a couple redundant comments, minor whitespace cleanup.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4xdr.c |   15 +++------------
 1 files changed, 3 insertions(+), 12 deletions(-)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-11-16 14:41:45.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2004-11-16 14:41:47.000000000 +1100
@@ -1796,10 +1796,8 @@ nfsd4_encode_dirent_fattr(struct nfsd4_r
 		}
 
 	}
-
-	nfserr = nfsd4_encode_fattr(NULL, exp,
-			dentry, p, buflen, cd->rd_bmval,
-			cd->rd_rqstp);
+	nfserr = nfsd4_encode_fattr(NULL, exp, dentry, p, buflen, cd->rd_bmval,
+					cd->rd_rqstp);
 out_put:
 	dput(dentry);
 	exp_put(exp);
@@ -1850,9 +1848,6 @@ nfsd4_encode_dirent(struct readdir_cd *c
 	p = xdr_encode_hyper(p, NFS_OFFSET_MAX);    /* offset of next entry */
 	p = xdr_encode_array(p, name, namlen);      /* name length & name */
 
-	/*
-	 * Now we come to the ugly part: writing the fattr for this entry.
-	 */
 	nfserr = nfsd4_encode_dirent_fattr(cd, name, namlen, p, &buflen);
 	switch (nfserr) {
 	case nfs_ok:
@@ -1865,9 +1860,7 @@ nfsd4_encode_dirent(struct readdir_cd *c
 		goto fail;
 	default:
 		/*
-		 * If we get here, we experienced a miscellaneous
-		 * failure while writing the attributes.  If the
-		 * client requested the RDATTR_ERROR attribute,
+		 * If the client requested the RDATTR_ERROR attribute,
 		 * we stuff the error code into this attribute
 		 * and continue.  If this attribute was not requested,
 		 * then in accordance with the spec, we fail the
@@ -1880,12 +1873,10 @@ nfsd4_encode_dirent(struct readdir_cd *c
 		if (p == NULL)
 			goto fail;
 	}
-
 	cd->buflen -= (p - cd->buffer);
 	cd->buffer = p;
 	cd->common.err = nfs_ok;
 	return 0;
-
 fail:
 	cd->common.err = nfserr;
 	return -EINVAL;


-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
