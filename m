Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60862 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756529AbbKEVVK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Nov 2015 16:21:10 -0500
Date: Thu, 5 Nov 2015 16:21:08 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andrew Elble <aweits@rit.edu>
Cc: linux-nfs@vger.kernel.org, jlayton@poochiereds.net
Subject: Re: [PATCH RFCv2] nfsd: fix race with open / open upgrade stateids
Message-ID: <20151105212108.GH9210@fieldses.org>
References: <1446657225-72903-1-git-send-email-aweits@rit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1446657225-72903-1-git-send-email-aweits@rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 04, 2015 at 12:13:45PM -0500, Andrew Elble wrote:
> We observed multiple open stateids on the server for files that
> seemingly should have been closed.

Thanks for tracking this down!

Is there some lock imbalance?:

[  100.705999] ------------[ cut here ]------------
[  100.706302] WARNING: CPU: 1 PID: 4351 at kernel/locking/lockdep.c:3382 lock_release+0x2e2/0x480()
[  100.706837] DEBUG_LOCKS_WARN_ON(depth <= 0)
[  100.707067] Modules linked in:
[  100.707299]  rpcsec_gss_krb5 nfsd auth_rpcgss oid_registry nfs_acl lockd grace sunrpc
[  100.708006] CPU: 1 PID: 4351 Comm: nfsd Not tainted
4.3.0-rc3-00040-ge09b8af #369
[  100.708006] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140709_153950- 04/01/2014
[  100.708006]  ffffffff81f0b535 ffff8800541e7b08 ffffffff8160524c ffff8800541e7b50
[  100.708006]  ffff8800541e7b40 ffffffff81077692 ffff8800541e1180 ffff880067c0bfd0
[  100.708006]  ffff880071ec7e98 ffff880067c0beb8 ffff88006b9bb240 ffff8800541e7ba0
[  100.708006] Call Trace:
[  100.708006]  [<ffffffff8160524c>] dump_stack+0x4e/0x82
[  100.708006]  [<ffffffff81077692>] warn_slowpath_common+0x82/0xc0
[  100.708006]  [<ffffffff8107771c>] warn_slowpath_fmt+0x4c/0x50
[  100.708006]  [<ffffffff810c7a42>] lock_release+0x2e2/0x480
[  100.708006]  [<ffffffffa00da8cb>] ?  nfs4_inc_and_copy_stateid+0x4b/0x60 [nfsd]
[  100.708006]  [<ffffffffa00de0e6>] ? nfsd4_process_open2+0x1c6/0x1200 [nfsd]
[  100.708006]  [<ffffffff810c081f>] up_read+0x1f/0x40
[  100.708006]  [<ffffffffa00de0e6>] nfsd4_process_open2+0x1c6/0x1200 [nfsd]
[  100.708006]  [<ffffffffa00ddf25>] ? nfsd4_process_open2+0x5/0x1200 [nfsd]
[  100.708006]  [<ffffffffa00ca472>] nfsd4_open+0x7e2/0x920 [nfsd]
[  100.708006]  [<ffffffffa00ca93a>] nfsd4_proc_compound+0x38a/0x660 [nfsd]
[  100.708006]  [<ffffffffa00b4608>] nfsd_dispatch+0xb8/0x200 [nfsd]
[  100.708006]  [<ffffffffa00151ff>] svc_process_common+0x40f/0x620 [sunrpc]
[  100.708006]  [<ffffffffa0015557>] svc_process+0x147/0x320 [sunrpc]
[  100.708006]  [<ffffffffa00b3b71>] nfsd+0x181/0x280 [nfsd]
[  100.708006]  [<ffffffffa00b39f5>] ? nfsd+0x5/0x280 [nfsd]
[  100.708006]  [<ffffffffa00b39f0>] ? nfsd_destroy+0x190/0x190 [nfsd]
[  100.708006]  [<ffffffff81098d6f>] kthread+0xef/0x110
[  100.708006]  [<ffffffff81a7661c>] ? _raw_spin_unlock_irq+0x2c/0x50
[  100.708006]  [<ffffffff81098c80>] ?  kthread_create_on_node+0x200/0x200
[  100.708006]  [<ffffffff81a772cf>] ret_from_fork+0x3f/0x70
[  100.708006]  [<ffffffff81098c80>] ?  kthread_create_on_node+0x200/0x200
[  100.708006] ---[ end trace 878c608a8de36bf5 ]---

