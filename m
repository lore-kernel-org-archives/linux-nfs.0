Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vn0-f52.google.com ([209.85.216.52]:42906 "EHLO
	mail-vn0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755141AbbE1XYs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 May 2015 19:24:48 -0400
Received: by vnbg129 with SMTP id g129so6559745vnb.9
        for <linux-nfs@vger.kernel.org>; Thu, 28 May 2015 16:24:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4bf77d045d2bd3494c695229cd0505b7002cc9a2.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
	<4bf77d045d2bd3494c695229cd0505b7002cc9a2.1429868795.git.agruenba@redhat.com>
Date: Thu, 28 May 2015 19:24:47 -0400
Message-ID: <CAHQdGtQbKvkG_FdFX+3cd1s2VsrE8FUK4beAn6BsK9Dt1hLQsw@mail.gmail.com>
Subject: Re: [RFC v3 41/45] rpc: Allow to demand-allocate pages to encode into
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 24, 2015 at 7:04 AM, Andreas Gruenbacher
<andreas.gruenbacher@gmail.com> wrote:
> When encoding large, variable-length objects such as acls into xdr_bufs, it is
> easier to allocate buffer pages on demand rather than computing the required
> buffer size beforehand.
>
> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
> ---
>  net/sunrpc/xdr.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
>
> diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
> index 4439ac4..062951b 100644
> --- a/net/sunrpc/xdr.c
> +++ b/net/sunrpc/xdr.c
> @@ -537,6 +537,14 @@ static __be32 *xdr_get_next_encode_buffer(struct xdr_stream *xdr,
>          */
>         xdr->scratch.iov_base = xdr->p;
>         xdr->scratch.iov_len = frag1bytes;
> +
> +       if (!*xdr->page_ptr) {
> +               struct page *page = alloc_page(GFP_KERNEL);
> +               if (!page)
> +                       return ERR_PTR(-ENOMEM);
> +               *xdr->page_ptr = page;
> +       }
> +
>         p = page_address(*xdr->page_ptr);
>         /*
>          * Note this is where the next encode will start after we've
>

xdr_get_next_encode() should return NULL on failure, not ENOMEM.
Why is this trying to do a GFP_KERNEL allocation inside an XDR routine
anyway? That's not an I/O safe sleep.

Trond
