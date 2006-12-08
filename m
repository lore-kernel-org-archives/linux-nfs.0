From: NeilBrown <neilb@suse.de>
Subject: [PATCH 013 of 18] knfsd: nfsd4: make verify and nverify
	wrappers
Date: Fri, 8 Dec 2006 12:14:30 +1100
Message-ID: <1061208011430.30713@suse.de>
References: <20061208120939.30428.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GsUJe-0003EH-46
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 17:14:18 -0800
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GsUJe-0001Fl-On
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 17:14:19 -0800
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

Make wrappers for verify and nverify, for consistency with other ops.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4proc.c |   28 ++++++++++++++++++++++------
 1 file changed, 22 insertions(+), 6 deletions(-)

diff .prev/fs/nfsd/nfs4proc.c ./fs/nfsd/nfs4proc.c
--- .prev/fs/nfsd/nfs4proc.c	2006-12-08 12:09:29.000000000 +1100
+++ ./fs/nfsd/nfs4proc.c	2006-12-08 12:09:30.000000000 +1100
@@ -681,7 +681,7 @@ nfsd4_write(struct svc_rqst *rqstp, stru
  * to NFS_OK after the call; NVERIFY by mapping NFSERR_NOT_SAME to NFS_OK.
  */
 static __be32
-nfsd4_verify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
+_nfsd4_verify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	     struct nfsd4_verify *verify)
 {
 	__be32 *buf, *p;
@@ -733,6 +733,26 @@ out_kfree:
 	return status;
 }
 
+static __be32
+nfsd4_nverify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
+	      struct nfsd4_verify *verify)
+{
+	__be32 status;
+
+	status = _nfsd4_verify(rqstp, cstate, verify);
+	return status == nfserr_not_same ? nfs_ok : status;
+}
+
+static __be32
+nfsd4_verify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
+	     struct nfsd4_verify *verify)
+{
+	__be32 status;
+
+	status = _nfsd4_verify(rqstp, cstate, verify);
+	return status == nfserr_same ? nfs_ok : status;
+}
+
 /*
  * NULL call.
  */
@@ -911,10 +931,8 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 			op->status = nfsd4_lookupp(rqstp, cstate);
 			break;
 		case OP_NVERIFY:
-			op->status = nfsd4_verify(rqstp, cstate,
+			op->status = nfsd4_nverify(rqstp, cstate,
 						  &op->u.nverify);
-			if (op->status == nfserr_not_same)
-				op->status = nfs_ok;
 			break;
 		case OP_OPEN:
 			op->status = nfsd4_open(rqstp, cstate,
@@ -975,8 +993,6 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 		case OP_VERIFY:
 			op->status = nfsd4_verify(rqstp, cstate,
 						  &op->u.verify);
-			if (op->status == nfserr_same)
-				op->status = nfs_ok;
 			break;
 		case OP_WRITE:
 			op->status = nfsd4_write(rqstp, cstate, &op->u.write);

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
