Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CEF043783AF;
	Mon, 25 May 2026 06:14:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779689646; cv=none; b=ZKKKwlMgrCr1yF9lMMS6Mh7dReZ/FDjxxYlOA/4k6IUd/KYIuH0nkI41/0+IciOGiwZi4f+wC6ejl+XSs6bNA1OTsZPut99iTX8p3OpHDmofW98j6Dfg1Fd9dU63H0/ZG+G+1S2ovyUOvVA7GaFsK9qx8yokd9xbCdm4wsiCNis=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779689646; c=relaxed/simple;
	bh=oITi3u4/naeI/ShOv/u4JISTZ+EZAVPBqqE0eu8cDp8=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=FcPNDPEjYCXzPlUKGwQKKlY2wlDcEY0LXYyrLg8kjYFc2mi3Y+4RnBb6m6hXyuKiSTpJlwJHGQV4H0li6QhGjDyPmkdcRoi9yi4zxYtMXO5l7qgPXCi+9hSyj5wKg56RsfhU7ZG9K5Tw7kxmfvxs0l4X6T79GMWPs5kEUX4g2o4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=zukCrUtu; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="zukCrUtu"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=wR2vIyoI0N5pwT1BwNstwo6UsRKMLal3+wIAvkxVMvs=; b=zukCrUtu3mimFKUeZm0RXMqQK2
	kGGyaNN6usXLgSEU9Gbgcd9Rnxu7OIAbwN70g4v7jeIBQ/PTGsCqjWKVowrD6E95c+yFcSirTXOCX
	2pmMIo7aGE4K8ub7kLxRf4wx2kyIwapXnUZXJ8vz4qq/X5GSoISA6ENIibRBD9mbRPRuKnzbWtC+4
	du5vhRkKVCfRUzFnwD/uNhod1/p6ROSCrwCQCyikwpZXMZzkuV18jBwoj5qRYOck+tIkbRXraPwLA
	GTRsNx3hGDic5W8Lre8E5Laissc7COmB0DCteaZNYnMjWR/chZwTY/tWp/j+wBVJA8AnEPVVK6dW0
	AL0uhuqg==;
Received: from hch by bombadil.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wROZT-0000000GOO6-1oJq;
	Mon, 25 May 2026 06:13:51 +0000
Date: Sun, 24 May 2026 23:13:51 -0700
From: Christoph Hellwig <hch@infradead.org>
To: David Howells <dhowells@redhat.com>
Cc: Christian Brauner <christian@brauner.io>,
	Matthew Wilcox <willy@infradead.org>,
	Christoph Hellwig <hch@infradead.org>,
	Paulo Alcantara <pc@manguebit.org>, Jens Axboe <axboe@kernel.dk>,
	Leon Romanovsky <leon@kernel.org>, Steve French <sfrench@samba.org>,
	ChenXiaoSong <chenxiaosong@chenxiaosong.com>,
	Marc Dionne <marc.dionne@auristor.com>,
	Eric Van Hensbergen <ericvh@kernel.org>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Ilya Dryomov <idryomov@gmail.com>,
	Trond Myklebust <trondmy@kernel.org>, netfs@lists.linux.dev,
	linux-afs@lists.infradead.org, linux-cifs@vger.kernel.org,
	linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org,
	v9fs@lists.linux.dev, linux-erofs@lists.ozlabs.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-block@vger.kernel.org
Subject: Re: [PATCH v2 06/21] iov_iter: Make iov_iter_get_pages*() wrap
 iov_iter_extract_pages()
Message-ID: <ahPon44OlN0SqzU6@infradead.org>
References: <20260518222959.488126-1-dhowells@redhat.com>
 <20260518222959.488126-7-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260518222959.488126-7-dhowells@redhat.com>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

On Mon, May 18, 2026 at 11:29:38PM +0100, David Howells wrote:
> Make iov_iter_get_pages*() wrap iov_iter_extract_pages() for kernel
> iterator types (e.g. ITER_BVEC, ITER_FOLIOQ, ITER_XARRAY).  The pages
> obtained have their refcounts incremented afterwards if they're not slab
> pages.  ITER_KVEC is left returning -EFAULT.

Just kill off iov_iter_get_pages*, please.  Or at least stop using it
where these types matter.

