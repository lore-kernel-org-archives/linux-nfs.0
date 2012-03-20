Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:11785 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754655Ab2CTNxY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Mar 2012 09:53:24 -0400
Message-ID: <4F688BCB.3090306@netapp.com>
Date: Tue, 20 Mar 2012 09:53:15 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Weston Andros Adamson <dros@netapp.com>
CC: Trond.Myklebust@netapp.com, chuck.lever@oracle.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: add filehandle crc for debug display
References: <1331084803-21460-1-git-send-email-dros@netapp.com>
In-Reply-To: <1331084803-21460-1-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Dros,

On 03/06/2012 08:46 PM, Weston Andros Adamson wrote:

> Match wireshark's CRC-32 hash for easier debugging
> 
> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> ---
> Reposted with Trond's suggestion of splitting out hash calculation to a 
> separate function.  Now dprintks can use a fh's CRC instead of the 
> multiline nfs_display_fhandle() when it makes sense.
> 
>  fs/nfs/inode.c         |   23 ++++++++++++++++++++---
>  include/linux/nfs_fs.h |    8 ++++++++
>  2 files changed, 28 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 99a4f52..3919ceb 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -39,6 +39,7 @@
>  #include <linux/slab.h>
>  #include <linux/compat.h>
>  #include <linux/freezer.h>
> +#include <linux/crc32.h>
>  
>  #include <asm/system.h>
>  #include <asm/uaccess.h>
> @@ -1045,7 +1046,23 @@ struct nfs_fh *nfs_alloc_fhandle(void)
>  	return fh;
>  }
>  
> -/**
> +#ifdef RPC_DEBUG
> +/*
> + * _nfs_display_fhandle_hash - calculate the crc32 hash for the filehandle
> + *                             in the same way that wireshark does
> + *
> + * @fh: file handle
> + *
> + * For debugging only.
> + */
> +u32 _nfs_display_fhandle_hash(const struct nfs_fh *fh)
> +{
> +	/* wireshark uses 32-bit AUTODIN crc and does a bitwise
> +	 * not on the result */
> +	return ~crc32(0xFFFFFFFF, &fh->data[0], fh->size);
> +}
> +
> +/*
>   * _nfs_display_fhandle - display an NFS file handle on the console
>   *
>   * @fh: file handle to display
> @@ -1053,7 +1070,6 @@ struct nfs_fh *nfs_alloc_fhandle(void)
>   *
>   * For debugging only.
>   */
> -#ifdef RPC_DEBUG
>  void _nfs_display_fhandle(const struct nfs_fh *fh, const char *caption)
>  {
>  	unsigned short i;
> @@ -1063,7 +1079,8 @@ void _nfs_display_fhandle(const struct nfs_fh *fh, const char *caption)
>  		return;
>  	}
>  
> -	printk(KERN_DEFAULT "%s at %p is %u bytes:\n", caption, fh, fh->size);
> +	printk(KERN_DEFAULT "%s at %p is %u bytes, crc: 0x%08x:\n",
> +	       caption, fh, fh->size, _nfs_display_fhandle_hash(fh));
>  	for (i = 0; i < fh->size; i += 16) {
>  		__be32 *pos = (__be32 *)&fh->data[i];
>  
> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
> index c07a757..ce8e436 100644
> --- a/include/linux/nfs_fs.h
> +++ b/include/linux/nfs_fs.h
> @@ -396,6 +396,11 @@ static inline void nfs_free_fhandle(const struct nfs_fh *fh)
>  }
>  
>  #ifdef RPC_DEBUG
> +extern u32 _nfs_display_fhandle_hash(const struct nfs_fh *fh);
> +static inline u32 nfs_display_fhandle_hash(const struct nfs_fh *fh)
> +{
> +	return _nfs_display_fhandle_hash(fh);
> +}
>  extern void _nfs_display_fhandle(const struct nfs_fh *fh, const char *caption);
>  #define nfs_display_fhandle(fh, caption)			\
>  	do {							\
> @@ -403,6 +408,9 @@ extern void _nfs_display_fhandle(const struct nfs_fh *fh, const char *caption);
>  			_nfs_display_fhandle(fh, caption);	\
>  	} while (0)
>  #else
> +static inline u32 nfs_display_fhandle_hash(const struct nfs_fh *fh)
> +{


This function should return something... maybe 0?

- Bryan

> +}
>  static inline void nfs_display_fhandle(const struct nfs_fh *fh,
>  				       const char *caption)
>  {


