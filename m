Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53561 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751105Ab3CKPCJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Mar 2013 11:02:09 -0400
Date: Mon, 11 Mar 2013 11:02:08 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: ycnian@gmail.com
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] nfsd: fix bug on nfs4 stateid deallocation
Message-ID: <20130311150208.GB16309@fieldses.org>
References: <1362962774-5141-1-git-send-email-ycnian@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1362962774-5141-1-git-send-email-ycnian@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 11, 2013 at 08:46:14AM +0800, ycnian@gmail.com wrote:
> NFS4_OO_PURGE_CLOSE is not handled properly. To avoid memory leak, nfs4 
> stateid which is pointed by oo_last_closed_stid is freed in nfsd4_close(), 
> but NFS4_OO_PURGE_CLOSE isn't cleared meanwhile. So the stateid released in 
> THIS close procedure may be freed immediately in the coming encoding function.

OK, makes sense.  This code is confusing, I wonder if there's some way
we could make it simpler.

> Sorry that Signed-off-by was forgotten in last version.

Do you have a test that reproduces this bug?

--b.

> 
> Signed-off-by: Yanchuan Nian <ycnian@gmail.com>
> ---
>  fs/nfsd/nfs4state.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index cc41bf4..d972db8 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -3827,6 +3827,7 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  
>  	nfsd4_close_open_stateid(stp);
>  	release_last_closed_stateid(oo);
> +	oo->oo_flags &= ~NFS4_OO_PURGE_CLOSE;
>  	oo->oo_last_closed_stid = stp;
>  
>  	if (list_empty(&oo->oo_owner.so_stateids)) {
> -- 
> 1.7.4.4
> 
