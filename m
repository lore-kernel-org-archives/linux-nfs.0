From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [2.6 patch] make nfsd_create_setattr() static
Date: Wed, 13 Feb 2008 16:38:09 -0500
Message-ID: <20080213213809.GC29590@fieldses.org>
References: <20080213213026.GD3383@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@suse.de, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:45169 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765830AbYBMViM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Feb 2008 16:38:12 -0500
In-Reply-To: <20080213213026.GD3383-Aar9JVdAhcRoA3hw4S0G5QR5/fbUUdgG@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 13, 2008 at 11:30:26PM +0200, Adrian Bunk wrote:
> This patch makes the needlessly global nfsd_create_setattr() static.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Thanks, applied.--b.

> 
> ---
> 7cfb17a22a0cf76477fbf1fbe6bf586108a13a44 diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index cc75e4f..035204f 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -1151,7 +1151,7 @@ nfsd_commit(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  }
>  #endif /* CONFIG_NFSD_V3 */
>  
> -__be32
> +static __be32
>  nfsd_create_setattr(struct svc_rqst *rqstp, struct svc_fh *resfhp,
>  			struct iattr *iap)
>  {
> 
