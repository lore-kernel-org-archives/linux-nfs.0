Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:47624 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753384AbbJNS70 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Oct 2015 14:59:26 -0400
Date: Wed, 14 Oct 2015 14:59:25 -0400
To: Andrew Elble <aweits@rit.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] nfsd: eliminate sending duplicate delegations
Message-ID: <20151014185925.GA12254@fieldses.org>
References: <1443634565-56140-1-git-send-email-aweits@rit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1443634565-56140-1-git-send-email-aweits@rit.edu>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 30, 2015 at 01:36:05PM -0400, Andrew Elble wrote:
> We've observed the nfsd server in a state where there are
> multiple delegations on the same nfs4_file for the same client.
> The nfs client does attempt to DELEGRETURN these when they are presented to
> it - but apparently under some (unknown) circumstances the client does not
> manage to return all of them. This leads to the eventual
> attempt to CB_RECALL more than one delegation with the same nfs
> filehandle to the same client. The first recall will succeed, but the
> next recall will fail with NFS4ERR_BADHANDLE. This leads to the server
> having delegations on cl_revoked that the client has no way to FREE
> or DELEGRETURN, with resulting inability to recover. The state manager
> on the server will continually assert SEQ4_STATUS_RECALLABLE_STATE_REVOKED,
> and the state manager on the client will be looping unable to satisfy
> the server.
> 
> So, let's not hand out duplicate delegations in the first place.
> 
> RFC 5561:
> 
> 9.1.1:
> "Delegations and layouts, on the other hand, are not associated with a
> specific owner but are associated with the client as a whole
> (identified by a client ID)."
> 
> 10.2:
> "...the stateid for a delegation is associated with a client ID and may be
> used on behalf of all the open-owners for the given client.  A
> delegation is made to the client as a whole and not to any specific
> process or thread of control within it."

So if I understand correctly the only reason we haven't seen this all
the time is that clients normally avoid sending opens once it already
has a delegation, so it's when the Linux client started doing parallel
opens that we started hitting this more often.

Looks good, thanks for this work.

Just some small nits:

