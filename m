From: Michael Trimarchi <trimarchimichael-whZMOeQn8C0@public.gmane.org>
Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
Date: Wed, 17 Sep 2008 13:42:30 +0000 (GMT)
Message-ID: <93909.85868.qm@web26204.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org
To: Martin Knoblauch <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>,
	linux-nfs list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from web26204.mail.ukl.yahoo.com ([217.12.10.241]:42826 "HELO
	web26204.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752399AbYIQNmc convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Sep 2008 09:42:32 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

...

> Signed-off-by: Martin Knoblauch 
> 
> diff -urp linux-2.6.27-rc6-git4/fs/nfs/client.c 
> linux-2.6.27-rc6-git4-nfs_ra/fs/nfs/client.c
> --- linux-2.6.27-rc6-git4/fs/nfs/client.c       2008-09-17 11:35:21.000000000 
> +0200
> +++ linux-2.6.27-rc6-git4-nfs_ra/fs/nfs/client.c        2008-09-17 
> 11:55:18.000000000 +0200
> @@ -722,6 +722,11 @@ error:
> }
> 
> /*
> + * NFS Client Read-Ahead factor
> +*/
> +unsigned int nfs_ra_factor;
> +
> +/*
>   * Load up the server record from information gained in an fsinfo record
>   */
> static void nfs_server_set_fsinfo(struct nfs_server *server, struct nfs_fsinfo 
> *fsinfo)
> @@ -746,7 +751,11 @@ static void nfs_server_set_fsinfo(struct
>                 server->rsize = NFS_MAX_FILE_IO_SIZE;
>         server->rpages = (server->rsize + PAGE_CACHE_SIZE - 1) >> 
> PAGE_CACHE_SHIFT;
> 
> -       server->backing_dev_info.ra_pages = server->rpages * NFS_MAX_READAHEAD;
> +       dprintk("nfs_server_set_fsinfo: rsize, wsize, rpages, \
> +               nfs_ra_factor, ra_pages: %d %d %d %d %d\n",
> +               server->rsize,server->wsize,server->rpages,
> +               nfs_ra_factor,server->rpages * nfs_ra_factor);
> +       server->backing_dev_info.ra_pages = server->rpages * nfs_ra_factor;
> 
>         if (server->wsize > max_rpc_payload)
>                 server->wsize = max_rpc_payload;
> diff -urp linux-2.6.27-rc6-git4/fs/nfs/inode.c 
> linux-2.6.27-rc6-git4-nfs_ra/fs/nfs/inode.c
> --- linux-2.6.27-rc6-git4/fs/nfs/inode.c        2008-09-17 11:35:21.000000000 
> +0200
> +++ linux-2.6.27-rc6-git4-nfs_ra/fs/nfs/inode.c 2008-09-17 11:45:09.000000000 
> +0200
> @@ -53,6 +53,8 @@
> 
> /* Default is to see 64-bit inode numbers */
> static int enable_ino64 = NFS_64_BIT_INODE_NUMBERS_ENABLED;
> +static unsigned int ra_factor __read_mostly = NFS_MAX_READAHEAD;
> +
> 
> static void nfs_invalidate_inode(struct inode *);
> static int nfs_update_inode(struct inode *, struct nfs_fattr *);
> @@ -1347,6 +1349,12 @@ static int __init init_nfs_fs(void)
> #endif
>         if ((err = register_nfs_fs()) != 0)
>                 goto out;
> +
> +       if (ra_factor < 1 || ra_factor > NFS_MAX_READAHEAD)
> +               nfs_ra_factor = NFS_MAX_READAHEAD;
> +       else
> +               nfs_ra_factor = ra_factor;
> +

So, I think that this is not necessary because it is done ( ... I hope) by the 
proc_dointvec_minmax handler. It is correct?

Regards Michael

__________________________________________________
Do You Yahoo!?
Poco spazio e tanto spam? Yahoo! Mail ti protegge dallo spam e ti da tanto spazio gratuito per i tuoi file e i messaggi 
http://mail.yahoo.it 
