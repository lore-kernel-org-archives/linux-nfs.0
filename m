Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 31C062D595B;
	Mon, 11 May 2026 06:35:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1778481312; cv=none; b=WG41KyuyIcumMkDQS5ISDtOSLnUlyZQmbxHPdf6g3TgP2w7J1lnWcaBBoIi3y3uauoB87LBubhxXwKTf1C2P9ISglZ9IcskQj1mIA6BHm3RPKE4lb+lavYcrJZSECIcGd619rOg3anbcXNxQqX6FYKr1Y5S2qNSnTIU2xmFyIrM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1778481312; c=relaxed/simple;
	bh=yRGgmTayJ77v09teJ5jBo4+iorYjGI1uK6xrVkB+fQs=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=FwYWxPhM96xwT6V09qKfQWaS26Zf+WNPlSxR7tfN/l0HszFK6umZiR7m1+obLdj6fsoj7nC5tlocF7T1UY/BWcCg1ALyrz4G/QtkFvkzakJ1K6zGqLyEfrSCrfp1fmOsXg7xfYRu2akEQJZjz2/r/KseY1+d9KP6VN7t0ZLrgc0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 3F45568B05; Mon, 11 May 2026 08:35:06 +0200 (CEST)
Date: Mon, 11 May 2026 08:35:06 +0200
From: Christoph Hellwig <hch@lst.de>
To: Caleb Sander Mateos <csander@purestorage.com>
Cc: Dmitry Antipov <dmantipov@yandex.ru>, Jens Axboe <axboe@kernel.dk>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@lst.de>, linux-block@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, lvc-project@linuxtesting.org,
	Fedor Pchelkin <pchelkin@ispras.ru>,
	David Howells <dhowells@redhat.com>,
	ric Van Hensbergen <ericvh@kernel.org>,
	Latchesar Ionkov <lucho@ionkov.net>,
	Dominique Martinet <asmadeus@codewreck.org>, v9fs@lists.linux.dev,
	Ilya Dryomov <idryomov@gmail.com>,
	Alex Markuze <amarkuze@redhat.com>,
	Viacheslav Dubeyko <slava@dubeyko.com>, ceph-devel@vger.kernel.org,
	Pranjal Shrivastava <praan@google.com>, linux-nfs@vger.kernel.org,
	Christian Schoenebeck <linux_oss@crudebyte.com>
Subject: Re: [PATCH] lib: free pagelist on error in iov_iter_extract_pages()
Message-ID: <20260511063506.GA26080@lst.de>
References: <20260508111329.329943-1-dmantipov@yandex.ru> <CADUfDZpC5WOBY4_xvAy6ORtgQsxwFYj3Px81RdN7NKQZBFdJSQ@mail.gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADUfDZpC5WOBY4_xvAy6ORtgQsxwFYj3Px81RdN7NKQZBFdJSQ@mail.gmail.com>
User-Agent: Mutt/1.5.17 (2007-11-01)

[adding authors and maintainers of relevant code]

On Fri, May 08, 2026 at 11:33:50AM -0700, Caleb Sander Mateos wrote:
> iov_iter_extract_pages() will only allocate a pages array if the
> initial struct page ** passed is NULL (see want_pages_array()). So the
> condition pages != stack_pages will never be true. Indeed, it looks
> like *all* callers of iov_iter_extract_pages() pass a non-NULL struct
> page **. Would it make sense for iov_iter_extract_pages() to require a
> pre-allocated pages array and remove support for allocating one?

I think the idea was to support this to replace existing users of
iov_iter_get_pages_alloc2.  Which is urgently neede as those missing
the proper page pinning support.  OTOH we should not keep dead code
around just in case.

For NFS, Pranjal has an initial series to convert away from
iov_iter_get_pages_alloc2, which makes use of the NULL pages argument
to iov_iter_extract_pages.

For 9p, Dominique had an untested patch in December that drops
iov_iter_get_pages_alloc2 in favor of a much better high level approach
that doesn't even involve iov_iter_extract_pages, which seems to not have
made it anywhere.  It would be great to get this going again.

net/ceph/ needs to also do work.  Not an expert on the code, but given
how it is based off the encryption flag it looks kinda fishy and
iov_iter_extract_pages might not be the best direct replacement.
