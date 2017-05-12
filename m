Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f174.google.com ([209.85.216.174]:35728 "EHLO
        mail-qt0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755947AbdELScV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 12 May 2017 14:32:21 -0400
Received: by mail-qt0-f174.google.com with SMTP id v27so35774853qtg.2
        for <linux-nfs@vger.kernel.org>; Fri, 12 May 2017 11:32:21 -0700 (PDT)
Message-ID: <1494613938.4227.7.camel@redhat.com>
Subject: Re: [PATCH 19/33] nfsd: use named initializers in PROC()
From: Jeff Layton <jlayton@redhat.com>
To: Christoph Hellwig <hch@lst.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Date: Fri, 12 May 2017 14:32:18 -0400
In-Reply-To: <20170512161701.22468-20-hch@lst.de>
References: <20170512161701.22468-1-hch@lst.de>
         <20170512161701.22468-20-hch@lst.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-05-12 at 18:16 +0200, Christoph Hellwig wrote:
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfsd/nfs2acl.c  | 22 +++++++++++-----------
>  fs/nfsd/nfs3acl.c  | 22 +++++++++++-----------
>  fs/nfsd/nfs4proc.c | 10 +++++-----
>  3 files changed, 27 insertions(+), 27 deletions(-)
> 
> diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
> index 838f90f3f890..12933d07204c 100644
> --- a/fs/nfsd/nfs2acl.c
> +++ b/fs/nfsd/nfs2acl.c
> @@ -345,17 +345,17 @@ static int nfsaclsvc_release_access(struct svc_rqst *rqstp, __be32 *p,
>  #define nfsd3_voidres		nfsd3_voidargs
>  struct nfsd3_voidargs { int dummy; };
>  
> -#define PROC(name, argt, rest, relt, cache, respsize)	\
> - { (svc_procfunc) nfsacld_proc_##name,		\
> -   (kxdrproc_t) nfsaclsvc_decode_##argt##args,	\
> -   (kxdrproc_t) nfsaclsvc_encode_##rest##res,	\
> -   (kxdrproc_t) nfsaclsvc_release_##relt,		\
> -   sizeof(struct nfsd3_##argt##args),		\
> -   sizeof(struct nfsd3_##rest##res),		\
> -   0,						\
> -   cache,					\
> -   respsize,					\
> - }
> +#define PROC(name, argt, rest, relt, cache, respsize)			\
> +{									\
> +	.pc_func	= (svc_procfunc) nfsacld_proc_##name,		\
> +	.pc_decode	= (kxdrproc_t) nfsaclsvc_decode_##argt##args,	\
> +	.pc_encode	= (kxdrproc_t) nfsaclsvc_encode_##rest##res,	\
> +	.pc_release	= (kxdrproc_t) nfsaclsvc_release_##relt,	\
> +	.pc_argsize	= sizeof(struct nfsd3_##argt##args),		\
> +	.pc_ressize	= sizeof(struct nfsd3_##rest##res),		\
> +	.pc_cachetype	= cache,					\
> +	.pc_xdrressize	= respsize,					\
> +}
>  
>  #define ST 1		/* status*/
>  #define AT 21		/* attributes */
> diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
> index dcb5f79076c0..db988a229b3a 100644
> --- a/fs/nfsd/nfs3acl.c
> +++ b/fs/nfsd/nfs3acl.c
> @@ -237,17 +237,17 @@ static int nfs3svc_release_getacl(struct svc_rqst *rqstp, __be32 *p,
>  #define nfsd3_voidres			nfsd3_voidargs
>  struct nfsd3_voidargs { int dummy; };
>  
> -#define PROC(name, argt, rest, relt, cache, respsize)	\
> - { (svc_procfunc) nfsd3_proc_##name,		\
> -   (kxdrproc_t) nfs3svc_decode_##argt##args,	\
> -   (kxdrproc_t) nfs3svc_encode_##rest##res,	\
> -   (kxdrproc_t) nfs3svc_release_##relt,		\
> -   sizeof(struct nfsd3_##argt##args),		\
> -   sizeof(struct nfsd3_##rest##res),		\
> -   0,						\
> -   cache,					\
> -   respsize,					\
> - }
> +#define PROC(name, argt, rest, relt, cache, respsize)			\
> +{									\
> +	.pc_func	= (svc_procfunc) nfsd3_proc_##name,		\
> +	.pc_decode	= (kxdrproc_t) nfs3svc_decode_##argt##args,	\
> +	.pc_encode	= (kxdrproc_t) nfs3svc_encode_##rest##res,	\
> +	.pc_release	= (kxdrproc_t) nfs3svc_release_##relt,		\
> +	.pc_argsize	= sizeof(struct nfsd3_##argt##args),		\
> +	.pc_ressize	= sizeof(struct nfsd3_##rest##res),		\
> +	.pc_cachetype	= cache,					\
> +	.pc_xdrressize	= respsize,					\
> +}
>  
>  #define ST 1		/* status*/
>  #define AT 21		/* attributes */
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index c453a1998e00..695e17605b67 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1673,10 +1673,10 @@ static void svcxdr_init_encode(struct svc_rqst *rqstp,
>   * COMPOUND call.
>   */
>  static __be32
> -nfsd4_proc_compound(struct svc_rqst *rqstp,
> -		    struct nfsd4_compoundargs *args,
> -		    struct nfsd4_compoundres *resp)
> +nfsd4_proc_compound(struct svc_rqst *rqstp, void *arg, void *res)
>  {
> +	struct nfsd4_compoundargs *args = arg;
> +	struct nfsd4_compoundres *resp = res;
>  	struct nfsd4_op	*op;
>  	struct nfsd4_operation *opdesc;
>  	struct nfsd4_compound_state *cstate = &resp->cstate;
> @@ -2518,7 +2518,7 @@ struct nfsd4_voidargs { int dummy; };
>  
>  static struct svc_procedure		nfsd_procedures4[2] = {
>  	[NFSPROC4_NULL] = {
> -		.pc_func = (svc_procfunc) nfsd4_proc_null,
> +		.pc_func = nfsd4_proc_null,
>  		.pc_encode = (kxdrproc_t) nfs4svc_encode_voidres,
>  		.pc_argsize = sizeof(struct nfsd4_voidargs),
>  		.pc_ressize = sizeof(struct nfsd4_voidres),
> @@ -2526,7 +2526,7 @@ static struct svc_procedure		nfsd_procedures4[2] = {
>  		.pc_xdrressize = 1,
>  	},
>  	[NFSPROC4_COMPOUND] = {
> -		.pc_func = (svc_procfunc) nfsd4_proc_compound,
> +		.pc_func = nfsd4_proc_compound,
>  		.pc_decode = (kxdrproc_t) nfs4svc_decode_compoundargs,
>  		.pc_encode = (kxdrproc_t) nfs4svc_encode_compoundres,
>  		.pc_argsize = sizeof(struct nfsd4_compoundargs),

OMG, thank you.

Reviewed-by: Jeff Layton <jlayton@redhat.com>
