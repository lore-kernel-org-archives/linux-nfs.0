Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60683 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751844AbaC2TrA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 29 Mar 2014 15:47:00 -0400
Date: Sat, 29 Mar 2014 15:46:59 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] NFSD: Clear wcc data between compound ops
Message-ID: <20140329194659.GF11085@fieldses.org>
References: <533299E9.6010806@gmail.com>
 <20140328211920.GD6041@fieldses.org>
 <5335FAB2.8050404@gmail.com>
 <20140329005831.GO6041@fieldses.org>
 <53362EB3.2040809@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <53362EB3.2040809@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Mar 29, 2014 at 10:23:47AM +0800, Kinglong Mee wrote:
> Testing NFS4.0 by pynfs, I got some messeages as,
> "nfsd: inode locked twice during operation."
> 
> When one compound RPC contains two or more ops that locks
> the filehandle,the second op will cause the message.
> 
> As two SETATTR ops, after the first SETATTR, nfsd will not call
> fh_put() to release current filehandle, it means filehandle have
> unlocked with fh_post_saved = 1.
> The second SETATTR find fh_post_saved = 1, and printk the message.
> 
> v2: introduce helper fh_clear_wcc().

Thanks, applying.--b.

> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4proc.c |  2 ++
>  fs/nfsd/nfsfh.h    | 14 +++++++++++++-
>  2 files changed, 15 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 550faf2..9849c61 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1358,6 +1358,8 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
>  			goto encode_op;
>  		}
> 
> +		fh_clear_wcc(current_fh);
> +
>  		/* If op is non-idempotent */
>  		if (opdesc->op_flags & OP_MODIFIES_SOMETHING) {
>  			plen = opdesc->op_rsize_bop(rqstp, op);
> diff --git a/fs/nfsd/nfsfh.h b/fs/nfsd/nfsfh.h
> index 4775bc4..ad67964 100644
> --- a/fs/nfsd/nfsfh.h
> +++ b/fs/nfsd/nfsfh.h
> @@ -133,6 +133,17 @@ fh_init(struct svc_fh *fhp, int maxsize)
> 
>  #ifdef CONFIG_NFSD_V3
>  /*
> + * The wcc data stored in current_fh should be cleared
> + * between compound ops.
> + */
> +static inline void
> +fh_clear_wcc(struct svc_fh *fhp)
> +{
> +	fhp->fh_post_saved = 0;
> +	fhp->fh_pre_saved = 0;
> +}
> +
> +/*
>   * Fill in the pre_op attr for the wcc data
>   */
>  static inline void
> @@ -152,7 +163,8 @@ fill_pre_wcc(struct svc_fh *fhp)
> 
>  extern void fill_post_wcc(struct svc_fh *);
>  #else
> -#define	fill_pre_wcc(ignored)
> +#define fh_clear_wcc(ignored)
> +#define fill_pre_wcc(ignored)
>  #define fill_post_wcc(notused)
>  #endif /* CONFIG_NFSD_V3 */
> 
> -- 
> 1.9.0
> 
