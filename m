Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 74D5723BF9F;
	Thu, 16 Apr 2026 05:28:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776317328; cv=none; b=r8L6rP407cfMbtZLljZYoZyTytywemaulsDZIazx4t/yL6k/YGKAGGH9YZSNjVY0odKWcSkvNIGYh38G6+Zaikjmn2Q5l7VD+TXnLbiMgsoROqkFwoV25Eo10t/LV3bjicu/37usRwVgKKaGrTrgOAJGbnUPVbq0DluZQUTn8dc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776317328; c=relaxed/simple;
	bh=f2Bz74BP2pIsx7bwNgOtMkR7gs2kpsZ/mqcprBDxtV0=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=siPqngCgSzCfX4AVmM0ashh8uhjLJ+Miw/LH22cDQgPXO6x8bNYDSOoTRNCHfxV8staYu+grfF1x+jsxmgklxnXYOsuvhcC4wZkq+u/W6werpBAvM9i72cOZCZkFljDxdUL19x8YOIwexgTdnI3p0CzVuMCwC+C+Qv0/45hk9MI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=vhp/HOv4; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="vhp/HOv4"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=SIkOAeDqR589cIp15aYU7JLk0xPA3K6/5hi1SlVRiiA=; b=vhp/HOv4iOOhl78LtmifEWmYv+
	gUQjzQk17apUxTKcmxwJ3nAylslHKgJrs4KwXWvzeE6FlivFkOcVpEVUgTa8cf2Uw4FDlor2WUtb5
	yDDfXjaqZf8eh61b8kVTFLg0N1oV2HENk3Kg7DappGTvmDjgyzYXX64A236mGRTA2dtRF8f6k1xj5
	oHdorqDH9wQkOaIb1RbgU8jv+m8URt+e5FGeF8reSz3BTk25tvtYs742DuaeSN6GdZ1kSMnBK30Vi
	4bIbMOiIqAHVXMm9HZGA+W3nNALREq+N87miKJULDJI9QRzajx6ncHGrk/gGpg3+5+080acO1MqA4
	VqW7LMRg==;
Received: from hch by bombadil.infradead.org with local (Exim 4.98.2 #2 (Red Hat Linux))
	id 1wDFHN-000000020IL-0KzZ;
	Thu, 16 Apr 2026 05:28:41 +0000
Date: Wed, 15 Apr 2026 22:28:41 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Pranjal Shrivastava <praan@google.com>
Cc: Christoph Hellwig <hch@infradead.org>, trond.myklebust@hammerspace.com,
	anna@kernel.org, davem@davemloft.net, kuba@kernel.org,
	edumazet@google.com, pabeni@redhat.com, chuck.lever@oracle.com,
	jlayton@kernel.org, tom@talpey.com, okorniev@redhat.com,
	neil@brown.name, dai.ngo@oracle.com, linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org
Subject: Re: [RFC PATCH 3/4] nfs: make nfs_page pin-aware
Message-ID: <aeBziXT8zVVtfRVL@infradead.org>
References: <20260401194501.2269200-1-praan@google.com>
 <20260401194501.2269200-4-praan@google.com>
 <ac341x4RXKoShXsB@infradead.org>
 <ad6cVbDGy3alQ2uK@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ad6cVbDGy3alQ2uK@google.com>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

On Tue, Apr 14, 2026 at 07:58:13PM +0000, Pranjal Shrivastava wrote:
> > > +			req = nfs_page_create_from_page(dreq->ctx, pagevec[i], false,
> > >  							pgbase, pos, req_len);
> > >
> > 
> > A lot of this code reads pretty odd as it's overflowing the lines.
> > 
> 
> Ahh, my bad. For some reason even checkpatch didn't catch this, I'll fix
> this here and everywhere else.

checkpatch is unfortunately completely broken :(  It misses lots of
important bits, but at the same time has complete incoherent and crazy
warnings.
