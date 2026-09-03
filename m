Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 862DD54763;
	Thu,  3 Sep 2026 06:06:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788415624; cv=none; b=FiGqcDo9qcTaKXQ0y8TlehHFtuEwedRf7AUQibciweQItPAH4fi3DdDlGcyTlrTp8TM1a7tr1lYlEc40otccU7D77nwiZcAAMeIjYT13rUYIxh1P7d60bBpnqU72ASOCEJYl5/HAm85ABnoTPOd2M+jgVezxQq2IR2P88f9rtzY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788415624; c=relaxed/simple;
	bh=MtXGGnaB//cIXib+7Ja611fuWGCcKoBSZueZSIWICZk=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=qG3jgJXkUOGnSvlm+nR6cgGRfAaZq5hghZFogCRRUpnUaSqrcYjOs8KPXBmsWwLrlpUrJ7r4GhNfVXEIH+NqMHzzocB3zb7OESmBHZVR4ktiP8QzjOV5i1mVB4oNTOsCI4kXRA0C3xmOp8c487xknr+3210L2UMpuJoDTj6nV6E=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=iOFOO94I; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="iOFOO94I"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=HpHIM6EYgD3LFqRo4UeY/HdeHCEhzL5x2gf9Hr6c2As=; b=iOFOO94IlAKiLitTeC8cPFrRcc
	Vd6TfSV7EkxpMY0epB9jCn8rmR+LQsZQws5lIvwXeIaJxcRHoM+zm9nWyrX2ovpAfyg2x8hImuiIc
	dqLamJXQnhD7UY9IZrYWygE4Jh77K/UGI57A5K3hJdA+Jee1Mi1zcpchxJZbdz8/EnkMrTgfjBieF
	KZPfyHtijfrmoSPvWM9O2iy8Cq7wGFnsoLgRCflF53yRTPc54Dvg/jUb1xGPaC2arDfe+8W5Fk1D9
	EfGrJa2KHPQg1ENHtQ7qAxCkm7gaeK7rK4pm2hngDxr/ubl+LUnxWMC70IaJQPHN/R3vTtVpazBHE
	L7zUw/pw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1x20am-0000000GRmn-12az;
	Thu, 03 Sep 2026 06:06:32 +0000
Date: Wed, 2 Sep 2026 23:06:32 -0700
From: Christoph Hellwig <hch@infradead.org>
To: David Howells <dhowells@redhat.com>
Cc: Paulo Alcantara <pc@manguebit.org>,
	Christian Brauner <christian@brauner.io>,
	Matthew Wilcox <willy@infradead.org>,
	Christoph Hellwig <hch@infradead.org>, Jens Axboe <axboe@kernel.dk>,
	Leon Romanovsky <leon@kernel.org>,
	Namjae Jeon <linkinjeon@kernel.org>,
	ChenXiaoSong <chenxiaosong@chenxiaosong.com>,
	Marc Dionne <marc.dionne@auristor.com>,
	Stefan Metzmacher <metze@samba.org>,
	Eric Van Hensbergen <ericvh@kernel.org>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Ilya Dryomov <idryomov@gmail.com>, netfs@lists.linux.dev,
	linux-afs@lists.infradead.org, linux-cifs@vger.kernel.org,
	linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org,
	v9fs@lists.linux.dev, linux-erofs@lists.ozlabs.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v11 00/36] netfs: Keep track of folios in a segmented
 bio_vec[] chain
Message-ID: <apkOaPegouqBcHee@infradead.org>
References: <20260902173350.3468672-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260902173350.3468672-1-dhowells@redhat.com>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

<broken record mode>
Please split out changes to core infrastructure.  Make sure they are
also useful and used outside of your little corner.  Ensure they can
be an are properly tested by either having common test exercise them
or adding new easy to run test in common testsuites like xfstests
or blktests.  And make sure the changes to the core code are relatively
self-contained and reviewable.
</broken record mode>

