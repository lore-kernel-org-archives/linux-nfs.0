From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 17 of 18] nfsd4: encode_dirent: fix dropit return
Date: Tue, 16 Nov 2004 15:50:51 +1100
Message-ID: <E1CTvIp-0004qM-1c@notabene.cse.unsw.edu.au>
References: <20041116154601.18412.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CTvFz-0005ui-1E
	for nfs@lists.sourceforge.net; Mon, 15 Nov 2004 20:47:55 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CTvFw-0000o2-Aj
	for nfs@lists.sourceforge.net; Mon, 15 Nov 2004 20:47:54 -0800
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



We need to handle nfserr_dropit as a special case here, since we don't
want to return it in the rdattr_error attribute.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4xdr.c |    2 ++
 1 files changed, 2 insertions(+)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-11-16 14:41:44.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2004-11-16 14:41:45.000000000 +1100
@@ -1861,6 +1861,8 @@ nfsd4_encode_dirent(struct readdir_cd *c
 	case nfserr_resource:
 		nfserr = nfserr_toosmall;
 		goto fail;
+	case nfserr_dropit:
+		goto fail;
 	default:
 		/*
 		 * If we get here, we experienced a miscellaneous


-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
