Received: from mail-qt1-f179.google.com (mail-qt1-f179.google.com [209.85.160.179])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 697B93955E3
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2026 10:17:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.160.179
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784542680; cv=pass; b=a58+uAB+RTFOA8UL1qwzUz4C29ooBU2TiEcS7AtJWZa27oVAIQlmJpjI4qC121Vcxj6/BaS3Nc9Ih3NZxS784wxzKgFPJ1Ob0tMuRoaHt2c1cxDKITad3b6rlzN1Lzm5FKRsYXzlLT8RWkdYoVYRNrOiLRoMsoR+SEoDseUxbyk=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784542680; c=relaxed/simple;
	bh=P7o1byTXNsf2TQMuu7w5KAObqOTYb68IPlBigJcv+8Y=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=eOIpPUO6M/VVrG95YbNeLt7LkzGZL7U68xyovzTwCkVpqcEE2JQ1tmHhG1w14On52LZrAMc6c8zoL5fiLTXXJiCBX4cDzyYRbd9MWlQOi5et5v5sB767VzWY3IZQHz6tKy6ktO5uQoHYOcPmKWxzOeRx4BWmJiOND4NuD8scSPI=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=P1obqloe; arc=pass smtp.client-ip=209.85.160.179
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="P1obqloe"
Received: by mail-qt1-f179.google.com with SMTP id d75a77b69052e-51c01c79467so666701cf.0
        for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2026 03:17:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1784542677; cv=none;
        d=google.com; s=arc-20260327;
        b=MNJt8n8TTx/weqhvLwZcLD3z8uMxcRzUb4yydWC+p/CKq7qIacr3CzYvHjTMdmSXCW
         6WU1jD0COSgzyC8i1yuIYMxBv09s+YFxwlIsTSbxOHStUlex1rTwuojdA75jGzP0rpRm
         RQ/dQzrp3+fzIeyDXmW6LdTuR/2UC8uq2Vk4bJwVkoOJ2JgK/BCDiwENLyvN32+wTUt2
         +pJ9C0LFAqV5bEx/6U/xn2d+3pq69Npuz5t20ziRNjz7xdpUoNCv2dufs0LzwgP3VqtS
         fDaWCbhXB4T5unL6cS4N4olI3g982zWXTt8Z8FF245wZcqRdnHxkF3GT34/KRl1yfDSQ
         rWwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=xJq+YybrtI85Vn4FYl4KzmOZzJIIseFYsuVksxW5qi4=;
        fh=Bm5Mp/3Eout3nWbe0lr9X4NtbielyenUqmDhQUoEtTc=;
        b=YjACqFtDOy73/Y0MirfSmdl99Klkz9VDiflryjG+TCpeJ8QrHvmM3sAxU9AKxBXD6c
         nu94H6/cR3tIky+aoOkpFBzXd7o4xA19bOWCNK+2DxoZBWCbNyRKNV0E+OlfKXG7bVzF
         /Fosa5soA9O5FDHLgsdLjH9eGBTetdP/9/MDPUwfGwRxWcc7yW3+suWIlS94dX33EazM
         eBFg0z/Kmy557bLghYbLePv8FkTp/4c1XM7t7UjsOgHGlZJKHy46AakA1DztlqGgrBI3
         Xvt7gx2JUYSDR3W1GEm3On4FZY7OCEumU5iUjZQ9e35p6UF7hK9cbBN8tCgTtkw1RH9G
         ltZw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1784542677; x=1785147477; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=xJq+YybrtI85Vn4FYl4KzmOZzJIIseFYsuVksxW5qi4=;
        b=P1obqloeO6hlIGCkzj41uvsNhBf5L2TMKbcJvVkydFckyOI3MJtsiWDwPSWVHjB+bz
         d+WaLnY7cmkcZprtCsSy+nrkfwUKBGSkKwMZTTv1CbwiJQXNQdSwISPifXBQabcVCVG1
         8Bur1YayamudF3HjfFbEdYre7+CRely11ZkkiN9/vyMuXIfLbZQGi5aUbL5dgOwDBfa2
         eZCbIBN2ngstC/GAOQuHb2LAOpasHSUAOrISo8HdsU1c8029vYuYn/ddlOpIUisQxvXW
         /A3FFM/7cRu3FlLmqL4W66awU2pSGPwPnDBzMGaRO6PaLsUAo1D74RW/+2U3D3jK+yC4
         ce0g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1784542677; x=1785147477;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=xJq+YybrtI85Vn4FYl4KzmOZzJIIseFYsuVksxW5qi4=;
        b=Mtd3jlqV+uuhvlVADh/HPNUOoRuimPeQcH1UUklhtEkr3JxpXUzTQNoZURN4EWKEG1
         udTD/Saf3dt5CTy81po4wpn0JgCmhgsr5lkI2S+U+WnkUxwRrMPkuqzzpQYVfk18J1kr
         kwFpz34ZMwvQQlhbZHg2snz/+DLiMjmiK2GP3tKKqV3n3sT3rdGlbIo9FZvFuICpHRgg
         6bCS57WhsjXsGsApkrHa/fLiC5YnJHXCCbYnf2w85AD2QJ7B7cgjdGhwi+tqzOLj9rP0
         BLWkh61ZjBoCXeTGn5h6kaMb/AN4fDZCZtQjFD26LIwPnG2LOIaVp0raeZfjVXkT8E70
         x+9Q==
