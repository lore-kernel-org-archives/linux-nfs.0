Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 808453BB9E3;
	Thu,  9 Jul 2026 06:22:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783578167; cv=none; b=DNHXk63F/WcWpSOrU2zBJUwr/8w823PMzww31UjQEgav+TzWjkctvKq4+juhD9FvQDWoAuvUUcEylQPW7VUo3KOAFBmT5dNSjOeBKVdC9lWGWZdPqCTInLrCLmScncqebTSMijpdrouz1SVCUT6urptvp81okKWNaHWvf02J+uM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783578167; c=relaxed/simple;
	bh=zfpT3sX54bTbBEQeU+F4ru8vBoBJn7jSFRhdYmYhqNE=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=jF5HCyf/evogQPa0DbG8j25EagD+5Sgmq58yE7asykwDqbRcr+mokD4dI7BaW2/ZMIRV9ZMQWbmA/x78uTDpgmxfDrDq+Y+WjuaFnh4qHsN4X9aRkMlFXnkMN5L+OckFo8q6e1CishCkFRIr2PQVqy8TxPcfkGNv0dKLemG6upY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=TxLl8m/b; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="TxLl8m/b"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=EAywz+hiKhqdw365nIbaeBzJ8UbXeVL7JDmIYJCVkAk=; b=TxLl8m/b9FuKBBioATGr0g8hzp
	WrjGhfz3c/eOmAJLe5S2Q4U11NzwhPtVLyi27gacDu1LoS1TzQc61S4qhG3JFfnlkCJApCkPhRxHP
	Q8lhx/csYNltvaul4EjL8c/sva/D9sy7c14WrBJ/7dBLYmpojI63mS8LoOiZmtobLEh4vVzGMyU9R
	zL1wT+v1JJ6InCDtFt9/hl3Iz7he/vxNfmEzHi+4vMiwBR+RORO4pDbnh7yxrvA/6k2/CdpK+8e92
	m+V+AAgPyspgJQHUH5vgo55JELAj+ecYzqwcQ1SroaZ4U2v9uz8pAK8VLDBRpyXlfKnMIioel51ac
	zr4pvyig==;
Received: from hch by bombadil.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1whi9k-000000018tH-2Kd7;
	Thu, 09 Jul 2026 06:22:44 +0000
Date: Wed, 8 Jul 2026 23:22:44 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Pranjal Shrivastava <praan@google.com>
Cc: Christoph Hellwig <hch@infradead.org>,
	Matthew Wilcox <willy@infradead.org>,
	Trond Myklebust <trondmy@kernel.org>, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, Anna Schumaker <anna@kernel.org>,
	Shivaji Kant <shivajikant@google.com>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v2 6/7] nfs: Optimize direct I/O to use folios for
 requests
Message-ID: <ak8-NMsNPOB3zpF-@infradead.org>
References: <7ee3bcfdd6126c93cbb1c219bf601182b95c10d9.camel@kernel.org>
 <ajGGpDvzZdkGtSbN@google.com>
 <ajP8ZTTLYkICFTO_@infradead.org>
 <ajQ21kH1ZVajS2Y7@casper.infradead.org>
 <aj4iiD5C_yyLeb3U@infradead.org>
 <akevQfFVteCOD6LM@google.com>
 <akfAgy52s_Gch2KG@infradead.org>
 <akzsO_vmYX_7Umjd@google.com>
 <ak4A6IEmWNi27I2d@infradead.org>
 <ak44z-X-SKKhkBkg@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ak44z-X-SKKhkBkg@google.com>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

On Wed, Jul 08, 2026 at 11:47:27AM +0000, Pranjal Shrivastava wrote:
> > Sorry if I'm thick, but I'm not sure what "folio" move means.  In doubt
> > if you think you can get a series merged quicker without a later part
> > I'd split it.
> 
> Apologies for being unclear. I meant I could post a standalone series
> that moves NFS Direct I/O to folio, i.e. break out Patches 6 & 7 to
> another series, if that makes sense?

Sounds good.

