Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37049 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751762Ab3EUU0b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 May 2013 16:26:31 -0400
Date: Tue, 21 May 2013 16:26:30 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <steved@redhat.com>
Cc: Bruce Fields <bfields@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSD: Don't give out read delegations on exclusive
 creates
Message-ID: <20130521202630.GB13725@fieldses.org>
References: <1368643909-8059-1-git-send-email-steved@redhat.com>
 <20130521192338.GC12114@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130521192338.GC12114@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 21, 2013 at 03:23:38PM -0400, bfields wrote:
> On Wed, May 15, 2013 at 02:51:49PM -0400, Steve Dickson wrote:
> > When an exclusive create is done with the mode bits
> > set (aka open(testfile, O_CREAT | O_EXCL, 0777)) this
> 
> so implicitly O_RDONLY.  Is that common?  Maybe so, OK.
> 
> > causes a OPEN op followed by a SETATTR op. When a
> > read delegation is given in the OPEN, it causes
> > the SETATTR to delay with EAGAIN until the
> > delegation is recalled.
> > 
> > This patch caused exclusive creates to give out
> > a write delegation (which turn into no delegation)
> > which allows the SETATTR seamlessly succeed.
> 
> OK.  May as well make it apply to all creates, though, I think?
> Any create flag seems like a sign the file's likely to be modified soon,
> hence isn't a good candidate for a read delegation.
> 
> I find it a little confusing the way we set this WRITE flag and then
> depend on later code to turn that into no delegation, maybe we should
> fix that.

And some cleanup.

--b.

commit e34bc725ce160cd619cd09420a861426099e860f
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Tue May 21 16:21:25 2013 -0400

    nfsd4: clean up nfs4_open_delegation
    
    The nfs4_open_delegation logic is unecessarily baroque.
    
    Also stop pretending we support write delegations in several places.
    
    Some day we will support write delegations, but when that happens adding
    back in these flag parameters will be the easy part.  For now they're
    just confusing.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 44dcea9..fcc0610 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -364,19 +364,12 @@ static struct nfs4_ol_stateid * nfs4_alloc_stateid(struct nfs4_client *clp)
 }
 
 static struct nfs4_delegation *
-alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct svc_fh *current_fh, u32 type)
+alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct svc_fh *current_fh)
 {
 	struct nfs4_delegation *dp;
 	struct nfs4_file *fp = stp->st_file;
 
 	dprintk("NFSD alloc_init_deleg\n");
-	/*
-	 * Major work on the lease subsystem (for example, to support
-	 * calbacks on stat) will be required before we can support
-	 * write delegations properly.
-	 */
-	if (type != NFS4_OPEN_DELEGATE_READ)
-		return NULL;
 	if (fp->fi_had_conflict)
 		return NULL;
 	if (num_delegations > max_delegations)
@@ -397,7 +390,7 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct sv
 	INIT_LIST_HEAD(&dp->dl_recall_lru);
 	get_nfs4_file(fp);
 	dp->dl_file = fp;
-	dp->dl_type = type;
+	dp->dl_type = NFS4_OPEN_DELEGATE_READ;
 	fh_copy_shallow(&dp->dl_fh, &current_fh->fh_handle);
 	dp->dl_time = 0;
 	atomic_set(&dp->dl_count, 1);
@@ -3020,13 +3013,13 @@ static struct file_lock *nfs4_alloc_init_lease(struct nfs4_delegation *dp, int f
 	return fl;
 }
 
-static int nfs4_setlease(struct nfs4_delegation *dp, int flag)
+static int nfs4_setlease(struct nfs4_delegation *dp)
 {
 	struct nfs4_file *fp = dp->dl_file;
 	struct file_lock *fl;
 	int status;
 
-	fl = nfs4_alloc_init_lease(dp, flag);
+	fl = nfs4_alloc_init_lease(dp, NFS4_OPEN_DELEGATE_READ);
 	if (!fl)
 		return -ENOMEM;
 	fl->fl_file = find_readable_file(fp);
@@ -3044,12 +3037,12 @@ static int nfs4_setlease(struct nfs4_delegation *dp, int flag)
 	return 0;
 }
 
-static int nfs4_set_delegation(struct nfs4_delegation *dp, int flag)
+static int nfs4_set_delegation(struct nfs4_delegation *dp)
 {
 	struct nfs4_file *fp = dp->dl_file;
 
 	if (!fp->fi_lease)
-		return nfs4_setlease(dp, flag);
+		return nfs4_setlease(dp);
 	spin_lock(&recall_lock);
 	if (fp->fi_had_conflict) {
 		spin_unlock(&recall_lock);
@@ -3085,6 +3078,9 @@ static void nfsd4_open_deleg_none_ext(struct nfsd4_open *open, int status)
 
 /*
  * Attempt to hand out a delegation.
+ *
+ * Note we don't support write delegations, and won't until the vfs has
+ * proper support for them.
  */
 static void
 nfs4_open_delegation(struct net *net, struct svc_fh *fh,
@@ -3093,26 +3089,26 @@ nfs4_open_delegation(struct net *net, struct svc_fh *fh,
 	struct nfs4_delegation *dp;
 	struct nfs4_openowner *oo = container_of(stp->st_stateowner, struct nfs4_openowner, oo_owner);
 	int cb_up;
-	int status = 0, flag = 0;
+	int status = 0;
 
 	cb_up = nfsd4_cb_channel_good(oo->oo_owner.so_client);
-	flag = NFS4_OPEN_DELEGATE_NONE;
 	open->op_recall = 0;
 	switch (open->op_claim_type) {
 		case NFS4_OPEN_CLAIM_PREVIOUS:
 			if (!cb_up)
 				open->op_recall = 1;
-			flag = open->op_delegate_type;
-			if (flag == NFS4_OPEN_DELEGATE_NONE)
-				goto out;
+			if (open->op_delegate_type != NFS4_OPEN_DELEGATE_READ)
+				goto out_no_deleg;
 			break;
 		case NFS4_OPEN_CLAIM_NULL:
-			/* Let's not give out any delegations till everyone's
-			 * had the chance to reclaim theirs.... */
+			/*
+			 * Let's not give out any delegations till everyone's
+			 * had the chance to reclaim theirs....
+			 */
 			if (locks_in_grace(net))
-				goto out;
+				goto out_no_deleg;
 			if (!cb_up || !(oo->oo_flags & NFS4_OO_CONFIRMED))
-				goto out;
+				goto out_no_deleg;
 			/*
 			 * Also, if the file was opened for write or
 			 * create, there's a good chance the client's
@@ -3121,20 +3117,17 @@ nfs4_open_delegation(struct net *net, struct svc_fh *fh,
 			 * write delegations):
 			 */
 			if (open->op_share_access & NFS4_SHARE_ACCESS_WRITE)
-				flag = NFS4_OPEN_DELEGATE_WRITE;
-			else if (open->op_create == NFS4_OPEN_CREATE)
-				flag = NFS4_OPEN_DELEGATE_WRITE;
-			else
-				flag = NFS4_OPEN_DELEGATE_READ;
+				goto out_no_deleg;
+			if (open->op_create == NFS4_OPEN_CREATE)
+				goto out_no_deleg;
 			break;
 		default:
-			goto out;
+			goto out_no_deleg;
 	}
-
-	dp = alloc_init_deleg(oo->oo_owner.so_client, stp, fh, flag);
+	dp = alloc_init_deleg(oo->oo_owner.so_client, stp, fh);
 	if (dp == NULL)
 		goto out_no_deleg;
-	status = nfs4_set_delegation(dp, flag);
+	status = nfs4_set_delegation(dp);
 	if (status)
 		goto out_free;
 
@@ -3142,24 +3135,21 @@ nfs4_open_delegation(struct net *net, struct svc_fh *fh,
 
 	dprintk("NFSD: delegation stateid=" STATEID_FMT "\n",
 		STATEID_VAL(&dp->dl_stid.sc_stateid));
-out:
-	open->op_delegate_type = flag;
-	if (flag == NFS4_OPEN_DELEGATE_NONE) {
-		if (open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS &&
-		    open->op_delegate_type != NFS4_OPEN_DELEGATE_NONE)
-			dprintk("NFSD: WARNING: refusing delegation reclaim\n");
-
-		/* 4.1 client asking for a delegation? */
-		if (open->op_deleg_want)
-			nfsd4_open_deleg_none_ext(open, status);
-	}
+	open->op_delegate_type = NFS4_OPEN_DELEGATE_READ;
 	return;
 out_free:
 	unhash_stid(&dp->dl_stid);
 	nfs4_put_delegation(dp);
 out_no_deleg:
-	flag = NFS4_OPEN_DELEGATE_NONE;
-	goto out;
+	open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE;
+	if (open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS &&
+	    open->op_delegate_type != NFS4_OPEN_DELEGATE_NONE)
+		dprintk("NFSD: WARNING: refusing delegation reclaim\n");
+
+	/* 4.1 client asking for a delegation? */
+	if (open->op_deleg_want)
+		nfsd4_open_deleg_none_ext(open, status);
+	return;
 }
 
 static void nfsd4_deleg_xgrade_none_ext(struct nfsd4_open *open,
