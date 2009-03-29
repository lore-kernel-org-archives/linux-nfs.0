From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 19/46] nfs41: use nfs4_setaclres
Date: Sun, 29 Mar 2009 13:30:23 -0400
Message-ID: <1238347823.10999.17.camel@heimdal.trondhjem.org>
References: <49ADBD04.2090002@panasas.com>
	 <1236124518-3488-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51757 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752215AbZC2RjF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 29 Mar 2009 13:39:05 -0400
In-Reply-To: <1236124518-3488-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-03-03 at 16:55 -0700, Benny Halevy wrote:
> In preparation for nfs41 sequence processing.
> 
> Signed-off-by: Andy Admason <andros@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/nfs4proc.c |    3 ++-
>  fs/nfs/nfs4xdr.c  |    3 ++-
>  2 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 1a5fa1d..98b2e89 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2915,10 +2915,11 @@ static int __nfs4_proc_set_acl(struct inode
> *inode, const void *buf, size_t bufl
>                 .acl_pages      = pages,
>                 .acl_len        = buflen,
>         };
> +       struct nfs_setaclres res;

Where is the definition?

>         struct rpc_message msg = {
>                 .rpc_proc       =
> &nfs4_procedures[NFSPROC4_CLNT_SETACL],
>                 .rpc_argp       = &arg,
> -               .rpc_resp       = NULL,
> +               .rpc_resp       = &res,
>         };
>         int ret;
> 
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 13320af..5fb452c 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -3911,7 +3911,8 @@ nfs4_xdr_enc_setacl(struct rpc_rqst *req, __be32
> *p, struct nfs_setaclargs *args
>   * Decode SETACL response
>   */
>  static int
> -nfs4_xdr_dec_setacl(struct rpc_rqst *rqstp, __be32 *p, void *res)
> +nfs4_xdr_dec_setacl(struct rpc_rqst *rqstp, __be32 *p,
> +                   struct nfs_setaclres *res)
>  {
>         struct xdr_stream xdr;
>         struct compound_hdr hdr;
> --
> 1.6.1.3
> 
> 
> 
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