> Reported-by: Eric Meddaugh <etmsys@rit.edu>
> Signed-off-by: Andrew Elble <aweits@rit.edu>
> ---
>  fs/nfsd/nfs4state.c | 147 +++++++++++++++++++++++++++++++++++++++++++++-------
>  1 file changed, 127 insertions(+), 20 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 0f1d5691b795..eea5c84101e5 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -765,16 +765,84 @@ void nfs4_unhash_stid(struct nfs4_stid *s)
>  	s->sc_type = 0;
>  }
>  
> -static void
> +static int
> +same_clid(clientid_t *cl1, clientid_t *cl2)
> +{
> +	return (cl1->cl_boot == cl2->cl_boot) && (cl1->cl_id == cl2->cl_id);
> +}
> +
> +/**
> + * nfs4_get_existing_delegation - Discover if this delegation already exists
> + * @clp:     a pointer to the nfs4_client we're granting a delegation to
> + * @fp:      a pointer to the nfs4_file we're granting a delegation on
> + *
> + * Return:
> + *      On success: NULL if the delegation was successfully hashed.
> + *
> + *      On error: an ERR_PTR if there was an existing delegation, but
> + *      it is being recalled - or, a pointer to the existing nfs4_delegation
> + *      if one was previously granted to this nfs4_client for this nfs4_file.
> + *
> + */
> +
> +static struct nfs4_delegation *
> +nfs4_get_existing_delegation(struct nfs4_client *clp, struct nfs4_file *fp)
> +{
> +	struct nfs4_delegation *searchdp = NULL;
> +	struct nfs4_client *searchclp = NULL;
> +
> +	lockdep_assert_held(&state_lock);
> +	lockdep_assert_held(&fp->fi_lock);
> +
> +	list_for_each_entry(searchdp, &fp->fi_delegations, dl_perfile) {
> +		searchclp = searchdp->dl_stid.sc_client;
> +		if (same_clid(&clp->cl_clientid, &searchclp->cl_clientid)) {

We can't have two clients with the same clientid (well, maybe if one of
them's unconfirmed, but then it couldn't hold a delegation).  So let's
just compare client pointers here.

> +			if (searchdp->dl_time == 0) {
> +				atomic_inc(&searchdp->dl_stid.sc_count);
> +				return searchdp;
> +			} else {
> +				return ERR_PTR(-EAGAIN);

I had to trace through the callers pretty carefully to make sure that's
handled right, but, OK, it looks like it is: in the end it'll be caught
by the

	if (IS_ERR(dp))
		goto out_no_deleg;

in nfs4_open_delegation, which is what we want, good.

> +			}
> +		}
> +	}
> +	return NULL;
> +}
> +
> +/**
> + * hash_delegation_locked - Add a delegation to the appropriate lists
> + * @dp:     a pointer to the nfs4_delegation we are adding.
> + * @fp:     a pointer to the nfs4_file we're granting a delegation on
> + *
> + * Return:
> + *      On success: NULL if the delegation was successfully hashed.
> + *
> + *      On error: an ERR_PTR if there was an existing delegation, but
> + *      it is being recalled - or, a pointer to the existing
> + *      nfs4_delegation if one was previously granted to this
> + *      nfs4_client for this nfs4_file.
> + *
> + */
> +
> +static struct nfs4_delegation *
>  hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
>  {
> +	struct nfs4_delegation *searchdp = NULL;
> +	struct nfs4_client *clp = dp->dl_stid.sc_client;
> +
>  	lockdep_assert_held(&state_lock);
>  	lockdep_assert_held(&fp->fi_lock);
>  
> -	atomic_inc(&dp->dl_stid.sc_count);
> -	dp->dl_stid.sc_type = NFS4_DELEG_STID;
> -	list_add(&dp->dl_perfile, &fp->fi_delegations);
> -	list_add(&dp->dl_perclnt, &dp->dl_stid.sc_client->cl_delegations);
> +	searchdp = nfs4_get_existing_delegation(clp, fp);
> +	if (!searchdp) {
> +		++fp->fi_delegees;
> +		atomic_inc(&dp->dl_stid.sc_count);
> +		dp->dl_stid.sc_type = NFS4_DELEG_STID;
> +		list_add(&dp->dl_perfile, &fp->fi_delegations);
> +		list_add(&dp->dl_perclnt, &clp->cl_delegations);
> +	} else {
> +		return searchdp;
> +	}
> +	return NULL;

I'd prefer this like:

	searchdp = nfs4_get_existing_delegation(clp, fp);
	if (searchdp)
		return searchdp;
	++fp->fi_delegees;
	atomic_inc(&dp->dl_stid.sc_count);
	dp->dl_stid.sc_type = NFS4_DELEG_STID;
	list_add(&dp->dl_perfile, &fp->fi_delegations);
	list_add(&dp->dl_perclnt, &clp->cl_delegations);
	return NULL;


>  }
>  
>  static bool
> @@ -1833,12 +1901,6 @@ same_verf(nfs4_verifier *v1, nfs4_verifier *v2)
>  	return 0 == memcmp(v1->data, v2->data, sizeof(v1->data));
>  }
>  
> -static int
> -same_clid(clientid_t *cl1, clientid_t *cl2)
> -{
> -	return (cl1->cl_boot == cl2->cl_boot) && (cl1->cl_id == cl2->cl_id);
> -}
> -
>  static bool groups_equal(struct group_info *g1, struct group_info *g2)
>  {
>  	int i;
> @@ -3945,9 +4007,29 @@ static struct file_lock *nfs4_alloc_init_lease(struct nfs4_file *fp, int flag)
>  	return fl;
>  }
>  
> -static int nfs4_setlease(struct nfs4_delegation *dp)
> +/**
> + * nfs4_setlease - Obtain a delegation by requesting locks from vfs layer
> + * @indp:   a pointer to a pointer to the nfs4_delegation we're adding.
> + *
> + * Return:
> + *      On success: If there already was an existing delegation for
> + *      this client on this file, the allocated delegation we were
> + *      passed is dropped and the pointer is changed and passed back
> + *      to the caller to reflect this. If the delegation is not
> + *      already hashed, there are no changes to the caller's version
> + *      of the delegation.  Return code will be 0 on success.
> + *
> + *      On error: an ERR_PTR will be passed back on indp if there was
> + *      an existing delegation, but it is being recalled. Return code
> + *      will be an nonzero if there is an error in other cases.
> + *
> + */
> +
> +static int nfs4_setlease(struct nfs4_delegation **indp)
>  {
> +	struct nfs4_delegation *dp = *indp;
>  	struct nfs4_file *fp = dp->dl_stid.sc_file;
> +	struct nfs4_delegation *found = NULL;
>  	struct file_lock *fl;
>  	struct file *filp;
>  	int status = 0;
> @@ -3977,34 +4059,55 @@ static int nfs4_setlease(struct nfs4_delegation *dp)
>  	/* Race breaker */
>  	if (fp->fi_deleg_file) {
>  		status = 0;
> -		++fp->fi_delegees;
> -		hash_delegation_locked(dp, fp);
> +		found = hash_delegation_locked(dp, fp);
>  		goto out_unlock;
>  	}
>  	fp->fi_deleg_file = filp;
> -	fp->fi_delegees = 1;
> -	hash_delegation_locked(dp, fp);
> +	fp->fi_delegees = 0;
> +	found = hash_delegation_locked(dp, fp);
>  	spin_unlock(&fp->fi_lock);
>  	spin_unlock(&state_lock);
> +	if (found) {
> +		/* Should never happen, this is a new fi_deleg_file  */
> +		WARN_ON_ONCE(1);
> +		goto out;
> +	}
>  	return 0;
>  out_unlock:
>  	spin_unlock(&fp->fi_lock);
>  	spin_unlock(&state_lock);
> +	if (found) {
> +out:
> +		put_clnt_odstate(dp->dl_clnt_odstate);
> +		nfs4_put_stid(&dp->dl_stid);
> +		*indp = found;
> +	}
>  out_fput:
>  	fput(filp);
>  	return status;
>  }
>  
> +
>  static struct nfs4_delegation *
>  nfs4_set_delegation(struct nfs4_client *clp, struct svc_fh *fh,
>  		    struct nfs4_file *fp, struct nfs4_clnt_odstate *odstate)
>  {
>  	int status;
> -	struct nfs4_delegation *dp;
> +	struct nfs4_delegation *dp = NULL;
> +	struct nfs4_delegation *found = NULL;
>  
>  	if (fp->fi_had_conflict)
>  		return ERR_PTR(-EAGAIN);
>  
> +	spin_lock(&state_lock);
> +	spin_lock(&fp->fi_lock);
> +	dp = nfs4_get_existing_delegation(clp, fp);
> +	spin_unlock(&fp->fi_lock);
> +	spin_unlock(&state_lock);
> +
> +	if (dp)
> +		return dp;
> +
>  	dp = alloc_init_deleg(clp, fh, odstate);
>  	if (!dp)
>  		return ERR_PTR(-ENOMEM);
> @@ -4016,19 +4119,23 @@ nfs4_set_delegation(struct nfs4_client *clp, struct svc_fh *fh,
>  	if (!fp->fi_deleg_file) {
>  		spin_unlock(&fp->fi_lock);
>  		spin_unlock(&state_lock);
> -		status = nfs4_setlease(dp);
> +		status = nfs4_setlease(&dp);
>  		goto out;
>  	}
>  	if (fp->fi_had_conflict) {
>  		status = -EAGAIN;
>  		goto out_unlock;
>  	}
> -	++fp->fi_delegees;
> -	hash_delegation_locked(dp, fp);
> +	found = hash_delegation_locked(dp, fp);
>  	status = 0;
>  out_unlock:
>  	spin_unlock(&fp->fi_lock);
>  	spin_unlock(&state_lock);
> +	if (found) {
> +		put_clnt_odstate(dp->dl_clnt_odstate);
> +		nfs4_put_stid(&dp->dl_stid);

We've got that same cleanup twice here and once in nfs4_set_delegation.
Best would be to do the cleanup just in one place.  If that can't be
arranged, then just make a little helper function and call it in both
places.  See also destroy_delegation, __destroy_client,
nfs4_state_shutdown_net.

--b.

> +		dp = found;
> +	}
>  out:
>  	if (status) {
>  		put_clnt_odstate(dp->dl_clnt_odstate);
> -- 
> 2.4.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
