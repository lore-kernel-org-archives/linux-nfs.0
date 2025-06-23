Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 94A542EAE5;
	Mon, 23 Jun 2025 07:34:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1750664067; cv=none; b=AXVy/usjznr+s16RkScMuRgzLVoW8OJghDnIt/2vWmLFYBe1ImVGZ3OuhFwqsT+SfNnyYeL7DfVV8EWvj7xsZTBb6SAvXKuNE/UWsMTy23P9oWM8ITljmNLyuC1ZklWDqBnUxdUNd7stJVCfgX5dGaeLRlSDvIfjiu1TZTdq2oQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1750664067; c=relaxed/simple;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=R6WpdBaeS9V2XTcUZ5DjZSV5iWMiyrQAJ9S0jQGKfVn4JqSC/CppcF/4zS7m9sHN34syyUcn/u9Rr27ElXmMUsYu3HQIuhS6A9HsY9cjtTS8ulG7/iih7yTnrlqtPZoBQsk1HErFYNzUu5azH+negO712g/CjMmKq/KBYpfrjyA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=WIywZHId; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="WIywZHId"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=; b=WIywZHIdABFNJUQfujK7QlG3p1
	IgIJbtSr0CzYcsrlKvt013AVz8JasZHP4usIXAGQwx4U+bSEyOx16hpoP53HFHH7w0Rdy8aFGuqkc
	Bhfne9pfSysFa2QuXo7iJ/3ntt4cCbzsXyLibQOLiR8u2hPwEa2jOiqMhza7sZBGU/g9ZG8y/zsbv
	VWRG8oV+NMyuRJlihqWLCeMJA2JBd9S5Mar5/jhZ+xDCQz127Jg/i6PfAuhU9Wa8pk/hyyHtTxbHy
	/ODIrh8FHopFFXmdiSaU6CpjmvI+r5w2W1Go0IOxBqKWcrEaMeLmJpkSb0/uLMObUPbvgj61xSUZk
	W1hZvf7g==;
Received: from hch by bombadil.infradead.org with local (Exim 4.98.2 #2 (Red Hat Linux))
	id 1uTbh6-00000001slz-1TiI;
	Mon, 23 Jun 2025 07:34:20 +0000
Date: Mon, 23 Jun 2025 00:34:20 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Sergey Bashirov <sergeybashirov@gmail.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Konstantin Evtushenko <koevtushenko@yandex.com>
Subject: Re: [PATCH v4 1/2] nfsd: Drop dprintk in blocklayout xdr functions
Message-ID: <aFkDfIwxQxd4MBbl@infradead.org>
References: <20250621165409.147744-1-sergeybashirov@gmail.com>
 <20250621165409.147744-2-sergeybashirov@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20250621165409.147744-2-sergeybashirov@gmail.com>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

