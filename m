Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=213.95.11.211
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793783884;
	b=IWCQnJYnoYXKrFJpClHIzTgkOWJM5I/Z5BlJT9OVtiv7oHRx+JqV8ztXm/9+0y7HQ8Cv
	 2+kngzu360i2G7K+PtodWmMI3NPF9dbNKLIdRdWuz607TYbHHOZZHQnhpVOjP0JXu/zb2
	 NOB5VfaXkQ2/QU+4uOUiRBRpFOfzs77zhAO7a+kMY88L4s72xzgy6sMSiXJ8dhccsdUfR
	 atYF/iA4UoO8BpJa6MKPrr3Z70RvFerTJO7cIvI2dK4TYkUEdK9m7nzKZGVEvockh9FrH
	 xm/TZPmg45MzdxCgkHmUY4wMjSL2zXdRnBGRcblplzCvKBwFK/j9gmWJPl/X9kZDCnA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793783884;
	h=DMARC-Filter:Received:Date:From:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To:User-Agent;
	bh=M+g/PqMDYZQI68tfBBcin7qYEE0xbkk7OS+btL9Bc2c=;
	b=TcGzfWHxzS/RcFTOGUUInYyeDWz2DH+o11bLB2z7RKqmsgQA1ImssYO8NwejrV7I5viZ
	 JAswyDtXURT0FSUkgxPRs9OjuqZwA1bip9U2R2hAWXTyLvgTQZYWy2fImacnwp8NYBoHM
	 Za9/875piTxaSzsWLyZosAhV18Y8quPzK3T7f4XRo5jg/4/A6rEfwoAWB1g+opHfiCMss
	 XehlqL1TqkO8cmEknPgwX+7Wp5gRnsDd+8r9Q5BMB5jV9C1t7nlm9Exa+RP6GJwoSmvvT
	 88QGS1dAXotPHuA4UIDZFhl7BuEUIClgwHzSkRwZplVguFcqIa+sohtXFgpgxbenAWA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=lst.de;
	spf=pass smtp.mailfrom=lst.de;
	arc=none smtp.remote-ip=213.95.11.211
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ABF13606A326;
	Wed,  4 Nov 2026 09:18:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org ABF13606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id AF6C568BEB; Wed,  4 Nov 2026 10:17:59 +0100 (CET)
Date: Wed, 4 Nov 2026 10:17:59 +0100
From: Christoph Hellwig <hch@lst.de>
To: Mike Snitzer <snitzer@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
	Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH v10 1/7] mm: move clearing the uncached flag of a found
 folio into a helper
Message-ID: <20261104091759.GC31130@lst.de>
References: <20261103211754.35352-1-snitzer@kernel.org> <20261103211754.35352-2-snitzer@kernel.org>
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
In-Reply-To: <20261103211754.35352-2-snitzer@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

Looks good as a general cleanup independent of the rest:

Reviewed-by: Christoph Hellwig <hch@lst.de>

