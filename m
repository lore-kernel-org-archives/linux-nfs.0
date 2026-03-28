Received: from mx1.manguebit.org (mx1.manguebit.org [143.255.12.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D31EB40DFDE;
	Sat, 28 Mar 2026 18:34:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=143.255.12.172
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1774722900; cv=none; b=oSIo5tsz5uokXC4AobbkuSG4LSPdOnL2PBUw060XvynaZnPEQrC2wMTYjAKacHvJ4ZnaH54HFv0octmisn/KswXozoJcv2eXTzE7lIxN2TEbjw2MN7kQhZWgEdGuEr+Sb5+ZUFJNMe9HRQshvVXD2vlxCidVbcodz+fWSr0/4yI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1774722900; c=relaxed/simple;
	bh=BRQ/bZjMzHq/hHbYlPQLno+iBSau6MiQLkViAU1QO6U=;
	h=Message-ID:From:To:Cc:Subject:In-Reply-To:References:Date:
	 MIME-Version:Content-Type; b=WRjMd7HnxHhUreoAVV2n1kpoZdavLUO14rGFc7COtR1rUDwjKjAARt1nQS0hOqWI377Mz8AmNYIhZhD3xSt/8bUvKi7i3Hgiq88nWAasxKOIFeBTFvfGt5HvAX8FC6mS97D5aOQkqrrL3Ilbr3zNnh6XIuoCGmZxp9yLhx/QOr4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=manguebit.org; spf=pass smtp.mailfrom=manguebit.org; dkim=pass (2048-bit key) header.d=manguebit.org header.i=@manguebit.org header.b=h3K0MwFp; arc=none smtp.client-ip=143.255.12.172
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=manguebit.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=manguebit.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=manguebit.org header.i=@manguebit.org header.b="h3K0MwFp"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=manguebit.org; s=dkim; h=Content-Type:MIME-Version:Date:References:
	In-Reply-To:Subject:Cc:To:From:Message-ID:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=1ub/AEo4t598Shwt8YJggaAGXX2PtzkMnlWDy9kFv50=; b=h3K0MwFpfg1kOVZtxuEJyHiHDU
	tX+sBwyY714azoskpQItXMe6WutTWzchu+ys9rlEXgKMUrtoQP+IMK7Hh18U7+mCps3nul3d2umbw
	IJHgA8WWL0iyYLsgndr9cSUZImNlxqScEJ5a/cY81IMsSsmZddiHNvr2hSgXlDmbKrffLxIi7kQ55
	TEZXxMr/ZXA7DsiyEpV7PRv0ffUkbX//iDCTtHQnEthyuAIRc5hoXiq5/kBimytSBr/dMF3/I69Wd
	VNe0A33tRpWQ2TFaN+m/7OfnlPqLzI9sedM1p6tNFek3X4nJGAr+Mk7msLIlTjBzj+mSm7B1kiDht
	0HhLASww==;
Received: from pc by mx1.manguebit.org with local (Exim 4.99.1)
	id 1w6YUr-00000001nnY-0QeS;
	Sat, 28 Mar 2026 15:34:57 -0300
Message-ID: <16a6ca6a01cb7f65cf71c1358cf88f53@manguebit.org>
From: Paulo Alcantara <pc@manguebit.org>
To: David Howells <dhowells@redhat.com>, Christian Brauner
 <christian@brauner.io>, Matthew Wilcox <willy@infradead.org>, Christoph
 Hellwig <hch@infradead.org>
Cc: David Howells <dhowells@redhat.com>, Jens Axboe <axboe@kernel.dk>, Leon
 Romanovsky <leon@kernel.org>, Steve French <sfrench@samba.org>,
 ChenXiaoSong <chenxiaosong@chenxiaosong.com>, Marc Dionne
 <marc.dionne@auristor.com>, Eric Van Hensbergen <ericvh@kernel.org>,
 Dominique Martinet <asmadeus@codewreck.org>, Ilya Dryomov
 <idryomov@gmail.com>, Trond Myklebust <trondmy@kernel.org>,
 netfs@lists.linux.dev, linux-afs@lists.infradead.org,
 linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
 ceph-devel@vger.kernel.org, v9fs@lists.linux.dev,
 linux-erofs@lists.ozlabs.org, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 09/26] mm: Make readahead store folio count in
 readahead_control
In-Reply-To: <20260326104544.509518-10-dhowells@redhat.com>
References: <20260326104544.509518-1-dhowells@redhat.com>
 <20260326104544.509518-10-dhowells@redhat.com>
Date: Sat, 28 Mar 2026 15:34:56 -0300
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

David Howells <dhowells@redhat.com> writes:

> Make readahead store folio count in readahead_control so that the
> filesystem can know in advance how many folios it needs to keep track of.
>
> Signed-off-by: David Howells <dhowells@redhat.com>
> cc: Paulo Alcantara <pc@manguebit.org>
> cc: Matthew Wilcox <willy@infradead.org>
> cc: netfs@lists.linux.dev
> cc: linux-mm@kvack.org
> cc: linux-fsdevel@vger.kernel.org
> ---
>  include/linux/pagemap.h | 1 +
>  mm/readahead.c          | 4 ++++
>  2 files changed, 5 insertions(+)

Reviewed-by:: Paulo Alcantara (Red Hat) <pc@manguebit.org>
