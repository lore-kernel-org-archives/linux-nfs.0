From: Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 7/8] pnfs-submit: forgetful client (layouts)
Date: Mon,  7 Jun 2010 14:11:52 -0700
Message-ID: <1275945113-3436-8-git-send-email-batsakis@netapp.com>
References: <1275945113-3436-1-git-send-email-batsakis@netapp.com>
 <1275945113-3436-2-git-send-email-batsakis@netapp.com>
 <1275945113-3436-3-git-send-email-batsakis@netapp.com>
 <1275945113-3436-4-git-send-email-batsakis@netapp.com>
 <1275945113-3436-5-git-send-email-batsakis@netapp.com>
 <1275945113-3436-6-git-send-email-batsakis@netapp.com>
 <1275945113-3436-7-git-send-email-batsakis@netapp.com>
Cc: bhalevy@panasas.com, Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64865 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753573Ab0FGVL2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Jun 2010 17:11:28 -0400
In-Reply-To: <1275945113-3436-7-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Forgetful client model:

If we receive a CB_LAYOUTRECALL
        - we spawn a thread to handle the recall
        (xxx: now only one recall can be active at a time, else NFS4ERR_DELAY)
        - we check the stateid seqid
        if it does not match we return NFS4ERR_DELAY
        - we check for pending I/O
        if there is we return NFS4ERR_DELAY
        Else we return NO_MATCHING_LAYOUT.
        Note that for whole file layouts there is no need to serialize LAYOUTGETs/LAYOUTRETURNs
