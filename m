Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41874 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751178AbeECVlU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 3 May 2018 17:41:20 -0400
Date: Thu, 3 May 2018 17:41:19 -0400
To: Andrew Elble <aweits@rit.edu>
Cc: linux-nfs@vger.kernel.org, bfields@redhat.com, jlayton@kernel.org
Subject: Re: [PATCH] nfsd: fix error handling in nfs4_set_delegation()
Message-ID: <20180503214119.GC27964@fieldses.org>
References: <20180418210437.97702-1-aweits@rit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180418210437.97702-1-aweits@rit.edu>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 18, 2018 at 05:04:37PM -0400, Andrew Elble wrote:
> I noticed a memory corruption crash in nfsd in
> 4.17-rc1. This patch corrects the issue.
> 
> Fix to return error if the delegation couldn't be hashed or there was
> a recall in progress. Use the existing error path instead of
> destroy_delegation() for readability.

Apologies for the slow response, this looks right, I'm just still trying
to figure out whether this is the only problem here--e.g. does it cause
problems to have this lease temporarily applied before the delegation is
hashed?

Also the RHEL7 code appears to have worse problems in the same spot and
I'm trying to work out if they'd explaining a long-standing bug
report....

--b.

> 
> Signed-off-by: Andrew Elble <aweits@rit.edu>
> Fixes: 353601e7d323c ("nfsd: create a separate lease for each delegation")
> ---
>  fs/nfsd/nfs4state.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 71b87738c015..449d42a0f71b 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -4376,8 +4376,11 @@ static struct file_lock *nfs4_alloc_init_lease(struct nfs4_delegation *dp,
>  	spin_unlock(&state_lock);
>  
>  	if (status)
> -		destroy_unhashed_deleg(dp);
> +		goto out_unlock;
> +
>  	return dp;
> +out_unlock:
> +	vfs_setlease(fp->fi_deleg_file, F_UNLCK, NULL, (void **)&dp);
>  out_clnt_odstate:
>  	put_clnt_odstate(dp->dl_clnt_odstate);
>  out_stid:
> -- 
> 1.8.3.1
