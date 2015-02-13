Return-Path: linux-kernel-owner@vger.kernel.org
Message-ID: <54DE3802.2000202@roeck-us.net>
Date: Fri, 13 Feb 2015 09:44:34 -0800
From: Guenter Roeck <linux@roeck-us.net>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Bas Peters <baspeters93@gmail.com>, hch@lst.de, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-next@vger.kernel.org,
        jim.epost@gmail.com
Subject: Re: [PATCH] fs: nfsd:xdr4.h: add missing conditional group CONFIG_NFSD_V3
References: <1423778953-28307-1-git-send-email-baspeters93@gmail.com> <20150212230201.GB17998@roeck-us.net> <20150213145121.GC6808@fieldses.org> <54DE2BE9.5030706@roeck-us.net> <20150213173348.GD6808@fieldses.org>
In-Reply-To: <20150213173348.GD6808@fieldses.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/13/2015 09:33 AM, J. Bruce Fields wrote:

>> Result is that every build with NFS configured but not NSFv3 is
>> now broken.
>
> Fortunately a v2-only server would be pretty unusual these days.
>
> I don't know, maybe this?
>
I applied the patch below on top of current mainline and passed it
to my build farm. I'll let you know how it goes.

Guenter

> --b.
>
> commit 535c381153631af3bc708a97e267a2a6a86ee030
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Fri Feb 13 12:27:39 2015 -0500
>
>      nfsd4: fix v3-less build
>
>      Includes of pnfs.h in export.c and fcntl.c also bring in xdr4.h, which
>      won't build without CONFIG_NFSD_V3, breaking non-V3 builds.  Ifdef-out
>      most of pnfs.h in that case.
>
>      Reported-by: Bas Peters <baspeters93@gmail.com>
>      Reported-by: Jim Davis <jim.epost@gmail.com>
>      Fixes: 9cf514ccfac "nfsd: implement pNFS operations"
>      Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>
> diff --git a/fs/nfsd/pnfs.h b/fs/nfsd/pnfs.h
> index fedb4d6..d4c4453 100644
> --- a/fs/nfsd/pnfs.h
> +++ b/fs/nfsd/pnfs.h
> @@ -1,6 +1,7 @@
>   #ifndef _FS_NFSD_PNFS_H
>   #define _FS_NFSD_PNFS_H 1
>
> +#ifdef CONFIG_NFSD_V4
>   #include <linux/exportfs.h>
>   #include <linux/nfsd/export.h>
>
> @@ -50,6 +51,7 @@ __be32 nfsd4_return_client_layouts(struct svc_rqst *rqstp,
>   int nfsd4_set_deviceid(struct nfsd4_deviceid *id, const struct svc_fh *fhp,
>   		u32 device_generation);
>   struct nfsd4_deviceid_map *nfsd4_find_devid_map(int idx);
> +#endif /* CONFIG_NFSD_V4 */
>
>   #ifdef CONFIG_NFSD_PNFS
>   void nfsd4_setup_layout_type(struct svc_export *exp);
> @@ -59,6 +61,9 @@ void nfsd4_return_all_file_layouts(struct nfs4_client *clp,
>   int nfsd4_init_pnfs(void);
>   void nfsd4_exit_pnfs(void);
>   #else
> +struct nfs4_client;
> +struct nfs4_file;
> +
>   static inline void nfsd4_setup_layout_type(struct svc_export *exp)
>   {
>   }
>

