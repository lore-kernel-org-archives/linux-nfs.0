From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 8 of 18] nfsd4: use the fsid export option when returning the fsid attribute
Date: Tue, 16 Nov 2004 15:50:50 +1100
Message-ID: <E1CTvIo-0004pm-5P@notabene.cse.unsw.edu.au>
References: <20041116154601.18412.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CTvF6-0005s6-4U
	for nfs@lists.sourceforge.net; Mon, 15 Nov 2004 20:47:00 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CTvF1-0007Hw-5x
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


Return the special NFSv4 pseudo filesystem fsid (0/0) in a GETATTR on an
NFSv4 pseudo filesystem node.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4xdr.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-11-16 14:41:22.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2004-11-16 14:41:24.000000000 +1100
@@ -1425,7 +1425,7 @@ nfsd4_encode_fattr(struct svc_fh *fhp, s
 		if (status)
 			goto out_nfserr;
 	}
-	if ((bmval0 & FATTR4_WORD0_FILEHANDLE) && !fhp) {
+	if ((bmval0 & (FATTR4_WORD0_FILEHANDLE | FATTR4_WORD0_FSID)) && !fhp) {
 		fh_init(&tempfh, NFS4_FHSIZE);
 		status = fh_compose(&tempfh, exp, dentry, NULL);
 		if (status)
@@ -1508,10 +1508,15 @@ nfsd4_encode_fattr(struct svc_fh *fhp, s
 	if (bmval0 & FATTR4_WORD0_FSID) {
 		if ((buflen -= 16) < 0)
 			goto out_resource;
-		WRITE32(0);
-		WRITE32(MAJOR(stat.dev));
-		WRITE32(0);
-		WRITE32(MINOR(stat.dev));
+		if (is_fsid(fhp, rqstp->rq_reffh)) {
+			WRITE64((u64)exp->ex_fsid);
+			WRITE64((u64)0);
+		} else {
+			WRITE32(0);
+			WRITE32(MAJOR(stat.dev));
+			WRITE32(0);
+			WRITE32(MINOR(stat.dev));
+		}
 	}
 	if (bmval0 & FATTR4_WORD0_UNIQUE_HANDLES) {
 		if ((buflen -= 4) < 0)


-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
