From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 9 of 18] nfsd4 encode_dirent cleanup
Date: Tue, 16 Nov 2004 15:50:50 +1100
Message-ID: <E1CTvIo-0004pq-7H@notabene.cse.unsw.edu.au>
References: <20041116154601.18412.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CTvF6-0005s5-4S
	for nfs@lists.sourceforge.net; Mon, 15 Nov 2004 20:47:00 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CTvF1-0007HG-5w
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



No sensible client is ever going to request only the RDATTR_ERROR attribute, so
there's no point optimizing for that case.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4xdr.c |  106 +++++++++++++++++++++++-----------------------------
 1 files changed, 47 insertions(+), 59 deletions(-)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-11-16 14:41:24.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2004-11-16 14:41:32.000000000 +1100
@@ -1805,73 +1805,62 @@ nfsd4_encode_dirent(struct readdir_cd *c
 	 */
 	bmval0 = cd->rd_bmval[0];
 	bmval1 = cd->rd_bmval[1];
-	if ((bmval0 & ~(FATTR4_WORD0_RDATTR_ERROR)) || bmval1)  {
-		/*
-		 * "Heavyweight" case: we have no choice except to
-		 * call nfsd4_encode_fattr(). 
-		 */
-		dentry = lookup_one_len(name, cd->rd_fhp->fh_dentry, namlen);
-		if (IS_ERR(dentry)) {
-			nfserr = nfserrno(PTR_ERR(dentry));
-			goto error;
-		}
-
-		exp_get(exp);
-		if (d_mountpoint(dentry)) {
-			if ((nfserr = nfsd_cross_mnt(cd->rd_rqstp, &dentry, 
-					 &exp))) {	
-			/* 
-			 * -EAGAIN is the only error returned from 
-			 * nfsd_cross_mnt() and it indicates that an 
-			 * up-call has  been initiated to fill in the export 
-			 * options on exp.  When the answer comes back,
-			 * this call will be retried.
-			 */
-				dput(dentry);
-				exp_put(exp);
-				nfserr = nfserr_dropit;
-				goto error;
-			}
 
-		}
-
-		nfserr = nfsd4_encode_fattr(NULL, exp,
-				dentry, p, &buflen, cd->rd_bmval,
-				cd->rd_rqstp);
-		dput(dentry);
-		exp_put(exp);
-		if (!nfserr) {
-			p += buflen;
-			goto out;
-		}
-		if (nfserr == nfserr_resource)
-			goto nospc;
+	dentry = lookup_one_len(name, cd->rd_fhp->fh_dentry, namlen);
+	if (IS_ERR(dentry)) {
+		nfserr = nfserrno(PTR_ERR(dentry));
+		goto error;
+	}
 
-error:
+	exp_get(exp);
+	if (d_mountpoint(dentry)) {
+		if ((nfserr = nfsd_cross_mnt(cd->rd_rqstp, &dentry,
+				 &exp))) {
 		/*
-		 * If we get here, we experienced a miscellaneous
-		 * failure while writing the attributes.  If the
-		 * client requested the RDATTR_ERROR attribute,
-		 * we stuff the error code into this attribute
-		 * and continue.  If this attribute was not requested,
-		 * then in accordance with the spec, we fail the
-		 * entire READDIR operation(!)
+		 * -EAGAIN is the only error returned from
+		 * nfsd_cross_mnt() and it indicates that an
+		 * up-call has  been initiated to fill in the export
+		 * options on exp.  When the answer comes back,
+		 * this call will be retried.
 		 */
-		if (!(bmval0 & FATTR4_WORD0_RDATTR_ERROR)) {
-			cd->common.err = nfserr;
-			return -EINVAL;
+			dput(dentry);
+			exp_put(exp);
+			nfserr = nfserr_dropit;
+			goto error;
 		}
 
-		bmval0 = FATTR4_WORD0_RDATTR_ERROR;
-		bmval1 = 0;
-		/* falling through here will do the right thing... */
 	}
 
+	nfserr = nfsd4_encode_fattr(NULL, exp,
+			dentry, p, &buflen, cd->rd_bmval,
+			cd->rd_rqstp);
+	dput(dentry);
+	exp_put(exp);
+	if (!nfserr) {
+		p += buflen;
+		goto out;
+	}
+	if (nfserr == nfserr_resource)
+		goto nospc;
+
+error:
 	/*
-	 * In the common "lightweight" case, we avoid
-	 * the overhead of nfsd4_encode_fattr() by assembling
-	 * a small fattr by hand.
+	 * If we get here, we experienced a miscellaneous
+	 * failure while writing the attributes.  If the
+	 * client requested the RDATTR_ERROR attribute,
+	 * we stuff the error code into this attribute
+	 * and continue.  If this attribute was not requested,
+	 * then in accordance with the spec, we fail the
+	 * entire READDIR operation(!)
 	 */
+	if (!(bmval0 & FATTR4_WORD0_RDATTR_ERROR)) {
+		cd->common.err = nfserr;
+		return -EINVAL;
+	}
+
+	bmval0 = FATTR4_WORD0_RDATTR_ERROR;
+	bmval1 = 0;
+
 	if (buflen < 6)
 		goto nospc;
 	*p++ = htonl(2);
@@ -1879,8 +1868,7 @@ error:
 	*p++ = htonl(bmval1);
 
 	attrlenp = p++;
-	if (bmval0 & FATTR4_WORD0_RDATTR_ERROR)
-		*p++ = nfserr;       /* no htonl */
+	*p++ = nfserr;       /* no htonl */
 	*attrlenp = htonl((char *)p - (char *)attrlenp - 4);
 
 out:


-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
