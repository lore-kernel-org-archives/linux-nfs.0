Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f175.google.com ([209.85.216.175]:33213 "EHLO
        mail-qt0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751416AbdLFMXO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Dec 2017 07:23:14 -0500
Received: by mail-qt0-f175.google.com with SMTP id e2so8484905qti.0
        for <linux-nfs@vger.kernel.org>; Wed, 06 Dec 2017 04:23:14 -0800 (PST)
Message-ID: <1512562990.4048.7.camel@redhat.com>
Subject: Re: [RFC v4 7/9] NFS: Add transient mount option
From: Jeff Layton <jlayton@redhat.com>
To: Joshua Watt <jpewhacker@gmail.com>, NeilBrown <neilb@suse.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J . Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        David Howells <dhowells@redhat.com>
Date: Wed, 06 Dec 2017 07:23:10 -0500
In-Reply-To: <20171117174552.18722-8-JPEWhacker@gmail.com>
References: <20171117174552.18722-1-JPEWhacker@gmail.com>
         <20171117174552.18722-8-JPEWhacker@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-11-17 at 11:45 -0600, Joshua Watt wrote:
> The "transient" option is used to indicate that the server might
> disappear unexpectedly, and a more aggressive behavior should be use to
> force unmount it. It implies "nosharecache"
> 
> Signed-off-by: Joshua Watt <JPEWhacker@gmail.com>
> ---
>  fs/nfs/super.c                 | 13 ++++++++++++-
>  include/uapi/linux/nfs_mount.h |  1 +
>  2 files changed, 13 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 71361ca6d6b4..09c413c098ef 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -90,6 +90,7 @@ enum {
>  	Opt_resvport, Opt_noresvport,
>  	Opt_fscache, Opt_nofscache,
>  	Opt_migration, Opt_nomigration,
> +	Opt_transient, Opt_notransient,
>  
>  	/* Mount options that take integer arguments */
>  	Opt_port,
> @@ -151,6 +152,8 @@ static const match_table_t nfs_mount_option_tokens = {
>  	{ Opt_nofscache, "nofsc" },
>  	{ Opt_migration, "migration" },
>  	{ Opt_nomigration, "nomigration" },
> +	{ Opt_transient, "transient" },
> +	{ Opt_notransient, "notransient" },
>  
>  	{ Opt_port, "port=%s" },
>  	{ Opt_rsize, "rsize=%s" },
> @@ -638,6 +641,7 @@ static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
>  		{ NFS_MOUNT_NORDIRPLUS, ",nordirplus", "" },
>  		{ NFS_MOUNT_UNSHARED, ",nosharecache", "" },
>  		{ NFS_MOUNT_NORESVPORT, ",noresvport", "" },
> +		{ NFS_MOUNT_TRANSIENT, ",transient", "" },
>  		{ 0, NULL, NULL }
>  	};
>  	const struct proc_nfs_info *nfs_infop;
> @@ -1329,7 +1333,8 @@ static int nfs_parse_mount_options(char *raw,
>  			mnt->flags |= NFS_MOUNT_NORDIRPLUS;
>  			break;
>  		case Opt_sharecache:
> -			mnt->flags &= ~NFS_MOUNT_UNSHARED;
> +			mnt->flags &= ~(NFS_MOUNT_UNSHARED |
> +					NFS_MOUNT_TRANSIENT);
>  			break;
>  		case Opt_nosharecache:
>  			mnt->flags |= NFS_MOUNT_UNSHARED;
> @@ -1356,6 +1361,12 @@ static int nfs_parse_mount_options(char *raw,
>  		case Opt_nomigration:
>  			mnt->options &= ~NFS_OPTION_MIGRATION;
>  			break;
> +		case Opt_transient:
> +			mnt->flags |= NFS_MOUNT_TRANSIENT | NFS_MOUNT_UNSHARED;
> +			break;
> +		case Opt_notransient:
> +			mnt->flags &= ~NFS_MOUNT_TRANSIENT;
> +			break;
>  
>  		/*
>  		 * options that take numeric values
> diff --git a/include/uapi/linux/nfs_mount.h b/include/uapi/linux/nfs_mount.h
> index e44e00616ab5..6067a9449d9f 100644
> --- a/include/uapi/linux/nfs_mount.h
> +++ b/include/uapi/linux/nfs_mount.h
> @@ -74,5 +74,6 @@ struct nfs_mount_data {
>  
>  #define NFS_MOUNT_LOCAL_FLOCK	0x100000
>  #define NFS_MOUNT_LOCAL_FCNTL	0x200000
> +#define NFS_MOUNT_TRANSIENT	0x400000
>  
>  #endif


I can't say I'm a fan of this new mount option.

Under what circumstances would I, as an admin, use this thing? Note too
that nosharecache is not without cost, so this option will have costs as
well. That will need to be documented of course.

I tend to think that stuck mounts are not something one usually
anticipates before it occurs. Requiring a mount option to give you an
out for it is probably not going to be as helpful as we'd like.
-- 
Jeff Layton <jlayton@redhat.com>
