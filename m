From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 1 of 4 - READ_BUF macro:
Date: Wed, 26 Mar 2003 11:10:53 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18xyVJ-0004Td-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18xyVm-0002NW-00
	for <nfs@lists.sourceforge.net>; Tue, 25 Mar 2003 16:11:22 -0800
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

Here-with: 4 patches for knfsd in 2.5.latest.
 3 NFSv4 related, from Andy Adamson and the NFSv4 team.
 1 fix for bug #29 @ bugme.osdl.org

### Comments for ChangeSet
Fix some misleading comments, and correct the test for requesting more
than one page.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4xdr.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2003-03-26 09:44:33.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2003-03-26 09:44:33.000000000 +1100
@@ -231,6 +231,7 @@ xdr_error:					\
 	p += XDR_QUADLEN(nbytes);		\
 } while (0)
 
+/* READ_BUF, read_buf(): nbytes must be <= PAGE_SIZE */
 #define READ_BUF(nbytes)  do {			\
 	if (nbytes <= (u32)((char *)argp->end - (char *)argp->p)) {	\
 		p = argp->p;			\
@@ -244,15 +245,15 @@ xdr_error:					\
 u32 *read_buf(struct nfsd4_compoundargs *argp, int nbytes)
 {
 	/* We want more bytes than seem to be available.
-	 * Maybe we need a new page, may wehave just run out
+	 * Maybe we need a new page, maybe we have just run out
 	 */
 	int avail = (char*)argp->end - (char*)argp->p;
 	u32 *p;
 	if (avail + argp->pagelen < nbytes)
 		return NULL;
-	if (avail + PAGE_SIZE > nbytes) /* need more than a page !! */
+	if (avail + PAGE_SIZE < nbytes) /* need more than a page !! */
 		return NULL;
-	/* ok, we can do it with the tail plus the next page */
+	/* ok, we can do it with the current plus the next page */
 	if (nbytes <= sizeof(argp->tmp))
 		p = argp->tmp;
 	else {


-------------------------------------------------------
This SF.net email is sponsored by:
The Definitive IT and Networking Event. Be There!
NetWorld+Interop Las Vegas 2003 -- Register today!
http://ads.sourceforge.net/cgi-bin/redirect.pl?keyn0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
