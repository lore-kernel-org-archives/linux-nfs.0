From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 3 of 4 - encode_read:
Date: Wed, 26 Mar 2003 11:10:54 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18xyVK-0004Tk-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18xyVn-0002Nl-00
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
change 'len' variable from unsigned long to a long for '(len > 0)' comparison.
don't set up a tail iovec for zero length reads.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4xdr.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletion(-)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2003-03-26 09:44:36.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2003-03-26 09:44:38.000000000 +1100
@@ -1691,7 +1691,8 @@ nfsd4_encode_read(struct nfsd4_compoundr
 {
 	u32 eof;
 	int v, pn;
-	unsigned long maxcount, len;
+	unsigned long maxcount; 
+	long len;
 	ENCODE_HEAD;
 
 	if (nfserr)
@@ -1732,6 +1733,10 @@ nfsd4_encode_read(struct nfsd4_compoundr
 
 	resp->xbuf->page_len = maxcount;
 
+	/* read zero bytes -> don't set up tail */
+	if(!maxcount)
+		return 0;        
+
 	/* set up page for remaining responses */
 	svc_take_page(resp->rqstp);
 	resp->xbuf->tail[0].iov_base = 


-------------------------------------------------------
This SF.net email is sponsored by:
The Definitive IT and Networking Event. Be There!
NetWorld+Interop Las Vegas 2003 -- Register today!
http://ads.sourceforge.net/cgi-bin/redirect.pl?keyn0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
