From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 5 of 18] nfsd4: fix open_downgrade decode error.
Date: Tue, 16 Nov 2004 15:50:49 +1100
Message-ID: <E1CTvIn-0004pa-St@notabene.cse.unsw.edu.au>
References: <20041116154601.18412.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CTvEy-0005r4-JY
	for nfs@lists.sourceforge.net; Mon, 15 Nov 2004 20:46:52 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CTvEx-0007Gt-Pk
	for nfs@lists.sourceforge.net; Mon, 15 Nov 2004 20:46:52 -0800
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


Fix open downgrade decode error.

Signed-off-by: Andy Adamson <andros@umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4xdr.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-11-16 14:41:20.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2004-11-16 14:41:20.000000000 +1100
@@ -825,7 +825,7 @@ nfsd4_decode_open_downgrade(struct nfsd4
 	DECODE_HEAD;
 		    
 	open_down->od_stateowner = NULL;
-	READ_BUF(4 + sizeof(stateid_t));
+	READ_BUF(12 + sizeof(stateid_t));
 	READ32(open_down->od_stateid.si_generation);
 	COPYMEM(&open_down->od_stateid.si_opaque, sizeof(stateid_opaque_t));
 	READ32(open_down->od_seqid);


-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
