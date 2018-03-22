Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48220 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751765AbeCVUSP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 22 Mar 2018 16:18:15 -0400
Date: Thu, 22 Mar 2018 16:18:15 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stefan Agner <stefan@agner.ch>
Cc: jlayton@kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: use correct enum type in decode_cb_op_status
Message-ID: <20180322201815.GC31914@fieldses.org>
References: <20180319223705.28974-1-stefan@agner.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180319223705.28974-1-stefan@agner.ch>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Applying, thanks!--b.

On Mon, Mar 19, 2018 at 11:37:05PM +0100, Stefan Agner wrote:
> Use enum nfs_cb_opnum4 in decode_cb_op_status. This fixes warnings
> seen with clang:
>   fs/nfsd/nfs4callback.c:451:36: warning: implicit conversion from
>       enumeration type 'enum nfs_cb_opnum4' to different enumeration
>       type 'enum nfs_opnum4' [-Wenum-conversion]
>         status = decode_cb_op_status(xdr, OP_CB_SEQUENCE, &cb->cb_seq_status);
>                  ~~~~~~~~~~~~~~~~~~~      ^~~~~~~~~~~~~~
> 
> Signed-off-by: Stefan Agner <stefan@agner.ch>
> ---
>  fs/nfsd/nfs4callback.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index 49b0a9e7ff18..1f04d2a70d25 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -223,8 +223,8 @@ static int nfs_cb_stat_to_errno(int status)
>  	return -status;
>  }
>  
> -static int decode_cb_op_status(struct xdr_stream *xdr, enum nfs_opnum4 expected,
> -			       int *status)
> +static int decode_cb_op_status(struct xdr_stream *xdr,
> +			       enum nfs_cb_opnum4 expected, int *status)
>  {
>  	__be32 *p;
>  	u32 op;
> -- 
> 2.16.2
