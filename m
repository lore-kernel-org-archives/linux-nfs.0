Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:38990 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756336Ab2D3R3B convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Apr 2012 13:29:01 -0400
Received: by vcqp1 with SMTP id p1so2199512vcq.19
        for <linux-nfs@vger.kernel.org>; Mon, 30 Apr 2012 10:29:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1335805613-23138-1-git-send-email-bjschuma@netapp.com>
References: <1335805613-23138-1-git-send-email-bjschuma@netapp.com>
Date: Mon, 30 Apr 2012 13:29:01 -0400
Message-ID: <CADnza47DxqkuX1gc1T8jNuhu9s_vXWHdNBREOm6h1eS-sR4k8A@mail.gmail.com>
Subject: Re: [PATCH] NFS: pnfs_pageio_init_read() and init_write() need an
 extra argument
From: Fred Isaman <iisaman@netapp.com>
To: bjschuma@netapp.com
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

ACK

Fred

On Mon, Apr 30, 2012 at 1:06 PM,  <bjschuma@netapp.com> wrote:
> From: Bryan Schumaker <bjschuma@netapp.com>
>
> This is only when CONFIG_NFS_V4_1 isn't enabled.
>
> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> ---
>  fs/nfs/pnfs.h |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 8efbee7..f20054b 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -424,12 +424,14 @@ static inline void unset_pnfs_layoutdriver(struct nfs_server *s)
>  {
>  }
>
> -static inline bool pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, struct inode *inode)
> +static inline bool pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, struct inode *inode,
> +                                        const struct nfs_pgio_completion_ops *compl_ops)
>  {
>        return false;
>  }
>
> -static inline bool pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode, int ioflags)
> +static inline bool pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode, int ioflags,
> +                                         const struct nfs_pgio_completion_ops *compl_ops)
>  {
>        return false;
>  }
> --
> 1.7.10
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
