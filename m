Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50146 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761743Ab3DCTaW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Apr 2013 15:30:22 -0400
Date: Wed, 3 Apr 2013 15:30:21 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: fanchaoting <fanchaoting@cn.fujitsu.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfsd: remove /proc/fs/nfs when create
 /proc/fs/nfs/exports error
Message-ID: <20130403193021.GJ6044@fieldses.org>
References: <5152AE56.5010306@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5152AE56.5010306@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying.

--b.

On Wed, Mar 27, 2013 at 04:31:18PM +0800, fanchaoting wrote:
> when create /proc/fs/nfs/exports error, we should remove /proc/fs/nfs,
> if don't do it, it maybe cause Memory leak.
> 
>  Signed-off-by: fanchaoting <fanchaoting@cn.fujitsu.com>
>  Reviewed-by: chendt.fnst <chendt.fnst@cn.fujitsu.com>
> 
> ---
>  fs/nfsd/nfsctl.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index f33455b..58e4db4 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -1102,8 +1102,10 @@ static int create_proc_exports_entry(void)
>  		return -ENOMEM;
>  	entry = proc_create("exports", 0, entry,
>  				 &exports_proc_operations);
> -	if (!entry)
> +	if (!entry) {
> +		remove_proc_entry("fs/nfs", NULL);
>  		return -ENOMEM;
> +	}
>  	return 0;
>  }
>  #else /* CONFIG_PROC_FS */
> -- 
> 1.7.1
> 
> 
