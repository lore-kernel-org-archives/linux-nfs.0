From: NeilBrown <neilb@suse.de>
Subject: [PATCH 015 of 18] knfsd: nfsd4: simplify migration op check
Date: Fri, 8 Dec 2006 12:14:41 +1100
Message-ID: <1061208011441.30737@suse.de>
References: <20061208120939.30428.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GsUJp-0003EV-1O
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 17:14:29 -0800
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GsUJp-0001I7-M9
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 17:14:30 -0800
To: Andrew Morton <akpm@osdl.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


From: J.Bruce Fields <bfields@fieldses.org>

I'm not too fond of these big if conditions.  Replace them by checks of a
flag in the operation descriptor.  To my eye this makes the code a bit more
self-documenting, and makes the complicated part of the code
(proc_compound) a little more compact.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4proc.c |   24 +++++++++++++-----------
 1 file changed, 13 insertions(+), 11 deletions(-)

diff .prev/fs/nfsd/nfs4proc.c ./fs/nfsd/nfs4proc.c
--- .prev/fs/nfsd/nfs4proc.c	2006-12-08 12:09:30.000000000 +1100
+++ ./fs/nfsd/nfs4proc.c	2006-12-08 12:09:30.000000000 +1100
@@ -802,6 +802,8 @@ typedef __be32(*nfsd4op_func)(struct svc
 struct nfsd4_operation {
 	nfsd4op_func op_func;
 	u32 op_flags;
+/* GETATTR and ops not listed as returning NFS4ERR_MOVED: */
+#define ALLOWED_ON_ABSENT_FS 1
 };
 
 static struct nfsd4_operation nfsd4_ops[];
@@ -887,17 +889,8 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 				op->status = nfserr_nofilehandle;
 				goto encode_op;
 			}
-		}
-		/* Check must be done at start of each operation, except
-		 * for GETATTR and ops not listed as returning NFS4ERR_MOVED
-		 */
-		else if (cstate->current_fh.fh_export->ex_fslocs.migrated &&
-			 !((op->opnum == OP_GETATTR) ||
-			   (op->opnum == OP_PUTROOTFH) ||
-			   (op->opnum == OP_PUTPUBFH) ||
-			   (op->opnum == OP_RENEW) ||
-			   (op->opnum == OP_SETCLIENTID) ||
-			   (op->opnum == OP_RELEASE_LOCKOWNER))) {
+		} else if (cstate->current_fh.fh_export->ex_fslocs.migrated &&
+			  !(opdesc->op_flags & ALLOWED_ON_ABSENT_FS)) {
 			op->status = nfserr_moved;
 			goto encode_op;
 		}
@@ -951,6 +944,7 @@ static struct nfsd4_operation nfsd4_ops[
 	},
 	[OP_GETATTR] = {
 		.op_func = (nfsd4op_func)nfsd4_getattr,
+		.op_flags = ALLOWED_ON_ABSENT_FS,
 	},
 	[OP_GETFH] = {
 		.op_func = (nfsd4op_func)nfsd4_getfh,
@@ -988,8 +982,13 @@ static struct nfsd4_operation nfsd4_ops[
 	[OP_PUTFH] = {
 		.op_func = (nfsd4op_func)nfsd4_putfh,
 	},
+	[OP_PUTPUBFH] = {
+		/* unsupported; just for future reference: */
+		.op_flags = ALLOWED_ON_ABSENT_FS,
+	},
 	[OP_PUTROOTFH] = {
 		.op_func = (nfsd4op_func)nfsd4_putrootfh,
+		.op_flags = ALLOWED_ON_ABSENT_FS,
 	},
 	[OP_READ] = {
 		.op_func = (nfsd4op_func)nfsd4_read,
@@ -1008,6 +1007,7 @@ static struct nfsd4_operation nfsd4_ops[
 	},
 	[OP_RENEW] = {
 		.op_func = (nfsd4op_func)nfsd4_renew,
+		.op_flags = ALLOWED_ON_ABSENT_FS,
 	},
 	[OP_RESTOREFH] = {
 		.op_func = (nfsd4op_func)nfsd4_restorefh,
@@ -1020,6 +1020,7 @@ static struct nfsd4_operation nfsd4_ops[
 	},
 	[OP_SETCLIENTID] = {
 		.op_func = (nfsd4op_func)nfsd4_setclientid,
+		.op_flags = ALLOWED_ON_ABSENT_FS,
 	},
 	[OP_SETCLIENTID_CONFIRM] = {
 		.op_func = (nfsd4op_func)nfsd4_setclientid_confirm,
@@ -1032,6 +1033,7 @@ static struct nfsd4_operation nfsd4_ops[
 	},
 	[OP_RELEASE_LOCKOWNER] = {
 		.op_func = (nfsd4op_func)nfsd4_release_lockowner,
+		.op_flags = ALLOWED_ON_ABSENT_FS,
 	},
 };
 

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
