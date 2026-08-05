Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 551473D5C23;
	Wed,  5 Aug 2026 20:12:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785960750; cv=none; b=P4m3Mfd6r8JEOsD3LXwEb0p8cNZA8RlCDT6sN5t/wa2AdLRQUA7JqVK+AuV+Ho5xPBeRO6nIq+0DzoqGZVyLFLvec5Vz92CAgTuCbEb+3U4Z75uSSW52fmz0GTMwWHU4cEXrn0yBugRUDspxJk6G0m+az4MOfOXhkrKxpZN+jMk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785960750; c=relaxed/simple;
	bh=HpPe5n1hdt+tdtFIiHbWgETDQGeqXLmppg4EelkUM3g=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=cO9DpV5tU1CtAQiKvGwiH3L+FDIJJkhYJQOnm/vFtswrZCddOHsYYbYQ/Z/FdsytpGpjB8rFyEyNz3bN4vjnA5HYVeOunDH9gLw4BRVGCPFkjP2oQbqY8P7G+vNm1sHeQpx0ogsTJM6pGi5cPxwLxgltbHxhqfSHf2lOt6cwoYM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=mT+XTq2B; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="mT+XTq2B"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 834D11F000E9;
	Wed,  5 Aug 2026 20:12:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785960748;
	bh=qKhFZjwoh9Z7eU7u5SE3stvRd+5tWHmU3iujv6Zqs9o=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=mT+XTq2BfoSjPDlU9PyzvB/WtaP3b68LUWHOQJXMFIbiI7NOPxSmb38BPMhlBg1OJ
	 urrSbyln5OArGUsMad+g7iB3f8FeTYULIrs87MlqNJzaHF+Gzxy/h8XRlsI25BHBwQ
	 YJq2oxxs6qJInAoMUR44sdNNjikbXHW5BgCxi4Mzlyh8s8Vzbd3derZbGrDlliQpcL
	 B58XbcZGE1s/a8zi2D7+VRUoOOIxndMbaxkYaGKUd6ZtvrH0CrLEv38GqBmlhoa4lq
	 9CwWzvbJ2GtuGi927kivy1AHfPZDYkcK/bfp5lyIpLVH4sed4b8sWuFCtIwVSlgCL2
	 Al1My28izQvzA==
Message-ID: <a7fe5eadb2999b8d95595e73d3b99d76df6895a4.camel@kernel.org>
Subject: Re: [PATCH v3 5/5] nfs: introduce nfs_direct_extract_pages helper
From: Trond Myklebust <trondmy@kernel.org>
To: Pranjal Shrivastava <praan@google.com>, Anna Schumaker
 <anna@kernel.org>, 	linux-nfs@vger.kernel.org
Cc: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
	linux-kernel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Logan
 Gunthorpe	 <logang@deltatee.com>, Jason Gunthorpe <jgg@ziepe.ca>, 
	linux-pci@vger.kernel.org, linux-rdma@vger.kernel.org, Shivaji Kant	
 <shivajikant@google.com>
Date: Wed, 05 Aug 2026 13:12:28 -0700
In-Reply-To: <20260715143540.3597616-6-praan@google.com>
References: <20260715143540.3597616-1-praan@google.com>
	 <20260715143540.3597616-6-praan@google.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-1.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Wed, 2026-07-15 at 14:35 +0000, Pranjal Shrivastava wrote:
