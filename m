Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43736 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750729AbbD2T4Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Apr 2015 15:56:24 -0400
Date: Wed, 29 Apr 2015 15:56:23 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/4] nfs: define NFS4_MAXTAGLEN to OPAQUE limits
Message-ID: <20150429195623.GC23980@fieldses.org>
References: <5516CCDB.4020509@gmail.com>
 <5516CD45.7060200@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5516CD45.7060200@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Mar 28, 2015 at 11:48:21PM +0800, Kinglong Mee wrote:
> According to rfc3530 and rfc5661, the max tag length should be
> limited by opaque limited.
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfs/nfs4xdr.c     | 7 -------
>  include/linux/nfs4.h | 1 +
>  2 files changed, 1 insertion(+), 7 deletions(-)
> 
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 5c399ec..1c2ad01 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -67,13 +67,6 @@
>  
>  static int nfs4_stat_to_errno(int);
>  
> -/* NFSv4 COMPOUND tags are only wanted for debugging purposes */
> -#ifdef DEBUG
> -#define NFS4_MAXTAGLEN		20
> -#else
> -#define NFS4_MAXTAGLEN		0
> -#endif

As far as I can tell, DEBUG is never defined, and there's no logic
elsewhere that could actually make use of the tag if DEBUG was defined.

So maybe simplest would be just to remove the DEBUG case and leave

	#define NFS4_MAXTAGLEN	0

--b.

> -
>  /* lock,open owner id:
>   * we currently use size 2 (u64) out of (NFS4_OPAQUE_LIMIT  >> 2)
>   */
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index ed43cb7..ba54ec2 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -33,6 +33,7 @@ struct nfs4_acl {
>  };
>  
>  #define NFS4_MAXLABELLEN	2048
> +#define NFS4_MAXTAGLEN		NFS4_OPAQUE_LIMIT
>  
>  struct nfs4_label {
>  	uint32_t	lfs;
> -- 
> 2.3.4
