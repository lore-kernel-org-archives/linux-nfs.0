Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:54144 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751357AbeEKVaG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 11 May 2018 17:30:06 -0400
Date: Fri, 11 May 2018 17:30:05 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andrew Elble <aweits@rit.edu>
Cc: linux-nfs@vger.kernel.org, jlayton@kernel.org
Subject: Re: [PATCH v2] nfsd: fix error handling in nfs4_set_delegation()
Message-ID: <20180511213005.GF3765@fieldses.org>
References: <20180509120249.62022-1-aweits@rit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180509120249.62022-1-aweits@rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 09, 2018 at 08:02:49AM -0400, Andrew Elble wrote:
> I noticed a memory corruption crash in nfsd in
> 4.17-rc1. This patch corrects the issue.
> 
> Fix to return error if the delegation couldn't be hashed or there was
> a recall in progress. Use the existing error path instead of
> destroy_unhashed_delegation() for readability. Set the fields of the
> delegation to indicate that it does not need to be recalled.
> 
> Signed-off-by: Andrew Elble <aweits@rit.edu>
> Fixes: 353601e7d323c ("nfsd: create a separate lease for each delegation")
> ---
> v2: typo in changelog, set delegation recall-suppression
>  fs/nfsd/nfs4state.c | 16 +++++++++++++++-
>  1 file changed, 15 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 71b87738c015..20463944cd61 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -4372,12 +4372,26 @@ static struct file_lock *nfs4_alloc_init_lease(struct nfs4_delegation *dp,
>  		status = -EAGAIN;
>  	else
>  		status = hash_delegation_locked(dp, fp);
> +	/*
> +	 * This delegation is doomed, tell the recall logic
> +	 * that it's being destroyed here.
> +	 */
> +
> +	if (status) {
> +		dp->dl_time++;
> +		list_del_init(&dp->dl_recall_lru);
> +		dp->dl_stid.sc_type = NFS4_CLOSED_DELEG_STID;
> +	}

I'm trying to figure out if this fixes an actual bug.  The code should
be able to deal with a callback on an already unhashed delegation, so I
think you're right it would at worst just be an unnecessary recall.
This won't catch every such case (could be that nfsd4_cb_recall_prepare
already ran and we're too late), so I wonder if this is worth it.

More interesting to me is what exactly it would take to hit this
case....  Another thread would have to have succesfully hashed a
delegation for this client and file to make our hash_delegation_locked
fail.  So there would be two leases for the same file and client, but
with different delegation pointers as the fl_owner.  I *think* we handle
that OK.  But it was likely problematic previously when we were still
using the file pointer as the fl_owner.

--b.

>  	spin_unlock(&fp->fi_lock);
>  	spin_unlock(&state_lock);
>  
>  	if (status)
> -		destroy_unhashed_deleg(dp);
> +		goto out_unlock;
> +
>  	return dp;
> +
> +out_unlock:
> +	vfs_setlease(fp->fi_deleg_file, F_UNLCK, NULL, (void **)&dp);
>  out_clnt_odstate:
>  	put_clnt_odstate(dp->dl_clnt_odstate);
>  out_stid:
> -- 
> 1.8.3.1
