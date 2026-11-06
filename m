Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=198.137.202.133
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793978684;
	b=LmjY7r/cXk9l48nzwfvBPNQlp1iWluVw9LsVd22Y6lzb1Db9+BVQJKGPMUjjeqfQ2SE2
	 q97+y55zYE7Y/sJ4qxE9jiOmJOe510r3Wv4c1g4gcF3tSDE6035HkpN/bKH/4tCMZ4dxN
	 /5nVmVnU2cSY7VGwkbsRAiYCopeyN6PIGce1RLsxFFtQjx3aybiT04p8h5fh+nKzpOds6
	 o26es/qkTO9yg4m2iV5F7x72B9Pj9hIkfH+cNg4knxTIVbZly8p1rNffzn8H7GiyKkZjq
	 v8gXrcc/x/L2S2D7LQGTSwaFyKKmM8rjvUg2ifD+vRYNCT2JkvbAHrUBLw7CKS55aeg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793978684;
	h=DMARC-Filter:DKIM-Signature:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-SRS-Rewrite;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	b=oSskFJbJEaylJ/THwobGj7rRgD+FniJvTGDUayUDsCRkeQbsKCFiDs+IN90ph7DEubxv
	 atP9QHmIL4tsx4xpZN3/d2J1lRX+Qqa1S4NliPaYxrA3s15LChTL/z3j68HHgG0qeL/WB
	 8GBSH1AmBDw5B1KbRiJhiymoFzBjKnUxqrmClT4MzMI6IzUxAkcZgUz/a/cJH5BJFepS3
	 4S1HwctqbJPSqG2TCYARdL2Q3YcLMkTxNuv+4/HShuiZQa1vclj/A8IPqpABEKc0a9qJg
	 ij3RP3ivme5xKAz67J5vl249RMJfatlFQrfsnHn0qcSVrrsp6zCH7WvyjqeeRDczDYw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=infradead.org;
	spf=none smtp.mailfrom=bombadil.srs.infradead.org;
	dkim=pass header.d=infradead.org header.i=@infradead.org header.a=rsa-sha256 header.s=bombadil.20210309 header.b=JrXH6uAo;
	arc=none smtp.remote-ip=198.137.202.133
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 56FDA606D803;
	Fri,  6 Nov 2026 15:24:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 56FDA606D803
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=infradead.org header.i=@infradead.org header.a=rsa-sha256 header.s=bombadil.20210309 header.b=JrXH6uAo
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=; b=JrXH6uAotgTWF0cDjpJnvfQjb/
	0klTG03fpyWBHHRVIY+2duulNbgVqY6tK9F97pGferSp2ExuB9bxFRagJberKfoGL3Sa+WHAe42ki
	8KEEhI03o0y3d8qGOnKWeQ6a9u5dUMn6y7xUGaaT6YNDCS86VdHx3qkzCh57xp+Tx46b/PYqINB6g
	tgv6+sTbNZ7ueMNOzivig1TFJK5gN5eDlkzQ0QjlNpVg61HxDqFruYUIvzOsrjOuklon0grZl55GQ
	v2f48u1JHrO6vshaP9DrbbjByHzbFC1T7VzlsehflHc8bCSxvHKwG5ULOSzJDyQEfSXvPgbEw7Sdr
	hObZfzjg==;
Received: from hch by bombadil.infradead.org with local (Exim 4.100.1 #2 (Red Hat Linux))
	id 1xPLo1-0000000CoVS-3Sxf;
	Fri, 06 Nov 2026 15:24:41 +0000
Date: Fri, 6 Nov 2026 07:24:41 -0800
From: Christoph Hellwig <hch@infradead.org>
To: =?iso-8859-1?B?Suly6W15?= Jean <Jeremy.Jean@oss.cyber.gouv.fr>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Subject: Re: [PATCH RESEND] NFS: blocklayout: reject oversized SCSI
 designators
Message-ID: <au3xORjyqzJo2QZe@infradead.org>
References: <20261105205536.250173-2-Jeremy.Jean@oss.cyber.gouv.fr>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261105205536.250173-2-Jeremy.Jean@oss.cyber.gouv.fr>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

