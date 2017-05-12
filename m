Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f177.google.com ([209.85.216.177]:34810 "EHLO
        mail-qt0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757613AbdELSBY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 12 May 2017 14:01:24 -0400
Received: by mail-qt0-f177.google.com with SMTP id l7so12221637qte.1
        for <linux-nfs@vger.kernel.org>; Fri, 12 May 2017 11:01:24 -0700 (PDT)
Message-ID: <1494612078.4227.0.camel@redhat.com>
Subject: Re: [PATCH 14/33] lockd: fix some weird indentation
From: Jeff Layton <jlayton@redhat.com>
To: Christoph Hellwig <hch@lst.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Date: Fri, 12 May 2017 14:01:18 -0400
In-Reply-To: <20170512161701.22468-15-hch@lst.de>
References: <20170512161701.22468-1-hch@lst.de>
         <20170512161701.22468-15-hch@lst.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-05-12 at 18:16 +0200, Christoph Hellwig wrote:
> Remove double indentation of a few struct rpc_version and
> struct rpc_program instance.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Acked-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/lockd/clntxdr.c | 22 +++++++++++-----------
>  fs/lockd/mon.c     | 16 ++++++++--------
>  2 files changed, 19 insertions(+), 19 deletions(-)
> 
> diff --git a/fs/lockd/clntxdr.c b/fs/lockd/clntxdr.c
> index 17e7f08b3a22..bd8a976785ae 100644
> --- a/fs/lockd/clntxdr.c
> +++ b/fs/lockd/clntxdr.c
> @@ -601,15 +601,15 @@ static struct rpc_procinfo	nlm_procedures[] = {
>  };
>  
>  static const struct rpc_version	nlm_version1 = {
> -		.number		= 1,
> -		.nrprocs	= ARRAY_SIZE(nlm_procedures),
> -		.procs		= nlm_procedures,
> +	.number		= 1,
> +	.nrprocs	= ARRAY_SIZE(nlm_procedures),
> +	.procs		= nlm_procedures,
>  };
>  
>  static const struct rpc_version	nlm_version3 = {
> -		.number		= 3,
> -		.nrprocs	= ARRAY_SIZE(nlm_procedures),
> -		.procs		= nlm_procedures,
> +	.number		= 3,
> +	.nrprocs	= ARRAY_SIZE(nlm_procedures),
> +	.procs		= nlm_procedures,
>  };
>  
>  static const struct rpc_version	*nlm_versions[] = {
> @@ -623,9 +623,9 @@ static const struct rpc_version	*nlm_versions[] = {
>  static struct rpc_stat		nlm_rpc_stats;
>  
>  const struct rpc_program	nlm_program = {
> -		.name		= "lockd",
> -		.number		= NLM_PROGRAM,
> -		.nrvers		= ARRAY_SIZE(nlm_versions),
> -		.version	= nlm_versions,
> -		.stats		= &nlm_rpc_stats,
> +	.name		= "lockd",
> +	.number		= NLM_PROGRAM,
> +	.nrvers		= ARRAY_SIZE(nlm_versions),
> +	.version	= nlm_versions,
> +	.stats		= &nlm_rpc_stats,
>  };
> diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
> index 80630f0347e1..62424e929a7f 100644
> --- a/fs/lockd/mon.c
> +++ b/fs/lockd/mon.c
> @@ -553,9 +553,9 @@ static struct rpc_procinfo	nsm_procedures[] = {
>  };
>  
>  static const struct rpc_version nsm_version1 = {
> -		.number		= 1,
> -		.nrprocs	= ARRAY_SIZE(nsm_procedures),
> -		.procs		= nsm_procedures
> +	.number		= 1,
> +	.nrprocs	= ARRAY_SIZE(nsm_procedures),
> +	.procs		= nsm_procedures
>  };
>  
>  static const struct rpc_version *nsm_version[] = {
> @@ -565,9 +565,9 @@ static const struct rpc_version *nsm_version[] = {
>  static struct rpc_stat		nsm_stats;
>  
>  static const struct rpc_program nsm_program = {
> -		.name		= "statd",
> -		.number		= NSM_PROGRAM,
> -		.nrvers		= ARRAY_SIZE(nsm_version),
> -		.version	= nsm_version,
> -		.stats		= &nsm_stats
> +	.name		= "statd",
> +	.number		= NSM_PROGRAM,
> +	.nrvers		= ARRAY_SIZE(nsm_version),
> +	.version	= nsm_version,
> +	.stats		= &nsm_stats
>  };

Acked-by: Jeff Layton <jlayton@redhat.com>
