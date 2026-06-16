Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 281161FFC59;
	Tue, 16 Jun 2026 12:39:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781613555; cv=none; b=UnAl1u2PNQiR1mFL5RGjsplsM8GwGeyn0ZPWWktLeZkoKBTaSzDNTdAEMVnsQjXdVW/J76QlsIaHAsfd0Jp2ILB7HSebYrux6kLFcMECbhvTyttBhfaJqxSTqXL6JdMR9JSf8kOC+ps7FL89ODwkTCnHa0HkODayQkHKyKZUYlc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781613555; c=relaxed/simple;
	bh=jLVmUs0h5h3IaSBoYYaiyzR1phrnWSJ/3wq7JcB45ME=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=kVqfXxefPTJXO+TAPM/FezLONen5TFZrZc3LROiqvXw1nJnnyLdFLXczeDDnsj/C81rKL8p0x9phpNiHrWD/XtoDnmvEAMswhpjwbZMOK75vtyb3U75RoomeF+ZsTNWRgiqZkHKFOHhFfkpIJU5ltHTa0uLW8xZl4oooPaIaHb4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=zCeou/M6; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="zCeou/M6"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=5EdZEQr56NngtMqetLIh7uZxlqXA7wuIkjKsBUo8El4=; b=zCeou/M6O+/c/sRe+2gVAa7PYn
	/KGY5iI9ZorqbKaBi5gXM79A0Hdh87LTj912G443HMxkWrGn0vWchAG3TFECfQnM6v2lC/uSjBqoL
	unuBQjir0+H5uXtGG+05z7ucyZOR3NZABpZ7FpeNTbGirx4ZEz4FAR6SX5JEPMTJs3QKNHb8IbzXe
	hJKSVJQ8C87eIs1+oQfvfAYMlUhbS3Kmcvbh4MlMQ0PC+8gj2+I35CR8YcARLds8XWm4PWNEx5RcB
	qN3CmCnObaGamY5XTxdYAdmKdHlFGMP265JrzvBpMWrwOKmazoOKLhJSUJMFBSoGutNBxFM4b5WQ2
	bOx5tseA==;
Received: from hch by bombadil.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wZT4C-0000000FlxD-2thP;
	Tue, 16 Jun 2026 12:38:56 +0000
Date: Tue, 16 Jun 2026 05:38:56 -0700
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
	Ilya Dryomov <idryomov@gmail.com>, netfs@lists.linux.dev,
	linux-afs@lists.infradead.org, linux-cifs@vger.kernel.org,
	linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org,
	v9fs@lists.linux.dev, linux-erofs@lists.ozlabs.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v4 00/30] netfs: Keep track of folios in a segmented
 bio_vec[] chain
Message-ID: <ajFD4ELy4yBpu0fb@infradead.org>
References: <20260616100821.2062304-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260616100821.2062304-1-dhowells@redhat.com>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

On Tue, Jun 16, 2026 at 11:07:49AM +0100, David Howells wrote:
> Hi Christian,
> 
> Could you add these patches to the VFS tree for next?

Really?  Not only are we in the merge window, but this is gigantic
unreviewable series, which consequently has none of the relevant
reviews.

Please try to work like everyone else and split out useful parts.  E.g.
if your new iter type is useful there must be smaller standalone
candidates for it that can explain the use.  Having to wade through all
of netfs to try to understand it is not really going to fly.

