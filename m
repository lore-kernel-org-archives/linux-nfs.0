From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 12 of 18] nfsd4: encode_dirent: more readdir attribute encoding to new function
Date: Tue, 16 Nov 2004 15:50:50 +1100
Message-ID: <E1CTvIo-0004q2-Ge@notabene.cse.unsw.edu.au>
References: <20041116154601.18412.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CTvF4-0005rw-QU
	for nfs@lists.sourceforge.net; Mon, 15 Nov 2004 20:46:58 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CTvF1-0000hk-6e
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



Move readdir attribute encoding to nfsd4_encode_dirent_fattr(), remove
the (no-longer used) error label.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4xdr.c |   73 +++++++++++++++++++++++++++++-----------------------
 1 files changed, 41 insertions(+), 32 deletions(-)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-11-16 14:41:36.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2004-11-16 14:41:37.000000000 +1100
@@ -1770,6 +1770,46 @@ out_serverfault:
 }
 
 static int
+nfsd4_encode_dirent_fattr(struct nfsd4_readdir *cd,
+		const char *name, int namlen, u32 *p, int *buflen)
+{
+	struct svc_export *exp = cd->rd_fhp->fh_export;
+	struct dentry *dentry;
+	int nfserr;
+
+	dentry = lookup_one_len(name, cd->rd_fhp->fh_dentry, namlen);
+	if (IS_ERR(dentry)) {
+		nfserr = nfserrno(PTR_ERR(dentry));
+		return nfserr;
+	}
+
+	exp_get(exp);
+	if (d_mountpoint(dentry)) {
+		if (nfsd_cross_mnt(cd->rd_rqstp, &dentry, &exp)) {
+		/*
+		 * -EAGAIN is the only error returned from
+		 * nfsd_cross_mnt() and it indicates that an
+		 * up-call has  been initiated to fill in the export
+		 * options on exp.  When the answer comes back,
+		 * this call will be retried.
+		 */
+			dput(dentry);
+			exp_put(exp);
+			nfserr = nfserr_dropit;
+			return nfserr;
+		}
+
+	}
+
+	nfserr = nfsd4_encode_fattr(NULL, exp,
+			dentry, p, buflen, cd->rd_bmval,
+			cd->rd_rqstp);
+	dput(dentry);
+	exp_put(exp);
+	return nfserr;
+}
+
+static int
 nfsd4_encode_dirent(struct readdir_cd *ccd, const char *name, int namlen,
 		    loff_t offset, ino_t ino, unsigned int d_type)
 {
@@ -1777,8 +1817,6 @@ nfsd4_encode_dirent(struct readdir_cd *c
 	int buflen;
 	u32 *p = cd->buffer;
 	u32 *attrlenp;
-	struct dentry *dentry;
-	struct svc_export *exp = cd->rd_fhp->fh_export;
 	int nfserr = 0;
 
 	/* In nfsv4, "." and ".." never make it onto the wire.. */
@@ -1802,35 +1840,7 @@ nfsd4_encode_dirent(struct readdir_cd *c
 	/*
 	 * Now we come to the ugly part: writing the fattr for this entry.
 	 */
-	dentry = lookup_one_len(name, cd->rd_fhp->fh_dentry, namlen);
-	if (IS_ERR(dentry)) {
-		nfserr = nfserrno(PTR_ERR(dentry));
-		goto error;
-	}
-
-	exp_get(exp);
-	if (d_mountpoint(dentry)) {
-		if (nfsd_cross_mnt(cd->rd_rqstp, &dentry, &exp)) {
-		/*
-		 * -EAGAIN is the only error returned from
-		 * nfsd_cross_mnt() and it indicates that an
-		 * up-call has  been initiated to fill in the export
-		 * options on exp.  When the answer comes back,
-		 * this call will be retried.
-		 */
-			dput(dentry);
-			exp_put(exp);
-			nfserr = nfserr_dropit;
-			goto error;
-		}
-
-	}
-
-	nfserr = nfsd4_encode_fattr(NULL, exp,
-			dentry, p, &buflen, cd->rd_bmval,
-			cd->rd_rqstp);
-	dput(dentry);
-	exp_put(exp);
+	nfserr = nfsd4_encode_dirent_fattr(cd, name, namlen, p, &buflen);
 	if (!nfserr) {
 		p += buflen;
 		goto out;
@@ -1838,7 +1848,6 @@ nfsd4_encode_dirent(struct readdir_cd *c
 	if (nfserr == nfserr_resource)
 		goto nospc;
 
-error:
 	/*
 	 * If we get here, we experienced a miscellaneous
 	 * failure while writing the attributes.  If the


-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
