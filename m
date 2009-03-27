From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] Fix a build warning about leaking CONFIG_NFSD to
	userspace.
Date: Fri, 27 Mar 2009 19:48:52 -0400
Message-ID: <20090327234852.GG18222@fieldses.org>
References: <49CBA01F.6050809@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Greg Banks <gnb@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:37335 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764513AbZC0Xsx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2009 19:48:53 -0400
In-Reply-To: <49CBA01F.6050809@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 27, 2009 at 02:32:47AM +1100, Greg Banks wrote:
> Fix a build warning about leaking CONFIG_NFSD to userspace.
> 
> The nfsd_stats data structure does not need to be available to
> userspace; no kernel interface uses it.  So move it inside #ifdef
> __KERNEL__ and the warning goes away.
> 
> Signed-off-by: Greg Banks <gnb@sgi.com>

Thanks, applied.--b.

> ---
> 
>  include/linux/nfsd/stats.h |    9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
> 
> Index: bfields/include/linux/nfsd/stats.h
> ===================================================================
> --- bfields.orig/include/linux/nfsd/stats.h
> +++ bfields/include/linux/nfsd/stats.h
> @@ -11,6 +11,11 @@
>  
>  #include <linux/nfs4.h>
>  
> +/* thread usage wraps very million seconds (approx one fortnight) */
> +#define	NFSD_USAGE_WRAP	(HZ*1000000)
> +
> +#ifdef __KERNEL__
> +
>  struct nfsd_stats {
>  	unsigned int	rchits;		/* repcache hits */
>  	unsigned int	rcmisses;	/* repcache hits */
> @@ -35,10 +40,6 @@ struct nfsd_stats {
>  
>  };
>  
> -/* thread usage wraps very million seconds (approx one fortnight) */
> -#define	NFSD_USAGE_WRAP	(HZ*1000000)
> -
> -#ifdef __KERNEL__
>  
>  extern struct nfsd_stats	nfsdstats;
>  extern struct svc_stat		nfsd_svcstats;
> 
> 
> -- 
> Greg Banks, P.Engineer, SGI Australian Software Group.
> the brightly coloured sporks of revolution.
> I don't speak for SGI.
> 
