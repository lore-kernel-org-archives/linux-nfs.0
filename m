Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57983 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755106Ab0IGWEi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Sep 2010 18:04:38 -0400
Subject: Re: [PATCH 2/2] We should clear NFS_DELEGATED_STATE after return
 delegation
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Bian Naimeng <biannm@cn.fujitsu.com>
Cc: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
In-Reply-To: <4C7DF56B.3040206@cn.fujitsu.com>
References: <4C592F85.8070308@cn.fujitsu.com>
	 <4C59306A.9090302@cn.fujitsu.com>
	 <1280925913.3011.23.camel@heimdal.trondhjem.org>
	 <4C5A213F.9000506@cn.fujitsu.com>
	 <1281013423.2948.1.camel@heimdal.trondhjem.org>
	 <4C5B8B48.4050008@cn.fujitsu.com>
	 <1281101448.3586.11.camel@heimdal.trondhjem.org>
	 <4C68EDAE.5000201@cn.fujitsu.com>
	 <1282087012.18385.30.camel@heimdal.trondhjem.org>
	 <4C7DF56B.3040206@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 07 Sep 2010 18:04:28 -0400
Message-ID: <1283897068.9097.15.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-09-01 at 14:40 +0800, Bian Naimeng wrote:
> > On Mon, 2010-08-16 at 15:50 +0800, Bian Naimeng wrote:
> >>>>>>>> We should clear NFS_DELEGATED_STATE bit for inode->open_states after return delegation.
> 
> ... snip ...
> 
> >>    A open state can be found at nfsi->open_states and owner->so_states always, but
> >>   it not be found at nfsi->open_files until we call nfs4_intent_set_file.
> >>
> >>    At _nfs4_do_open, we will invoke nfs4_return_incompatible_delegation to return a 
> >>   delegation,  a open stateid which set NFS_DELEGATED_STATE bit may not be found at
> >>   nfsi->open_files, but it still at nfsi->open_states, so we do not clear 
> >>   NFS_DELEGATED_STATE bit for it.
> >>
> >>    Then _nfs4_do_open will find it by nfs4_get_open_state, and we still use it
> >>   as a delegation, some error will occur.
> >>
> > 
> > OK. I see agree that is a race, but AFAICS, your fix means that we end
> > up with an nfs_state structure that has cleared NFS_DELEGATED_STATE, but
> > that did not recover its open stateid.
> > 
> 
> Hi trond, what do you think about this one?

Hi Bian,

See comments/questions below.

> Best Regards
>  Bian
> 
> -------------------------------------------------------------------------
> If there are not any delegation at this inode, we should clear stateid's
> NFS_DELEGATED_STATE when update it.
> 
> Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>
> 
> ---
>  fs/nfs/delegation.c |    1 +
>  fs/nfs/nfs4proc.c   |   12 +++++++++++-
>  2 files changed, 12 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
> index 83bb16f..3a7a19d 100644
> --- a/fs/nfs/delegation.c
> +++ b/fs/nfs/delegation.c
> @@ -109,6 +109,7 @@ again:
>  			continue;
>  		if (memcmp(state->stateid.data, stateid->data, sizeof(state->stateid.data)) != 0)
>  			continue;
> +		clear_bit(NFS_DELEGATED_STATE, &state->flags);
>  		get_nfs_open_context(ctx);
>  		spin_unlock(&inode->i_lock);
>  		err = nfs4_open_delegation_recall(ctx, state, stateid);
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 36400d3..c0c0320 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -900,8 +900,18 @@ static int update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_stat
>  
>  	rcu_read_lock();
>  	deleg_cur = rcu_dereference(nfsi->delegation);
> -	if (deleg_cur == NULL)
> +	if (deleg_cur == NULL) {
> +		if (delegation == NULL &&
> +		    test_bit(NFS_DELEGATED_STATE, &state->flags)) {

Any reason why we can't ditch the 'test_bit'?

> +			/*FIXME: If the state has NFS_DELEGATED_STATE bit, 
> +			 * we catch a race. Maybe should recover its open
> +			 * stateid, here we just clear the NFS_DELEGATED_STATE
> +			 * bit.

Can this ever be called with both deleg_cur==NULL and
open_stateid==NULL? If so, then we still have a bug.

> +			 */
> +			clear_bit(NFS_DELEGATED_STATE, &state->flags);
> +		}
>  		goto no_delegation;
> +	}
>  
>  	spin_lock(&deleg_cur->lock);
>  	if (nfsi->delegation != deleg_cur ||

Cheers
  Trond
