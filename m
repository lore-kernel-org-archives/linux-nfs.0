From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 10 of 18] nfsd4: encode_dirent: superfluous assignment
Date: Tue, 16 Nov 2004 15:50:50 +1100
Message-ID: <E1CTvIo-0004pu-AD@notabene.cse.unsw.edu.au>
References: <20041116154601.18412.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CTvF2-0005rb-Nn
	for nfs@lists.sourceforge.net; Mon, 15 Nov 2004 20:46:56 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CTvEy-0000hd-JI
	for nfs@lists.sourceforge.net; Mon, 15 Nov 2004 20:46:56 -0800
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



Remove unused assignment

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4xdr.c |    3 +--
 1 files changed, 1 insertion(+), 2 deletions(-)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-11-16 14:41:32.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2004-11-16 14:41:35.000000000 +1100
@@ -1814,8 +1814,7 @@ nfsd4_encode_dirent(struct readdir_cd *c
 
 	exp_get(exp);
 	if (d_mountpoint(dentry)) {
-		if ((nfserr = nfsd_cross_mnt(cd->rd_rqstp, &dentry,
-				 &exp))) {
+		if (nfsd_cross_mnt(cd->rd_rqstp, &dentry, &exp)) {
 		/*
 		 * -EAGAIN is the only error returned from
 		 * nfsd_cross_mnt() and it indicates that an


-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