> Introduce nfs_direct_extract_pages() in direct.c to centralize page
> extraction and request creation for the Direct I/O path. The helper
> manages extraction from the iters and builds a list of nfs_page
> requests
>=20
> Refactor nfs_direct_read_schedule_iovec() and
> nfs_direct_write_schedule_iovec() to utilize the new helper, unifying
> the extraction logic on both paths.
>=20
> Signed-off-by: Pranjal Shrivastava <praan@google.com>
> ---
> =C2=A0fs/nfs/direct.c | 127 ++++++++++++++++++++++++---------------------=
-
> --
> =C2=A01 file changed, 64 insertions(+), 63 deletions(-)
>=20
> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> index b9ac0a67693c..d31e4720ffff 100644
> --- a/fs/nfs/direct.c
> +++ b/fs/nfs/direct.c
> @@ -178,6 +178,50 @@ static void nfs_direct_release_pages(struct page
> **pages, unsigned int npages,
> =C2=A0	}
> =C2=A0}
> =C2=A0
> +static ssize_t nfs_direct_extract_pages(struct nfs_direct_req *dreq,
> +					 struct iov_iter *iter,
> +					 size_t size, loff_t *pos,
> +					 struct list_head *list)
> +{
> +	bool pinned =3D iov_iter_extract_will_pin(iter);
> +	struct page **pagevec =3D NULL;
> +	ssize_t result, bytes =3D 0;
> +	unsigned int npages, i;
> +	size_t pgbase;
> +
> +	result =3D iov_iter_extract_pages(iter, &pagevec, size, ~0U,
> 0, &pgbase);
> +	if (result <=3D 0)
> +		return result;
> +
> +	npages =3D (result + pgbase + PAGE_SIZE - 1) >> PAGE_SHIFT;
> +	for (i =3D 0; i < npages; i++) {
> +		struct nfs_page *req;
> +		unsigned int req_len =3D min_t(size_t, result - bytes,
> PAGE_SIZE - pgbase);
> +
> +		req =3D nfs_page_create_from_page(dreq->ctx,
> pagevec[i],
> +						pinned, pgbase,
> *pos,
> +						req_len);
> +		if (IS_ERR(req)) {
> +			if (!bytes)
> +				bytes =3D PTR_ERR(req);
> +			break;
> +		}
> +
> +		list_add_tail(&req->wb_list, list);
> +		pgbase =3D 0;
> +		bytes +=3D req_len;
> +		*pos +=3D req_len;
> +	}
> +
> +	if (i < npages) {
> +		iov_iter_revert(iter, result - bytes);

Oopsable if bytes =3D=3D PTR_ERR(req)

> +		nfs_direct_release_pages(pagevec + i, npages - i,
> pinned);

See what happens above with swap over NFS (which sets pinned =3D false).

> +	}
> +
> +	kvfree(pagevec);
> +	return bytes;
> +}
> +
> =C2=A0void nfs_init_cinfo_from_dreq(struct nfs_commit_info *cinfo,
> =C2=A0			=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 struct nfs_direct_req *dreq)
> =C2=A0{
> @@ -346,6 +390,7 @@ static ssize_t
> nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
> =C2=A0	ssize_t result =3D -EINVAL;
> =C2=A0	size_t requested_bytes =3D 0;
> =C2=A0	size_t rsize =3D max_t(size_t, NFS_SERVER(inode)->rsize,
> PAGE_SIZE);
> +	LIST_HEAD(nfs_page_list);
> =C2=A0
> =C2=A0	nfs_pageio_init_read(&desc, dreq->inode, false,
> =C2=A0			=C2=A0=C2=A0=C2=A0=C2=A0 &nfs_direct_read_completion_ops);
> @@ -354,43 +399,23 @@ static ssize_t
> nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
> =C2=A0	inode_dio_begin(inode);
> =C2=A0
> =C2=A0	while (iov_iter_count(iter)) {
> -		struct page **pagevec =3D NULL;
> -		size_t bytes;
> -		size_t pgbase;
> -		unsigned npages, i;
> -		bool pinned =3D iov_iter_extract_will_pin(iter);
> -
> -		result =3D iov_iter_extract_pages(iter, &pagevec,
> -						rsize, ~0U, 0,
> &pgbase);
> +		result =3D nfs_direct_extract_pages(dreq, iter, rsize,
> &pos, &nfs_page_list);
> =C2=A0		if (result < 0)
> =C2=A0			break;
> =C2=A0
> -		bytes =3D result;
> -		npages =3D (result + pgbase + PAGE_SIZE - 1) /
> PAGE_SIZE;
> -		for (i =3D 0; i < npages; i++) {
> -			struct nfs_page *req;
> -			unsigned int req_len =3D min_t(size_t, bytes,
> PAGE_SIZE - pgbase);
> -			/* XXX do we need to do the eof zeroing
> found in async_filler? */
> -			req =3D nfs_page_create_from_page(dreq->ctx,
> pagevec[i],
> -							pinned,
> pgbase, pos,
> -							req_len);
> -			if (IS_ERR(req)) {
> -				result =3D PTR_ERR(req);
> -				break;
> -			}
> +		while (!list_empty(&nfs_page_list)) {
> +			struct nfs_page *req =3D
> nfs_list_entry(nfs_page_list.next);
> +			size_t req_len =3D req->wb_bytes;
> +
> +			nfs_list_remove_request(req);
> =C2=A0			if (!nfs_pageio_add_request(&desc, req)) {
> =C2=A0				result =3D desc.pg_error;
> =C2=A0				nfs_release_request(req);
> +				nfs_release_request_list(&nfs_page_l
> ist);
> =C2=A0				break;
> =C2=A0			}
> -			pgbase =3D 0;
> -			bytes -=3D req_len;
> =C2=A0			requested_bytes +=3D req_len;
> -			pos +=3D req_len;
> =C2=A0		}
> -		if (i < npages)
> -			nfs_direct_release_pages(pagevec + i, npages
> - i, pinned);
> -		kvfree(pagevec);
> =C2=A0		if (result < 0)
> =C2=A0			break;
> =C2=A0	}
> @@ -881,6 +906,7 @@ static ssize_t
> nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
> =C2=A0	ssize_t result =3D 0;
> =C2=A0	size_t requested_bytes =3D 0;
> =C2=A0	size_t wsize =3D max_t(size_t, NFS_SERVER(inode)->wsize,
> PAGE_SIZE);
> +	LIST_HEAD(nfs_page_list);
> =C2=A0	bool defer =3D false;
> =C2=A0
> =C2=A0	trace_nfs_direct_write_schedule_iovec(dreq);
> @@ -893,55 +919,32 @@ static ssize_t
> nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
> =C2=A0
> =C2=A0	NFS_I(inode)->write_io +=3D iov_iter_count(iter);
> =C2=A0	while (iov_iter_count(iter)) {
> -		struct page **pagevec =3D NULL;
> -		size_t bytes;
> -		size_t pgbase;
> -		unsigned npages, i;
> -		bool pinned =3D iov_iter_extract_will_pin(iter);
> -
> -		result =3D iov_iter_extract_pages(iter, &pagevec,
> -						wsize, ~0U, 0,
> &pgbase);
> +		result =3D nfs_direct_extract_pages(dreq, iter, wsize,
> &pos, &nfs_page_list);
> =C2=A0		if (result < 0)
> =C2=A0			break;
> =C2=A0
> -		bytes =3D result;
> -		npages =3D (result + pgbase + PAGE_SIZE - 1) /
> PAGE_SIZE;
> -		for (i =3D 0; i < npages; i++) {
> -			struct nfs_page *req;
> -			unsigned int req_len =3D min_t(size_t, bytes,
> PAGE_SIZE - pgbase);
> -
> -			req =3D nfs_page_create_from_page(dreq->ctx,
> pagevec[i],
> -							pinned,
> pgbase, pos,
> -							req_len);
> -			if (IS_ERR(req)) {
> -				result =3D PTR_ERR(req);
> -				break;
> -			}
> -
> -			if (desc.pg_error < 0) {
> -				nfs_free_request(req);
> -				result =3D desc.pg_error;
> -				break;
> -			}
> -
> -			pgbase =3D 0;
> -			bytes -=3D req_len;
> -			requested_bytes +=3D req_len;
> -			pos +=3D req_len;
> +		while (!list_empty(&nfs_page_list)) {
> +			struct nfs_page *req =3D
> nfs_list_entry(nfs_page_list.next);
> +			size_t req_len =3D req->wb_bytes;
> =C2=A0
> +			nfs_list_remove_request(req);
> =C2=A0			if (defer) {
> =C2=A0				nfs_mark_request_commit(req, NULL,
> &cinfo, 0);
> +				requested_bytes +=3D req_len;
> =C2=A0				continue;
> =C2=A0			}
> =C2=A0
> =C2=A0			nfs_lock_request(req);
> -			if (nfs_pageio_add_request(&desc, req))
> +			if (nfs_pageio_add_request(&desc, req)) {
> +				requested_bytes +=3D req_len;
> =C2=A0				continue;
> +			}
> =C2=A0
> =C2=A0			/* Exit on hard errors */
> =C2=A0			if (desc.pg_error < 0 && desc.pg_error !=3D -
> EAGAIN) {
> =C2=A0				result =3D desc.pg_error;
> =C2=A0				nfs_unlock_and_release_request(req);
> +				nfs_release_request_list(&nfs_page_l
> ist);
> =C2=A0				break;
> =C2=A0			}
> =C2=A0
> @@ -952,12 +955,10 @@ static ssize_t
> nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
> =C2=A0			spin_unlock(&dreq->lock);
> =C2=A0			nfs_unlock_request(req);
> =C2=A0			nfs_mark_request_commit(req, NULL, &cinfo,
> 0);
> +			requested_bytes +=3D req_len;
> =C2=A0			desc.pg_error =3D 0;
> =C2=A0			defer =3D true;
> =C2=A0		}
> -		if (i < npages)
> -			nfs_direct_release_pages(pagevec + i, npages
> - i, pinned);
> -		kvfree(pagevec);
> =C2=A0		if (result < 0)
> =C2=A0			break;
> =C2=A0	}

--=20
Trond Myklebust
Linux NFS client maintainer, Hammerspace
trondmy@kernel.org, trond.myklebust@hammerspace.com
