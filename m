Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:32833 "EHLO
	mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751440AbcFJUF2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2016 16:05:28 -0400
Received: by mail-yw0-f196.google.com with SMTP id y6so9763532ywe.0
        for <linux-nfs@vger.kernel.org>; Fri, 10 Jun 2016 13:05:27 -0700 (PDT)
Message-ID: <1465589124.3759.3.camel@poochiereds.net>
Subject: Re: [PATCH 1/5] NFSv4.1/pnfs: Ensure we handle delegation errors in
 nfs4_proc_layoutget()
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Date: Fri, 10 Jun 2016 16:05:24 -0400
In-Reply-To: <1465573798-80118-1-git-send-email-trond.myklebust@primarydata.com>
References: <1465573798-80118-1-git-send-email-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2016-06-10 at 11:49 -0400, Trond Myklebust wrote:
> nfs4_handle_exception() relies on the caller setting the 'inode' field
> in the struct nfs4_exception argument when the error applies to a
> delegation.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/nfs4proc.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index de97567795a5..27fe63b502d5 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -8036,7 +8036,10 @@ nfs4_proc_layoutget(struct nfs4_layoutget *lgp, long *timeout, gfp_t gfp_flags)
>  		.flags = RPC_TASK_ASYNC,
>  	};
>  	struct pnfs_layout_segment *lseg = NULL;
> -	struct nfs4_exception exception = { .timeout = *timeout };
> +	struct nfs4_exception exception = {
> +		.inode = inode,
> +		.timeout = *timeout,
> +	};
>  	int status = 0;
>  
>  	dprintk("--> %s\n", __func__);

The whole set looks good to me. You can add this to all of them:

Reviewed-by: Jeff Layton <jlayton@poochiereds.net>
