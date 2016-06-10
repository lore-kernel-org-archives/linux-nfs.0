Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:33657 "EHLO
	mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932084AbcFJKui (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2016 06:50:38 -0400
Received: by mail-yw0-f193.google.com with SMTP id y6so8033541ywe.0
        for <linux-nfs@vger.kernel.org>; Fri, 10 Jun 2016 03:50:37 -0700 (PDT)
Message-ID: <1465555833.1425.15.camel@poochiereds.net>
Subject: Re: [PATCH] nfsd: Close a race between access checking/setting in
 nfs4_get_vfs_file
From: Jeff Layton <jlayton@poochiereds.net>
To: Oleg Drokin <green@linuxhacker.ru>,
        "J . Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Andrew W Elble <aweits@rit.edu>
Date: Fri, 10 Jun 2016 06:50:33 -0400
In-Reply-To: <D672EBB0-E73C-4BA6-BB2C-F687CA780CBA@linuxhacker.ru>
References: <1465406560.30890.10.camel@poochiereds.net>
	 <1465506099-475103-1-git-send-email-green@linuxhacker.ru>
	 <D672EBB0-E73C-4BA6-BB2C-F687CA780CBA@linuxhacker.ru>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2016-06-10 at 00:18 -0400, Oleg Drokin wrote:
> On Jun 9, 2016, at 5:01 PM, Oleg Drokin wrote:
> 
> > Currently there's an unprotected access mode check in
> > nfs4_upgrade_open
> > that then calls nfs4_get_vfs_file which in turn assumes whatever
> > access mode was present in the state is still valid which is racy.
> > Two nfs4_get_vfs_file van enter the same path as result and get two
> > references to nfs4_file, but later drop would only happens once
> > because
> > access mode is only denoted by bits, so no refcounting.
> > 
> > The locking around access mode testing is introduced to avoid this
> > race.
> > 
> > Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
> > ---
> > 
> > This patch performs equally well to the st_rwsem -> mutex
> > conversion,
> > but is a bit ligher-weight I imagine.
> > For one it seems to allow truncates in parallel if we ever want it.
> > 
> > fs/nfsd/nfs4state.c | 28 +++++++++++++++++++++++++---
> > 1 file changed, 25 insertions(+), 3 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index f5f82e1..d4b9eba 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -3958,6 +3958,11 @@ static __be32 nfs4_get_vfs_file(struct
> > svc_rqst *rqstp, struct nfs4_file *fp,
> > 
> > 	spin_lock(&fp->fi_lock);
> > 
> > +	if (test_access(open->op_share_access, stp)) {
> > +		spin_unlock(&fp->fi_lock);
> > +		return nfserr_eagain;
> > +	}
> > +
> > 	/*
> > 	 * Are we trying to set a deny mode that would conflict with
> > 	 * current access?
> > @@ -4017,11 +4022,21 @@ nfs4_upgrade_open(struct svc_rqst *rqstp,
> > struct nfs4_file *fp, struct svc_fh *c
> > 	__be32 status;
> > 	unsigned char old_deny_bmap = stp->st_deny_bmap;
> > 
> > -	if (!test_access(open->op_share_access, stp))
> > -		return nfs4_get_vfs_file(rqstp, fp, cur_fh, stp,
> > open);
> > +again:
> > +	spin_lock(&fp->fi_lock);
> > +	if (!test_access(open->op_share_access, stp)) {
> > +		spin_unlock(&fp->fi_lock);
> > +		status = nfs4_get_vfs_file(rqstp, fp, cur_fh, stp,
> > open);
> > +		/*
> > +		 * Somebody won the race for access while we did
> > not hold
> > +		 * the lock here
> > +		 */
> > +		if (status == nfserr_eagain)
> > +			goto again;
> > +		return status;
> > +	}
> > 
> > 	/* test and set deny mode */
> > -	spin_lock(&fp->fi_lock);
> > 	status = nfs4_file_check_deny(fp, open->op_share_deny);
> > 	if (status == nfs_ok) {
> > 		set_deny(open->op_share_deny, stp);
> > @@ -4361,6 +4376,13 @@ nfsd4_process_open2(struct svc_rqst *rqstp,
> > struct svc_fh *current_fh, struct nf
> > 		status = nfs4_get_vfs_file(rqstp, fp, current_fh, stp,
> > open);
> > 		if (status) {
> > 			up_read(&stp->st_rwsem);
> > +			/*
> > +			 * EAGAIN is returned when there's a
> > racing access,
> > +			 * this should never happen as we are the
> > only user
> > +			 * of this new state, and since it's not
> > yet hashed,
> > +			 * nobody can find it
> > +			 */
> > +			WARN_ON(status == nfserr_eagain);
> 
> Ok, some more testing shows that this CAN happen.
> So this patch is inferior to the mutex one after all.
> 

Yeah, that can happen for all sorts of reasons. As Andrew pointed out,
you can get this when there is a lease break in progress, and that may
be occurring for a completely different stateid (or because of samba,
etc...)

It may be possible to do something like this, but we'd need to audit
all of the handling of st_access_bmap (and the deny bmap) to ensure
that we get it right.

For now, I think just turning that rwsem into a mutex is the best
solution. That is a per-stateid mutex so any contention is going to be
due to the client sending racing OPEN calls for the same inode anyway.
Allowing those to run in parallel again could be useful in some cases,
but most use-cases won't be harmed by that serialization.

> > 			release_open_stateid(stp);
> > 			goto out;
> > 		}
> > -- 
> > 2.7.4
> 
-- 
Jeff Layton <jlayton@poochiereds.net>
