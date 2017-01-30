Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:35095 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932379AbdA3PmC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jan 2017 10:42:02 -0500
Received: by mail-qt0-f195.google.com with SMTP id s58so15266754qtc.2
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2017 07:40:46 -0800 (PST)
Message-ID: <1485790844.2671.8.camel@poochiereds.net>
Subject: Re: [PATCH v4 2/2] ceph: switch DIO code to use
 iov_iter_get_pages_alloc
From: Jeff Layton <jlayton@poochiereds.net>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        lustre-devel@lists.lustre.org, v9fs-developer@lists.sourceforge.net
Date: Mon, 30 Jan 2017 10:40:44 -0500
In-Reply-To: <20170127132451.6601-3-jlayton@redhat.com>
References: <1485434106.6547.1.camel@poochiereds.net>
         <20170127132451.6601-1-jlayton@redhat.com>
         <20170127132451.6601-3-jlayton@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-01-27 at 08:24 -0500, Jeff Layton wrote:
> xfstest generic/095 triggers soft lockups in kcephfs. It uses fio to
> drive some I/O via vmsplice ane splice. Ceph then ends up trying to
> access an ITER_BVEC type iov_iter as a ITER_IOVEC one. That causes it to
> pick up a wrong offset and get stuck in an infinite loop while trying to
> populate the page array. dio_get_pagev_size has a similar problem.
> 
> Now that iov_iter_get_pages_alloc doesn't stop after the first vector in
> the array, we can just call it instead and dump the old code that tried
> to do the same thing.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/ceph/file.c | 75 +++-------------------------------------------------------
>  1 file changed, 3 insertions(+), 72 deletions(-)
> 
> diff --git a/fs/ceph/file.c b/fs/ceph/file.c
> index 045d30d26624..0ce79f1eabbc 100644
> --- a/fs/ceph/file.c
> +++ b/fs/ceph/file.c
> @@ -35,75 +35,6 @@
>   */
>  
>  /*
> - * Calculate the length sum of direct io vectors that can
> - * be combined into one page vector.
> - */
> -static size_t dio_get_pagev_size(const struct iov_iter *it)
> -{
> -    const struct iovec *iov = it->iov;
> -    const struct iovec *iovend = iov + it->nr_segs;
> -    size_t size;
> -
> -    size = iov->iov_len - it->iov_offset;
> -    /*
> -     * An iov can be page vectored when both the current tail
> -     * and the next base are page aligned.
> -     */
> -    while (PAGE_ALIGNED((iov->iov_base + iov->iov_len)) &&
> -           (++iov < iovend && PAGE_ALIGNED((iov->iov_base)))) {
> -        size += iov->iov_len;
> -    }
> -    dout("dio_get_pagevlen len = %zu\n", size);
> -    return size;
> -}
> -
> -/*
> - * Allocate a page vector based on (@it, @nbytes).
> - * The return value is the tuple describing a page vector,
> - * that is (@pages, @page_align, @num_pages).
> - */
> -static struct page **
> -dio_get_pages_alloc(const struct iov_iter *it, size_t nbytes,
> -		    size_t *page_align, int *num_pages)
> -{
> -	struct iov_iter tmp_it = *it;
> -	size_t align;
> -	struct page **pages;
> -	int ret = 0, idx, npages;
> -
> -	align = (unsigned long)(it->iov->iov_base + it->iov_offset) &
> -		(PAGE_SIZE - 1);
> -	npages = calc_pages_for(align, nbytes);
> -	pages = kmalloc(sizeof(*pages) * npages, GFP_KERNEL);
> -	if (!pages) {
> -		pages = vmalloc(sizeof(*pages) * npages);
> -		if (!pages)
> -			return ERR_PTR(-ENOMEM);
> -	}
> -
> -	for (idx = 0; idx < npages; ) {
> -		size_t start;
> -		ret = iov_iter_get_pages(&tmp_it, pages + idx, nbytes,
> -					 npages - idx, &start);
> -		if (ret < 0)
> -			goto fail;
> -
> -		iov_iter_advance(&tmp_it, ret);
> -		nbytes -= ret;
> -		idx += (ret + start + PAGE_SIZE - 1) / PAGE_SIZE;
> -	}
> -
> -	BUG_ON(nbytes != 0);
> -	*num_pages = npages;
> -	*page_align = align;
> -	dout("dio_get_pages_alloc: got %d pages align %zu\n", npages, align);
> -	return pages;
> -fail:
> -	ceph_put_page_vector(pages, idx, false);
> -	return ERR_PTR(ret);
> -}
> -
> -/*
>   * Prepare an open request.  Preallocate ceph_cap to avoid an
>   * inopportune ENOMEM later.
>   */
> @@ -923,7 +854,7 @@ ceph_direct_read_write(struct kiocb *iocb, struct iov_iter *iter,
>  	}
>  
>  	while (iov_iter_count(iter) > 0) {
> -		u64 size = dio_get_pagev_size(iter);
> +		u64 size = iov_iter_count(iter);
>  		size_t start = 0;
>  		ssize_t len;
>  
> @@ -943,13 +874,13 @@ ceph_direct_read_write(struct kiocb *iocb, struct iov_iter *iter,
>  			break;
>  		}
>  
> -		len = size;
> -		pages = dio_get_pages_alloc(iter, len, &start, &num_pages);
> +		len = iov_iter_get_pages_alloc(iter, &pages, size, &start);
>  		if (IS_ERR(pages)) {
>  			ceph_osdc_put_request(req);
>  			ret = PTR_ERR(pages);
>  			break;
>  		}
> +		num_pages = DIV_ROUND_UP(len, PAGE_SIZE);

Sigh, this should be:

    num_pages = DIV_ROUND_UP(len + start, PAGE_SIZE);

Also, while it is a simple thing to determine, it is rather easy to get
that wrong.

Maybe we should have iov_iter_get_pages_alloc also return the number of
pages? Not having to do a DIV_ROUND_UP on every call into it would be
nice, and all of the callers need that value anyway.

>  
>  		/*
>  		 * To simplify error handling, allow AIO when IO within i_size

-- 
Jeff Layton <jlayton@poochiereds.net>
