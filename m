From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 5 of 9] Reduce stack usage in nfsd4
Date: Thu, 24 Jun 2004 14:46:51 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BdM8R-0001Ln-QF@notabene.cse.unsw.edu.au>
References: <20040624143710.5086.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BdM8u-00025v-Mw
	for nfs@lists.sourceforge.net; Wed, 23 Jun 2004 21:47:20 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BdM8t-0007FC-Ne
	for nfs@lists.sourceforge.net; Wed, 23 Jun 2004 21:47:19 -0700
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



nfsd4_proc_compound is using over a thousand bytes of stack.

This is partly because it declares two local svc_fh's, partly because of a big
switch statement which calls a bunch of functions which may be inlined.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>         
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4proc.c |   85 ++++++++++++++++++++++++++++-----------------------
 1 files changed, 48 insertions(+), 37 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2004-06-23 14:37:06.000000000 +1000
+++ ./fs/nfsd/nfs4proc.c	2004-06-23 14:37:39.000000000 +1000
@@ -318,7 +318,7 @@ nfsd4_commit(struct svc_rqst *rqstp, str
 	return status;
 }
 
-static inline int
+static int
 nfsd4_create(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_create *create)
 {
 	struct svc_fh resfh;
@@ -435,7 +435,7 @@ nfsd4_link(struct svc_rqst *rqstp, struc
 	return status;
 }
 
-static inline int
+static int
 nfsd4_lookupp(struct svc_rqst *rqstp, struct svc_fh *current_fh)
 {
 	struct svc_fh tmp_fh;
@@ -773,13 +773,20 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 		    struct nfsd4_compoundres *resp)
 {
 	struct nfsd4_op	*op;
-	struct svc_fh	current_fh;
-	struct svc_fh	save_fh;
+	struct svc_fh	*current_fh = NULL;
+	struct svc_fh	*save_fh = NULL;
 	int		slack_space;    /* in words, not bytes! */
 	int		status;
 
-	fh_init(&current_fh, NFS4_FHSIZE);
-	fh_init(&save_fh, NFS4_FHSIZE);
+	status = nfserr_resource;
+	current_fh = kmalloc(sizeof(*current_fh), GFP_KERNEL);
+	if (current_fh == NULL)
+		goto out;
+	fh_init(current_fh, NFS4_FHSIZE);
+	save_fh = kmalloc(sizeof(*save_fh), GFP_KERNEL);
+	if (save_fh == NULL)
+		goto out;
+	fh_init(save_fh, NFS4_FHSIZE);
 
 	resp->xbuf = &rqstp->rq_res;
 	resp->p = rqstp->rq_res.head[0].iov_base + rqstp->rq_res.head[0].iov_len;
@@ -831,7 +838,7 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 		* SETATTR NOFILEHANDLE error handled in nfsd4_setattr
 		* due to required returned bitmap argument
 		*/
-		if ((!current_fh.fh_dentry) &&
+		if ((!current_fh->fh_dentry) &&
 		   !((op->opnum == OP_PUTFH) || (op->opnum == OP_PUTROOTFH) ||
 		   (op->opnum == OP_SETCLIENTID) ||
 		   (op->opnum == OP_SETCLIENTID_CONFIRM) ||
@@ -843,105 +850,105 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 		}
 		switch (op->opnum) {
 		case OP_ACCESS:
-			op->status = nfsd4_access(rqstp, &current_fh, &op->u.access);
+			op->status = nfsd4_access(rqstp, current_fh, &op->u.access);
 			break;
 		case OP_CLOSE:
-			op->status = nfsd4_close(rqstp, &current_fh, &op->u.close);
+			op->status = nfsd4_close(rqstp, current_fh, &op->u.close);
 			if (op->u.close.cl_stateowner)
 				op->replay =
 					&op->u.close.cl_stateowner->so_replay;
 			break;
 		case OP_COMMIT:
-			op->status = nfsd4_commit(rqstp, &current_fh, &op->u.commit);
+			op->status = nfsd4_commit(rqstp, current_fh, &op->u.commit);
 			break;
 		case OP_CREATE:
-			op->status = nfsd4_create(rqstp, &current_fh, &op->u.create);
+			op->status = nfsd4_create(rqstp, current_fh, &op->u.create);
 			break;
 		case OP_GETATTR:
-			op->status = nfsd4_getattr(rqstp, &current_fh, &op->u.getattr);
+			op->status = nfsd4_getattr(rqstp, current_fh, &op->u.getattr);
 			break;
 		case OP_GETFH:
-			op->status = nfsd4_getfh(&current_fh, &op->u.getfh);
+			op->status = nfsd4_getfh(current_fh, &op->u.getfh);
 			break;
 		case OP_LINK:
-			op->status = nfsd4_link(rqstp, &current_fh, &save_fh, &op->u.link);
+			op->status = nfsd4_link(rqstp, current_fh, save_fh, &op->u.link);
 			break;
 		case OP_LOCK:
-			op->status = nfsd4_lock(rqstp, &current_fh, &op->u.lock);
+			op->status = nfsd4_lock(rqstp, current_fh, &op->u.lock);
 			if (op->u.lock.lk_stateowner)
 				op->replay =
 					&op->u.lock.lk_stateowner->so_replay;
 			break;
 		case OP_LOCKT:
-			op->status = nfsd4_lockt(rqstp, &current_fh, &op->u.lockt);
+			op->status = nfsd4_lockt(rqstp, current_fh, &op->u.lockt);
 			break;
 		case OP_LOCKU:
-			op->status = nfsd4_locku(rqstp, &current_fh, &op->u.locku);
+			op->status = nfsd4_locku(rqstp, current_fh, &op->u.locku);
 			if (op->u.locku.lu_stateowner)
 				op->replay =
 					&op->u.locku.lu_stateowner->so_replay;
 			break;
 		case OP_LOOKUP:
-			op->status = nfsd4_lookup(rqstp, &current_fh, &op->u.lookup);
+			op->status = nfsd4_lookup(rqstp, current_fh, &op->u.lookup);
 			break;
 		case OP_LOOKUPP:
-			op->status = nfsd4_lookupp(rqstp, &current_fh);
+			op->status = nfsd4_lookupp(rqstp, current_fh);
 			break;
 		case OP_NVERIFY:
-			op->status = nfsd4_verify(rqstp, &current_fh, &op->u.nverify);
+			op->status = nfsd4_verify(rqstp, current_fh, &op->u.nverify);
 			if (op->status == nfserr_not_same)
 				op->status = nfs_ok;
 			break;
 		case OP_OPEN:
-			op->status = nfsd4_open(rqstp, &current_fh, &op->u.open);
+			op->status = nfsd4_open(rqstp, current_fh, &op->u.open);
 			if (op->u.open.op_stateowner)
 				op->replay =
 					&op->u.open.op_stateowner->so_replay;
 			break;
 		case OP_OPEN_CONFIRM:
-			op->status = nfsd4_open_confirm(rqstp, &current_fh, &op->u.open_confirm);
+			op->status = nfsd4_open_confirm(rqstp, current_fh, &op->u.open_confirm);
 			if (op->u.open_confirm.oc_stateowner)
 				op->replay =
 					&op->u.open_confirm.oc_stateowner->so_replay;
 			break;
 		case OP_OPEN_DOWNGRADE:
-			op->status = nfsd4_open_downgrade(rqstp, &current_fh, &op->u.open_downgrade);
+			op->status = nfsd4_open_downgrade(rqstp, current_fh, &op->u.open_downgrade);
 			if (op->u.open_downgrade.od_stateowner)
 				op->replay =
 					&op->u.open_downgrade.od_stateowner->so_replay;
 			break;
 		case OP_PUTFH:
-			op->status = nfsd4_putfh(rqstp, &current_fh, &op->u.putfh);
+			op->status = nfsd4_putfh(rqstp, current_fh, &op->u.putfh);
 			break;
 		case OP_PUTROOTFH:
-			op->status = nfsd4_putrootfh(rqstp, &current_fh);
+			op->status = nfsd4_putrootfh(rqstp, current_fh);
 			break;
 		case OP_READ:
-			op->status = nfsd4_read(rqstp, &current_fh, &op->u.read);
+			op->status = nfsd4_read(rqstp, current_fh, &op->u.read);
 			break;
 		case OP_READDIR:
-			op->status = nfsd4_readdir(rqstp, &current_fh, &op->u.readdir);
+			op->status = nfsd4_readdir(rqstp, current_fh, &op->u.readdir);
 			break;
 		case OP_READLINK:
-			op->status = nfsd4_readlink(rqstp, &current_fh, &op->u.readlink);
+			op->status = nfsd4_readlink(rqstp, current_fh, &op->u.readlink);
 			break;
 		case OP_REMOVE:
-			op->status = nfsd4_remove(rqstp, &current_fh, &op->u.remove);
+			op->status = nfsd4_remove(rqstp, current_fh, &op->u.remove);
 			break;
 		case OP_RENAME:
-			op->status = nfsd4_rename(rqstp, &current_fh, &save_fh, &op->u.rename);
+			op->status = nfsd4_rename(rqstp, current_fh, save_fh, &op->u.rename);
 			break;
 		case OP_RENEW:
 			op->status = nfsd4_renew(&op->u.renew);
 			break;
 		case OP_RESTOREFH:
-			op->status = nfsd4_restorefh(&current_fh, &save_fh);
+			op->status = nfsd4_restorefh(current_fh, save_fh);
 			break;
 		case OP_SAVEFH:
-			op->status = nfsd4_savefh(&current_fh, &save_fh);
+			op->status = nfsd4_savefh(current_fh, save_fh);
 			break;
 		case OP_SETATTR:
-			op->status = nfsd4_setattr(rqstp, &current_fh, &op->u.setattr);
+			op->status = nfsd4_setattr(rqstp, current_fh, &op->u.setattr);
 			break;
 		case OP_SETCLIENTID:
 			op->status = nfsd4_setclientid(rqstp, &op->u.setclientid);
@@ -950,12 +957,12 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 			op->status = nfsd4_setclientid_confirm(rqstp, &op->u.setclientid_confirm);
 			break;
 		case OP_VERIFY:
-			op->status = nfsd4_verify(rqstp, &current_fh, &op->u.verify);
+			op->status = nfsd4_verify(rqstp, current_fh, &op->u.verify);
 			if (op->status == nfserr_same)
 				op->status = nfs_ok;
 			break;
 		case OP_WRITE:
-			op->status = nfsd4_write(rqstp, &current_fh, &op->u.write);
+			op->status = nfsd4_write(rqstp, current_fh, &op->u.write);
 			break;
 		case OP_RELEASE_LOCKOWNER:
 			op->status = nfsd4_release_lockowner(rqstp, &op->u.release_lockowner);
@@ -990,8 +997,12 @@ out:
 		kfree(tb->buf);
 		kfree(tb);
 	}
-	fh_put(&current_fh);
-	fh_put(&save_fh);
+	if (current_fh)
+		fh_put(current_fh);
+	kfree(current_fh);
+	if (save_fh)
+		fh_put(save_fh);
+	kfree(save_fh);
 	return status;
 }
 


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
