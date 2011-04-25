Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:42110 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758441Ab1DYOLk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Apr 2011 10:11:40 -0400
Subject: Re: [PATCH] nfsstat: reorder nfs4 stats for 2.6.38 and up
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1303461980-6731-1-git-send-email-bhalevy@panasas.com>
Date: Mon, 25 Apr 2011 10:11:30 -0400
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Message-Id: <23EF6F61-46F2-431B-8A44-A3E941688D65@oracle.com>
References: <1303461980-6731-1-git-send-email-bhalevy@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hey all-

So what are we going to do when adding NFSv4.2 to this mix?  Will we then have to freeze both the NFSv4.1 and NFSv4.0 procedure API in the kernel?  Seems painful.

On Apr 22, 2011, at 4:46 AM, Benny Halevy wrote:

> match order in 2.6.38, 2.6.39 (-rc3) and development tree
> while at it, get rid of obsolete ds_write and ds_commit
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
> utils/nfsstat/nfsstat.c |    5 +----
> 1 files changed, 1 insertions(+), 4 deletions(-)
> 
> git://linux-nfs.org/~bhalevy/pnfs-nfs-utils.git
> updated respectively
> 
> diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
> index f31bb81..a4a8034 100644
> --- a/utils/nfsstat/nfsstat.c
> +++ b/utils/nfsstat/nfsstat.c
> @@ -126,14 +126,11 @@ static const char *	nfscltproc4name[CLTPROC4_SZ] = {
> 	"sequence",
> 	"get_lease_t",
> 	"reclaim_comp",
> +	"getdevinfo",
> 	"layoutget",
> 	"layoutcommit",
> 	"layoutreturn",
> 	"getdevlist",
> -	"getdevinfo",
> -	/* nfsv4.1 pnfs client ops to data server only */
> -	"ds_write",
> -	"ds_commit",
> };
> 
> static const char *     nfssrvproc4opname[SRVPROC4OPS_SZ] = {
> -- 
> 1.7.3.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




