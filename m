Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35750 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760355Ab3GZVOq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Jul 2013 17:14:46 -0400
Date: Fri, 26 Jul 2013 17:14:42 -0400
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Jeff Layton <jlayton@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 15/16] nfsd4: close open-deleg/unlink/rename race
Message-ID: <20130726211441.GE30651@fieldses.org>
References: <1374094217-31493-1-git-send-email-bfields@redhat.com>
 <1374094217-31493-17-git-send-email-bfields@redhat.com>
 <20130726072326.56113a2c@corrin.poochiereds.net>
 <20130726160433.GA15846@pad.fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130726160433.GA15846@pad.fieldses.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 26, 2013 at 12:04:33PM -0400, J. Bruce Fields wrote:
> On Fri, Jul 26, 2013 at 07:23:26AM -0400, Jeff Layton wrote:
> > On Wed, 17 Jul 2013 16:50:16 -0400
> > "J. Bruce Fields" <bfields@redhat.com> wrote:
> > 
> > > From: "J. Bruce Fields" <bfields@redhat.com>
> > > 
> > > If a file is unlinked or renamed between the time when we do the local
> > > open and the time when we get the delegation, then we will return to the
> > > client indicating that it holds a delegation even though the file no
> > > longer exists under the name it was open under.
> > > 
> > > But a client performing an open-by-name, when it is returned a
> > > delegation, must be able to assume that the file is still linked at the
> > > name it was opened under.
> > > 
> > > So, pass the parent filehandle into the delegation and lease-setting
> > > code, and use it to re-lookup the file after we get the lease.
> > > 
> > > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > > ---
> > >  fs/nfsd/nfs4proc.c  |    2 +-
> > >  fs/nfsd/nfs4state.c |   52 +++++++++++++++++++++++++++++++++++++++++++--------
> > >  fs/nfsd/xdr4.h      |    3 ++-
> > >  3 files changed, 47 insertions(+), 10 deletions(-)
> > > 
> > > diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> > > index 4c0cbeb..f44b29d 100644
> > > --- a/fs/nfsd/nfs4proc.c
> > > +++ b/fs/nfsd/nfs4proc.c
> > > @@ -457,7 +457,7 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> > >  	 * successful, it (1) truncates the file if open->op_truncate was
> > >  	 * set, (2) sets open->op_stateid, (3) sets open->op_delegation.
> > >  	 */
> > > -	status = nfsd4_process_open2(rqstp, resfh, open);
> > > +	status = nfsd4_process_open2(rqstp, resfh, open, &cstate->current_fh);
> > >  	WARN_ON(status && open->op_created);
> > >  out:
> > >  	if (resfh && resfh != &cstate->current_fh) {
> > > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > > index 7c91b6c..193f2bb 100644
> > > --- a/fs/nfsd/nfs4state.c
> > > +++ b/fs/nfsd/nfs4state.c
> > > @@ -3018,7 +3018,28 @@ static struct file_lock *nfs4_alloc_init_lease(struct nfs4_delegation *dp, int f
> > >  	return fl;
> > >  }
> > >  
> > > -static int nfs4_setlease(struct nfs4_delegation *dp)
> > > +static bool nfsd4_name_still_same(struct svc_fh *parent, struct nfsd4_open *open, struct dentry *dentry)
> > > +{
> > > +	struct xdr_netobj *name = &open->op_fname;
> > > +	struct dentry *res;
> > > +	bool ret;
> > > +
> > > +	if (parent->fh_dentry == dentry)
> > > +		/* This was an open by filehandle, we don't care: */
> > > +		return true;
> > > +	if (nfsd_mountpoint(dentry, parent->fh_export))
> > > +		/* We assume those never change */
> > > +		return true;
> > > +	mutex_lock(&parent->fh_dentry->d_inode->i_mutex); /* XXX? */
> > > +	res = lookup_one_len(name->data, parent->fh_dentry, name->len);
> > > +	mutex_unlock(&parent->fh_dentry->d_inode->i_mutex);
> > > +	ret = res == dentry;
> > > +	if (!IS_ERR(res))
> > > +		dput(res);
> > > +	return ret;
> > > +}
> > > +
> > > +static int nfs4_setlease(struct nfs4_delegation *dp, struct nfsd4_open *open, struct svc_fh *parent)
> > >  {
> > >  	struct nfs4_file *fp = dp->dl_file;
> > >  	struct file_lock *fl;
> > > @@ -3031,23 +3052,37 @@ static int nfs4_setlease(struct nfs4_delegation *dp)
> > >  	status = vfs_setlease(fl->fl_file, fl->fl_type, &fl);
> > >  	if (status)
> > >  		goto out_free;
> > > +	if (!nfsd4_name_still_same(parent, open, fl->fl_file->f_dentry))
> > > +		goto out_unlease;
> > > +	spin_lock(&recall_lock);
> > > +	if (fp->fi_had_conflict)
> > > +		/*
> > > +		 * whoops, already broken, but before we got a chance to
> > > +		 * install our delegation; never mind:
> > > +		 */
> > > +		 goto out_unlock;
> > > +	list_add(&dp->dl_perfile, &fp->fi_delegations);
> > > +	spin_unlock(&recall_lock);
> > >  	list_add(&dp->dl_perclnt, &dp->dl_stid.sc_client->cl_delegations);
> > >  	fp->fi_lease = fl;
> > >  	fp->fi_deleg_file = get_file(fl->fl_file);
> > >  	atomic_set(&fp->fi_delegees, 1);
> > > -	list_add(&dp->dl_perfile, &fp->fi_delegations);
> > >  	return 0;
> > > +out_unlock:
> > > +	spin_unlock(&recall_lock);
> > > +out_unlease:
> > > +	vfs_setlease(fl->fl_file, F_UNLCK, &fl);
> > >  out_free:
> > >  	locks_free_lock(fl);
> > >  	return -ENOMEM;
> > 
> > Seems a little odd to return -ENOMEM when fi_had_conflict is true, but
> > from looking over the code I think that eventually becomes something
> > else so it shouldn't affect anything.
> 
> Yeah.  Errors setting a lease are ignored.  But I suppose eventually
> (e.g. as we implement more 4.1 stuff that tells client more about why
> delegations failed) we may want to use that.

Oh, actually we already do enough of that for the difference to be
visible to a 4.1 client (it will get either WND4_CONTENTION or
WND4_RESOURCE).  Doubt it makes much difference, probably no client is
even using this information yet, but I'll queue this up for 3.12.

--b.

commit b1948a641daefe8d128749f3d419ed24d529a8ed
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Jul 26 16:57:20 2013 -0400

    nfsd4: fix setlease error return
    
    This actually makes a difference in the 4.1 case, since we use the
    status to decide what reason to give the client for the delegation
    refusal (see nfsd4_open_deleg_none_ext), and in theory a client might
    choose suboptimal behavior if we give the wrong answer.
    
    Reported-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1cb6211..1852f53 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3028,7 +3028,7 @@ static int nfs4_setlease(struct nfs4_delegation *dp)
 	if (status) {
 		list_del_init(&dp->dl_perclnt);
 		locks_free_lock(fl);
-		return -ENOMEM;
+		return status;
 	}
 	fp->fi_lease = fl;
 	fp->fi_deleg_file = get_file(fl->fl_file);
