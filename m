Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f52.google.com ([209.85.216.52]:61563 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752629AbaIKOb1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Sep 2014 10:31:27 -0400
Received: by mail-qa0-f52.google.com with SMTP id m5so2548843qaj.11
        for <linux-nfs@vger.kernel.org>; Thu, 11 Sep 2014 07:31:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1410362617-28018-9-git-send-email-hch@lst.de>
References: <1410362617-28018-1-git-send-email-hch@lst.de> <1410362617-28018-9-git-send-email-hch@lst.de>
From: Peng Tao <bergwolf@primarydata.com>
Date: Thu, 11 Sep 2014 22:24:04 +0800
Message-ID: <CAKVebiUqhCVy4jyzccBOXcHo3dkQNXjF0WsP1sHkOMkdnEAG9Q@mail.gmail.com>
Subject: Re: [PATCH 8/9] pnfs/blocklayout: return layouts on setattr
To: Christoph Hellwig <hch@lst.de>, Boaz Harrosh <boaz@plexistor.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 10, 2014 at 11:23 PM, Christoph Hellwig <hch@lst.de> wrote:
> This speads up truncate-heavy workloads like fsx by multiple orders of
> magnitude.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfs/blocklayout/blocklayout.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
> index a7524c4..d5a2b87 100644
> --- a/fs/nfs/blocklayout/blocklayout.c
> +++ b/fs/nfs/blocklayout/blocklayout.c
> @@ -799,7 +799,8 @@ static struct pnfs_layoutdriver_type blocklayout_type = {
>         .id                             = LAYOUT_BLOCK_VOLUME,
>         .name                           = "LAYOUT_BLOCK_VOLUME",
>         .owner                          = THIS_MODULE,
> -       .flags                          = PNFS_READ_WHOLE_PAGE,
> +       .flags                          = PNFS_LAYOUTRET_ON_SETATTR |
> +                                         PNFS_READ_WHOLE_PAGE,
The reason I didn't add it was because PNFS_LAYOUTRET_ON_SETATTR is
too much for blocks layout. What we really want is to return layouts
on truncate and chown, instead of _all_ setattr requests.

Boaz, does object layout require return on setattr for other reasons?
If not, I'd suggest we change PNFS_LAYOUTRET_ON_SETATTR to return only
on chown/truncate events.

Thanks,
Tao