For bulk layouts, if there is a layout active, we return NFS4_OK and we start
cleaning the layouts asynchronously. At the end we send a bulk LAYOUTRETURN.
Note that there is no need to prevent any new LAYOUTGETs explicitly as the server should reject them.

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
---
 fs/nfs/callback_proc.c |  146 ++++++++++++++++++++++++++++++++++--------------
 fs/nfs/nfs4_fs.h       |    1 +
 fs/nfs/pnfs.c          |   70 ++++++++++-------------
 3 files changed, 136 insertions(+), 81 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 3bae785..af7a01d 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -129,6 +129,38 @@ int nfs4_validate_delegation_stateid(struct nfs_delegation *delegation, const nf
 
 #if defined(CONFIG_NFS_V4_1)
 
+static bool
+pnfs_is_next_layout_stateid(const struct pnfs_layout_type *lo,
+			    const nfs4_stateid stateid)
+{
+	int seqlock;
+	bool res;
+	u32 oldseqid, newseqid;
+
+	do {
+		seqlock = read_seqbegin(&lo->seqlock);
+		oldseqid = be32_to_cpu(lo->stateid.u.stateid.seqid);
+		newseqid = be32_to_cpu(stateid.u.stateid.seqid);
+		res = !memcmp(lo->stateid.u.stateid.other,
+			      stateid.u.stateid.other,
+			      NFS4_STATEID_OTHER_SIZE);
+		if (res) { /* comparing layout stateids */
+			if (oldseqid == ~0)
+				res = (newseqid == 1);
+			else
+				res = (newseqid == oldseqid + 1);
+		} else { /* open stateid */
+			res = !memcmp(lo->stateid.u.data,
+				      &zero_stateid,
+				      NFS4_STATEID_SIZE);
+			if (res)
+				res = (newseqid == 1);
+		}
+	} while (read_seqretry(&lo->seqlock, seqlock));
+
+	return res;
+}
+
 /*
  * Retrieve an inode based on layout recall parameters
  *
@@ -191,9 +223,10 @@ static int pnfs_recall_layout(void *data)
 	struct inode *inode, *ino;
 	struct nfs_client *clp;
 	struct cb_pnfs_layoutrecallargs rl;
+	struct nfs4_pnfs_layoutreturn *lrp;
 	struct recall_layout_threadargs *args =
 		(struct recall_layout_threadargs *)data;
-	int status;
+	int status = 0;
 
 	daemonize("nfsv4-layoutreturn");
 
@@ -204,47 +237,59 @@ static int pnfs_recall_layout(void *data)
 	clp = args->clp;
 	inode = args->inode;
 	rl = *args->rl;
-	args->result = 0;
-	complete(&args->started);
-	args = NULL;
-	/* Note: args must not be used after this point!!! */
-
-/* FIXME: need barrier here:
-   pause I/O to data servers
-   pause layoutgets
-   drain all outstanding writes to storage devices
-   wait for any outstanding layoutreturns and layoutgets mentioned in
-   cb_sequence.
-   then return layouts, resume after layoutreturns complete
- */
 
 	/* support whole file layouts only */
 	rl.cbl_seg.offset = 0;
 	rl.cbl_seg.length = NFS4_MAX_UINT64;
 
 	if (rl.cbl_recall_type == RETURN_FILE) {
-		status = pnfs_return_layout(inode, &rl.cbl_seg, &rl.cbl_stateid,
-					    RETURN_FILE, true);
+		if (pnfs_is_next_layout_stateid(&NFS_I(inode)->layout,
+						rl.cbl_stateid))
+			status = pnfs_return_layout(inode, &rl.cbl_seg,
+						    &rl.cbl_stateid, RETURN_FILE,
+						    false);
+		else
+			status = cpu_to_be32(NFS4ERR_DELAY);
 		if (status)
 			dprintk("%s RETURN_FILE error: %d\n", __func__, status);
+		else
+			status =  cpu_to_be32(NFS4ERR_NOMATCHING_LAYOUT);
+		args->result = status;
+		complete(&args->started);
 		goto out;
 	}
 
-	/* FIXME: This loop is inefficient, running in O(|s_inodes|^2) */
+	status = cpu_to_be32(NFS4_OK);
+	args->result = status;
+	complete(&args->started);
+	args = NULL;
+
+	/* IMPROVEME: This loop is inefficient, running in O(|s_inodes|^2) */
 	while ((ino = nfs_layoutrecall_find_inode(clp, &rl)) != NULL) {
-		/* XXX need to check status on pnfs_return_layout */
-		pnfs_return_layout(ino, &rl.cbl_seg, NULL, RETURN_FILE, true);
+		/* FIXME: need to check status on pnfs_return_layout */
+		pnfs_return_layout(ino, &rl.cbl_seg, NULL, RETURN_FILE, false);
 		iput(ino);
 	}
 
+	lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
+	if (!lrp) {
+		dprintk("%s: allocation failed. Cannot send last LAYOUTRETURN\n",
+			__func__);
+		goto out;
+	}
+
 	/* send final layoutreturn */
-	status = pnfs_return_layout(inode, &rl.cbl_seg, NULL,
-				    rl.cbl_recall_type, true);
-	if (status)
-		printk(KERN_INFO "%s: ignoring pnfs_return_layout status=%d\n",
-				__func__, status);
+	lrp->args.reclaim = 0;
+	lrp->args.layout_type = rl.cbl_layout_type;
+	lrp->args.return_type = rl.cbl_recall_type;
+	lrp->args.lseg = rl.cbl_seg;
+	lrp->args.inode = inode;
+	lrp->lo = NULL;
+	pnfs4_proc_layoutreturn(lrp, true);
+
 out:
-	iput(inode);
+	clear_bit(NFS4CLNT_LAYOUT_RECALL, &clp->cl_state);
+	nfs_put_client(clp);
 	module_put_and_exit(0);
 	dprintk("%s: exit status %d\n", __func__, 0);
 	return 0;
@@ -262,15 +307,18 @@ static int pnfs_async_return_layout(struct nfs_client *clp, struct inode *inode,
 		.rl = rl,
 	};
 	struct task_struct *t;
-	int status;
-
-	/* should have returned NFS4ERR_NOMATCHING_LAYOUT... */
-	BUG_ON(inode == NULL);
+	int status = -EAGAIN;
 
 	dprintk("%s: -->\n", __func__);
 
+	/* FIXME: do not allow two concurrent layout recalls */
+	if (test_and_set_bit(NFS4CLNT_LAYOUT_RECALL, &clp->cl_state))
+		return status;
+
 	init_completion(&data.started);
 	__module_get(THIS_MODULE);
+	if (!atomic_inc_not_zero(&clp->cl_count))
+		goto out_put_no_client;
 
 	t = kthread_run(pnfs_recall_layout, &data, "%s", "pnfs_recall_layout");
 	if (IS_ERR(t)) {
@@ -284,6 +332,9 @@ static int pnfs_async_return_layout(struct nfs_client *clp, struct inode *inode,
 	wait_for_completion(&data.started);
 	return data.result;
 out_module_put:
+	nfs_put_client(clp);
+out_put_no_client:
+	clear_bit(NFS4CLNT_LAYOUT_RECALL, &clp->cl_state);
 	module_put(THIS_MODULE);
 	return status;
 }
@@ -294,35 +345,46 @@ __be32 pnfs_cb_layoutrecall(struct cb_pnfs_layoutrecallargs *args,
 	struct nfs_client *clp;
 	struct inode *inode = NULL;
 	__be32 res;
+	int status;
 	unsigned int num_client = 0;
 
 	dprintk("%s: -->\n", __func__);
 
-	res = htonl(NFS4ERR_INVAL);
-	clp = nfs_find_client(args->cbl_addr, 4);
+	res = cpu_to_be32(NFS4ERR_OP_NOT_IN_SESSION);
+	clp  = nfs_find_client(args->cbl_addr, 4);
 	if (clp == NULL) {
 		dprintk("%s: no client for addr %u.%u.%u.%u\n",
 			__func__, NIPQUAD(args->cbl_addr));
 		goto out;
 	}
 
-	res = htonl(NFS4ERR_NOMATCHING_LAYOUT);
+	res = cpu_to_be32(NFS4ERR_NOMATCHING_LAYOUT);
 	do {
 		struct nfs_client *prev = clp;
 		num_client++;
-		inode = nfs_layoutrecall_find_inode(clp, args);
-		if (inode != NULL) {
-			if (PNFS_LD(&NFS_I(inode)->layout)->id ==
-			    args->cbl_layout_type) {
-				/* Set up a helper thread to actually
-				 * return the delegation */
-				res = pnfs_async_return_layout(clp, inode, args);
-				if (res != 0)
-					res = htonl(NFS4ERR_RESOURCE);
-				break;
+		/* the callback must come from the MDS personality */
+		if (!(clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_MDS))
+			goto loop;
+		if (args->cbl_recall_type == RETURN_FILE) {
+			inode = nfs_layoutrecall_find_inode(clp, args);
+			if (inode != NULL) {
+				status = pnfs_async_return_layout(clp, inode,
+								  args);
+				if (status == -EAGAIN)
+					res = cpu_to_be32(NFS4ERR_DELAY);
+				iput(inode);
 			}
+		} else { /* _ALL or _FSID */
+			/* we need the inode to get the nfs_server struct */
+			inode = nfs_layoutrecall_find_inode(clp, args);
+			if (!inode)
+				goto loop;
+			status = pnfs_async_return_layout(clp, inode, args);
+			if (status == -EAGAIN)
+				res = cpu_to_be32(NFS4ERR_DELAY);
 			iput(inode);
 		}
+loop:
 		clp = nfs_find_client_next(prev);
 		nfs_put_client(prev);
 	} while (clp != NULL);
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index ebc9b3b..2f7974b 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -47,6 +47,7 @@ enum nfs4_client_state {
 	NFS4CLNT_SESSION_RESET,
 	NFS4CLNT_SESSION_DRAINING,
 	NFS4CLNT_RECALL_SLOT,
+	NFS4CLNT_LAYOUT_RECALL,
 };
 
 /*
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index d0b45bf..2006926 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -709,6 +709,8 @@ return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 
 	dprintk("--> %s\n", __func__);
 
+	BUG_ON(type != RETURN_FILE);
+
 	lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
 	if (lrp == NULL) {
 		if (lo && (type == RETURN_FILE))
@@ -745,13 +747,11 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 
 	dprintk("--> %s type %d\n", __func__, type);
 
-	if (range)
-		arg = *range;
-	else {
-		arg.iomode = IOMODE_ANY;
-		arg.offset = 0;
-		arg.length = NFS4_MAX_UINT64;
-	}
+
+	arg.iomode = range ? range->iomode : IOMODE_ANY;
+	arg.offset = 0;
+	arg.length = NFS4_MAX_UINT64;
+
 	if (type == RETURN_FILE) {
 		lo = get_lock_current_layout(nfsi);
 		if (lo && !has_layout_to_return(lo, &arg)) {
@@ -760,11 +760,7 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 		}
 		if (!lo) {
 			dprintk("%s: no layout segments to return\n", __func__);
-			/* must send the LAYOUTRETURN in response to recall */
-			if (stateid)
-				goto send_return;
-			else
-				goto out;
+			goto out;
 		}
 
 		/* unlock w/o put rebalanced by eventual call to
@@ -773,12 +769,23 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 		unlock_current_layout(nfsi);
 
 		if (pnfs_return_layout_barrier(nfsi, &arg)) {
+			if (stateid) { /* callback */
+				status = -EAGAIN;
+				lock_current_layout(nfsi);
+				put_unlock_current_layout(lo);
+				goto out;
+			}
 			dprintk("%s: waiting\n", __func__);
 			wait_event(nfsi->lo_waitq,
-				!pnfs_return_layout_barrier(nfsi, &arg));
+				   !pnfs_return_layout_barrier(nfsi, &arg));
 		}
 
 		if (layoutcommit_needed(nfsi)) {
+			if (stateid && !wait) { /* callback */
+				dprintk("%s: layoutcommit pending\n", __func__);
+				status = -EAGAIN;
+				goto out;
+			}
 			status = pnfs_layoutcommit_inode(ino, wait);
 			if (status) {
 				dprintk("%s: layoutcommit failed, status=%d. "
@@ -787,9 +794,13 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 				status = 0;
 			}
 		}
+
+		if (stateid && wait)
+			status = return_layout(ino, &arg, stateid, type,
+					       lo, wait);
+		else
+			pnfs_layout_release(lo, &arg);
 	}
-send_return:
-	status = return_layout(ino, &arg, stateid, type, lo, wait);
 out:
 	dprintk("<-- %s status: %d\n", __func__, status);
 	return status;
@@ -1044,7 +1055,7 @@ pnfs_update_layout(struct inode *ino,
 	struct nfs4_pnfs_layout_segment arg = {
 		.iomode = iomode,
 		.offset = 0,
-		.length = ~0
+		.length = NFS4_MAX_UINT64,
 	};
 	struct nfs_inode *nfsi = NFS_I(ino);
 	struct pnfs_layout_type *lo;
@@ -1063,31 +1074,12 @@ pnfs_update_layout(struct inode *ino,
 	/* Check to see if the layout for the given range already exists */
 	lseg = pnfs_has_layout(lo, &arg, take_ref, !take_ref);
 	if (lseg && !lseg->valid) {
-		unlock_current_layout(nfsi);
 		if (take_ref)
 			put_lseg(lseg);
-		for (;;) {
-			prepare_to_wait(&nfsi->lo_waitq, &__wait,
-					TASK_KILLABLE);
-			lock_current_layout(nfsi);
-			lseg = pnfs_has_layout(lo, &arg, take_ref, !take_ref);
-			if (!lseg || lseg->valid)
-				break;
-			dprintk("%s: invalid lseg %p ref %d\n", __func__,
-				lseg, atomic_read(&lseg->kref.refcount)-1);
-			if (take_ref)
-				put_lseg(lseg);
-			if (signal_pending(current)) {
-				lseg = NULL;
-				result = -ERESTARTSYS;
-				break;
-			}
-			unlock_current_layout(nfsi);
-			schedule();
-		}
-		finish_wait(&nfsi->lo_waitq, &__wait);
-		if (result)
-			goto out_put;
+
+		/* someone is cleaning the layout */
+		result = -EAGAIN;
+		goto out_put;
 	}
 
 	if (lseg) {
-- 
1.6.2.5

