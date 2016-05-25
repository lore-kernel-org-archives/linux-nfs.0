Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:33410 "EHLO
	mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751127AbcEYLta (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 May 2016 07:49:30 -0400
Received: by mail-yw0-f196.google.com with SMTP id y6so6201222ywe.0
        for <linux-nfs@vger.kernel.org>; Wed, 25 May 2016 04:49:30 -0700 (PDT)
Message-ID: <1464176967.3037.1.camel@poochiereds.net>
Subject: Re: [PATCH 1/4] nfsd: flex file device id encoding will need the
 server addres
From: Jeff Layton <jlayton@poochiereds.net>
To: Tom Haynes <thomas.haynes@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@lst.de>
Date: Wed, 25 May 2016 07:49:27 -0400
In-Reply-To: <1464152979-103988-2-git-send-email-loghyr@primarydata.com>
References: <1464152979-103988-1-git-send-email-loghyr@primarydata.com>
	 <1464152979-103988-2-git-send-email-loghyr@primarydata.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2016-05-24 at 22:09 -0700, Tom Haynes wrote:
> Signed-off-by: Tom Haynes <loghyr@primarydata.com>
> ---
>  fs/nfsd/blocklayout.c | 2 ++
>  fs/nfsd/nfs4proc.c    | 1 +
>  fs/nfsd/pnfs.h        | 1 +
>  3 files changed, 4 insertions(+)
> 
> diff --git a/fs/nfsd/blocklayout.c b/fs/nfsd/blocklayout.c
> index e55b524..248adb6 100644
> --- a/fs/nfsd/blocklayout.c
> +++ b/fs/nfsd/blocklayout.c
> @@ -162,6 +162,7 @@ nfsd4_block_get_device_info_simple(struct super_block *sb,
>  
>  static __be32
>  nfsd4_block_proc_getdeviceinfo(struct super_block *sb,
> +		struct svc_rqst *rqstp,
>  		struct nfs4_client *clp,
>  		struct nfsd4_getdeviceinfo *gdp)
>  {
> @@ -354,6 +355,7 @@ nfsd4_block_get_device_info_scsi(struct super_block *sb,
>  
>  static __be32
>  nfsd4_scsi_proc_getdeviceinfo(struct super_block *sb,
> +		struct svc_rqst *rqstp,
>  		struct nfs4_client *clp,
>  		struct nfsd4_getdeviceinfo *gdp)
>  {
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index de1ff1d..b28e45b 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1270,6 +1270,7 @@ nfsd4_getdeviceinfo(struct svc_rqst *rqstp,
>  	nfserr = nfs_ok;
>  	if (gdp->gd_maxcount != 0) {
>  		nfserr = ops->proc_getdeviceinfo(exp->ex_path.mnt->mnt_sb,
> +					rqstp,
>  					cstate->session->se_client, gdp);
>  	}
>  
> diff --git a/fs/nfsd/pnfs.h b/fs/nfsd/pnfs.h
> index 7d073b9..e855677 100644
> --- a/fs/nfsd/pnfs.h
> +++ b/fs/nfsd/pnfs.h
> @@ -21,6 +21,7 @@ struct nfsd4_layout_ops {
>  	u32		notify_types;
>  
>  	__be32 (*proc_getdeviceinfo)(struct super_block *sb,
> +			struct svc_rqst *rqstp,
>  			struct nfs4_client *clp,
>  			struct nfsd4_getdeviceinfo *gdevp);
>  	__be32 (*encode_getdeviceinfo)(struct xdr_stream *xdr,

Looks fine.

Reviewed-by: Jeff Layton <jlayton@poochiereds.net>
