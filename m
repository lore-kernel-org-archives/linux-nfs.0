From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd: eliminate unused nfs4_callback.cb_program
Date: Tue, 10 Jun 2008 11:14:51 -0400
Message-ID: <20080610151451.GB20184@fieldses.org>
References: <1213091947-19618-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:46284 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751909AbYFJPOx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jun 2008 11:14:53 -0400
In-Reply-To: <1213091947-19618-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 10, 2008 at 12:59:07PM +0300, Benny Halevy wrote:
> The cb_program member of struct nfs4_callback unused
> since commit ff7d9756 nfsd: use static memory for callback program and stats

Thanks, Benny; I've applied both.

--b.

> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  include/linux/nfsd/state.h |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
> index 0722162..2716f10 100644
> --- a/include/linux/nfsd/state.h
> +++ b/include/linux/nfsd/state.h
> @@ -100,7 +100,6 @@ struct nfs4_callback {
>  	u32			cb_ident;	/* minorversion 0 only */
>  	/* RPC client info */
>  	atomic_t		cb_set;     /* successful CB_NULL call */
> -	struct rpc_program      cb_program;
>  	struct rpc_stat         cb_stat;
>  	struct rpc_clnt *       cb_client;
>  };
> -- 
> 1.5.3.3
> 
