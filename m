Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33731 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752432AbbL1SfP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Dec 2015 13:35:15 -0500
Date: Mon, 28 Dec 2015 13:35:13 -0500 (EST)
From: Benjamin Coddington <bcodding@redhat.com>
To: Kinglong Mee <kinglongmee@gmail.com>
cc: Steve Dickson <SteveD@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsstat: show client rpc information correctly
In-Reply-To: <567BE110.3070406@gmail.com>
Message-ID: <alpine.OSX.2.19.9992.1512281200080.87866@planck.local>
References: <567BE110.3070406@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> There are 59 client rpc procedures, not 60.
>
> The order of rpc name must be the same as define of
> NFSPROC4_CLNT_xx in include/linux/nfs4.h,
> not nfs4_procedures in nfs4xdr.c.

Thanks for fixing this -- I did not look very closely at the
#define PROC(proc, argtype, restype) and missed the designated initializer.

It looks like we don't keep track of stats for NULL, then.  That seems like
a minor problem -- but maybe we shouldn't be pretending we are keeping track
of it.

> Drop duplicate rpc name "getdevlist".
>
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>

Reviewed-by: Benjamin Coddington <bcodding@redhat.com>

> ---
>  utils/nfsstat/nfsstat.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
>
> diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
> index b67f0aa..8376347 100644
> --- a/utils/nfsstat/nfsstat.c
> +++ b/utils/nfsstat/nfsstat.c
> @@ -31,7 +31,7 @@ enum {
>  	SRVPROC3_SZ = 22,
>  	CLTPROC3_SZ = 22,
>  	SRVPROC4_SZ = 2,
> -	CLTPROC4_SZ = 60,
> +	CLTPROC4_SZ = 59,
>  	SRVPROC4OPS_SZ = 71,
>  };
>
> @@ -135,11 +135,10 @@ static const char *	nfscltproc4name[CLTPROC4_SZ] = {
>  	"sequence",
>  	"get_lease_time",
>  	"reclaim_comp",
> -	"getdevinfo",
>  	"layoutget",
> +	"getdevinfo",
>  	"layoutcommit",
>  	"layoutreturn",
> -	"getdevlist",
>  	"secinfo_no",
>  	"test_stateid",
>  	"free_stateid",
> --
> 2.5.0
>
>
