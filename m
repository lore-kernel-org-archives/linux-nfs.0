From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd41: gather and report statistics also for v4.1 ops
Date: Fri, 10 Jul 2009 18:18:49 -0400
Message-ID: <20090710221849.GP10700@fieldses.org>
References: <1247218660-14084-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38233 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752337AbZGJWSv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Jul 2009 18:18:51 -0400
In-Reply-To: <1247218660-14084-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applied for 2.6.32.

--b.

On Fri, Jul 10, 2009 at 12:37:40PM +0300, Benny Halevy wrote:
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  include/linux/nfs4.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index bd2eba5..aff924a 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -234,7 +234,7 @@ enum nfs_opnum4 {
>  Needs to be updated if more operations are defined in future.*/
>  
>  #define FIRST_NFS4_OP	OP_ACCESS
> -#define LAST_NFS4_OP 	OP_RELEASE_LOCKOWNER
> +#define LAST_NFS4_OP 	OP_RECLAIM_COMPLETE
>  
>  enum nfsstat4 {
>  	NFS4_OK = 0,
> -- 
> 1.6.3.3
> 
