Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:28453 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751577AbaAGU7x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Jan 2014 15:59:53 -0500
Message-ID: <52CC6B31.4030803@RedHat.com>
Date: Tue, 07 Jan 2014 16:01:37 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Sander Klein <roedie@roedie.nl>, "J. Bruce Fields" <bfields@fieldses.org>
CC: Karel Zak <kzak@redhat.com>, linux-nfs@vger.kernel.org,
        linux-nfs-owner@vger.kernel.org
Subject: Re: rpc.mountd high cpu usage
References: <889b64df295ba04d47f941762ebe0bac@roedie.nl> <20131212154642.GA11521@fieldses.org> <20140106111805.GF4435@x2.net.home> <20140106212514.GG31764@fieldses.org> <0a94c641959a8084a56c688dd2242c04@roedie.nl>
In-Reply-To: <0a94c641959a8084a56c688dd2242c04@roedie.nl>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/01/14 14:55, Sander Klein wrote:
> Hi,
> 
> Thank you very much for this patch. I've added the ZFS magic and tested it on my nfs-utils-1.2.8 package and it looks like it fixes my issue.
> 
> Is there any chance this patch will be accepted upstream with the ZFS_SUPER_MAGIC as shown below?
It looks reasonable to me... I committed... 

steved.

> 
> Greets,
> 
> Sander
> 
> From e4f5b38c87ef8d713c6d0a3169afaf1acc7e22c6 Mon Sep 17 00:00:00 2001
> From: Karel Zak <kzak@redhat.com>
> Date: Mon, 6 Jan 2014 12:03:01 +0100
> Subject: [PATCH] mountd: optimize libblkid usage
> 
>  * use get_uuid_blkdev() only first time for the path (it means
>    that uuid_by_path() is called with type==0)
> 
>  * don't use libblkid for btrfs, network or pseudo filesystems
> 
> Note that the patch defines the fs type ID rather than include
> <linux/magic.h> as this file seems incomplete and libc specific).
> 
> Signed-off-by: Karel Zak <kzak@redhat.com>
> ---
>  utils/mountd/cache.c | 38 +++++++++++++++++++++++++++++++++++---
>  1 file changed, 35 insertions(+), 3 deletions(-)
> 
> Index: nfs-utils-1.2.8/utils/mountd/cache.c
> ===================================================================
> --- nfs-utils-1.2.8.orig/utils/mountd/cache.c    2013-05-02 14:21:12.000000000 +0200
> +++ nfs-utils-1.2.8/utils/mountd/cache.c    2014-01-07 20:46:55.799904557 +0100
> @@ -266,6 +266,27 @@
>      return 1;
>  }
> 
> +
> +/*
> + * Don't ask libblkid for these filesystems. Note that BTRF is ignored, because
> + * we generate the identifier from statfs->f_fsid. The rest are network or
> + * pseudo filesystems. (See <linux/magic.h> for the basic IDs.)
> + */
> +static const long int nonblkid_filesystems[] = {
> +    0x2fc12fc1,    /* ZFS_SUPER_MAGIC */
> +    0x9123683E,    /* BTRFS_SUPER_MAGIC */
> +    0xFF534D42,    /* CIFS_MAGIC_NUMBER */
> +    0x1373,        /* DEVFS_SUPER_MAGIC */
> +    0x73757245,    /* CODA_SUPER_MAGIC */
> +    0x564C,        /* NCP_SUPER_MAGIC */
> +    0x6969,        /* NFS_SUPER_MAGIC */
> +    0x9FA0,        /* PROC_SUPER_MAGIC */
> +    0x62656572,    /* SYSFS_MAGIC */
> +    0x517B,        /* SMB_SUPER_MAGIC */
> +    0x01021994,    /* TMPFS_SUPER_MAGIC */
> +    0        /* last */
> +};
> +
>  static int uuid_by_path(char *path, int type, size_t uuidlen, char *uuid)
>  {
>      /* get a uuid for the filesystem found at 'path'.
> @@ -297,12 +318,24 @@
>       */
>      struct statfs64 st;
>      char fsid_val[17];
> -    const char *blkid_val;
> +    const char *blkid_val = NULL;
>      const char *val;
> +    int rc;
> +
> +    rc = statfs64(path, &st);
> +
> +    if (type == 0 && rc == 0) {
> +        const long int *bad;
> 
> -    blkid_val = get_uuid_blkdev(path);
> +        for (bad = nonblkid_filesystems; *bad; bad++) {
> +            if (*bad == st.f_type)
> +                break;
> +        }
> +        if (*bad == 0)
> +            blkid_val = get_uuid_blkdev(path);
> +    }
> 
> -    if (statfs64(path, &st) == 0 &&
> +    if (rc == 0 &&
>          (st.f_fsid.__val[0] || st.f_fsid.__val[1]))
>          snprintf(fsid_val, 17, "%08x%08x",
>               st.f_fsid.__val[0], st.f_fsid.__val[1]);
> 
> -- 
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
