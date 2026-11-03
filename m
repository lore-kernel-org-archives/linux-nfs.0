Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=213.95.11.211
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793703099;
	b=RwDwnTVZ9R1durBj+mkso+aUSRiv3QW2ib3jJkWtVy5IR6lgVHeOJ5tWuVsALnE3x1/A
	 JcIbGU5MulvmPaSpLqfaFeVEiQ3z+m2oIPsxSRyAM/qmAWD3bTnXKEqoY6q7S7GBpHcGs
	 tor2pXF+g+mfd10a0uYeh6t6Q6qRnq3aU6fSvKZ7pZZtqboywHdbTf7xHh9y7QJeFcKVp
	 riwLjsXq8hp0a/rOmIS4CkCx6CNWrAJWzcIe8YkQ8yCVJFpx5AZQLOp4t0zSIJVfXOtn0
	 loEEDlujYsbC0iK61SSWwm5/zZb4EVQtBz7RMN8zOSZp7KhHulxqXrM0SdbB1Fh3ioA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793703099;
	h=DMARC-Filter:Received:Date:From:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To:User-Agent;
	bh=tKZDWcIar/lAYH+ykSXDvWJWvnWut4DuuspliFjEz8c=;
	b=LU9RETfFtip9+HSUfYt5SRQAZIcmyP9s2s/tYSM3Sh7VyHuOdUftbUAIu0VB4Q83rTgG
	 F1dVfxKO4AquJkre4cugLjDIIlKIF40y+O4AxwWLwH+27e+KwUW6RHA5qKKHaRTNRimm+
	 BsX+FFCw/igzwVSMdI+M5B7E9ikMcSza9A6IT2WJWXX7ujV8FtQD8skHt5uImF4Lo0OLx
	 2bKAG6tEPmCkZ4iAlQN+XnBo7LJMsOOYa34okcpEkJqD35wJpMXNhpCstJ48+xcswi/mz
	 KNWId1WuLAMXKd/KaZsjatPtDwHqGqTqS6IOw5cJCDI5yj/joltLWBFf1/Crabb4G9Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=lst.de;
	spf=pass smtp.mailfrom=lst.de;
	arc=none smtp.remote-ip=213.95.11.211
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 49BA2606B121;
	Tue,  3 Nov 2026 10:51:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 49BA2606B121
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 46CA068BEB; Tue,  3 Nov 2026 11:51:34 +0100 (CET)
Date: Tue, 3 Nov 2026 11:51:34 +0100
From: Christoph Hellwig <hch@lst.de>
To: Mike Snitzer <snitzer@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
	Jonathan Corbet <corbet@lwn.net>,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: Re: [PATCH v9 6/6] NFSD: drop a shared boundary page only once
 both WRITEs have written it
Message-ID: <20261103105134.GC7296@lst.de>
References: <20261024221152.6965-1-snitzer@kernel.org> <20261024221152.6965-7-snitzer@kernel.org>
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
In-Reply-To: <20261024221152.6965-7-snitzer@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

FYI, this doesn't apply to mainline.  Together with the complete
garbage commit logs this doesn't really leave much to review
unfortunately.

