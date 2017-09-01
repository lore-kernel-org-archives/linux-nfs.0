Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44104 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751968AbdIAQSK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 1 Sep 2017 12:18:10 -0400
Date: Fri, 1 Sep 2017 12:18:09 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: NeilBrown <neilb@suse.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 2/3] fs: hide another detail of delegation logic
Message-ID: <20170901161809.GA22140@parsley.fieldses.org>
References: <1503697958-6122-1-git-send-email-bfields@redhat.com>
 <1503697958-6122-3-git-send-email-bfields@redhat.com>
 <878ti4i9pi.fsf@notabene.neil.brown.name>
 <20170829214026.GI8822@parsley.fieldses.org>
 <8760d5hol3.fsf@notabene.neil.brown.name>
 <20170830170938.GC24373@parsley.fieldses.org>
 <87wp5kfxi3.fsf@notabene.neil.brown.name>
 <20170831190531.GA8223@parsley.fieldses.org>
 <873787fhc5.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <873787fhc5.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 01, 2017 at 09:27:54AM +1000, NeilBrown wrote:
> On Thu, Aug 31 2017, J. Bruce Fields wrote:
> > Only nfsd fills in the "who" field of deleg_break_ctl.  But non-nfsd
> > users do need to pass a non-NULL delegated_inode.
> 
> Yes, of course...

Just to be clear, I've taken your suggestion to pass the nfs4_client
instead of the request so we only have to do a comparison in callback.
Among other things that should be a safe approach if we ever have
non-nfs breakers that want to pass a "who".  Patch appended below if
you're curious.

> So having been wrong about this code twice, I'm starting to get a feel
> for what it does and why.  I still wonder if there might be a better
> approach though.
> 
> You are changing the interface to pass a magic cookie with the meaning
> "Don't bother breaking a delegation which matches this magic cookie".
> Would it not be better to pass a delegation, and say "Don't bother
> breaking this delegation".  And if it were a WRITE delegation, that
> could be optimised as "don't bother breaking any delegation, I have a
> write delegation so I have exclusive access".
> 
> Whenever we call a vfs_* function that will need to break delegations we
> have already done the lookup and have the dentry and inode, so finding a
> delegation shouldn't be prohibitive.
> 
> nfsd would need to find that delegation, prevent further delegations
> being handed out, and check that there aren't already conflicting
> delegations.  If there are conflicts, recall them.  Once there are no
> conflicting delegations, make the vfs_ request.

The way that we currently serialize setting, unsetting, and breaking
delegations is by locks on the delegated inodes which aren't taken till
deeper in the vfs code.

I guess you're suggesting adding a second mechanism to prevent
delegations being given out on the inode.  We could add an atomic
counter taken by each nfsd breaker while it's in progress.  Hrm.

--b.

> One downside of this is that nfsd delegations would be recalled before
> any others, rather than doing them all in parallel.  This could be
> addressed by calling try_break_deleg() when recalling the nfsd
> delegations.
> 
> This approach seems to be half-way between your original attempt that
> you described, which is racy, and the attempt you posted which adds the
> callback that I don't particularly like.

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index fb15efcc4e08..b50a7492f47f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3825,7 +3825,7 @@ nfsd_break_deleg_cb(struct file_lock *fl)
 	return ret;
 }
 
-static struct nfs4_client *nfsd4_client_from_rqst(struct svc_rqst *rqst)
+void *nfsd4_client_from_rqst(struct svc_rqst *rqst)
 {
 	struct nfsd4_compoundres *resp;
 
@@ -3843,19 +3843,14 @@ static struct nfs4_client *nfsd4_client_from_rqst(struct svc_rqst *rqst)
 
 static bool nfsd_breaker_owns_lease(void *who, struct file_lock *fl)
 {
-	struct svc_rqst *rqst = who;
 	struct nfs4_client *cl;
 	struct nfs4_delegation *dl;
 	struct nfs4_file *fi = (struct nfs4_file *)fl->fl_owner;
 	bool ret = true;
 
-	cl = nfsd4_client_from_rqst(rqst);
-	if (!cl)
-		return false;
-
 	spin_lock(&fi->fi_lock);
 	list_for_each_entry(dl, &fi->fi_delegations, dl_perfile) {
-		if (dl->dl_stid.sc_client != cl) {
+		if (dl->dl_stid.sc_client != who) {
 			ret = false;
 			break;
 		}
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index b9c538ab7a59..f7819ce6c817 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -125,6 +125,7 @@ void nfs4_reset_lease(time_t leasetime);
 int nfs4_reset_recoverydir(char *recdir);
 char * nfs4_recoverydir(void);
 bool nfsd4_spo_must_allow(struct svc_rqst *rqstp);
+void *nfsd4_client_from_rqst(struct svc_rqst *rqst);
 #else
 static inline int nfsd4_init_slabs(void) { return 0; }
 static inline void nfsd4_free_slabs(void) { }
@@ -139,6 +140,7 @@ static inline bool nfsd4_spo_must_allow(struct svc_rqst *rqstp)
 {
 	return false;
 }
+void *nfsd4_client_from_rqst(struct svc_rqst *rqst) { return NULL; }
 #endif
 
 /*
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index fe62bc744143..fc9b9ad1d444 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -395,8 +395,8 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 	bool		get_write_count;
 	bool		size_change = (iap->ia_valid & ATTR_SIZE);
 	struct deleg_break_ctl deleg_break_ctl = {
-			.delegated_inode = DELEG_NO_WAIT,
-			.who = rqstp
+		.delegated_inode = DELEG_NO_WAIT,
+		.who = nfsd4_client_from_rqst(rqstp),
 	};
 
 	if (iap->ia_valid & (ATTR_ATIME | ATTR_MTIME | ATTR_SIZE))
@@ -1559,7 +1559,7 @@ nfsd_link(struct svc_rqst *rqstp, struct svc_fh *ffhp,
 	int		host_err;
 	struct deleg_break_ctl deleg_break_ctl = {
 		.delegated_inode = DELEG_NO_WAIT,
-		.who = rqstp
+		.who = nfsd4_client_from_rqst(rqstp),
 	};
 
 	err = fh_verify(rqstp, ffhp, S_IFDIR, NFSD_MAY_CREATE);
@@ -1636,7 +1636,7 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
 	int		host_err;
 	struct deleg_break_ctl deleg_break_ctl = {
 		.delegated_inode = DELEG_NO_WAIT,
-		.who = rqstp
+		.who = nfsd4_client_from_rqst(rqstp),
 	};
 
 	err = fh_verify(rqstp, ffhp, S_IFDIR, NFSD_MAY_REMOVE);
@@ -1736,7 +1736,7 @@ nfsd_unlink(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
 	int		host_err;
 	struct deleg_break_ctl deleg_break_ctl = {
 		.delegated_inode = DELEG_NO_WAIT,
-		.who = rqstp
+		.who = nfsd4_client_from_rqst(rqstp),
 	};
 
 	err = nfserr_acces;
