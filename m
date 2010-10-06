Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-phx2.redhat.com ([209.132.183.24]:46279 "EHLO
	mx01.colomx.prod.int.phx2.redhat.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1759221Ab0JFP7q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Oct 2010 11:59:46 -0400
Date: Wed, 6 Oct 2010 11:59:20 -0400 (EDT)
From: Sachin Prabhu <sprabhu@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <26335422.12.1286380757582.JavaMail.sprabhu@dhcp-1-233.fab.redhat.com>
In-Reply-To: <1286285838.3338.1.camel@heimdal.trondhjem.org>
Subject: Re: NFS4 clients cannot reclaim locks
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


----- "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:

> Yup. That makes sense. Does the following patch help?
> 
> Cheers
>   Trond
> --------------------------------------------------------------------------------------------------------
> NFSv4: Fix open recovery
> 
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> NFSv4 open recovery is currently broken: since we do not clear the
> state->flags states before attempting recovery, we end up with the
> 'can_open_cached()' function triggering. This again leads to no OPEN
> call
> being put on the wire.
> 
> Reported-by: Sachin Prabhu <sprabhu@redhat.com>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> 
>  fs/nfs/nfs4proc.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 089da5b..01b4817 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -1120,6 +1120,7 @@ static int nfs4_open_recover(struct
> nfs4_opendata *opendata, struct nfs4_state *
>  	clear_bit(NFS_DELEGATED_STATE, &state->flags);
>  	smp_rmb();
>  	if (state->n_rdwr != 0) {
> +		clear_bit(NFS_O_RDWR_STATE, &state->flags);
>  		ret = nfs4_open_recover_helper(opendata, FMODE_READ|FMODE_WRITE,
> &newstate);
>  		if (ret != 0)
>  			return ret;
> @@ -1127,6 +1128,7 @@ static int nfs4_open_recover(struct
> nfs4_opendata *opendata, struct nfs4_state *
>  			return -ESTALE;
>  	}
>  	if (state->n_wronly != 0) {
> +		clear_bit(NFS_O_WRONLY_STATE, &state->flags);
>  		ret = nfs4_open_recover_helper(opendata, FMODE_WRITE, &newstate);
>  		if (ret != 0)
>  			return ret;
> @@ -1134,6 +1136,7 @@ static int nfs4_open_recover(struct
> nfs4_opendata *opendata, struct nfs4_state *
>  			return -ESTALE;
>  	}
>  	if (state->n_rdonly != 0) {
> +		clear_bit(NFS_O_RDONLY_STATE, &state->flags);
>  		ret = nfs4_open_recover_helper(opendata, FMODE_READ, &newstate);
>  		if (ret != 0)
>  			return ret;
> 


Yes. The patch works. 

As expected, repeated open calls are made with claim-type set to NULL. For each of these calls, a NFS4ERR_GRACE is returned by the server as long as it is in Grace period. Once the grace period has completed, the open call succeeds, a new stateid is set and the write operation continues.

Thank You
Sachin Prabhu
