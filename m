Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:35414 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751254AbdAZMfL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jan 2017 07:35:11 -0500
Received: by mail-qt0-f196.google.com with SMTP id f4so38164493qte.2
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jan 2017 04:35:11 -0800 (PST)
Message-ID: <1485434106.6547.1.camel@poochiereds.net>
Subject: Re: [PATCH v3 1/2] iov_iter: allow iov_iter_get_pages_alloc to
 allocate more pages per call
From: Jeff Layton <jlayton@poochiereds.net>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        lustre-devel@lists.lustre.org, v9fs-developer@lists.sourceforge.net
Date: Thu, 26 Jan 2017 07:35:06 -0500
In-Reply-To: <20170125133205.21704-2-jlayton@redhat.com>
References: <20170124212327.14517-1-jlayton@redhat.com>
         <20170125133205.21704-1-jlayton@redhat.com>
         <20170125133205.21704-2-jlayton@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2017-01-25 at 08:32 -0500, Jeff Layton wrote:
> Currently, iov_iter_get_pages_alloc will only ever operate on the first
> vector that iterate_all_kinds hands back. Most of the callers however
> would like to have as long a set of pages as possible, to allow for
> fewer, but larger I/Os.
> 
> When the previous vector ends on a page boundary and the current one
> begins on one, we can continue to add more pages.
> 
> Change the function to first scan the iov_iter to see how long an
> array of pages we could create from the current position up to the
> maxsize passed in. Then, allocate an array that large and start
> filling in that many pages.
> 
> The main impetus for this patch is to rip out a swath of code in ceph
> that tries to do this but that doesn't handle ITER_BVEC correctly.
> 
> NFS also uses this function and this also allows the client to do larger
> I/Os when userland passes down an array of page-aligned iovecs in an
> O_DIRECT request. This should also make splice writes into an O_DIRECT
> file on NFS use larger I/Os, since that's now done by passing down an
> ITER_BVEC representing the data to be written.
> 
> I believe the other callers (lustre and 9p) may also benefit from this
> change, but I don't have a great way to verify that.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  lib/iov_iter.c | 142 +++++++++++++++++++++++++++++++++++++++++++++------------
>  1 file changed, 113 insertions(+), 29 deletions(-)
> 
> diff --git a/lib/iov_iter.c b/lib/iov_iter.c
> index e68604ae3ced..c87ba154371a 100644
> --- a/lib/iov_iter.c
> +++ b/lib/iov_iter.c
> @@ -883,6 +883,59 @@ unsigned long iov_iter_gap_alignment(const struct iov_iter *i)
>  }
>  EXPORT_SYMBOL(iov_iter_gap_alignment);
>  
> +/**
> + * iov_iter_pvec_size - find length of page aligned iovecs in iov_iter
> + * @i: iov_iter to in which to find the size
> + * @maxsize: maximum size to return
> + *
> + * Some filesystems can stitch together multiple iovecs into a single page
> + * vector when both the previous tail and current base are page aligned. This
> + * function determines how much of the remaining iov_iter can be stuffed into
> + * a single pagevec, up to the provided maxsize value.
> + */
> +static size_t iov_iter_pvec_size(const struct iov_iter *i, size_t maxsize)
> +{
> +	size_t size = min(iov_iter_count(i), maxsize);
> +	size_t pv_size = 0;
> +	bool contig = false, first = true;
> +
> +	if (!size)
> +		return 0;
> +
> +	/* Pipes are naturally aligned for this */
> +	if (unlikely(i->type & ITER_PIPE))
> +		return size;
> +
> +	/*
> +	 * An iov can be page vectored when the current base and previous
> +	 * tail are both page aligned. Note that we don't require that the
> +	 * initial base in the first iovec also be page aligned.
> +	 */
> +	iterate_all_kinds(i, size, v,
> +		({
> +		 if (first || (contig && PAGE_ALIGNED(v.iov_base))) {
> +			pv_size += v.iov_len;
> +			first = false;
> +			contig = PAGE_ALIGNED(v.iov_base + v.iov_len);
> +		 }; 0;
> +		 }),
> +		({
> +		 if (first || (contig && v.bv_offset == 0)) {
> +			pv_size += v.bv_len;
> +			first = false;
> +			contig = PAGE_ALIGNED(v.bv_offset + v.bv_len);
> +		 }
> +		 }),
> +		({
> +		 if (first || (contig && PAGE_ALIGNED(v.iov_base))) {
> +			pv_size += v.iov_len;
> +			first = false;
> +			contig = PAGE_ALIGNED(v.iov_base + v.iov_len);
> +		 }
> +		 }))
> +	return pv_size;
> +}
> +
>  static inline size_t __pipe_get_pages(struct iov_iter *i,
>  				size_t maxsize,
>  				struct page **pages,
> @@ -1006,47 +1059,78 @@ static ssize_t pipe_get_pages_alloc(struct iov_iter *i,
>  }
>  
>  ssize_t iov_iter_get_pages_alloc(struct iov_iter *i,
> -		   struct page ***pages, size_t maxsize,
> -		   size_t *start)
> +		   struct page ***ppages, size_t maxsize,
> +		   size_t *pstart)
>  {
> -	struct page **p;
> -
> -	if (maxsize > i->count)
> -		maxsize = i->count;
> +	struct page **p, **pc;
> +	size_t start = 0;
> +	ssize_t len = 0;
> +	int npages, res = 0;
> +	bool first = true;
>  
>  	if (unlikely(i->type & ITER_PIPE))
> -		return pipe_get_pages_alloc(i, pages, maxsize, start);
> +		return pipe_get_pages_alloc(i, ppages, maxsize, pstart);
> +
> +	maxsize = iov_iter_pvec_size(i, maxsize);
> +	npages = DIV_ROUND_UP(maxsize, PAGE_SIZE);

Bah, the above is wrong when the offset into the first page is non-
zero. I'll fix -- this probably also points out the need for some tests
for this. I'll see if I can cook something up for xfstests.

> +	p = get_pages_array(npages);
> +	if (!p)
> +		return -ENOMEM;
> +
> +	pc = p;
>  	iterate_all_kinds(i, maxsize, v, ({
>  		unsigned long addr = (unsigned long)v.iov_base;
> -		size_t len = v.iov_len + (*start = addr & (PAGE_SIZE - 1));
> +		size_t slen = v.iov_len;
>  		int n;
> -		int res;
>  
> -		addr &= ~(PAGE_SIZE - 1);
> -		n = DIV_ROUND_UP(len, PAGE_SIZE);
> -		p = get_pages_array(n);
> -		if (!p)
> -			return -ENOMEM;
> -		res = get_user_pages_fast(addr, n, (i->type & WRITE) != WRITE, p);
> -		if (unlikely(res < 0)) {
> -			kvfree(p);
> -			return res;
> +		if (first) {
> +			start = addr & (PAGE_SIZE - 1);
> +			slen += start;
> +			first = false;
>  		}
> -		*pages = p;
> -		return (res == n ? len : res * PAGE_SIZE) - *start;
> +
> +		n = DIV_ROUND_UP(slen, PAGE_SIZE);
> +		if (pc + n > p + npages) {
> +			/* Did something change the iov array?!? */
> +			res = -EFAULT;
> +			goto out;
> +		}
> +		addr &= ~(PAGE_SIZE - 1);
> +		res = get_user_pages_fast(addr, n,
> +					  (i->type & WRITE) != WRITE, pc);
> +		if (unlikely(res < 0))
> +			goto out;
> +		len += (res == n ? slen : res * PAGE_SIZE) - start;
> +		pc += res;
>  	0;}),({
> -		/* can't be more than PAGE_SIZE */
> -		*start = v.bv_offset;
> -		*pages = p = get_pages_array(1);
> -		if (!p)
> -			return -ENOMEM;
> -		get_page(*p = v.bv_page);
> -		return v.bv_len;
> +		/* bio_vecs are limited to a single page each */
> +		if (first) {
> +			start = v.bv_offset;
> +			first = false;
> +		}
> +		get_page(*pc = v.bv_page);
> +		len += v.bv_len;
> +		++pc;
> +		BUG_ON(pc > p + npages);
>  	}),({
> -		return -EFAULT;
> +		/* FIXME: should we handle this case? */
> +		res = -EFAULT;
> +		goto out;
>  	})
>  	)
> -	return 0;
> +out:
> +	if (unlikely(res < 0)) {
> +		struct page **i;
> +
> +		for (i = p; i < pc; i++)
> +			put_page(*i);
> +		kvfree(p);
> +		return res;
> +	}
> +
> +	*ppages = p;
> +	*pstart = start;
> +	return len;
>  }
>  EXPORT_SYMBOL(iov_iter_get_pages_alloc);
>  
