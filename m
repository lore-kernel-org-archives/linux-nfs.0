From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 10 of 11 - nfsd-create-fix.patch
Date: Fri, 28 May 2004 14:37:31 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BTZ7b-0008Er-9V@notabene.cse.unsw.edu.au>
References: <20040528143518.31534.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BUkX5-0006PJ-PE
	for nfs@lists.sourceforge.net; Mon, 31 May 2004 04:00:43 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BUkX4-0002od-Si
	for nfs@lists.sourceforge.net; Mon, 31 May 2004 04:00:43 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.172.124]) (auth-user neilb) (ident-user Debian-exim)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Fri, 28 May 2004 14:37:31 +1000
To: Andrew Morton <akpm@osdl.org>
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



Fix error return in create. (See comment in xdr for createtype4 at end of
rfc3530.)



From: Andy Adamson <andros@citi.umich.edu>
From: "J. Bruce Fields" <bfields@fieldses.org>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4proc.c |    2 +-
 ./fs/nfsd/nfs4xdr.c  |    3 +--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2004-05-28 14:27:26.000000000 +1000
+++ ./fs/nfsd/nfs4proc.c	2004-05-28 14:28:27.000000000 +1000
@@ -389,7 +389,7 @@ nfsd4_create(struct svc_rqst *rqstp, str
 		break;
 
 	default:
-		BUG();
+		status = nfserr_badtype;
 	}
 
 	if (!status) {

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-05-28 14:27:26.000000000 +1000
+++ ./fs/nfsd/nfs4xdr.c	2004-05-28 14:28:27.000000000 +1000
@@ -538,9 +538,8 @@ nfsd4_decode_create(struct nfsd4_compoun
 	case NF4SOCK:
 	case NF4FIFO:
 	case NF4DIR:
-		break;
 	default:
-		goto xdr_error;
+		break;
 	}
 
 	READ_BUF(4);


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
