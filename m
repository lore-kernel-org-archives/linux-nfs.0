Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vn0-f42.google.com ([209.85.216.42]:46695 "EHLO
	mail-vn0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752818AbbFLOEz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jun 2015 10:04:55 -0400
Received: by vnbf7 with SMTP id f7so6132033vnb.13
        for <linux-nfs@vger.kernel.org>; Fri, 12 Jun 2015 07:04:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <557AE2E7.1090908@gmail.com>
References: <557AE2E7.1090908@gmail.com>
Date: Fri, 12 Jun 2015 10:04:54 -0400
Message-ID: <CAHQdGtSB9s6m12Y2pY+JYToLcak9Q-vw-ybC0-UbBPJQUd0P+A@mail.gmail.com>
Subject: Re: [PATCH] nfs: Fix showing truncated fsid/dev in /proc/net/nfsfs/volumes
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        David Howells <dhowells@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 12, 2015 at 9:47 AM, Kinglong Mee <kinglongmee@gmail.com> wrote:
> A truncated fsid showing from /proc/fs/nfsfs/volumes as,
> # cat /proc/fs/nfsfs/volumes
> NV SERVER   PORT DEV     FSID              FSC
> v4 c0a80881  801 0:43    34931f044c2a439b  no
>
> It should be as,
> # cat /proc/fs/nfsfs/volumes
> NV SERVER   PORT DEV          FSID                              FSC
> v4 c0a80881  801 0:43         34931f044c2a439b:954c5d830fa4be8c no
>
> The max buffer length for storing "%llx:%llx" format should be
>  16 + 1 + 16 + 1 = 34 (16 for %llx, 1 for ':', 1 for '\0').
>
> Also, for storing "%u:%u" of MAJOR() and MINOR() should be
>  8 + 1 + 3 + 1 = 13 (8 for 2^24, 1 for ':', 3 for 2^8, 1 for '\0').
>
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfs/client.c | 11 ++++++-----
>  1 file changed, 6 insertions(+), 5 deletions(-)
>
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 892aeff..873f194 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -1364,27 +1364,28 @@ static int nfs_volume_list_show(struct seq_file *m, void *v)
>  {
>         struct nfs_server *server;
>         struct nfs_client *clp;
> -       char dev[8], fsid[17];
> +       char dev[13], fsid[34];

Could use a comment to explain why these particular sizes.

>         struct nfs_net *nn = net_generic(seq_file_net(m), nfs_net_id);
>
>         /* display header on line 1 */
>         if (v == &nn->nfs_volume_list) {
> -               seq_puts(m, "NV SERVER   PORT DEV     FSID              FSC\n");
> +               seq_puts(m, "NV SERVER   PORT DEV          FSID"
> +                           "                              FSC\n");
>                 return 0;
>         }
>         /* display one transport per line on subsequent lines */
>         server = list_entry(v, struct nfs_server, master_link);
>         clp = server->nfs_client;
>
> -       snprintf(dev, 8, "%u:%u",
> +       snprintf(dev, 13, "%u:%u",

Is there any reason not to settle for using sizeof(dev) here?

>                  MAJOR(server->s_dev), MINOR(server->s_dev));
>
> -       snprintf(fsid, 17, "%llx:%llx",
> +       snprintf(fsid, 34, "%llx:%llx",

ditto

>                  (unsigned long long) server->fsid.major,
>                  (unsigned long long) server->fsid.minor);
>
>         rcu_read_lock();
> -       seq_printf(m, "v%u %s %s %-7s %-17s %s\n",
> +       seq_printf(m, "v%u %s %s %-12s %-33s %s\n",
>                    clp->rpc_ops->version,
>                    rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_HEX_ADDR),
>                    rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_HEX_PORT),
> --
> 2.4.3
>
