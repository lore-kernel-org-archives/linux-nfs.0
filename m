From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 2 of 7 - Subject: [PATCH] NFS4XDR get rid of warning
Date: Tue, 23 Sep 2003 09:33:13 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1A1aB7-0004Dm-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A1aBV-0008U0-00
	for <nfs@lists.sourceforge.net>; Mon, 22 Sep 2003 16:33:37 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 1A1aBV-0003h7-16
	for nfs@lists.sourceforge.net; Mon, 22 Sep 2003 16:33:37 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@osdl.org>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Tue, 23 Sep 2003 09:33:24 +1000
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
with small mods by NeilBrown

On 2.6.0-test5 there is a warning because of calling return with an argument
on a void function. The root cause is putting a return statement in a macro
(evil side effect).

Change ENCODE_SEQID_OP_TAIL to be a more proper macro, change all
calling functions to return void.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4xdr.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2003-09-23 09:08:08.000000000 +1000
+++ ./fs/nfsd/nfs4xdr.c	2003-09-23 09:11:28.000000000 +1000
@@ -1116,13 +1116,13 @@ nfsd4_decode_compound(struct nfsd4_compo
  * where seqids are incremented
  */
 
-#define ENCODE_SEQID_OP_TAIL(stateowner)		\
+#define ENCODE_SEQID_OP_TAIL(stateowner) do {		\
 	BUG_ON(!stateowner);				\
 	if (seqid_mutating_err(nfserr) && stateowner) {	\
 		if (stateowner->so_confirmed)		\
 			stateowner->so_seqid++;		\
 	}						\
-	return nfserr;
+} while(0)
 
 
 static u32 nfs4_ftypes[16] = {
@@ -1773,7 +1773,7 @@ nfsd4_encode_open(struct nfsd4_compoundr
 	ENCODE_SEQID_OP_TAIL(open->op_stateowner);
 }
 
-static int
+static void
 nfsd4_encode_open_confirm(struct nfsd4_compoundres *resp, int nfserr, struct nfsd4_open_confirm *oc)
 {
 	ENCODE_HEAD;
@@ -1788,7 +1788,7 @@ nfsd4_encode_open_confirm(struct nfsd4_c
 	ENCODE_SEQID_OP_TAIL(oc->oc_stateowner);
 }
 
-static int
+static void
 nfsd4_encode_open_downgrade(struct nfsd4_compoundres *resp, int nfserr, struct nfsd4_open_downgrade *od)
 {
 	ENCODE_HEAD;


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
