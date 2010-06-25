From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 2/2] nfsd: reject NFSv4 requests over UDP (try #2)
Date: Fri, 25 Jun 2010 14:45:09 -0400
Message-ID: <1277491509.6141.20.camel@heimdal.trondhjem.org>
References: <1277490055-27030-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org, Staubach_Peter@emc.com,
	bfields@fieldses.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:48297 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756731Ab0FYSpP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jun 2010 14:45:15 -0400
In-Reply-To: <1277490055-27030-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2010-06-25 at 14:20 -0400, Jeff Layton wrote:
> RFC3530 states:
> 
>    Where an NFS version 4 implementation supports operation over the IP
>    network protocol, the supported transports between NFS and IP MUST be
>    among the IETF-approved congestion control transport protocols, which
>    include TCP and SCTP
> 
> This patch adds a wrapper for nfsd_dispatch that checks to see whether
> the call came in via UDP, and then rejects it with a PROG_MISMATCH RPC
> error. This replaces the earlier one I proposed -- it should mean no
> extra overhead for NFSv2/3.
> 
> It also has the NFS server skip rpcbind registration for NFSv4 over UDP.
> 
> Reported-by: Sachin Prabhu <sprabhu@redhat.com>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfsd/nfs4proc.c |    3 ++-
>  fs/nfsd/nfsd.h     |    1 +
>  fs/nfsd/nfssvc.c   |   13 +++++++++++++
>  3 files changed, 16 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 59ec449..afbd03c 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1363,8 +1363,9 @@ struct svc_version	nfsd_version4 = {
>  		.vs_vers	= 4,
>  		.vs_nproc	= 2,
>  		.vs_proc	= nfsd_procedures4,
> -		.vs_dispatch	= nfsd_dispatch,
> +		.vs_dispatch	= nfsd4_dispatch,
>  		.vs_xdrsize	= NFS4_SVC_XDRSIZE,
> +		.vs_hidden_udp	= true,
>  };
>  
>  /*
> diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
> index 7237776..f36e07c 100644
> --- a/fs/nfsd/nfsd.h
> +++ b/fs/nfsd/nfsd.h
> @@ -41,6 +41,7 @@ extern const struct seq_operations nfs_exports_op;
>   */
>  int		nfsd_svc(unsigned short port, int nrservs);
>  int		nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp);
> +int		nfsd4_dispatch(struct svc_rqst *rqstp, __be32 *statp);
>  
>  int		nfsd_nrthreads(void);
>  int		nfsd_nrpools(void);
> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> index 6b59d32..0a04472 100644
> --- a/fs/nfsd/nfssvc.c
> +++ b/fs/nfsd/nfssvc.c
> @@ -595,6 +595,19 @@ nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp)
>  	return 1;
>  }
>  
> +int
> +nfsd4_dispatch(struct svc_rqst *rqstp, __be32 *statp)
> +{
> +	/* Reject any NFSv4 request over UDP. Don't bother caching it. */
> +	if (rqstp->rq_prot == IPPROTO_UDP) {
> +		dprintk("%s: rejecting vers 4 request over UDP\n", __func__);
> +		*statp = rpc_prog_mismatch;
> +		return 1;
> +	}
> +
> +	return nfsd_dispatch(rqstp, statp);
> +}
> +
>  int nfsd_pool_stats_open(struct inode *inode, struct file *file)
>  {
>  	int ret;

Won't that lead to svc_process() returning garbage? As far as I can see,
it will indeed lead to the status being set to RPC_PROG_MISMATCH, but it
will fail to set the 'lower/upper' RPC prognumber arguments.

Might something like the following perhaps work?

            statp[0] = rpc_prog_mismatch;
            statp[1] = 2;
	    statp[2] = 3;
            rqstp->rq_res.head[0].iov_len += 2 * sizeof(__be32);
	    return 0;

Cheers
  Trond

