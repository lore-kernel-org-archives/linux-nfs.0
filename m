Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38984 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753103Ab3ACAj7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Jan 2013 19:39:59 -0500
Date: Wed, 2 Jan 2013 19:39:58 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: ycnian@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: Don't unlock the state while it's not locked
Message-ID: <20130103003958.GD26356@fieldses.org>
References: <1356343905-11990-1-git-send-email-ycnian@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1356343905-11990-1-git-send-email-ycnian@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 24, 2012 at 06:11:45PM +0800, ycnian@gmail.com wrote:
> From: Yanchuan Nian <ycnian@gmail.com>
> 
> In the procedure of CREATE_SESSION, the state is locked after
> alloc_conn_from_crses(). If the allocation fails, the function
> goes to "out_free_session", and then "out" where there is an
> unlock function.

Thanks, applying for 3.9.--b.

> 
> Signed-off-by: Yanchuan Nian <ycnian@gmail.com>
> 
> ---
>  fs/nfsd/nfs4state.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 29924a0..cc41bf4 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1844,11 +1844,12 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>  
>  	/* cache solo and embedded create sessions under the state lock */
>  	nfsd4_cache_create_session(cr_ses, cs_slot, status);
> -out:
>  	nfs4_unlock_state();
> +out:
>  	dprintk("%s returns %d\n", __func__, ntohl(status));
>  	return status;
>  out_free_conn:
> +	nfs4_unlock_state();
>  	free_conn(conn);
>  out_free_session:
>  	__free_session(new);
> -- 
> 1.7.4.4
> 
