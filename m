From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 13 of 18] nfsd4: encode_dirent: simplify nfs4_encode_dirent_fattr
Date: Tue, 16 Nov 2004 15:50:50 +1100
Message-ID: <E1CTvIo-0004q6-L8@notabene.cse.unsw.edu.au>
References: <20041116154601.18412.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CTvF6-0005s4-4I
	for nfs@lists.sourceforge.net; Mon, 15 Nov 2004 20:47:00 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CTvF1-0007HM-5v
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



Make nfsd4_encode_dirent_fattr() slightly more concise.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4xdr.c |   11 ++++-------
 1 files changed, 4 insertions(+), 7 deletions(-)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-11-16 14:41:37.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2004-11-16 14:41:39.000000000 +1100
@@ -1778,10 +1778,8 @@ nfsd4_encode_dirent_fattr(struct nfsd4_r
 	int nfserr;
 
 	dentry = lookup_one_len(name, cd->rd_fhp->fh_dentry, namlen);
-	if (IS_ERR(dentry)) {
-		nfserr = nfserrno(PTR_ERR(dentry));
-		return nfserr;
-	}
+	if (IS_ERR(dentry))
+		return nfserrno(PTR_ERR(dentry));
 
 	exp_get(exp);
 	if (d_mountpoint(dentry)) {
@@ -1793,10 +1791,8 @@ nfsd4_encode_dirent_fattr(struct nfsd4_r
 		 * options on exp.  When the answer comes back,
 		 * this call will be retried.
 		 */
-			dput(dentry);
-			exp_put(exp);
 			nfserr = nfserr_dropit;
-			return nfserr;
+			goto out_put;
 		}
 
 	}
@@ -1804,6 +1800,7 @@ nfsd4_encode_dirent_fattr(struct nfsd4_r
 	nfserr = nfsd4_encode_fattr(NULL, exp,
 			dentry, p, buflen, cd->rd_bmval,
 			cd->rd_rqstp);
+out_put:
 	dput(dentry);
 	exp_put(exp);
 	return nfserr;


-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
