Received: from casper.infradead.org (casper.infradead.org [90.155.50.34])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BA04242FCB8;
	Mon, 10 Aug 2026 20:09:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=90.155.50.34
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786392552; cv=none; b=sQUr2RRZEATTwSTqvzJUOwtxP+uqgmX4B1CXxi0e/RBUnP/fHxHjrUynEWyTY9r0tIpYo72+Cisg17dv2aaS1Bp8hpNCjj3AA4VSKu8Amfs3UFlOF4E07Xn93aIN8it9WwOinL2gYB5VpVXFHIMvnZdvoA6vZtxxbJZErqKXz/U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786392552; c=relaxed/simple;
	bh=cK6Z2eFxMtYWEYMtKNKG58PVTCus14JkzK21bMM/BRU=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=Z3k4DiBPpDRIkToGBDHTTlcTz1b6b2UF0Ryv523ozdOTFh1Fr5PtGt/BEyva/Rtmk2p9T52j13SLo7fmEfZaj3/DCOT55ruV6EizflxmoICbUYwyvBvmRMEnSmSfBRKsnJOSONEwBWVgn+89A8IXKvrtQP+MA7nF09CKOmXtZEY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=pass smtp.mailfrom=infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=WyOU0EKD; arc=none smtp.client-ip=90.155.50.34
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="WyOU0EKD"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=casper.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=w8yXT5X28jD8ZzH4O3pAXcMg6o723h3Ulp37jcRX8zM=; b=WyOU0EKDsMOUdYmkMDteNK0iH7
	F7H7rskf1JokJLT1sQ+3xAt1pEzIgkcKhjpvQMcjn+SPkJuP24dAXc+GS5rOQWk3hyGKxtSvEnmBQ
	pdSulUxOSO+5Ikl81Z6EJqFs1Z5Fe5ZdnwawU1wzR32ZA4dea55YLGSTXpEslBD5OWVpqJMwHiwW0
	yAp7+IHx0GoJ+uRa2276XVR5u1tSr7g87aYgAVkRYjCRDfobiAsEyLcLUYHMeLGTRdnqN5Ecdwc2B
	Bk6L64D/tgDrL4L6zUmRIYHoGlnCWfC9pUN73VJQM6UkqdDR48ZANjy8hz4tUKzR4rOLjtpRRUJ2B
	qLnlp2Zg==;
Received: from willy by casper.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wtVn9-00000000ss5-2mP1;
	Mon, 10 Aug 2026 19:36:11 +0000
Date: Mon, 10 Aug 2026 20:36:11 +0100
From: Matthew Wilcox <willy@infradead.org>
To: David Howells <dhowells@redhat.com>
Cc: Christian Brauner <christian@brauner.io>,
	Christoph Hellwig <hch@infradead.org>,
	Paulo Alcantara <pc@manguebit.org>, Jens Axboe <axboe@kernel.dk>,
	Leon Romanovsky <leon@kernel.org>, Steve French <sfrench@samba.org>,
	ChenXiaoSong <chenxiaosong@chenxiaosong.com>,
	Marc Dionne <marc.dionne@auristor.com>,
	Stefan Metzmacher <metze@samba.org>,
	Eric Van Hensbergen <ericvh@kernel.org>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Ilya Dryomov <idryomov@gmail.com>, netfs@lists.linux.dev,
	linux-afs@lists.infradead.org, linux-cifs@vger.kernel.org,
	linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org,
	v9fs@lists.linux.dev, linux-erofs@lists.ozlabs.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-block@vger.kernel.org
Subject: Re: [PATCH v9 04/26] Add a function to kmap one page of a multipage
 bio_vec
Message-ID: <anooK9-UCNTmoSAq@casper.infradead.org>
References: <20260810144746.574036-1-dhowells@redhat.com>
 <20260810144746.574036-5-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260810144746.574036-5-dhowells@redhat.com>

On Mon, Aug 10, 2026 at 03:47:21PM +0100, David Howells wrote:
> Add a function to kmap one page of a multipage bio_vec by offset (which is
> added to the offset in the bio_vec internally).  The caller is responsible
> for calculating how much of the page is then available.

I think this should be kmap_local_bvec().  Living in bvec.h makes sense,
but keeping it in the kmap_local_ namespace is better than putting it in
the bvec_ namespace.

The bvec should be const-qualified.  We're not very good at
being const-clean, but let's try harder ;-)

I think it's better to steal the same terminology for the kernel-doc
used in highmem.h, just for consistency:

/**
 * kmap_local_bvec - Map a page in this bvec for temporary usage
 * @bvec: The bvec containing the page.
 * @offset: The first byte within the bvec to map.
 *
 * This will not map the entire bvec, only the page containing @offset
 * from the start of @bvec.  Unmap the address with kunmap_local().
 * See kmap_local_page() for nesting rules.
 *
 * Context: Interrupt or process context.
 * Return: A pointer to a temporary mapping.
 */

> +/**
> + * bvec_kmap_partial - Map part of a bvec into the kernel virtual address space
> + * @bvec: bvec to map
> + * @offset: Offset into bvec
> + *
> + * Map the page containing the byte at @offset into the kernel virtual address
> + * space.  The caller is responsible for making sure this doesn't overrun.
> + *
> + * Call kunmap_local on the returned address to unmap.
> + */
> +static inline void *bvec_kmap_partial(struct bio_vec *bvec, size_t offset)
> +{
> +	offset += bvec->bv_offset;
> +
> +	return kmap_local_page(bvec->bv_page + (offset >> PAGE_SHIFT)) +
> +		(offset & ~PAGE_MASK);
> +}
> +
>  #endif /* __LINUX_BVEC_H */
> 
> 
