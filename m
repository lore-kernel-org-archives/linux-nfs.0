Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:35677 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751545AbdFIU6R (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Jun 2017 16:58:17 -0400
Received: by mail-qt0-f193.google.com with SMTP id x58so17674887qtc.2
        for <linux-nfs@vger.kernel.org>; Fri, 09 Jun 2017 13:58:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170608165554.54102-1-kolga@netapp.com>
References: <20170608165554.54102-1-kolga@netapp.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 9 Jun 2017 16:58:16 -0400
Message-ID: <CAN-5tyHUJW85oxaX81Zr3Drp5WFv05-tWWXGcKCQh5S+1VZ7JQ@mail.gmail.com>
Subject: Re: [PATCH 1/1] PNFS fix dangling DS mount
To: Olga Kornievskaia <kolga@netapp.com>
Cc: Trond Myklebust <Trond.Myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 8, 2017 at 12:55 PM, Olga Kornievskaia <kolga@netapp.com> wrote:
> There is a regression by commit 8d40b0f14846 ("NFS filelayout:call
> GETDEVICEINFO after pnfs_layout_process completes"). It leaves the
> DS mount dangling.
>
> Previously, filelayout_alloc_sec() would call filelayout_check_layout()
> which would call nfs4_find_get_deviceid which ups the count on the
> device_id. It's only called once and it's matched by the
> filelayout_free_lseg() that calls nfs4_fl_put_deviceid().
>
> After that patch, each read/write ends up calling nfs4_find_get_deviceid
> and there is no balance for that. Instead, do nfs4_fl_put_deviceid()
> in the filelayout's .pg_cleanup and remove it from filelayout_free_lseg.
>
> Fixes: 8d40b0f14846 ("NFS filelayout:call GETDEVICEINFO after pnfs_layout_process completes")
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfs/filelayout/filelayout.c | 16 +++++++++++++---
>  1 file changed, 13 insertions(+), 3 deletions(-)
>
> diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
> index acd30ba..3c6d043 100644
> --- a/fs/nfs/filelayout/filelayout.c
> +++ b/fs/nfs/filelayout/filelayout.c
> @@ -763,7 +763,6 @@ static void _filelayout_free_lseg(struct nfs4_filelayout_segment *fl)
>         struct nfs4_filelayout_segment *fl = FILELAYOUT_LSEG(lseg);
>
>         dprintk("--> %s\n", __func__);
> -       nfs4_fl_put_deviceid(fl->dsaddr);
>         /* This assumes a single RW lseg */
>         if (lseg->pls_range.iomode == IOMODE_RW) {
>                 struct nfs4_filelayout *flo;
> @@ -989,18 +988,29 @@ static void _filelayout_free_lseg(struct nfs4_filelayout_segment *fl)
>         nfs_pageio_reset_write_mds(pgio);
>  }
>
> +static void filelayout_pg_cleanup(struct nfs_pageio_descriptor *desc)
> +{
> +       if (desc->pg_lseg) {
> +               struct nfs4_filelayout_segment *fl =
> +                       FILELAYOUT_LSEG(desc->pg_lseg);
> +
> +               nfs4_fl_put_deviceid(fl->dsaddr);
> +       }
> +       pnfs_generic_pg_cleanup(desc);
> +}
> +
>  static const struct nfs_pageio_ops filelayout_pg_read_ops = {
>         .pg_init = filelayout_pg_init_read,
>         .pg_test = filelayout_pg_test,
>         .pg_doio = pnfs_generic_pg_readpages,
> -       .pg_cleanup = pnfs_generic_pg_cleanup,
> +       .pg_cleanup = filelayout_pg_cleanup,
>  };
>
>  static const struct nfs_pageio_ops filelayout_pg_write_ops = {
>         .pg_init = filelayout_pg_init_write,
>         .pg_test = filelayout_pg_test,
>         .pg_doio = pnfs_generic_pg_writepages,
> -       .pg_cleanup = pnfs_generic_pg_cleanup,
> +       .pg_cleanup = filelayout_pg_cleanup,
>  };
>
>  static u32 select_bucket_index(struct nfs4_filelayout_segment *fl, u32 j)
> --
> 1.8.3.1

Needs to do a bit more. It fixes a dangling mount on non-error case.
But on server reboots it leads to ref count imbalance again.
