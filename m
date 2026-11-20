Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=213.95.11.211
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795191174;
	b=k8SP9v1BenZVhpGQXtzAQwRPTVUy9/IE3yVXlSGyeD9JgpvQKUoAYRldz9UNnhz1Ofz0
	 vq2pUa2nu2zqTovdyNWHU9UEPJher9aHMTk3/BYpoHcvPhgB7f4mtg4fPGuFFd8HKKmbg
	 0X+OOpAsxTHhTZaKT86wdgLR08j88ETIqzCG3CEz3t0WRycBInh1z1dne5q0lqCA9+Z4q
	 XawKQHEcUZdK1z68/f74c2M/gAcuzMTNJxFLbGFNHo/Az3+IFBQ8hXmHHtue1fMm8pSqD
	 8p6tdXSQWWGXz8wpvolqfSTJZTXKAT9uLSCYqApjBiT1UNTgliLIr9KkFQNgQ6jxBWQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795191174;
	h=DMARC-Filter:Received:Date:From:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To:User-Agent;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	b=OtlLsYawpKzC0LyDvUSYjpWh86G2ccfA8WFZlf/Q7q8QVQkoITXPgW0LcTaDVC3VvzH4
	 xDsMi1AOoXonqIg6P/pFTG2qxI2lyhbeHeitaXKcxAKyHFu8hesER5cfBj3ddHwuJsF0V
	 eV9a4gpjZ2U4zGJi/E5Z9/7LHGl+RsyX10NVfNRdoXg5IV9lhD/cUZtgxxiUF3iZH4DBt
	 jrtY/N+sWAKuGaERrAAK3++2gNxqfvqEsabjdzsSqE/Mh1s0i+TkjZzix1jvgKGUzBBCr
	 /4c7LrzgXcuybYp2vg1u90A8/I+rpriwKHgMPLvww0ZHX8GwaCj+Rd4Jiqn7wBdjcTg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=lst.de;
	spf=pass smtp.mailfrom=lst.de;
	arc=none smtp.remote-ip=213.95.11.211
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 18A9B606A325
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 16:12:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 18A9B606A325
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 6B7B168AFE; Fri, 20 Nov 2026 17:12:47 +0100 (CET)
Date: Fri, 20 Nov 2026 17:12:46 +0100
From: Christoph Hellwig <hch@lst.de>
To: Chuck Lever <cel@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Sergey Bashirov <sergeybashirov@gmail.com>,
	Konstantin Evtushenko <koevtushenko@yandex.com>,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/4] NFSD: Reject layoutupdate extent counts that wrap
 the length check
Message-ID: <20261120161246.GA31082@lst.de>
References: <20261119-blocklayout-decode-stream-v1-0-d71322f42c28@kernel.org> <20261119-blocklayout-decode-stream-v1-1-d71322f42c28@kernel.org>
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
In-Reply-To: <20261119-blocklayout-decode-stream-v1-1-d71322f42c28@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