X-Forwarded-Encrypted: i=1; AHgh+RppOQ1Sq9enTYrSZIvA4gQYBO7em9xfw4pPB7b+REiF2BnI4yefA+q2UrG1HdRFLnt3pRolBfDRz4Y=@vger.kernel.org
X-Gm-Message-State: AOJu0Yz2WFrfOOn3CIyuS1JXt7s5lJeRg6Y/2IdodQ4zxadqDWK/dUmK
	wdKryIh+maBoXlvRv5qeeZUlByMwUqnysba44BS0bRzEQqFT5uYzYLpm7xXcayRjZvG4qKCIIIO
	e7IWxDvJ4OEvcfStGDWWoR/eLfGrXWkWSljgy2eLi
X-Gm-Gg: AfdE7ckJ7jqFpEqRqhg86lGYDP6T/w0mbNA+8Gg5CST+XHbc99U9XfsPTYeu6HEFl4G
	EQ7lE6zH0F3kAUjhXjK0G0n2XSoArdOBCxeORAFjayQgHfLmb3+Bwrb47VV4dTHa2UWTLEVKU7o
	Yzmyo34c445bXTZ4GMS4r259RnaREuXX/fgGH47jUhvIKhwX13/a9rsrS444fC9EnEuzTdtH+bM
	oH2lDz9DOXR2uOnwI2GTFw26jjL53DQ7y3qKd/wJPwI4r4TjqmXkkdk4iswx897LpAp+xy4zZYs
	JsfUQ0WO57vd2xK2uHeb52enVqnUQJhlXsofLfhEN4NODCVqqXJW
X-Received: by 2002:a05:622a:390:b0:517:38aa:c2b3 with SMTP id
 d75a77b69052e-5223af3723emr16114181cf.14.1784542676570; Mon, 20 Jul 2026
 03:17:56 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260715143540.3597616-1-praan@google.com> <20260715143540.3597616-6-praan@google.com>
In-Reply-To: <20260715143540.3597616-6-praan@google.com>
From: Shivaji Kant <shivajikant@google.com>
Date: Mon, 20 Jul 2026 15:47:44 +0530
X-Gm-Features: AUfX_mwFKB-UFO6JOmpIoa1TvMAxsAgrez4LnGL8xlaK5hQvecT-_c65Guw-ttE
Message-ID: <CAMEhMpmYhOUOC8CpmAQhoFY8CCq9=gVstgfZWGwppATVKV0orA@mail.gmail.com>
Subject: Re: [PATCH v3 5/5] nfs: introduce nfs_direct_extract_pages helper
To: Pranjal Shrivastava <praan@google.com>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, linux-nfs@vger.kernel.org, 
	Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, linux-kernel@vger.kernel.org, 
	Christoph Hellwig <hch@lst.de>, Logan Gunthorpe <logang@deltatee.com>, Jason Gunthorpe <jgg@ziepe.ca>, 
	linux-pci@vger.kernel.org, linux-rdma@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, Jul 15, 2026 at 8:05=E2=80=AFPM Pranjal Shrivastava <praan@google.c=
