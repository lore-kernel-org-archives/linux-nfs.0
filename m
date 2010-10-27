Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:50130 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756560Ab0J0TtU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Oct 2010 15:49:20 -0400
Received: by eye27 with SMTP id 27so1044950eye.19
        for <linux-nfs@vger.kernel.org>; Wed, 27 Oct 2010 12:49:18 -0700 (PDT)
In-Reply-To: <1288203860-26920-1-git-send-email-bhalevy@panasas.com>
References: <4CC86D96.8020803@panasas.com>
	<1288203860-26920-1-git-send-email-bhalevy@panasas.com>
Date: Wed, 27 Oct 2010 15:49:18 -0400
Message-ID: <AANLkTikKpCO_xYjOpj74AiptyDjtMtJJhQaObksF_+LE@mail.gmail.com>
Subject: Re: [PATCH 3/3] SQUASHME: pnfs: filelayout: print_ds should use dprintk
From: Fred Isaman <iisaman@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The change to printk was in response to Trond's complaint about
successive dprintks.

Instead, the following would work:


diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 5f52e6f..2ce393c 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -585,7 +585,8 @@ filelayout_commit(struct nfs_write_data *data, int sync)
 		}
 		dprintk("%s: Initiating commit: %llu USE DS:\n",
 			__func__, file_offset);
-		print_ds(ds);
+		ifdebug(FACILITY)
+			print_ds(ds);

 		/* Send COMMIT to data server */
 		nfs_initiate_commit(dsdata, clnt, call_ops, sync);


Fred

On Wed, Oct 27, 2010 at 2:24 PM, Benny Halevy <bhalevy@panasas.com> wrote:
> rather than printk to prevent printouts in non-debug mode
> currently happening in filelayout_commit
>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/nfs4filelayoutdev.c |    9 ++++-----
>  1 files changed, 4 insertions(+), 5 deletions(-)
>
> diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
> index 1f0ab62..de47112 100644
> --- a/fs/nfs/nfs4filelayoutdev.c
> +++ b/fs/nfs/nfs4filelayoutdev.c
> @@ -53,10 +53,10 @@ void
>  print_ds(struct nfs4_pnfs_ds *ds)
>  {
>        if (ds == NULL) {
> -               printk("%s NULL device\n", __func__);
> +               dprintk("%s NULL device\n", __func__);
>                return;
>        }
> -       printk("        ip_addr %x port %hu\n"
> +       dprintk("        ip_addr %x port %hu\n"
>                "        ref count %d\n"
>                "        client %p\n"
>                "        cl_exchange_flags %x\n",
> @@ -71,7 +71,7 @@ print_ds_list(struct nfs4_file_layout_dsaddr *dsaddr)
>        int i;
>
>        ifdebug(FACILITY) {
> -               printk("%s dsaddr->ds_num %d\n", __func__,
> +               dprintk("%s dsaddr->ds_num %d\n", __func__,
>                       dsaddr->ds_num);
>                for (i = 0; i < dsaddr->ds_num; i++)
>                        print_ds(dsaddr->ds_list[i]);
> @@ -211,8 +211,7 @@ static void
>  destroy_ds(struct nfs4_pnfs_ds *ds)
>  {
>        dprintk("--> %s\n", __func__);
> -       ifdebug(FACILITY)
> -               print_ds(ds);
> +       print_ds(ds);
>
>        if (ds->ds_clp)
>                nfs_put_client(ds->ds_clp);
> --
> 1.7.2.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