Also, some nits:

> 
> nfsd4_process_open2() tests for the existence of a preexisting
> stateid. If one is not found, the locks are dropped and a new
> one is created. The problem is that init_open_stateid(), which
> is also responsible for hashing the newly initialized stateid,
> doesn't check to see if another open has raced in and created
> a matching stateid. This fix is to enable init_open_stateid() to
> return the matching stateid and have nfsd4_process_open2()
> swap to that stateid and switch to the open upgrade path.
> In testing this patch, coverage to the newly created
> path indicates that the race was indeed happening.
> 
> Signed-off-by: Andrew Elble <aweits@rit.edu>
> ---
>  fs/nfsd/nfs4state.c | 109 +++++++++++++++++++++++++++++++++++++++-------------
>  1 file changed, 83 insertions(+), 26 deletions(-)

When you send a v2 patch, would you mind also describing what's changed?
If you stick the description here (between the --- and the diff), it'll
be discarded when git applies the patch (which is what we want).

> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index e3a10df44896..66df2903ab8e 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -3345,6 +3345,40 @@ static const struct nfs4_stateowner_operations openowner_ops = {
>  	.so_free =	nfs4_free_openowner,
>  };
>  

I appreciate comments in general, but:

> +/**
> + * nfsd4_find_existing_open - Find an existing open stateid for this openowner

That description pretty much just restates the name of the function.

> + * @fp:     a pointer to an nfs4_file
> + * @open:   a pointer to an nfsd4_open

There's nothing in those two lines that isn't already in the prototype.

> + *
> + * Return:
> + *      On success: a pointer to the nfs4_ol_stateid that was found
> + *                  matching this nfs4_file and openowner.
> + *
> + *      On error: NULL if an existing stateid was not found

And maybe this is a little helpful, though really I think it doesn't add
a lot to the code below.

Is there's some particular point that you thought was confusing here?
Then I'm fine with highlighting that.  But I don't want to routinely add
these block comments on every little function.

> + *
> + */
> +
> +static struct nfs4_ol_stateid *
> +nfsd4_find_existing_open(struct nfs4_file *fp, struct nfsd4_open *open)
> +{
> +	struct nfs4_ol_stateid *local, *ret = NULL;
> +	struct nfs4_openowner *oo = open->op_openowner;
> +
> +	lockdep_assert_held(&fp->fi_lock);
> +
> +	list_for_each_entry(local, &fp->fi_stateids, st_perfile) {
> +		/* ignore lock owners */
> +		if (local->st_stateowner->so_is_open_owner == 0)
> +			continue;
> +		if (local->st_stateowner == &oo->oo_owner) {
> +			ret = local;
> +			atomic_inc(&ret->st_stid.sc_count);
> +			break;
> +		}
> +	}
> +	return ret;
> +}
> +
>  static struct nfs4_openowner *
>  alloc_init_open_stateowner(unsigned int strhashval, struct nfsd4_open *open,
>  			   struct nfsd4_compound_state *cstate)
> @@ -3376,9 +3410,37 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfsd4_open *open,
>  	return ret;
>  }
>  
> -static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp, struct nfsd4_open *open) {
> +/**
> + * init_open_stateid - initialize a nfs4_ol_stateid structure and hash it
> + * @stp:     a pointer to a freshly allocated nfs4_ol_stateid
> + * @fp:      a pointer to an nfs4_file
> + * @open:    a pointer to an nfsd4_open
> + *
> + * Return:
> + *      On success: NULL if an existing stateid was not found
> + *                  matching this nfs4_file and openowner, and the
> + *                  new nfs4_ol_stateid was hashed.
> + *
> + *      On error: a pointer to the existing stateid that was found
> + *                matching this nfs4_file and openowner. The passed-in
> + *                stateid is not hashed.
> + *
> + */

Similar questions to above.

Code looks OK, though.  (And I don't spot the locking problem on a quick
skim...).

--b.

> +
> +static struct nfs4_ol_stateid *
> +init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
> +		struct nfsd4_open *open)
> +{
> +
>  	struct nfs4_openowner *oo = open->op_openowner;
> +	struct nfs4_ol_stateid *retstp = NULL;
>  
> +	spin_lock(&oo->oo_owner.so_client->cl_lock);
> +	spin_lock(&fp->fi_lock);
> +
> +	retstp = nfsd4_find_existing_open(fp, open);
> +	if (retstp)
> +		goto out_unlock;
>  	atomic_inc(&stp->st_stid.sc_count);
>  	stp->st_stid.sc_type = NFS4_OPEN_STID;
>  	INIT_LIST_HEAD(&stp->st_locks);
> @@ -3389,12 +3451,13 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
>  	stp->st_deny_bmap = 0;
>  	stp->st_openstp = NULL;
>  	init_rwsem(&stp->st_rwsem);
> -	spin_lock(&oo->oo_owner.so_client->cl_lock);
>  	list_add(&stp->st_perstateowner, &oo->oo_owner.so_stateids);
> -	spin_lock(&fp->fi_lock);
>  	list_add(&stp->st_perfile, &fp->fi_stateids);
> +
> +out_unlock:
>  	spin_unlock(&fp->fi_lock);
>  	spin_unlock(&oo->oo_owner.so_client->cl_lock);
> +	return retstp;
>  }
>  
>  /*
> @@ -3805,27 +3868,6 @@ out:
>  	return nfs_ok;
>  }
>  
> -static struct nfs4_ol_stateid *
> -nfsd4_find_existing_open(struct nfs4_file *fp, struct nfsd4_open *open)
> -{
> -	struct nfs4_ol_stateid *local, *ret = NULL;
> -	struct nfs4_openowner *oo = open->op_openowner;
> -
> -	spin_lock(&fp->fi_lock);
> -	list_for_each_entry(local, &fp->fi_stateids, st_perfile) {
> -		/* ignore lock owners */
> -		if (local->st_stateowner->so_is_open_owner == 0)
> -			continue;
> -		if (local->st_stateowner == &oo->oo_owner) {
> -			ret = local;
> -			atomic_inc(&ret->st_stid.sc_count);
> -			break;
> -		}
> -	}
> -	spin_unlock(&fp->fi_lock);
> -	return ret;
> -}
> -
>  static inline int nfs4_access_to_access(u32 nfs4_access)
>  {
>  	int flags = 0;
> @@ -4189,6 +4231,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
>  	struct nfs4_client *cl = open->op_openowner->oo_owner.so_client;
>  	struct nfs4_file *fp = NULL;
>  	struct nfs4_ol_stateid *stp = NULL;
> +	struct nfs4_ol_stateid *swapstp = NULL;
>  	struct nfs4_delegation *dp = NULL;
>  	__be32 status;
>  
> @@ -4202,7 +4245,9 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
>  		status = nfs4_check_deleg(cl, open, &dp);
>  		if (status)
>  			goto out;
> +		spin_lock(&fp->fi_lock);
>  		stp = nfsd4_find_existing_open(fp, open);
> +		spin_unlock(&fp->fi_lock);
>  	} else {
>  		open->op_file = NULL;
>  		status = nfserr_bad_stateid;
> @@ -4225,8 +4270,19 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
>  	} else {
>  		stp = open->op_stp;
>  		open->op_stp = NULL;
> -		init_open_stateid(stp, fp, open);
> -		down_read(&stp->st_rwsem);
> +		swapstp = init_open_stateid(stp, fp, open);
> +		if (swapstp) {
> +			nfs4_put_stid(&stp->st_stid);
> +			stp = swapstp;
> +			down_read(&stp->st_rwsem);
> +			status = nfs4_upgrade_open(rqstp, fp, current_fh,
> +						stp, open);
> +			if (status) {
> +				up_read(&stp->st_rwsem);
> +				goto out;
> +			}
> +			goto upgrade_out;
> +		}
>  		status = nfs4_get_vfs_file(rqstp, fp, current_fh, stp, open);
>  		if (status) {
>  			up_read(&stp->st_rwsem);
> @@ -4239,6 +4295,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
>  		if (stp->st_clnt_odstate == open->op_odstate)
>  			open->op_odstate = NULL;
>  	}
> +upgrade_out:
>  	nfs4_inc_and_copy_stateid(&open->op_stateid, &stp->st_stid);
>  	up_read(&stp->st_rwsem);
>  
> -- 
> 2.4.6
