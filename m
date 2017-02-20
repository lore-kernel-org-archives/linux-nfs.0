Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f48.google.com ([209.85.213.48]:35737 "EHLO
        mail-vk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750981AbdBTWij (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Feb 2017 17:38:39 -0500
Received: by mail-vk0-f48.google.com with SMTP id x75so69771084vke.2
        for <linux-nfs@vger.kernel.org>; Mon, 20 Feb 2017 14:38:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1487470070-32358-5-git-send-email-bfields@redhat.com>
References: <1487470070-32358-1-git-send-email-bfields@redhat.com> <1487470070-32358-5-git-send-email-bfields@redhat.com>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Mon, 20 Feb 2017 23:38:38 +0100
Message-ID: <CAHc6FU7Zif7GYQGxRT59aBKjtSxsB3T+mQsLNn0TR7WK+AWiLg@mail.gmail.com>
Subject: Re: [PATCH 4/6] NFSv4: minor getacl cleanup
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Weston Andros Adamson <dros@primarydata.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Feb 19, 2017 at 3:07 AM, J. Bruce Fields <bfields@redhat.com> wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
>
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
Reviewed-by: Andreas Gruenbacher <agreuenba@rdhat.com>

> ---
>  fs/nfs/nfs4proc.c | 8 +++-----
>  1 file changed, 3 insertions(+), 5 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index a4e33e519f6e..eb6c34db9a79 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -5134,11 +5134,9 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
>  out_ok:
>         ret = res.acl_len;
>  out_free:
> -       for (i = 0; i < npages; i++)
> -               if (pages[i])
> -                       __free_page(pages[i]);
> -       if (res.acl_scratch)
> -               __free_page(res.acl_scratch);
> +       for (i = 0; i < ARRAY_SIZE(pages) && pages[i]; i++)
> +               __free_page(pages[i]);
> +       __free_page(res.acl_scratch);
>         return ret;
>  }
>
> --
> 2.9.3
>