om> wrote:
>
> Introduce nfs_direct_extract_pages() in direct.c to centralize page
> extraction and request creation for the Direct I/O path. The helper
> manages extraction from the iters and builds a list of nfs_page requests
>
> Refactor nfs_direct_read_schedule_iovec() and
> nfs_direct_write_schedule_iovec() to utilize the new helper, unifying
> the extraction logic on both paths.
>
> Signed-off-by: Pranjal Shrivastava <praan@google.com>
> ---
>  fs/nfs/direct.c | 127 ++++++++++++++++++++++++------------------------
>  1 file changed, 64 insertions(+), 63 deletions(-)
>
> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> index b9ac0a67693c..d31e4720ffff 100644
> --- a/fs/nfs/direct.c
> +++ b/fs/nfs/direct.c
> @@ -178,6 +178,50 @@ static void nfs_direct_release_pages(struct page **p=
ages, unsigned int npages,
>         }
>  }
>
> +static ssize_t nfs_direct_extract_pages(struct nfs_direct_req *dreq,
> +                                        struct iov_iter *iter,
> +                                        size_t size, loff_t *pos,
> +                                        struct list_head *list)
> +{
> +       bool pinned =3D iov_iter_extract_will_pin(iter);
> +       struct page **pagevec =3D NULL;
> +       ssize_t result, bytes =3D 0;
> +       unsigned int npages, i;
> +       size_t pgbase;
> +
> +       result =3D iov_iter_extract_pages(iter, &pagevec, size, ~0U, 0, &=
pgbase);
> +       if (result <=3D 0)
> +               return result;
> +
> +       npages =3D (result + pgbase + PAGE_SIZE - 1) >> PAGE_SHIFT;
> +       for (i =3D 0; i < npages; i++) {
> +               struct nfs_page *req;
> +               unsigned int req_len =3D min_t(size_t, result - bytes, PA=
GE_SIZE - pgbase);
> +
> +               req =3D nfs_page_create_from_page(dreq->ctx, pagevec[i],
> +                                               pinned, pgbase, *pos,
> +                                               req_len);
> +               if (IS_ERR(req)) {
> +                       if (!bytes)
> +                               bytes =3D PTR_ERR(req);
> +                       break;
> +               }
> +
> +               list_add_tail(&req->wb_list, list);
> +               pgbase =3D 0;
> +               bytes +=3D req_len;
> +               *pos +=3D req_len;
> +       }
> +
> +       if (i < npages) {
> +               iov_iter_revert(iter, result - bytes);
> +               nfs_direct_release_pages(pagevec + i, npages - i, pinned)=
;
> +       }
> +
> +       kvfree(pagevec);
> +       return bytes;
> +}
> +
>  void nfs_init_cinfo_from_dreq(struct nfs_commit_info *cinfo,
>                               struct nfs_direct_req *dreq)
>  {
> @@ -346,6 +390,7 @@ static ssize_t nfs_direct_read_schedule_iovec(struct =
nfs_direct_req *dreq,
>         ssize_t result =3D -EINVAL;
>         size_t requested_bytes =3D 0;
>         size_t rsize =3D max_t(size_t, NFS_SERVER(inode)->rsize, PAGE_SIZ=
E);
> +       LIST_HEAD(nfs_page_list);
>
>         nfs_pageio_init_read(&desc, dreq->inode, false,
>                              &nfs_direct_read_completion_ops);
> @@ -354,43 +399,23 @@ static ssize_t nfs_direct_read_schedule_iovec(struc=
t nfs_direct_req *dreq,
>         inode_dio_begin(inode);
>
>         while (iov_iter_count(iter)) {
> -               struct page **pagevec =3D NULL;
> -               size_t bytes;
> -               size_t pgbase;
> -               unsigned npages, i;
> -               bool pinned =3D iov_iter_extract_will_pin(iter);
> -
> -               result =3D iov_iter_extract_pages(iter, &pagevec,
> -                                               rsize, ~0U, 0, &pgbase);
> +               result =3D nfs_direct_extract_pages(dreq, iter, rsize, &p=
os, &nfs_page_list);
>                 if (result < 0)
>                         break;
>
> -               bytes =3D result;
> -               npages =3D (result + pgbase + PAGE_SIZE - 1) / PAGE_SIZE;
> -               for (i =3D 0; i < npages; i++) {
> -                       struct nfs_page *req;
> -                       unsigned int req_len =3D min_t(size_t, bytes, PAG=
E_SIZE - pgbase);
> -                       /* XXX do we need to do the eof zeroing found in =
async_filler? */
> -                       req =3D nfs_page_create_from_page(dreq->ctx, page=
vec[i],
> -                                                       pinned, pgbase, p=
os,
> -                                                       req_len);
> -                       if (IS_ERR(req)) {
> -                               result =3D PTR_ERR(req);
> -                               break;
> -                       }
> +               while (!list_empty(&nfs_page_list)) {
> +                       struct nfs_page *req =3D nfs_list_entry(nfs_page_=
list.next);
> +                       size_t req_len =3D req->wb_bytes;
> +
> +                       nfs_list_remove_request(req);
>                         if (!nfs_pageio_add_request(&desc, req)) {
>                                 result =3D desc.pg_error;
>                                 nfs_release_request(req);
> +                               nfs_release_request_list(&nfs_page_list);
>                                 break;
>                         }
> -                       pgbase =3D 0;
> -                       bytes -=3D req_len;
>                         requested_bytes +=3D req_len;
> -                       pos +=3D req_len;
>                 }
> -               if (i < npages)
> -                       nfs_direct_release_pages(pagevec + i, npages - i,=
 pinned);
> -               kvfree(pagevec);
>                 if (result < 0)
>                         break;
>         }
> @@ -881,6 +906,7 @@ static ssize_t nfs_direct_write_schedule_iovec(struct=
 nfs_direct_req *dreq,
>         ssize_t result =3D 0;
>         size_t requested_bytes =3D 0;
>         size_t wsize =3D max_t(size_t, NFS_SERVER(inode)->wsize, PAGE_SIZ=
E);
> +       LIST_HEAD(nfs_page_list);
>         bool defer =3D false;
>
>         trace_nfs_direct_write_schedule_iovec(dreq);
> @@ -893,55 +919,32 @@ static ssize_t nfs_direct_write_schedule_iovec(stru=
ct nfs_direct_req *dreq,
>
>         NFS_I(inode)->write_io +=3D iov_iter_count(iter);
>         while (iov_iter_count(iter)) {
> -               struct page **pagevec =3D NULL;
> -               size_t bytes;
> -               size_t pgbase;
> -               unsigned npages, i;
> -               bool pinned =3D iov_iter_extract_will_pin(iter);
> -
> -               result =3D iov_iter_extract_pages(iter, &pagevec,
> -                                               wsize, ~0U, 0, &pgbase);
> +               result =3D nfs_direct_extract_pages(dreq, iter, wsize, &p=
os, &nfs_page_list);
>                 if (result < 0)
>                         break;
>
> -               bytes =3D result;
> -               npages =3D (result + pgbase + PAGE_SIZE - 1) / PAGE_SIZE;
> -               for (i =3D 0; i < npages; i++) {
> -                       struct nfs_page *req;
> -                       unsigned int req_len =3D min_t(size_t, bytes, PAG=
E_SIZE - pgbase);
> -
> -                       req =3D nfs_page_create_from_page(dreq->ctx, page=
vec[i],
> -                                                       pinned, pgbase, p=
os,
> -                                                       req_len);
> -                       if (IS_ERR(req)) {
> -                               result =3D PTR_ERR(req);
> -                               break;
> -                       }
> -
> -                       if (desc.pg_error < 0) {
> -                               nfs_free_request(req);
> -                               result =3D desc.pg_error;
> -                               break;
> -                       }
> -
> -                       pgbase =3D 0;
> -                       bytes -=3D req_len;
> -                       requested_bytes +=3D req_len;
> -                       pos +=3D req_len;
> +               while (!list_empty(&nfs_page_list)) {
> +                       struct nfs_page *req =3D nfs_list_entry(nfs_page_=
list.next);
> +                       size_t req_len =3D req->wb_bytes;
>
> +                       nfs_list_remove_request(req);
>                         if (defer) {
>                                 nfs_mark_request_commit(req, NULL, &cinfo=
, 0);
> +                               requested_bytes +=3D req_len;
>                                 continue;
>                         }
>
>                         nfs_lock_request(req);
> -                       if (nfs_pageio_add_request(&desc, req))
> +                       if (nfs_pageio_add_request(&desc, req)) {
> +                               requested_bytes +=3D req_len;
>                                 continue;
> +                       }
>
>                         /* Exit on hard errors */
>                         if (desc.pg_error < 0 && desc.pg_error !=3D -EAGA=
IN) {
>                                 result =3D desc.pg_error;
>                                 nfs_unlock_and_release_request(req);
> +                               nfs_release_request_list(&nfs_page_list);
>                                 break;
>                         }
>
> @@ -952,12 +955,10 @@ static ssize_t nfs_direct_write_schedule_iovec(stru=
ct nfs_direct_req *dreq,
>                         spin_unlock(&dreq->lock);
>                         nfs_unlock_request(req);
>                         nfs_mark_request_commit(req, NULL, &cinfo, 0);
> +                       requested_bytes +=3D req_len;
>                         desc.pg_error =3D 0;
>                         defer =3D true;
>                 }
> -               if (i < npages)
> -                       nfs_direct_release_pages(pagevec + i, npages - i,=
 pinned);
> -               kvfree(pagevec);
>                 if (result < 0)
>                         break;
>         }
> --
> 2.55.0.229.g6434b31f56-goog
>

Refactoring looks good. Consolidates extraction, error handling, and
iov_iter_revert() into a single helper shared by both read and write
paths.

Reviewed-by: Shivaji Kant <shivajikant@google.com>
