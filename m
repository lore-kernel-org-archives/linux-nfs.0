Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:51795 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755248AbbHYQEW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Aug 2015 12:04:22 -0400
Subject: Re: [PATCH RFC 03/11] nfs42: decode_layoutstats does not need res
 parameter
To: Peng Tao <tao.peng@primarydata.com>, <linux-nfs@vger.kernel.org>
References: <1440516829-116041-1-git-send-email-tao.peng@primarydata.com>
 <1440516829-116041-4-git-send-email-tao.peng@primarydata.com>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>, Zach Brown <zab@zabbo.net>,
        Darren Hart <dvhart@linux.intel.com>, <bfields@fieldses.org>,
        Jeff Layton <jeff.layton@primarydata.com>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <55DC9202.3080203@Netapp.com>
Date: Tue, 25 Aug 2015 12:04:18 -0400
MIME-Version: 1.0
In-Reply-To: <1440516829-116041-4-git-send-email-tao.peng@primarydata.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Tao,

Should this be sent as a separate patch?  It could probably be included now, rather than waiting on the rest of the CLONE patches to filter through.

Thanks,
Anna

On 08/25/2015 11:33 AM, Peng Tao wrote:
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Peng Tao <tao.peng@primarydata.com>
> ---
>  fs/nfs/nfs42xdr.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
> index a6bd27d..0eb29e1 100644
> --- a/fs/nfs/nfs42xdr.c
> +++ b/fs/nfs/nfs42xdr.c
> @@ -238,8 +238,7 @@ out_overflow:
>  	return -EIO;
>  }
>  
> -static int decode_layoutstats(struct xdr_stream *xdr,
> -			      struct nfs42_layoutstat_res *res)
> +static int decode_layoutstats(struct xdr_stream *xdr)
>  {
>  	return decode_op_hdr(xdr, OP_LAYOUTSTATS);
>  }
> @@ -343,7 +342,7 @@ static int nfs4_xdr_dec_layoutstats(struct rpc_rqst *rqstp,
>  		goto out;
>  	WARN_ON(res->num_dev > PNFS_LAYOUTSTATS_MAXDEV);
>  	for (i = 0; i < res->num_dev; i++) {
> -		status = decode_layoutstats(xdr, res);
> +		status = decode_layoutstats(xdr);
>  		if (status)
>  			goto out;
>  	}
> 

