From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 2 of 4 - NFSv4 operations after WRITE are decoded into wr_vec[] pages,
Date: Wed, 26 Mar 2003 11:10:54 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18xyVK-0004Tg-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18xyVn-0002NY-00
	for <nfs@lists.sourceforge.net>; Tue, 25 Mar 2003 16:11:23 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 26 Mar 2003 11:11:12 +1100
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


### Comments for ChangeSet
thus the argp->pagelen can be non-zero at the end of decoding the 
WRITE operation. 
this patch correctly sets argp->pagelen, and correctly advances argp->p 
after the WRITE operation

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4xdr.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2003-03-26 09:44:33.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2003-03-26 09:44:36.000000000 +1100
@@ -852,16 +852,16 @@ nfsd4_decode_write(struct nfsd4_compound
 		v++;
 		write->wr_vec[v].iov_base = page_address(argp->pagelist[0]);
 		argp->pagelist++;
-		if (argp->pagelen >= PAGE_SIZE) {
+		if (len >= PAGE_SIZE) {
 			write->wr_vec[v].iov_len = PAGE_SIZE;
 			argp->pagelen -= PAGE_SIZE;
 		} else {
 			write->wr_vec[v].iov_len = argp->pagelen;
-			argp->pagelen = 0;
+			argp->pagelen -= len;
 		}
 	}
 	argp->end = (u32*) (write->wr_vec[v].iov_base + write->wr_vec[v].iov_len);
-	argp->p = (u32*)  (write->wr_vec[v].iov_base + len);
+	argp->p = (u32*)  (write->wr_vec[v].iov_base + (XDR_QUADLEN(len) << 2));
 	write->wr_vec[v].iov_len = len;
 	write->wr_vlen = v+1;
 


-------------------------------------------------------
This SF.net email is sponsored by:
The Definitive IT and Networking Event. Be There!
NetWorld+Interop Las Vegas 2003 -- Register today!
http://ads.sourceforge.net/cgi-bin/redirect.pl?keyn0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
