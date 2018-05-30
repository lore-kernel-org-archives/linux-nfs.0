Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f196.google.com ([209.85.217.196]:38015 "EHLO
        mail-ua0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932170AbeE3UKZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 30 May 2018 16:10:25 -0400
Received: by mail-ua0-f196.google.com with SMTP id y8-v6so13411497ual.5
        for <linux-nfs@vger.kernel.org>; Wed, 30 May 2018 13:10:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180530180553.38769-5-trond.myklebust@hammerspace.com>
References: <20180530180553.38769-1-trond.myklebust@hammerspace.com>
 <20180530180553.38769-2-trond.myklebust@hammerspace.com> <20180530180553.38769-3-trond.myklebust@hammerspace.com>
 <20180530180553.38769-4-trond.myklebust@hammerspace.com> <20180530180553.38769-5-trond.myklebust@hammerspace.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Wed, 30 May 2018 16:10:23 -0400
Message-ID: <CAN-5tyGKCoRKLW2_KVP8_eMx0mqC7U2yEYNr=jj5_ybM+vaL6Q@mail.gmail.com>
Subject: Re: [PATCH 04/19] pnfs: Add layout driver flag PNFS_LAYOUTGET_ON_OPEN
To: Trond Myklebust <trondmy@gmail.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

This feature is enabled for Flexfiles layout type. Is there a reason
that it shouldn't be generic for all pnfs?

On Wed, May 30, 2018 at 2:05 PM, Trond Myklebust <trondmy@gmail.com> wrote:
> From: Fred Isaman <fred.isaman@gmail.com>
>
> Driver can set flag to allow LAYOUTGET to be sent with OPEN.
>
> Signed-off-by: Fred Isaman <fred.isaman@gmail.com>
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> ---
>  fs/nfs/flexfilelayout/flexfilelayout.c | 1 +
>  fs/nfs/pnfs.h                          | 1 +
>  2 files changed, 2 insertions(+)
>
> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
> index c75ad982bcfc..3ae038d9c292 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayout.c
> +++ b/fs/nfs/flexfilelayout/flexfilelayout.c
> @@ -2347,6 +2347,7 @@ static struct pnfs_layoutdriver_type flexfilelayout_type = {
>         .id                     = LAYOUT_FLEX_FILES,
>         .name                   = "LAYOUT_FLEX_FILES",
>         .owner                  = THIS_MODULE,
> +       .flags                  = PNFS_LAYOUTGET_ON_OPEN,
>         .set_layoutdriver       = ff_layout_set_layoutdriver,
>         .alloc_layout_hdr       = ff_layout_alloc_layout_hdr,
>         .free_layout_hdr        = ff_layout_free_layout_hdr,
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index daf6cbf5c15f..f71a55f11b97 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -110,6 +110,7 @@ enum layoutdriver_policy_flags {
>         PNFS_LAYOUTRET_ON_SETATTR       = 1 << 0,
>         PNFS_LAYOUTRET_ON_ERROR         = 1 << 1,
>         PNFS_READ_WHOLE_PAGE            = 1 << 2,
> +       PNFS_LAYOUTGET_ON_OPEN          = 1 << 3,
>  };
>
>  struct nfs4_deviceid_node;
> --
> 2.17.0
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
