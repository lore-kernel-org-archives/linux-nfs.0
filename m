From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 7 of 7 - nfsv4 page boundary handling fixes.
Date: Tue, 05 Aug 2003 13:59:24 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19jsyq-0000nY-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19jsz0-0001hj-00
	for <nfs@lists.sourceforge.net>; Mon, 04 Aug 2003 20:59:34 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@osdl.org>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Tue, 5 Aug 2003 13:59:29 +1000
To: Linus Torvalds <torvalds@osdl.org>
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

From: Galen Michael Elias <gme@citi.umich.edu>

  This patch fixes two places where the handling of page boundaries was
incorrect and caused to IO_ERR's when it shouldn't have.

1.  In decode_write it was just a small typo.
2.  In decode_compound we avoid using READ_BUF, but don't provide all of
it's functionality, specifically crosses a page boundary.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4xdr.c |   37 ++++++++++++++++++++++++++++---------
 1 files changed, 28 insertions(+), 9 deletions(-)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2003-08-04 14:42:17.000000000 +1000
+++ ./fs/nfsd/nfs4xdr.c	2003-08-04 14:42:17.000000000 +1000
@@ -880,7 +880,7 @@ nfsd4_decode_write(struct nfsd4_compound
 		v++;
 		write->wr_vec[v].iov_base = page_address(argp->pagelist[0]);
 		argp->pagelist++;
-		if (len >= PAGE_SIZE) {
+		if (argp->pagelen >= PAGE_SIZE) {
 			write->wr_vec[v].iov_len = PAGE_SIZE;
 			argp->pagelen -= PAGE_SIZE;
 		} else {
@@ -934,16 +934,35 @@ nfsd4_decode_compound(struct nfsd4_compo
 		op = &argp->ops[i];
 
 		/*
-		 * Before reading the opcode, we test for the 4-byte buffer
-		 * overrun explicitly, instead of using READ_BUF().  This is
-		 * because we want a missing opcode to be treated as opcode
-		 * OP_WRITE+1, instead of a failed XDR.
+		 * We can't use READ_BUF() here because we need to handle
+		 * a missing opcode as an OP_WRITE + 1. So we need to check
+		 * to see if we're truly at the end of our buffer or if there
+		 * is another page we need to flip to.
 		 */
+
 		if (argp->p == argp->end) {
-			op->opnum = OP_WRITE + 1;
-			op->status = nfserr_bad_xdr;
-			argp->opcnt = i+1;
-			break;
+			if (argp->pagelen < 4) {
+				/* There isn't an opcode still on the wire */
+				op->opnum = OP_WRITE + 1;
+				op->status = nfserr_bad_xdr;
+				argp->opcnt = i+1;
+				break;
+			}
+
+			/*
+			 * False alarm. We just hit a page boundary, but there
+			 * is still data available.  Move pointer across page
+			 * boundary.  *snip from READ_BUF*
+			 */
+			argp->p = page_address(argp->pagelist[0]);
+			argp->pagelist++;
+			if (argp->pagelen < PAGE_SIZE) {
+				argp->end = p + (argp->pagelen>>2);
+				argp->pagelen = 0;
+			} else {
+				argp->end = p + (PAGE_SIZE>>2);
+				argp->pagelen -= PAGE_SIZE;
+			}
 		}
 		op->opnum = ntohl(*argp->p++);
 


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
