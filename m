Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:56624 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751442AbcFNSq4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Jun 2016 14:46:56 -0400
Date: Tue, 14 Jun 2016 14:46:55 -0400
From: "J . Bruce Fields" <bfields@fieldses.org>
To: Oleg Drokin <green@linuxhacker.ru>
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] nfsd: Always lock state exclusively.
Message-ID: <20160614184655.GI25973@fieldses.org>
References: <30E98D26-CB99-4BF8-8697-A2E9BB41920D@linuxhacker.ru>
 <1465781187-824653-1-git-send-email-green@linuxhacker.ru>
 <20160614154659.GE25973@fieldses.org>
 <799A23EB-FA33-4251-A137-028402BDA4C8@linuxhacker.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <799A23EB-FA33-4251-A137-028402BDA4C8@linuxhacker.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 14, 2016 at 11:56:20AM -0400, Oleg Drokin wrote:
> 
> On Jun 14, 2016, at 11:46 AM, J . Bruce Fields wrote:
> 
> > On Sun, Jun 12, 2016 at 09:26:27PM -0400, Oleg Drokin wrote:
> >> It used to be the case that state had an rwlock that was locked for write
> >> by downgrades, but for read for upgrades (opens). Well, the problem is
> >> if there are two competing opens for the same state, they step on
> >> each other toes potentially leading to leaking file descriptors
> >> from the state structure, since access mode is a bitmap only set once.
> >> 
> >> Extend the holding region around in nfsd4_process_open2() to avoid
> >> racing entry into nfs4_get_vfs_file().
> >> Make init_open_stateid() return with locked stateid to be unlocked
> >> by the caller.
> >> 
> >> Now this version held up pretty well in my testing for 24 hours.
> >> It still does not address the situation if during one of the racing
> >> nfs4_get_vfs_file() calls we are getting an error from one (first?)
> >> of them. This is to be addressed in a separate patch after having a
> >> solid reproducer (potentially using some fault injection).
> >> 
> >> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
> >> ---
> >> fs/nfsd/nfs4state.c | 47 +++++++++++++++++++++++++++--------------------
> >> fs/nfsd/state.h     |  2 +-
> >> 2 files changed, 28 insertions(+), 21 deletions(-)
> >> 
> >> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> >> index f5f82e1..fa5fb5a 100644
> >> --- a/fs/nfsd/nfs4state.c
> >> +++ b/fs/nfsd/nfs4state.c
> >> @@ -3487,6 +3487,10 @@ init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
> >> 	struct nfs4_openowner *oo = open->op_openowner;
> >> 	struct nfs4_ol_stateid *retstp = NULL;
> >> 
> >> +	/* We are moving these outside of the spinlocks to avoid the warnings */
> >> +	mutex_init(&stp->st_mutex);
> >> +	mutex_lock(&stp->st_mutex);
> > 
> > A mutex_init_locked() primitive might also be convenient here.
> 
> I know! I would be able to do it under spinlock then without moving this around too.
> 
> But alas, not only there is not one, mutex documentation states this is disallowed.

You're just talking about this comment?:

	 * It is not allowed to initialize an already locked mutex.

That's a weird comment.  You're proably right that what they meant was
something like "It is not allowed to initialize a mutex to locked
state".  But, I don't know, taken literally that comment doesn't make
sense (how could you even distinguish between an already-locked mutex
and an uninitialized mutex?), so maybe it'd be worth asking.

> > You could also take the two previous lines from the caller into this
> > function instead of passing in stp, that might simplify the code.
> > (Haven't checked.)
> 
> I am not really sure what do you mean here.
> These lines are moved from further away in this function )well, just the init, anyway).
> 
> Having half initialisation of stp here and half in the caller sounds kind of strange
> to me.

I was thinking of something like the following--so init_open_stateid
hides more of the details of the swapping.  Untested.  Does it look like
an improvement to you?

There's got to be a way to make this code a little less convoluted....

--b.

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index fa5fb5aa4847..41b59854c40f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3480,13 +3480,15 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfsd4_open *open,
 }
 
 static struct nfs4_ol_stateid *
-init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
-		struct nfsd4_open *open)
+init_open_stateid(struct nfs4_file *fp, struct nfsd4_open *open)
 {
 
 	struct nfs4_openowner *oo = open->op_openowner;
 	struct nfs4_ol_stateid *retstp = NULL;
+	struct nfs4_ol_stateid *stp;
 
+	stp = open->op_stp;
+	open->op_stp = NULL;
 	/* We are moving these outside of the spinlocks to avoid the warnings */
 	mutex_init(&stp->st_mutex);
 	mutex_lock(&stp->st_mutex);
@@ -3512,9 +3514,12 @@ init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
 out_unlock:
 	spin_unlock(&fp->fi_lock);
 	spin_unlock(&oo->oo_owner.so_client->cl_lock);
-	if (retstp)
-		mutex_lock(&retstp->st_mutex);
-	return retstp;
+	if (retstp) {
+		nfs4_put_stid(&stp->st_stid);
+		stp = retstp;
+		mutex_lock(&stp->st_mutex);
+	}
+	return stp;
 }
 
 /*
@@ -4310,7 +4315,6 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 	struct nfs4_client *cl = open->op_openowner->oo_owner.so_client;
 	struct nfs4_file *fp = NULL;
 	struct nfs4_ol_stateid *stp = NULL;
-	struct nfs4_ol_stateid *swapstp = NULL;
 	struct nfs4_delegation *dp = NULL;
 	__be32 status;
 
@@ -4347,16 +4351,9 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 			goto out;
 		}
 	} else {
-		stp = open->op_stp;
-		open->op_stp = NULL;
-		/*
-		 * init_open_stateid() either returns a locked stateid
-		 * it found, or initializes and locks the new one we passed in
-		 */
-		swapstp = init_open_stateid(stp, fp, open);
-		if (swapstp) {
-			nfs4_put_stid(&stp->st_stid);
-			stp = swapstp;
+		/* stp is returned locked: */
+		stp = init_open_stateid(fp, open);
+		if (stp->st_access_bmap == 0) {
 			status = nfs4_upgrade_open(rqstp, fp, current_fh,
 						stp, open);
 			if (status) {
