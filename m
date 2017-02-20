Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f51.google.com ([209.85.213.51]:35902 "EHLO
        mail-vk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750979AbdBTWiX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Feb 2017 17:38:23 -0500
Received: by mail-vk0-f51.google.com with SMTP id t8so69867135vke.3
        for <linux-nfs@vger.kernel.org>; Mon, 20 Feb 2017 14:38:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1487470070-32358-7-git-send-email-bfields@redhat.com>
References: <1487470070-32358-1-git-send-email-bfields@redhat.com> <1487470070-32358-7-git-send-email-bfields@redhat.com>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Mon, 20 Feb 2017 23:38:22 +0100
Message-ID: <CAHc6FU6FGPBXv0tu30wbChwdw3L7C7+aCjVxLrNfDB2N=MWk6w@mail.gmail.com>
Subject: Re: [PATCH 6/6] NFSv4: allow getacl rpc to allocate pages on demand
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Weston Andros Adamson <dros@primarydata.com>,
        Weston Andros Adamson <dros@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Feb 19, 2017 at 3:07 AM, J. Bruce Fields <bfields@redhat.com> wrote:
> From: Weston Andros Adamson <dros@netapp.com>
>
> Instead of preallocating pags, allow xdr_partial_copy_from_skb() to
> allocate whatever pages we need on demand.  This is what the NFSv3 ACL
> code does.
>
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
Reviewed-by: Andreas Gruenbacher <agreuenba@rdhat.com>

> ---
>  fs/nfs/nfs4proc.c | 23 +++++++----------------
>  1 file changed, 7 insertions(+), 16 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 3e3dbba4aa74..7842c73fddfc 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -5068,6 +5068,7 @@ static ssize_t nfs4_do_get_acl(struct inode *inode, void *buf, size_t buflen)
>         struct page *pages[NFS4ACL_MAXPAGES + 1] = {NULL, };
>         struct nfs_getaclargs args = {
>                 .fh = NFS_FH(inode),
> +               /* The xdr layer may allocate pages here. */
>                 .acl_pages = pages,
>         };
>         struct nfs_getaclres res = {
> @@ -5079,32 +5080,22 @@ static ssize_t nfs4_do_get_acl(struct inode *inode, void *buf, size_t buflen)
>                 .rpc_argp = &args,
>                 .rpc_resp = &res,
>         };
> -       unsigned int npages = DIV_ROUND_UP(buflen, PAGE_SIZE) + 1;
> -       int ret = -ENOMEM, i;
> -
> -       if (npages > ARRAY_SIZE(pages))
> -               return -ERANGE;
> -
> -       for (i = 0; i < npages; i++) {
> -               pages[i] = alloc_page(GFP_KERNEL);
> -               if (!pages[i])
> -                       goto out_free;
> -       }
> +       int ret, i;
>
>         /* for decoding across pages */
>         res.acl_scratch = alloc_page(GFP_KERNEL);
>         if (!res.acl_scratch)
> -               goto out_free;
> +               return -ENOMEM;
>
> -       args.acl_len = npages * PAGE_SIZE;
> +       args.acl_len = ARRAY_SIZE(pages) << PAGE_SHIFT;

Define acl_len directly in the args initializer instead of here.

> -       dprintk("%s  buf %p buflen %zu npages %d args.acl_len %zu\n",
> -               __func__, buf, buflen, npages, args.acl_len);
> +       dprintk("%s  buf %p buflen %zu args.acl_len %zu\n",
> +               __func__, buf, buflen, args.acl_len);
>         ret = nfs4_call_sync(NFS_SERVER(inode)->client, NFS_SERVER(inode),
>                              &msg, &args.seq_args, &res.seq_res, 0);
>         if (ret == 0)
>                 ret = res.acl_len;
> -out_free:
> +
>         for (i = 0; i < ARRAY_SIZE(pages) && pages[i]; i++)
>                 __free_page(pages[i]);
>         __free_page(res.acl_scratch);
> --
> 2.9.3
>
