Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47495 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755007Ab1CGRLX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Mar 2011 12:11:23 -0500
Date: Mon, 7 Mar 2011 12:11:14 -0500
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: Benny Halevy <bhalevy@panasas.com>, "J. Bruce Fields" <bfields@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>, NFS <linux-nfs@vger.kernel.org>,
        andros@netapp.com
Subject: Re: [PATCH] nfsd41: modify the members value of nfsd4_op_flags
Message-ID: <20110307171114.GE6718@fieldses.org>
References: <4D5CE432.10304@cn.fujitsu.com>
 <4D5D259B.9040605@panasas.com>
 <4D5DC6E2.5070307@cn.fujitsu.com>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4D5DC6E2.5070307@cn.fujitsu.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Feb 18, 2011 at 09:09:54AM +0800, Mi Jinlong wrote:
> 
> 
> Benny Halevy 写道:
> > BTW, any particular reason you sent this to Chuck and not Bruce <bfields@redhat.com>
> > who's the nfs server maintainer?
> 
>   Sorry for my mistake. 
> 
> > 
> > On 2011-02-17 04:02, Mi Jinlong wrote:
> >> The members of nfsd4_op_flags, (ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS)
> >> equals to  ALLOWED_AS_FIRST_OP, maybe that's not what we want.
> >>
> >> OP_PUTROOTFH with op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS,
> >> can't appears as the first operation with out SEQUENCE ops.
> >>
> >> This patch modify the wrong value of ALLOWED_WITHOUT_FH etc which 
> >> was introduced by f9bb94c4.
> >>
> >> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> >> ---
> >>  fs/nfsd/nfs4proc.c |    6 +++---
> >>  1 files changed, 3 insertions(+), 3 deletions(-)
> >>
> >> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> >> index db52546..8605d38 100644
> >> --- a/fs/nfsd/nfs4proc.c
> >> +++ b/fs/nfsd/nfs4proc.c
> >> @@ -983,9 +983,9 @@ static inline void nfsd4_increment_op_stats(u32 opnum)
> >>  typedef __be32(*nfsd4op_func)(struct svc_rqst *, struct nfsd4_compound_state *,
> >>  			      void *);
> >>  enum nfsd4_op_flags {
> >> -	ALLOWED_WITHOUT_FH = 1 << 0,	/* No current filehandle required */
> >> -	ALLOWED_ON_ABSENT_FS = 2 << 0,	/* ops processed on absent fs */
> >> -	ALLOWED_AS_FIRST_OP = 3 << 0,	/* ops reqired first in compound */
> >> +	ALLOWED_WITHOUT_FH = 1 << 1,	/* No current filehandle required */
> >> +	ALLOWED_ON_ABSENT_FS = 1 << 2,	/* ops processed on absent fs */
> >> +	ALLOWED_AS_FIRST_OP = 1 << 3,	/* ops reqired first in compound */
> > 
> > Right, just 1 << {0,1,2} would make more sense :)
> 
>   Thanks for your advice.

Thanks for catching this, and apologies for the delay; queueing up for
2.6.39.

--b.

> 
> --------------------------------------------
> >From b01bae649293d160af07dde30fde6aa3ac7f8759 Mon Sep 17 00:00:00 2001
> From: Mi Jinlong <mijinlong@cn.fujitsu.com>
> Date: Fri, 18 Feb 2011 09:08:31 +0800
> Subject: [PATCH] nfsd41: modify the members value of nfsd4_op_flags
> 
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
>  fs/nfsd/nfs4proc.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index db52546..5fcb139 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -984,8 +984,8 @@ typedef __be32(*nfsd4op_func)(struct svc_rqst *, struct nfsd4_compound_state *,
>  			      void *);
>  enum nfsd4_op_flags {
>  	ALLOWED_WITHOUT_FH = 1 << 0,	/* No current filehandle required */
> -	ALLOWED_ON_ABSENT_FS = 2 << 0,	/* ops processed on absent fs */
> -	ALLOWED_AS_FIRST_OP = 3 << 0,	/* ops reqired first in compound */
> +	ALLOWED_ON_ABSENT_FS = 1 << 1,	/* ops processed on absent fs */
> +	ALLOWED_AS_FIRST_OP = 1 << 2,	/* ops reqired first in compound */
>  };
>  
>  struct nfsd4_operation {
> -- 
> 1.7.4.1
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
