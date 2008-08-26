From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] SUNRPC: Make svc_addr's argument a constant
Date: Tue, 26 Aug 2008 15:20:41 -0400
Message-ID: <20080826192041.GI4380@fieldses.org>
References: <20080822164315.20600.28603.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:37216 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758304AbYHZTUs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Aug 2008 15:20:48 -0400
In-Reply-To: <20080822164315.20600.28603.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Also applied.--b.

On Fri, Aug 22, 2008 at 12:43:16PM -0400, Chuck Lever wrote:
> Clean up: Add extra type safety and squelch a few compiler complaints
> in upcoming patches.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  include/linux/sunrpc/svc.h |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> index 2a41d29..564e045 100644
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -266,17 +266,17 @@ struct svc_rqst {
>  /*
>   * Rigorous type checking on sockaddr type conversions
>   */
> -static inline struct sockaddr_in *svc_addr_in(struct svc_rqst *rqst)
> +static inline struct sockaddr_in *svc_addr_in(const struct svc_rqst *rqst)
>  {
>  	return (struct sockaddr_in *) &rqst->rq_addr;
>  }
>  
> -static inline struct sockaddr_in6 *svc_addr_in6(struct svc_rqst *rqst)
> +static inline struct sockaddr_in6 *svc_addr_in6(const struct svc_rqst *rqst)
>  {
>  	return (struct sockaddr_in6 *) &rqst->rq_addr;
>  }
>  
> -static inline struct sockaddr *svc_addr(struct svc_rqst *rqst)
> +static inline struct sockaddr *svc_addr(const struct svc_rqst *rqst)
>  {
>  	return (struct sockaddr *) &rqst->rq_addr;
>  }
> 
