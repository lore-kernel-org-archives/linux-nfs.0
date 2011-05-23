From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] nfsstat: reorder nfs4 stats for 2.6.38 and up
Date: Mon, 23 May 2011 08:39:53 -0400
Message-ID: <4DDA5599.7000506@RedHat.com>
References: <1303461980-6731-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8543 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754294Ab1EWMkY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 May 2011 08:40:24 -0400
In-Reply-To: <1303461980-6731-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/22/2011 04:46 AM, Benny Halevy wrote:
> match order in 2.6.38, 2.6.39 (-rc3) and development tree
> while at it, get rid of obsolete ds_write and ds_commit
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  utils/nfsstat/nfsstat.c |    5 +----
>  1 files changed, 1 insertions(+), 4 deletions(-)
> 
> git://linux-nfs.org/~bhalevy/pnfs-nfs-utils.git
> updated respectively
> 
> diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
> index f31bb81..a4a8034 100644
> --- a/utils/nfsstat/nfsstat.c
> +++ b/utils/nfsstat/nfsstat.c
> @@ -126,14 +126,11 @@ static const char *	nfscltproc4name[CLTPROC4_SZ] = {
>  	"sequence",
>  	"get_lease_t",
>  	"reclaim_comp",
> +	"getdevinfo",
>  	"layoutget",
>  	"layoutcommit",
>  	"layoutreturn",
>  	"getdevlist",
> -	"getdevinfo",
> -	/* nfsv4.1 pnfs client ops to data server only */
> -	"ds_write",
> -	"ds_commit",
>  };
>  
>  static const char *     nfssrvproc4opname[SRVPROC4OPS_SZ] = {
Committed...

steved.
