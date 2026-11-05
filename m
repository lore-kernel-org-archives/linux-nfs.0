Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=198.137.202.133
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793866602;
	b=xQSCwuHAlfzpbvt8SLvhQQ8dZprRy4gYLJfBzqt9fz5wBZOX0m2PA0znI/t1nnzD5yT7
	 /JhfOSzbbELGIQLpiHVMA91+lSTj2V5EjhTPEwR3zTRNCrh9NnVoFAphNBefHQ8Y7UQHS
	 bh2xRKXdb6YxajNOr3bBUDn/ZLhUiJvZtHOvcSP7INPb9EMV3s2sJsO8q12WxOcE0Nsnc
	 EL6DuVLsLRhjwCFRL3gDhkXr+SJ+R6hO9WDFvmyKKpvOfNEKUSQFTzjVd+h9cUqw/p6iZ
	 d6uEoeohFotQ7GK2d8GE6qtKjG1W4Dcu0XS0xos6OgDVpZoCldLgAOUj2tvvYZ618Hg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793866602;
	h=DMARC-Filter:DKIM-Signature:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-SRS-Rewrite;
	bh=Ogk5yRUelJumT/vXF9GUjKZICCQOq7QO32mohhH9l7U=;
	b=XOK1ejiRsalPN6L8MS24vSpwIOKgbkOQ4dxxsUWKhJrKlWz5zyoGOIilMipZhEvWGw7Z
	 EWXg+8ByiIcBlf2J4tLj5uuD08Viq7vjZPVjuWWN0tnL5rsdaSAeBIIId8m0z2ZS6idWB
	 tMziLkm0viijVLlnamUvVVZhG4vrH+gJkkIa1peYEyI5nyXjv8gKe4+eMaWRqoNUKxjAH
	 LYAGNNN0GhQLe0dJnH44vvYfLcVtvHiczFgT01wx5MhSevGt39YPM/1lzOuLZY/s6qcUD
	 SpBetuDaxgvpfjK/aCNjBSh/cXYDTHJyDVCEcB2ThXH4b5AJVjJO9iM5LumrHn/MECw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=infradead.org;
	spf=none smtp.mailfrom=bombadil.srs.infradead.org;
	dkim=pass header.d=infradead.org header.i=@infradead.org header.a=rsa-sha256 header.s=bombadil.20210309 header.b=jN+fplrv;
	arc=none smtp.remote-ip=198.137.202.133
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B6977606A329;
	Thu,  5 Nov 2026 08:16:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org B6977606A329
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=infradead.org header.i=@infradead.org header.a=rsa-sha256 header.s=bombadil.20210309 header.b=jN+fplrv
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=Ogk5yRUelJumT/vXF9GUjKZICCQOq7QO32mohhH9l7U=; b=jN+fplrv8eDDiKZb5BtCV6sQK0
	2gIRUYEjAasriqpaZ8Ktb1GNKyGViIzNKrm7ubyA8nN3bdh1+NS2WfX3mytqRhw+4GPetuJrhtSD0
	iLQt/Av85K3JpMyHSZ7PQ0dsarvnS1yld2l49boOjgI2303qTiOwPDtoTLRYg15+PselLt0s3tLWQ
	UpiFJln3WsWLiX4akJX6uIelTfUe7ogiJP7YShsMNcxLgd/0LutiQWk1drW+SgQxb6YuaFPmih12D
	FrM/N6/l0SCIqnwy/iaQqy0cS2hWofA2J4XHrJsrjSCjdaJTvzQPFaIC8ZNzPSlwQ9IIvtBs4dOIE
	yaEDJ0Lg==;
Received: from hch by bombadil.infradead.org with local (Exim 4.100.1 #2 (Red Hat Linux))
	id 1xOseG-0000000873r-1akD;
	Thu, 05 Nov 2026 08:16:40 +0000
Date: Thu, 5 Nov 2026 00:16:40 -0800
From: Christoph Hellwig <hch@infradead.org>
To: =?iso-8859-1?B?Suly6W15?= Jean <jeremy.jean@oss.cyber.gouv.fr>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Subject: Re: [PATCH] NFS: blocklayout: reject oversized SCSI designators
Message-ID: <auw7aHnCdQij7e6l@infradead.org>
References: <20260826080736.1431809-2-Jeremy.Jean@oss.cyber.gouv.fr>
 <c65fcdbf90ff456f00a80bbb1086fbca@oss.cyber.gouv.fr>
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
In-Reply-To: <c65fcdbf90ff456f00a80bbb1086fbca@oss.cyber.gouv.fr>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

Please resend against a current kernel.

