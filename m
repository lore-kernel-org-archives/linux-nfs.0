Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:48951 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757862Ab3HMTw0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Aug 2013 15:52:26 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 02/10] NFS: refactor code for calculating the crc32 hash
 of a filehandle
Date: Tue, 13 Aug 2013 19:52:25 +0000
Message-ID: <60B814F0-8EED-466E-B06E-4EAB9809B541@netapp.com>
References: <1376418952-12481-1-git-send-email-Trond.Myklebust@netapp.com>
 <1376418952-12481-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1376418952-12481-2-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I think I was the last one to touch this.

On Aug 13, 2013, at 2:35 PM, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> We want to be able to display the crc32 hash of the filehandle in
> tracepoints.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> fs/nfs/inode.c    |  3 +--
> fs/nfs/internal.h | 20 ++++++++++++++++++++
> 2 files changed, 21 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index af6e806..9a98b04 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -38,7 +38,6 @@
> #include <linux/slab.h>
> #include <linux/compat.h>
> #include <linux/freezer.h>
> -#include <linux/crc32.h>
> 
> #include <asm/uaccess.h>
> 
> @@ -1190,7 +1189,7 @@ u32 _nfs_display_fhandle_hash(const struct nfs_fh *fh)
> {
> 	/* wireshark uses 32-bit AUTODIN crc and does a bitwise
> 	 * not on the result */
> -	return ~crc32(0xFFFFFFFF, &fh->data[0], fh->size);
> +	return nfs_fhandle_hash(fh);
> }
> 
> /*
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index 9b694f1..50f7068 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -5,6 +5,7 @@
> #include "nfs4_fs.h"
> #include <linux/mount.h>
> #include <linux/security.h>
> +#include <linux/crc32.h>
> 
> #define NFS_MS_MASK (MS_RDONLY|MS_NOSUID|MS_NODEV|MS_NOEXEC|MS_SYNCHRONOUS)
> 
> @@ -574,3 +575,22 @@ u64 nfs_timespec_to_change_attr(const struct timespec *ts)
> {
> 	return ((u64)ts->tv_sec << 30) + ts->tv_nsec;
> }
> +
> +#ifdef CONFIG_CRC32

Good catch!

> +/**
> + * nfs_fhandle_hash - calculate the crc32 hash for the filehandle
> + * @fh - pointer to filehandle
> + *
> + * returns a crc32 hash for the filehandle that is compatible with
> + * the one displayed by "wireshark".
> + */
> +static inline u32 nfs_fhandle_hash(const struct nfs_fh *fh)
> +{
> +	return ~crc32_le(0xFFFFFFFF, &fh->data[0], fh->size);

Why the change to crc32_le? Is that what wireshark does? I don't remember exactly what I found when I looked at how wireshark made FH hashes.

-dros

> +}
> +#else
> +static inline u32 nfs_fhandle_hash(const struct nfs_fh *fh)
> +{
> +	return 0;
> +}
> +#endif
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

