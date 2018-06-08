Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44908 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751241AbeFHQdI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 8 Jun 2018 12:33:08 -0400
Date: Fri, 8 Jun 2018 12:33:07 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@kernel.org>
Cc: devel@lists.nfs-ganesha.org, sostapov@redhat.com,
        Supriti.Singh@suse.com,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>
Subject: Re: [RFC PATCH] rados_cluster: add a "design" manpage
Message-ID: <20180608163307.GC12719@fieldses.org>
References: <20180523122140.8373-1-jlayton@kernel.org>
 <20180531213733.GB4654@fieldses.org>
 <fbc5ad16342dc1b4d50041bfa1274fc0197486a9.camel@kernel.org>
 <20180601141725.GB10666@fieldses.org>
 <84dd9dbf7e11818cd4188b01e0834a1f04cd24ae.camel@kernel.org>
 <20180601144655.GD10666@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180601144655.GD10666@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 01, 2018 at 10:46:55AM -0400, J. Bruce Fields wrote:
> I think it would also be easy to extend it on demand.
> 
> So, for example: end the grace period when:
> 
> 	(one lease period has passed *and* we've received no reclaim
> 	request in the last second) *or*
> 	two lease periods have passed
> 
> Maybe think about the exact choice of numbers a little.

Something like this.  (Totally untested.)

I also wonder if 90 seconds is overkill as our default lease time.  What
does anyone else do?  Maybe I'll just half it to 45s at the same time.

--b.

commit 90c471ab0150
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Jun 8 12:28:47 2018 -0400

    nfsd4: extend reclaim period for reclaiming clients
    
    If the client is only renewing state a little sooner than once a lease
    period, then it might not discover the server has restarted till close
    to the end of the grace period, and might run out of time to do the
    actual reclaim.
    
    Extend the grace period by a second each time we notice there are
    clients still trying to reclaim, up to a limit of another whole lease
    period.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 36358d435cb0..426f55005697 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -102,6 +102,7 @@ struct nfsd_net {
 
 	time_t nfsd4_lease;
 	time_t nfsd4_grace;
+	bool somebody_reclaimed;
 
 	bool nfsd_net_up;
 	bool lockd_up;
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 5d99e8810b85..1929f85b8269 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -354,6 +354,7 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct svc_fh *resfh = NULL;
 	struct net *net = SVC_NET(rqstp);
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+	bool reclaim = false;
 
 	dprintk("NFSD: nfsd4_open filename %.*s op_openowner %p\n",
 		(int)open->op_fname.len, open->op_fname.data,
@@ -424,6 +425,7 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			if (status)
 				goto out;
 			open->op_openowner->oo_flags |= NFS4_OO_CONFIRMED;
+			reclaim = true;
 		case NFS4_OPEN_CLAIM_FH:
 		case NFS4_OPEN_CLAIM_DELEG_CUR_FH:
 			status = do_open_fhandle(rqstp, cstate, open);
@@ -452,6 +454,8 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	WARN(status && open->op_created,
 	     "nfsd4_process_open2 failed to open newly-created file! status=%u\n",
 	     be32_to_cpu(status));
+	if (reclaim && !status)
+		nn->somebody_reclaimed = true;
 out:
 	if (resfh && resfh != &cstate->current_fh) {
 		fh_dup2(&cstate->current_fh, resfh);
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 59ae65d3eec3..ffe816fe6e89 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4689,6 +4689,28 @@ nfsd4_end_grace(struct nfsd_net *nn)
 	 */
 }
 
+/*
+ * If we've waited a lease period but there are still clients trying to
+ * reclaim, wait a little longer to give them a chance to finish.
+ */
+static bool clients_still_reclaiming(struct nfsd_net *nn)
+{
+	unsigned long now = get_seconds();
+	unsigned long double_grace_period_end = nn->boot_time +
+						2 * nn->nfsd4_lease;
+
+	if (!nn->somebody_reclaimed)
+		return false;
+	nn->somebody_reclaimed = false;
+	/*
+	 * If we've given them *two* lease times to reclaim, and they're
+	 * still not done, give up:
+	 */
+	if (time_after(now, double_grace_period_end))
+		return false;
+	return true;
+}
+
 static time_t
 nfs4_laundromat(struct nfsd_net *nn)
 {
@@ -4702,6 +4724,11 @@ nfs4_laundromat(struct nfsd_net *nn)
 	time_t t, new_timeo = nn->nfsd4_lease;
 
 	dprintk("NFSD: laundromat service - starting\n");
+
+	if (clients_still_reclaiming(nn)) {
+		new_timeo = 0;
+		goto out;
+	}
 	nfsd4_end_grace(nn);
 	INIT_LIST_HEAD(&reaplist);
 	spin_lock(&nn->client_lock);
@@ -4799,7 +4826,7 @@ nfs4_laundromat(struct nfsd_net *nn)
 		posix_unblock_lock(&nbl->nbl_lock);
 		free_blocked_lock(nbl);
 	}
-
+out:
 	new_timeo = max_t(time_t, new_timeo, NFSD_LAUNDROMAT_MINTIMEOUT);
 	return new_timeo;
 }
@@ -6049,6 +6076,8 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	case 0: /* success! */
 		nfs4_inc_and_copy_stateid(&lock->lk_resp_stateid, &lock_stp->st_stid);
 		status = 0;
+		if (lock->lk_reclaim)
+			nn->somebody_reclaimed = true;
 		break;
 	case FILE_LOCK_DEFERRED:
 		nbl = NULL;
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index d107b4426f7e..5f22476cf371 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1239,6 +1239,7 @@ static __net_init int nfsd_init_net(struct net *net)
 		goto out_idmap_error;
 	nn->nfsd4_lease = 90;	/* default lease time */
 	nn->nfsd4_grace = 90;
+	nn->somebody_reclaimed = false;
 	nn->clverifier_counter = prandom_u32();
 	nn->clientid_counter = prandom_u32();
 
