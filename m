Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:27182 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758571Ab3GZLWx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Jul 2013 07:22:53 -0400
Date: Fri, 26 Jul 2013 07:23:26 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 15/16] nfsd4: close open-deleg/unlink/rename race
Message-ID: <20130726072326.56113a2c@corrin.poochiereds.net>
In-Reply-To: <1374094217-31493-17-git-send-email-bfields@redhat.com>
References: <1374094217-31493-1-git-send-email-bfields@redhat.com>
	<1374094217-31493-17-git-send-email-bfields@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 17 Jul 2013 16:50:16 -0400
"J. Bruce Fields" <bfields@redhat.com> wrote:

> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> If a file is unlinked or renamed between the time when we do the local
> open and the time when we get the delegation, then we will return to the
> client indicating that it holds a delegation even though the file no
> longer exists under the name it was open under.
> 
> But a client performing an open-by-name, when it is returned a
> delegation, must be able to assume that the file is still linked at the
> name it was opened under.
> 
> So, pass the parent filehandle into the delegation and lease-setting
> code, and use it to re-lookup the file after we get the lease.
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/nfsd/nfs4proc.c  |    2 +-
>  fs/nfsd/nfs4state.c |   52 +++++++++++++++++++++++++++++++++++++++++++--------
>  fs/nfsd/xdr4.h      |    3 ++-
>  3 files changed, 47 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 4c0cbeb..f44b29d 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -457,7 +457,7 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	 * successful, it (1) truncates the file if open->op_truncate was
>  	 * set, (2) sets open->op_stateid, (3) sets open->op_delegation.
>  	 */
> -	status = nfsd4_process_open2(rqstp, resfh, open);
> +	status = nfsd4_process_open2(rqstp, resfh, open, &cstate->current_fh);
>  	WARN_ON(status && open->op_created);
>  out:
>  	if (resfh && resfh != &cstate->current_fh) {
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 7c91b6c..193f2bb 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -3018,7 +3018,28 @@ static struct file_lock *nfs4_alloc_init_lease(struct nfs4_delegation *dp, int f
>  	return fl;
>  }
>  
> -static int nfs4_setlease(struct nfs4_delegation *dp)
> +static bool nfsd4_name_still_same(struct svc_fh *parent, struct nfsd4_open *open, struct dentry *dentry)
> +{
> +	struct xdr_netobj *name = &open->op_fname;
> +	struct dentry *res;
> +	bool ret;
> +
> +	if (parent->fh_dentry == dentry)
> +		/* This was an open by filehandle, we don't care: */
> +		return true;
> +	if (nfsd_mountpoint(dentry, parent->fh_export))
> +		/* We assume those never change */
> +		return true;
> +	mutex_lock(&parent->fh_dentry->d_inode->i_mutex); /* XXX? */
> +	res = lookup_one_len(name->data, parent->fh_dentry, name->len);
> +	mutex_unlock(&parent->fh_dentry->d_inode->i_mutex);
> +	ret = res == dentry;
> +	if (!IS_ERR(res))
> +		dput(res);
> +	return ret;
> +}
> +
> +static int nfs4_setlease(struct nfs4_delegation *dp, struct nfsd4_open *open, struct svc_fh *parent)
>  {
>  	struct nfs4_file *fp = dp->dl_file;
>  	struct file_lock *fl;
> @@ -3031,23 +3052,37 @@ static int nfs4_setlease(struct nfs4_delegation *dp)
>  	status = vfs_setlease(fl->fl_file, fl->fl_type, &fl);
>  	if (status)
>  		goto out_free;
> +	if (!nfsd4_name_still_same(parent, open, fl->fl_file->f_dentry))
> +		goto out_unlease;
> +	spin_lock(&recall_lock);
> +	if (fp->fi_had_conflict)
> +		/*
> +		 * whoops, already broken, but before we got a chance to
> +		 * install our delegation; never mind:
> +		 */
> +		 goto out_unlock;
> +	list_add(&dp->dl_perfile, &fp->fi_delegations);
> +	spin_unlock(&recall_lock);
>  	list_add(&dp->dl_perclnt, &dp->dl_stid.sc_client->cl_delegations);
>  	fp->fi_lease = fl;
>  	fp->fi_deleg_file = get_file(fl->fl_file);
>  	atomic_set(&fp->fi_delegees, 1);
> -	list_add(&dp->dl_perfile, &fp->fi_delegations);
>  	return 0;
> +out_unlock:
> +	spin_unlock(&recall_lock);
> +out_unlease:
> +	vfs_setlease(fl->fl_file, F_UNLCK, &fl);
>  out_free:
>  	locks_free_lock(fl);
>  	return -ENOMEM;

Seems a little odd to return -ENOMEM when fi_had_conflict is true, but
from looking over the code I think that eventually becomes something
else so it shouldn't affect anything.

>  }
>  
> -static int nfs4_set_delegation(struct nfs4_delegation *dp)
> +static int nfs4_set_delegation(struct nfs4_delegation *dp, struct nfsd4_open *open, struct svc_fh *parent)
>  {
>  	struct nfs4_file *fp = dp->dl_file;
>  
>  	if (!fp->fi_lease)
> -		return nfs4_setlease(dp);
> +		return nfs4_setlease(dp, open, parent);
>  	spin_lock(&recall_lock);
>  	if (fp->fi_had_conflict) {
>  		spin_unlock(&recall_lock);
> @@ -3089,7 +3124,8 @@ static void nfsd4_open_deleg_none_ext(struct nfsd4_open *open, int status)
>   */
>  static void
>  nfs4_open_delegation(struct net *net, struct svc_fh *fh,
> -		     struct nfsd4_open *open, struct nfs4_ol_stateid *stp)
> +		     struct nfsd4_open *open, struct nfs4_ol_stateid *stp,
> +		     struct svc_fh *parent)
>  {
>  	struct nfs4_delegation *dp;
>  	struct nfs4_openowner *oo = container_of(stp->st_stateowner, struct nfs4_openowner, oo_owner);
> @@ -3132,7 +3168,7 @@ nfs4_open_delegation(struct net *net, struct svc_fh *fh,
>  	dp = alloc_init_deleg(oo->oo_owner.so_client, stp, fh);
>  	if (dp == NULL)
>  		goto out_no_deleg;
> -	status = nfs4_set_delegation(dp);
> +	status = nfs4_set_delegation(dp, open, parent);
>  	if (status)
>  		goto out_free;
>  
> @@ -3181,7 +3217,7 @@ static void nfsd4_deleg_xgrade_none_ext(struct nfsd4_open *open,
>   * called with nfs4_lock_state() held.
>   */
>  __be32
> -nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open *open)
> +nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open *open, struct svc_fh *parent)
>  {
>  	struct nfsd4_compoundres *resp = rqstp->rq_resp;
>  	struct nfs4_client *cl = open->op_openowner->oo_owner.so_client;
> @@ -3250,7 +3286,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
>  	* Attempt to hand out a delegation. No error return, because the
>  	* OPEN succeeds even if we fail.
>  	*/
> -	nfs4_open_delegation(SVC_NET(rqstp), current_fh, open, stp);
> +	nfs4_open_delegation(SVC_NET(rqstp), current_fh, open, stp, parent);
>  nodeleg:
>  	status = nfs_ok;
>  
> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> index b3ed644..3058885 100644
> --- a/fs/nfsd/xdr4.h
> +++ b/fs/nfsd/xdr4.h
> @@ -596,7 +596,8 @@ __be32 nfsd4_reclaim_complete(struct svc_rqst *, struct nfsd4_compound_state *,
>  extern __be32 nfsd4_process_open1(struct nfsd4_compound_state *,
>  		struct nfsd4_open *open, struct nfsd_net *nn);
>  extern __be32 nfsd4_process_open2(struct svc_rqst *rqstp,
> -		struct svc_fh *current_fh, struct nfsd4_open *open);
> +		struct svc_fh *current_fh, struct nfsd4_open *open,
> +		struct svc_fh *parent);
>  extern void nfsd4_cleanup_open_state(struct nfsd4_open *open, __be32 status);
>  extern __be32 nfsd4_open_confirm(struct svc_rqst *rqstp,
>  		struct nfsd4_compound_state *, struct nfsd4_open_confirm *oc);


Acked-by: Jeff Layton <jlayton@redhat.com>
