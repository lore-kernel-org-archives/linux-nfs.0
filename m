From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 3/3] nfs-utils: Add nonegde mount option
Date: Tue, 15 Jan 2008 11:42:54 -0500
Message-ID: <243A7D1D-E2DB-4669-8E19-6D07D03144FF@oracle.com>
References: <20080115163130.GD18911@newbie.thebellsplace.net>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Bob Bell <b_linuxnfs-Y/+76LoPTq9wBoktGHYdvgC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:54782 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801AbYAOQn7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jan 2008 11:43:59 -0500
In-Reply-To: <20080115163130.GD18911-y89O8yXFYpDSsb2jM9SCN5/hYUUxywnI@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 15, 2008, at 11:31 AM, Bob Bell wrote:
> From: Bob Bell <bell_robert@emc.com>
>
> Support a "nonegde" mount option to match the new NFS_MOUNT_NONEGDE  
> flag.
>
> Signed-off-by: Bob Bell <bell_robert@emc.com>
> ---
> utils/mount/nfs.man     |   18 ++++++++++++++++++
> utils/mount/nfs_mount.h |   31 ++++++++++++++++---------------
> utils/mount/nfsmount.c  |    9 +++++++--
> 3 files changed, 41 insertions(+), 17 deletions(-)
>
> diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
> index 2c0b687..b0a885a 100644
> --- a/utils/mount/nfs.man
> +++ b/utils/mount/nfs.man
> @@ -613,6 +613,24 @@ If this option is not specified, the NFS  
> client uses READDIRPLUS requests
> on NFS version 3 mounts to read small directories.
> Some applications perform better if the client uses only READDIR  
> requests
> for all directories.  +.TP 1.5i
> +.BR negde " / " nonegde
> +Selects whether to cache negative dentries,
> +which record the non-existence of a file.
> +If neither option is specified (or if +.B negde
> +is specified),
> +each negative dentry will be kept in the kernel dcache until it is  
> invalidated
> +when a change is detected in its parent directory,
> +or until sufficient memory pressure forces it out.
> +.IP
> +Using the
> +.B nonegde
> +option may be helpful if the NFS server does not provide
> +sufficiently fine-grained timestamps to consistently distinguish  
> when the
> +contents of a directory have been updated.  However, by not  
> caching negative
> +dentries, the client will have to contact the server whenever  
> there is an
> +attempt to access a previously non-existent file, which may impact  
> performance.
> .SS "Valid options for the nfs4 file system type"
> Use these options, along with the options in the first subsection  
> above,
> for mounting the
> diff --git a/utils/mount/nfs_mount.h b/utils/mount/nfs_mount.h
> index 7df8fb2..2deca87 100644
> --- a/utils/mount/nfs_mount.h
> +++ b/utils/mount/nfs_mount.h
> @@ -50,21 +50,22 @@ struct nfs_mount_data {
> /* bits in the flags field */
> -#define NFS_MOUNT_SOFT		0x0001	/* 1 */
> -#define NFS_MOUNT_INTR		0x0002	/* 1 */
> -#define NFS_MOUNT_SECURE	0x0004	/* 1 */
> -#define NFS_MOUNT_POSIX		0x0008	/* 1 */
> -#define NFS_MOUNT_NOCTO		0x0010	/* 1 */
> -#define NFS_MOUNT_NOAC		0x0020	/* 1 */
> -#define NFS_MOUNT_TCP		0x0040	/* 2 */
> -#define NFS_MOUNT_VER3		0x0080	/* 3 */
> -#define NFS_MOUNT_KERBEROS	0x0100	/* 3 */
> -#define NFS_MOUNT_NONLM		0x0200	/* 3 */
> -#define NFS_MOUNT_BROKEN_SUID	0x0400	/* 4 */
> -#define NFS_MOUNT_NOACL     0x0800  /* 4 */
> -#define NFS_MOUNT_SECFLAVOUR	0x2000	/* 5 */
> -#define NFS_MOUNT_NORDIRPLUS	0x4000	/* 5 */
> -#define NFS_MOUNT_UNSHARED	0x8000	/* 5 */
> +#define NFS_MOUNT_SOFT		0x00001	/* 1 */
> +#define NFS_MOUNT_INTR		0x00002	/* 1 */
> +#define NFS_MOUNT_SECURE	0x00004	/* 1 */
> +#define NFS_MOUNT_POSIX		0x00008	/* 1 */
> +#define NFS_MOUNT_NOCTO		0x00010	/* 1 */
> +#define NFS_MOUNT_NOAC		0x00020	/* 1 */
> +#define NFS_MOUNT_TCP		0x00040	/* 2 */
> +#define NFS_MOUNT_VER3		0x00080	/* 3 */
> +#define NFS_MOUNT_KERBEROS	0x00100	/* 3 */
> +#define NFS_MOUNT_NONLM		0x00200	/* 3 */
> +#define NFS_MOUNT_BROKEN_SUID	0x00400	/* 4 */
> +#define NFS_MOUNT_NOACL		0x00800	/* 4 */
> +#define NFS_MOUNT_SECFLAVOUR	0x02000	/* 5 */
> +#define NFS_MOUNT_NORDIRPLUS	0x04000	/* 5 */
> +#define NFS_MOUNT_UNSHARED	0x08000	/* 5 */
> +#define NFS_MOUNT_NONEGDE	0x10000	/* 5 */

Why is the patch replacing all the flag definitions?  Did you check  
for inadvertent white space damage?

> /* security pseudoflavors */
> diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
> index 23dd2f6..81ab371 100644
> --- a/utils/mount/nfsmount.c
> +++ b/utils/mount/nfsmount.c
> @@ -422,6 +422,10 @@ parse_options(char *old_opts, struct  
> nfs_mount_data *data,
> 				if (!val)
> 					data->flags |= NFS_MOUNT_UNSHARED;
> #endif
> +			} else if (!strcmp(opt, "negde")) {
> +				data->flags &= ~NFS_MOUNT_NONEGDE;
> +				if (!val)
> +					data->flags |= NFS_MOUNT_NONEGDE;
> 			} else {
> 			bad_option:
> 				if (sloppy)
> @@ -595,12 +599,13 @@ nfsmount(const char *spec, const char *node,  
> int flags,
> 	printf(_("mountprog = %lu, mountvers = %lu, nfsprog = %lu, nfsvers  
> = %lu\n"),
> 	       mnt_pmap->pm_prog, mnt_pmap->pm_vers,
> 	       nfs_pmap->pm_prog, nfs_pmap->pm_vers);
> -	printf(_("soft = %d, intr = %d, posix = %d, nocto = %d, noac = %d"),
> +	printf(_("soft = %d, intr = %d, posix = %d, nocto = %d, noac = % 
> d, nonegde = %d"),
> 	       (data.flags & NFS_MOUNT_SOFT) != 0,
> 	       (data.flags & NFS_MOUNT_INTR) != 0,
> 	       (data.flags & NFS_MOUNT_POSIX) != 0,
> 	       (data.flags & NFS_MOUNT_NOCTO) != 0,
> -	       (data.flags & NFS_MOUNT_NOAC) != 0);
> +	       (data.flags & NFS_MOUNT_NOAC) != 0,
> +	       (data.flags & NFS_MOUNT_NONEGDE) != 0);
> #if NFS_MOUNT_VERSION >= 2
> 	printf(_(", tcp = %d"),
> 	       (data.flags & NFS_MOUNT_TCP) != 0);
> -
> To unsubscribe from this list: send the line "unsubscribe linux- 
> nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


As I understand it, we aren't adding new options to the legacy part  
of the nfs-utils mount command any longer.  Instead, add support for  
the option in the kernel's NFS mount option parser in fs/nfs/super.c.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
