Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E03B0317165;
	Wed,  4 Mar 2026 14:06:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772633218; cv=none; b=I6UNCA2rSgr9ALxTf7UvyId0cT1KewFgpzcjuCVopDFXfnr1RJF6+0OLidnoccIuk/T4lnQwr9fJ/yfkDCGxAh54boEqt6pwU6QXlu/hZn2jDETLkQmnqVJHbKgt70558GgpzeVoXmV2U3K0aUoqezyQXjiRbq4Xu+Frn4I/zu4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772633218; c=relaxed/simple;
	bh=VUkKOHHwR4DUqNl7CIoYkjEs34HKeKA+DvhqCHfXda8=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=XR2nXniE405tfhWF166h4hgkf4mJNJ6BJnI6aqtluAlnklnxVDwyVlbkYdZTUH2bAo2lvko4rekc108+vJJ93IF61ksH0cJccgV8trqSyFoB52/eDpaIRWJx0SOX5WJgyjMy51TKELkkU0uy6zzaYjVq+arkXQAds0novjiBTlc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=itEE5yL7; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="itEE5yL7"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=xqxwF+gq0vpYABTAm5oTRzQyr7fLwLpJQ2d9FH5PKsY=; b=itEE5yL74fTzhgAjiXSjzWrWxa
	tkS0tph6z/o24xtAwqxinzTa3LTdHa4hLb5Yz9BZj80NDy4k+VdepgO0JgJAI9zACjWGPvmhXFyL1
	AARQPMlrorYLcUnvXfHqHVxTQmSqqpYSYVVjFgnEajMdVwraIxdiBOgSRBxQgs5FF9njsK65W4UB1
	ywjq1fZFcIbt4xN+SEqb2suW0+wRtyX9uSzRfxjysfy0QSV7k57nH7IGtNColVPOwukkaP34Q2xpm
	ukTRtBs9wzFDTxj+fVro4FCB82T9PDK+KIvMiWHFrYtLS2yGqGZSdQ+T77FJEAeVbZg6n0PXKeU/O
	cbpdSYcw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.98.2 #2 (Red Hat Linux))
	id 1vxmsG-0000000HKBE-09qn;
	Wed, 04 Mar 2026 14:06:52 +0000
Date: Wed, 4 Mar 2026 06:06:52 -0800
From: Christoph Hellwig <hch@infradead.org>
To: David Howells <dhowells@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>,
	Christoph Hellwig <hch@infradead.org>, Jens Axboe <axboe@kernel.dk>,
	Leon Romanovsky <leon@kernel.org>,
	Christian Brauner <christian@brauner.io>,
	Paulo Alcantara <pc@manguebit.com>, netfs@lists.linux.dev,
	linux-afs@lists.infradead.org, linux-cifs@vger.kernel.org,
	linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org,
	v9fs@lists.linux.dev, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, Paulo Alcantara <pc@manguebit.org>,
	Steve French <sfrench@samba.org>,
	Namjae Jeon <linkinjeon@kernel.org>, Tom Talpey <tom@talpey.com>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC PATCH 02/17] vfs: Implement a FIEMAP callback
Message-ID: <aag8fPUDCY_g-_LY@infradead.org>
References: <20260304140328.112636-1-dhowells@redhat.com>
 <20260304140328.112636-3-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260304140328.112636-3-dhowells@redhat.com>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

On Wed, Mar 04, 2026 at 02:03:09PM +0000, David Howells wrote:
> Implement a callback in the internal kernel FIEMAP API so that kernel users
> can make use of it as the filler function expects to write to userspace.
> This allows the FIEMAP data to be captured and parsed.  This is useful for
> cachefiles and also potentially for knfsd and ksmbd to implement their
> equivalents of FIEMAP remotely rather than using SEEK_DATA/SEEK_HOLE.

Hell no.  FIEMAP is purely a debugging toool and must not get anywhere
near a data path.  NAK to all of this.

