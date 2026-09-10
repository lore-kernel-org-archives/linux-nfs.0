Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 740D63C09E4;
	Thu, 10 Sep 2026 07:14:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789024476; cv=none; b=qkFkFnlSJCeE23UTc6scjdioZvRr/8DVaGJmL9ivKSYdLkbmtBCxlJcwr9V6WzZA9fn1IZnFOU8qRvuICaluSpz/Cdfl2TcUNpXdOqeomQzYxJLA7tRT7wSJ03nLsB/ZBd5VbX12sP7JfgDem/eHw/VNBlZdq7Wxu5qiitadpjk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789024476; c=relaxed/simple;
	bh=Thk0WpRybF+dmcauY2m19M72ihu1ldfX/TxSxZ/61bM=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=dteeolQTIE6jgbwPU/C+bPBhaN5GUZG2TFEcKAwFOKiJWOC0IaJG0Yb0e0qSsyuEkcdTPkNod3sEYsKCOPCjQ9zc3hp0G2YU23T+FKfj+B1S8gyqPRhe5b+z01YocDEodJ7zUd/YmQ83pnVPo9lVuX3LmPFFBX5Vbtp3NjX+5hM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=ULnIYf0A; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ULnIYf0A"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=SYD3VMiXbpdpZ22/Tg+CfHJAwLvgdRa6D0M7uCmd7cw=; b=ULnIYf0AFmn73VVROHfiJzH1tl
	UGHn7ISL0KKM99Vidd6OgKsOA/gLny9bkDHLXebd0osDemRXBhg62yMxMuc29F3FM1uu50NkAe5gm
	EhyyI40yb/+RitrgFGiLf+8hJ5URCwH5GBVVwCzQul9l6WGVojNxXLtg3wqbp2vyHDHT7KH6igxaf
	/hXt/s1wOG9enCGYp1oib/ZVdd6lQ/m5rd1UCdLZIb5JWBD87FkvvqW6dbnkB6YZEBCKPCB1WRifG
	lfQ8ry02lenE7yZnvOwd7OJ9rQXQ0JDAgCIB+oeyJcd7OoYMi8UFD+iF67hB+F2Z8RnZelAEiO368
	RL6v1IDg==;
Received: from hch by bombadil.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1x4YzP-0000000DbWw-1K02;
	Thu, 10 Sep 2026 07:14:31 +0000
Date: Thu, 10 Sep 2026 00:14:31 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-block@vger.kernel.org,
	dm-devel@lists.linux.dev, axboe@kernel.dk, cel@kernel.org,
	jlayton@kernel.org, david.flynn@hammerspace.com
Subject: Re: [PATCH 0/4] block, nfsd: fixes for sub-sector bvec direct I/O
Message-ID: <aqJY16I2Zc2PRlCH@infradead.org>
References: <20260908163232.30774-1-snitzer@kernel.org>
 <20260908163448.30841-1-snitzer@kernel.org>
 <aqA5qgfUTbNi0nHJ@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <aqA5qgfUTbNi0nHJ@kernel.org>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

On Tue, Sep 08, 2026 at 12:36:58PM -0400, Mike Snitzer wrote:
> Apologies for the git-send-email misfire.. still not sure what
> happened, but will sort it out for future.

When you do that please also don't mix unrelated bits.  The two
block driver fixes should go to linux-block, Jens and the relevant
maintainers and re pretty much unrelated to the nfsd bits.

