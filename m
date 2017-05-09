Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f169.google.com ([209.85.216.169]:35676 "EHLO
        mail-qt0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752559AbdEIRfT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 13:35:19 -0400
Received: by mail-qt0-f169.google.com with SMTP id n4so7011806qte.2
        for <linux-nfs@vger.kernel.org>; Tue, 09 May 2017 10:35:18 -0700 (PDT)
Message-ID: <1494351316.2659.13.camel@redhat.com>
Subject: Re: [PATCH 29/32] RFC: sunrpc: remove pc_count
From: Jeff Layton <jlayton@redhat.com>
To: Christoph Hellwig <hch@lst.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Date: Tue, 09 May 2017 13:35:16 -0400
In-Reply-To: <20170509092010.30752-30-hch@lst.de>
References: <20170509092010.30752-1-hch@lst.de>
         <20170509092010.30752-30-hch@lst.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2017-05-09 at 11:20 +0200, Christoph Hellwig wrote:
> pc_count is the only writeable memeber of struct svc_procinfo, which is
> a good candidate to be const-ified as it contains function pointers.
> 
> This patch just removes it and returns zero in the /proc file as the
> count of calls per procedure doesn't seem all that useful.  But it's
> just a dumb hack and we might need a proper fix instead.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  include/linux/sunrpc/svc.h | 1 -
>  net/sunrpc/stats.c         | 2 +-
>  net/sunrpc/svc.c           | 3 ---
>  3 files changed, 1 insertion(+), 5 deletions(-)
> 
> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> index 8eeb39286422..cab77b0904b0 100644
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -430,7 +430,6 @@ struct svc_procedure {
>  	void			(*pc_release)(struct svc_rqst *);
>  	unsigned int		pc_argsize;	/* argument struct size */
>  	unsigned int		pc_ressize;	/* result struct size */
> -	unsigned int		pc_count;	/* call count */
>  	unsigned int		pc_cachetype;	/* cache info (NFS) */
>  	unsigned int		pc_xdrressize;	/* maximum size of XDR reply */
>  };
> diff --git a/net/sunrpc/stats.c b/net/sunrpc/stats.c
> index 42053510b96b..f37d0fc835d7 100644
> --- a/net/sunrpc/stats.c
> +++ b/net/sunrpc/stats.c
> @@ -102,7 +102,7 @@ void svc_seq_show(struct seq_file *seq, const struct svc_stat *statp) {
>  			continue;
>  		seq_printf(seq, "proc%d %u", i, vers->vs_nproc);
>  		for (j = 0; j < vers->vs_nproc; j++, proc++)
> -			seq_printf(seq, " %u", proc->pc_count);
> +			seq_printf(seq, " %u", 0);

The rest of the patches also look fine, aside from this one where I
agree with Trond and Chuck that we don't want to break nfsstat.

>  		seq_putc(seq, '\n');
>  	}
>  }
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index bbf8d938812e..af74604fdadd 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -1202,9 +1202,6 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
>  	statp = resv->iov_base +resv->iov_len;
>  	svc_putnl(resv, RPC_SUCCESS);
>  
> -	/* Bump per-procedure stats counter */
> -	procp->pc_count++;
> -
>  	/* Initialize storage for argp and resp */
>  	memset(rqstp->rq_argp, 0, procp->pc_argsize);
>  	memset(rqstp->rq_resp, 0, procp->pc_ressize);
 
Agree with Chuck and Trond's comments on 
-- 
Jeff Layton <jlayton@redhat.com>
