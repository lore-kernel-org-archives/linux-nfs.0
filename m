Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx141.netapp.com ([216.240.21.12]:46626 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755383AbbBLNyy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Feb 2015 08:54:54 -0500
Message-ID: <54DCB0AB.1000700@Netapp.com>
Date: Thu, 12 Feb 2015 08:54:51 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Peng Tao <tao.peng@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsstat: update client op to match latest kernel
References: <1423732041-18082-1-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1423732041-18082-1-git-send-email-tao.peng@primarydata.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Tao,

On 02/12/2015 04:07 AM, Peng Tao wrote:
> We've added a bunch of ops and removed getdevicelist.
> 
> Signed-off-by: Peng Tao <tao.peng@primarydata.com>
> ---
>  utils/nfsstat/nfsstat.c | 11 ++++++++---
>  1 file changed, 8 insertions(+), 3 deletions(-)
> 
> diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
> index 9f481db..de57109 100644
> --- a/utils/nfsstat/nfsstat.c
> +++ b/utils/nfsstat/nfsstat.c
> @@ -31,7 +31,7 @@ enum {
>  	SRVPROC3_SZ = 22,
>  	CLTPROC3_SZ = 22,
>  	SRVPROC4_SZ = 2,
> -	CLTPROC4_SZ = 49,
> +	CLTPROC4_SZ = 55,
>  	SRVPROC4OPS_SZ = 59,
>  };
>  
> @@ -127,7 +127,7 @@ static const char *	nfscltproc4name[CLTPROC4_SZ] = {
>  	"remove",    "rename",    "link",    "symlink",     "create",      "pathconf",
>  	"statfs",    "readlink",  "readdir", "server_caps", "delegreturn", "getacl",
>  	"setacl",    "fs_locations",
> -	"rel_lkowner", "secinfo",
> +	"rel_lkowner", "secinfo", "fsid_present",
>  	/* nfsv4.1 client ops */
>  	"exchange_id",
>  	"create_ses",
> @@ -139,7 +139,12 @@ static const char *	nfscltproc4name[CLTPROC4_SZ] = {
>  	"getdevinfo",
>  	"layoutcommit",
>  	"layoutreturn",
> -	"getdevlist",
> +	"secinfo_no_n",
> +	"test_stateid",
> +	"free_stateid",
> +	"bind_con_ses",
> +	"destroy_clid",
> +	"seek",

Can you add ALLOCATE and DEALLOCATE while you're at it?

Thanks,
Anna
>  };
>  
>  static const char *     nfssrvproc4opname[SRVPROC4OPS_SZ] = {
> 

