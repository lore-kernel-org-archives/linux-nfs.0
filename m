Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:33552 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775AbbDUMSB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Apr 2015 08:18:01 -0400
MIME-Version: 1.0
In-Reply-To: <1428591737-19071-1-git-send-email-tao.peng@primarydata.com>
References: <1428591737-19071-1-git-send-email-tao.peng@primarydata.com>
Date: Tue, 21 Apr 2015 08:18:00 -0400
Message-ID: <CA+5PVA51+0GkKGCCcc83N83BrJQ5tmJhJt7rnR0v8H1uHtiYUw@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] nfs: fix DIO good bytes calculation
From: Josh Boyer <jwboyer@fedoraproject.org>
To: Peng Tao <tao.peng@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "stable@vger.kernel.org" <stable@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 9, 2015 at 11:02 AM, Peng Tao <tao.peng@primarydata.com> wrote:
> For direct read that has IO size larger than rsize, we'll split
> it into several READ requests and nfs_direct_good_bytes() would
> count completed bytes incorrectly by eating last zero count reply.
>
> Fix it by handling mirror and non-mirror cases differently such that
> we only count mirrored writes differently.
>
> This fixes 5fadeb47("nfs: count DIO good bytes correctly with mirroring").
>
> Reported-by: Jean Spector <jean@primarydata.com>
> Cc: <stable@vger.kernel.org> # v3.19+
> Signed-off-by: Peng Tao <tao.peng@primarydata.com>

This one (and 2/2 in the series) have been setting here with no
comments for a while now.  Are these going to get picked up for 4.1?
We have a couple of bug reports against 3.19 that these should fix, so
I'm curious if they're headed in-tree.

josh

> ---
>  fs/nfs/direct.c | 29 +++++++++++++++++------------
>  1 file changed, 17 insertions(+), 12 deletions(-)
>
> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> index e907c8c..5e451a7 100644
> --- a/fs/nfs/direct.c
> +++ b/fs/nfs/direct.c
> @@ -131,20 +131,25 @@ nfs_direct_good_bytes(struct nfs_direct_req *dreq, struct nfs_pgio_header *hdr)
>
>         WARN_ON_ONCE(hdr->pgio_mirror_idx >= dreq->mirror_count);
>
> -       count = dreq->mirrors[hdr->pgio_mirror_idx].count;
> -       if (count + dreq->io_start < hdr->io_start + hdr->good_bytes) {
> -               count = hdr->io_start + hdr->good_bytes - dreq->io_start;
> -               dreq->mirrors[hdr->pgio_mirror_idx].count = count;
> -       }
> -
> -       /* update the dreq->count by finding the minimum agreed count from all
> -        * mirrors */
> -       count = dreq->mirrors[0].count;
> +       if (dreq->mirror_count == 1) {
> +               dreq->mirrors[hdr->pgio_mirror_idx].count += hdr->good_bytes;
> +               dreq->count += hdr->good_bytes;
> +       } else {
> +               /* mirrored writes */
> +               count = dreq->mirrors[hdr->pgio_mirror_idx].count;
> +               if (count + dreq->io_start < hdr->io_start + hdr->good_bytes) {
> +                       count = hdr->io_start + hdr->good_bytes - dreq->io_start;
> +                       dreq->mirrors[hdr->pgio_mirror_idx].count = count;
> +               }
> +               /* update the dreq->count by finding the minimum agreed count from all
> +                * mirrors */
> +               count = dreq->mirrors[0].count;
>
> -       for (i = 1; i < dreq->mirror_count; i++)
> -               count = min(count, dreq->mirrors[i].count);
> +               for (i = 1; i < dreq->mirror_count; i++)
> +                       count = min(count, dreq->mirrors[i].count);
>
> -       dreq->count = count;
> +               dreq->count = count;
> +       }
>  }
>
>  /*
> --
> 1.9.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe stable" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
