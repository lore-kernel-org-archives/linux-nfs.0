Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34348 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932102Ab1D1VC3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Apr 2011 17:02:29 -0400
Date: Thu, 28 Apr 2011 17:02:28 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: bjschuma@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] NFSD: Remove unused variable from
 nfsd4_decode_bind_conn_to_session()
Message-ID: <20110428210228.GD9624@fieldses.org>
References: <1303933636-22134-1-git-send-email-bjschuma@netapp.com>
 <1303933636-22134-3-git-send-email-bjschuma@netapp.com>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1303933636-22134-3-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Apr 27, 2011 at 03:47:16PM -0400, bjschuma@netapp.com wrote:
> From: Bryan Schumaker <bjschuma@netapp.com>
> 
> Compiling gave me this warning:
> fs/nfsd/nfs4xdr.c: In function ‘nfsd4_decode_bind_conn_to_session’:
> fs/nfsd/nfs4xdr.c:427:6: warning: variable ‘dummy’ set but not used
> [-Wunused-but-set-variable]
> 
> The local variable "dummy" wasn't being used past the READ32() macro that
> set it.  READ_BUF() should ensure that the xdr buffer is pushed past the
> data read into dummy already, so nothing needs to be read in.
> 
> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> ---
>  fs/nfsd/nfs4xdr.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index c6766af..6191eec 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -424,14 +424,12 @@ nfsd4_decode_access(struct nfsd4_compoundargs *argp, struct nfsd4_access *access
>  static __be32 nfsd4_decode_bind_conn_to_session(struct nfsd4_compoundargs *argp, struct nfsd4_bind_conn_to_session *bcts)
>  {
>  	DECODE_HEAD;
> -	u32 dummy;
>  
>  	READ_BUF(NFS4_MAX_SESSIONID_LEN + 8);
>  	COPYMEM(bcts->sessionid.data, NFS4_MAX_SESSIONID_LEN);
>  	READ32(bcts->dir);
>  	/* XXX: Perhaps Tom Tucker could help us figure out how we
>  	 * should be using ctsa_use_conn_in_rdma_mode: */
> -	READ32(dummy);

That leaves it unclear what the comment was referring to.... OK, fixed
that up and applied all 3 patches.  Thanks!

--b.

>  
>  	DECODE_TAIL;
>  }
> -- 
> 1.7.4.4
> 
