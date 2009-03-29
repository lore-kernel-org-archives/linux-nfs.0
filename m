From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 17/46] nfs41: use nfs4_getaclres
Date: Sun, 29 Mar 2009 13:28:12 -0400
Message-ID: <1238347692.10999.16.camel@heimdal.trondhjem.org>
References: <49ADBD04.2090002@panasas.com>
	 <1236124495-3430-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51757 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751536AbZC2RjE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 29 Mar 2009 13:39:04 -0400
In-Reply-To: <1236124495-3430-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-03-03 at 16:54 -0700, Benny Halevy wrote:
> In preparation for nfs41 sequence processing.
> 
> Signed-off-by: Andy Admason <andros@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/nfs4proc.c |    7 +++++--
>  fs/nfs/nfs4xdr.c  |    5 +++--
>  2 files changed, 8 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 4db965c..1a5fa1d 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2822,17 +2822,20 @@ out:
>  static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void
> *buf, size_t buflen)
>  {
>         struct page *pages[NFS4ACL_MAXPAGES];
> +       size_t resp_len = buflen;
>         struct nfs_getaclargs args = {
>                 .fh = NFS_FH(inode),
>                 .acl_pages = pages,
>                 .acl_len = buflen,
>         };
> -       size_t resp_len = buflen;
> +       struct nfs_getaclres res = {
> +               .acl_len = &resp_len,
> +       };

Please embed resp_len in nfs_getaclres. There is no need for a double
indirection here...

>         void *resp_buf;
>         struct rpc_message msg = {
>                 .rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_GETACL],
>                 .rpc_argp = &args,
> -               .rpc_resp = &resp_len,
> +               .rpc_resp = &res,
>         };
>         struct page *localpage = NULL;
>         int ret;
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 3f84ab7..62fc817 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -3933,7 +3933,8 @@ out:
>   * Decode GETACL response
>   */
>  static int
> -nfs4_xdr_dec_getacl(struct rpc_rqst *rqstp, __be32 *p, size_t
> *acl_len)
> +nfs4_xdr_dec_getacl(struct rpc_rqst *rqstp, __be32 *p,
> +                   struct nfs_getaclres *res)
>  {
>         struct xdr_stream xdr;
>         struct compound_hdr hdr;
> @@ -3946,7 +3947,7 @@ nfs4_xdr_dec_getacl(struct rpc_rqst *rqstp,
> __be32 *p, size_t *acl_len)
>         status = decode_putfh(&xdr);
>         if (status)
>                 goto out;
> -       status = decode_getacl(&xdr, rqstp, acl_len);
> +       status = decode_getacl(&xdr, rqstp, res->acl_len);
> 
>  out:
>         return status;
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
