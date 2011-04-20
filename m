Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46004 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752135Ab1DTVOX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Apr 2011 17:14:23 -0400
Date: Wed, 20 Apr 2011 17:14:21 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: nfsd41: add flag checking for create_session
Message-ID: <20110420211421.GH15919@fieldses.org>
References: <4D89C3F3.9020505@cn.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D89C3F3.9020505@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Mar 23, 2011 at 05:57:07PM +0800, Mi Jinlong wrote:
> At the latest kernel, NFS server doesn't check create_session 
> operation's falg.
> 
> This patch add flag mask and check flag for create_session
>  as exchang_id. Also, make some adjustment for align.

A clients sending undefined flags is out of spec as far as I can tell,
and I'm not sure we owe them any particular error.

But perhaps erroring out is useful for debugging at least, OK.  Applying
for 2.6.40.

--b.

> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
>  fs/nfsd/nfs4state.c  |    3 +++
>  include/linux/nfs4.h |    8 +++++---
>  2 files changed, 8 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 7b566ec..1f66370 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1514,6 +1514,9 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>  	bool confirm_me = false;
>  	int status = 0;
>  
> +	if (cr_ses->flags & ~SESSION4_FLAG_MASK_A)
> +		return nfserr_inval;
> +
>  	nfs4_lock_state();
>  	unconf = find_unconfirmed_client(&cr_ses->clientid);
>  	conf = find_confirmed_client(&cr_ses->clientid);
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index 134716e..e064895 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -568,9 +568,11 @@ struct nfs4_sessionid {
>  };
>  
>  /* Create Session Flags */
> -#define SESSION4_PERSIST	 0x001
> -#define SESSION4_BACK_CHAN 	 0x002
> -#define SESSION4_RDMA		 0x004
> +#define SESSION4_PERSIST	0x001
> +#define SESSION4_BACK_CHAN	0x002
> +#define SESSION4_RDMA		0x004
> +
> +#define SESSION4_FLAG_MASK_A	0x007
>  
>  enum state_protect_how4 {
>  	SP4_NONE	= 0,
> -- 
> 1.7.4.1
> 
> 
