Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:46006 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756332Ab1BQNls (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Feb 2011 08:41:48 -0500
Message-ID: <4D5D259B.9040605@panasas.com>
Date: Thu, 17 Feb 2011 08:41:47 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
CC: Chuck Lever <chuck.lever@oracle.com>, NFS <linux-nfs@vger.kernel.org>,
        andros@netapp.com, "J. Bruce Fields" <bfields@redhat.com>
Subject: Re: [PATCH] nfsd41: modify the members value of nfsd4_op_flags
References: <4D5CE432.10304@cn.fujitsu.com>
In-Reply-To: <4D5CE432.10304@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

BTW, any particular reason you sent this to Chuck and not Bruce <bfields@redhat.com>
who's the nfs server maintainer?

On 2011-02-17 04:02, Mi Jinlong wrote:
> The members of nfsd4_op_flags, (ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS)
> equals to  ALLOWED_AS_FIRST_OP, maybe that's not what we want.
> 
> OP_PUTROOTFH with op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS,
> can't appears as the first operation with out SEQUENCE ops.
> 
> This patch modify the wrong value of ALLOWED_WITHOUT_FH etc which 
> was introduced by f9bb94c4.
> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
>  fs/nfsd/nfs4proc.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index db52546..8605d38 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -983,9 +983,9 @@ static inline void nfsd4_increment_op_stats(u32 opnum)
>  typedef __be32(*nfsd4op_func)(struct svc_rqst *, struct nfsd4_compound_state *,
>  			      void *);
>  enum nfsd4_op_flags {
> -	ALLOWED_WITHOUT_FH = 1 << 0,	/* No current filehandle required */
> -	ALLOWED_ON_ABSENT_FS = 2 << 0,	/* ops processed on absent fs */
> -	ALLOWED_AS_FIRST_OP = 3 << 0,	/* ops reqired first in compound */
> +	ALLOWED_WITHOUT_FH = 1 << 1,	/* No current filehandle required */
> +	ALLOWED_ON_ABSENT_FS = 1 << 2,	/* ops processed on absent fs */
> +	ALLOWED_AS_FIRST_OP = 1 << 3,	/* ops reqired first in compound */

Right, just 1 << {0,1,2} would make more sense :)

Benny

>  };
>  
>  struct nfsd4_operation {
