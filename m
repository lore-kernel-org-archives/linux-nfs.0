Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f46.google.com ([209.85.212.46]:55086 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752392Ab2EATMM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 May 2012 15:12:12 -0400
Received: by vbbff1 with SMTP id ff1so2969725vbb.19
        for <linux-nfs@vger.kernel.org>; Tue, 01 May 2012 12:12:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1335897620-17569-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1335897434.4060.17.camel@lade.trondhjem.org>
	<1335897620-17569-1-git-send-email-Trond.Myklebust@netapp.com>
	<1335897620-17569-2-git-send-email-Trond.Myklebust@netapp.com>
	<1335897620-17569-3-git-send-email-Trond.Myklebust@netapp.com>
Date: Tue, 1 May 2012 15:12:11 -0400
Message-ID: <CADnza47Cc+R68xmYCJHiytPJU9+-cDrzLm_caVn1tmons2kgDQ@mail.gmail.com>
Subject: Re: [PATCH v3 3/3] NFS: Simplify the nfs_read_completion functions
From: Fred Isaman <iisaman@netapp.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 1, 2012 at 2:40 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: Fred Isaman <iisaman@netapp.com>
> ---
>  fs/nfs/direct.c |   46 +++++++++++++++++++---------------------------
>  fs/nfs/read.c   |   42 +++++++++++++++++-------------------------
>  2 files changed, 36 insertions(+), 52 deletions(-)
>
> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> index f17e469..a1d366b 100644
> --- a/fs/nfs/direct.c
> +++ b/fs/nfs/direct.c
> @@ -243,36 +243,28 @@ static void nfs_direct_read_completion(struct nfs_pgio_header *hdr)
>                dreq->count += hdr->good_bytes;
>        spin_unlock(&dreq->lock);
>
> -       if (!test_bit(NFS_IOHDR_ERROR, &hdr->flags)) {
> -               while (!list_empty(&hdr->pages)) {
> -                       struct nfs_page *req = nfs_list_entry(hdr->pages.next);
> -                       struct page *page = req->wb_page;
> -
> -                       if (test_bit(NFS_IOHDR_EOF, &hdr->flags)) {
> -                               if (bytes > hdr->good_bytes)
> -                                       zero_user(page, 0, PAGE_SIZE);
> -                               else if (hdr->good_bytes - bytes < PAGE_SIZE)
> -                                       zero_user_segment(page,
> -                                               hdr->good_bytes & ~PAGE_MASK,
> -                                               PAGE_SIZE);
> -                       }
> -                       bytes += req->wb_bytes;
> -                       nfs_list_remove_request(req);
> -                       if (!PageCompound(page))
> -                               set_page_dirty(page);
> -                       nfs_direct_readpage_release(req);
> +       while (!list_empty(&hdr->pages)) {
> +               struct nfs_page *req = nfs_list_entry(hdr->pages.next);
> +               struct page *page = req->wb_page;
> +
> +               if (test_bit(NFS_IOHDR_EOF, &hdr->flags)) {
> +                       if (bytes > hdr->good_bytes)
> +                               zero_user(page, 0, PAGE_SIZE);
> +                       else if (hdr->good_bytes - bytes < PAGE_SIZE)
> +                               zero_user_segment(page,
> +                                       hdr->good_bytes & ~PAGE_MASK,
> +                                       PAGE_SIZE);
>                }
> -       } else {
> -               while (!list_empty(&hdr->pages)) {
> -                       struct nfs_page *req = nfs_list_entry(hdr->pages.next);
> -
> -                       if (bytes < hdr->good_bytes)
> -                               if (!PageCompound(req->wb_page))
> +               if (!PageCompound(page)) {
> +                       if (test_bit(NFS_IOHDR_ERROR, &hdr->flags)) {
> +                               if (bytes < hdr->good_bytes)
>                                        set_page_dirty(req->wb_page);

You can s/req->wb_page/page/

Other than that, looks fine, but I'll note that my intent in writing
it as it was was to move the test_bit out of the loop.
But given the EOF test that was still there, I guess it doesn't make
much difference.

Fred

> -                       bytes += req->wb_bytes;
> -                       nfs_list_remove_request(req);
> -                       nfs_direct_readpage_release(req);
> +                       } else
> +                               set_page_dirty(page);
>                }
> +               bytes += req->wb_bytes;
> +               nfs_list_remove_request(req);
> +               nfs_direct_readpage_release(req);
>        }
>  out_put:
>        if (put_dreq(dreq))
> diff --git a/fs/nfs/read.c b/fs/nfs/read.c
> index 1961a19..b81281b 100644
> --- a/fs/nfs/read.c
> +++ b/fs/nfs/read.c
> @@ -179,34 +179,26 @@ static void nfs_read_completion(struct nfs_pgio_header *hdr)
>
>        if (test_bit(NFS_IOHDR_REDO, &hdr->flags))
>                goto out;
> -       if (!test_bit(NFS_IOHDR_ERROR, &hdr->flags)) {
> -               while (!list_empty(&hdr->pages)) {
> -                       struct nfs_page *req = nfs_list_entry(hdr->pages.next);
> -                       struct page *page = req->wb_page;
> -
> -                       if (test_bit(NFS_IOHDR_EOF, &hdr->flags)) {
> -                               if (bytes > hdr->good_bytes)
> -                                       zero_user(page, 0, PAGE_SIZE);
> -                               else if (hdr->good_bytes - bytes < PAGE_SIZE)
> -                                       zero_user_segment(page,
> -                                               hdr->good_bytes & ~PAGE_MASK,
> -                                               PAGE_SIZE);
> -                       }
> -                       SetPageUptodate(page);
> -                       nfs_list_remove_request(req);
> -                       nfs_readpage_release(req);
> -                       bytes += PAGE_SIZE;
> +       while (!list_empty(&hdr->pages)) {
> +               struct nfs_page *req = nfs_list_entry(hdr->pages.next);
> +               struct page *page = req->wb_page;
> +
> +               if (test_bit(NFS_IOHDR_EOF, &hdr->flags)) {
> +                       if (bytes > hdr->good_bytes)
> +                               zero_user(page, 0, PAGE_SIZE);
> +                       else if (hdr->good_bytes - bytes < PAGE_SIZE)
> +                               zero_user_segment(page,
> +                                       hdr->good_bytes & ~PAGE_MASK,
> +                                       PAGE_SIZE);
>                }
> -       } else {
> -               while (!list_empty(&hdr->pages)) {
> -                       struct nfs_page *req = nfs_list_entry(hdr->pages.next);
> -
> -                       bytes += req->wb_bytes;
> +               bytes += req->wb_bytes;
> +               if (test_bit(NFS_IOHDR_ERROR, &hdr->flags)) {
>                        if (bytes <= hdr->good_bytes)
>                                SetPageUptodate(req->wb_page);
> -                       nfs_list_remove_request(req);
> -                       nfs_readpage_release(req);
> -               }
> +               } else
> +                       SetPageUptodate(page);
> +               nfs_list_remove_request(req);
> +               nfs_readpage_release(req);
>        }
>  out:
>        hdr->release(hdr);
> --
> 1.7.7.6
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
