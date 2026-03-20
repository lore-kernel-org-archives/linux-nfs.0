Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 927AD359A92;
	Fri, 20 Mar 2026 07:51:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1773993085; cv=none; b=F54Q5Zal7j83j8QbRlyisWyjGNOx8jm47QttElbT0b4yvunWOjtB3wF7uUxW0D+Z/0urQUMatt/tyNzulGxCOMjHfLp6Dw2IT9BETx8PyMhPY9fElJBFegKVjw14JcwCEwXj0onrDvKeJB8TKo/2ENjOix0cfrN91LOnAl1DwCk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1773993085; c=relaxed/simple;
	bh=qsklEFQ8YIRRpbjjojWq0ixw6RxehjpELyqi7JbrSjw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=lRPlbipnRhj/Hgi4N4gVi7iSJZrOPEJ6G5+CXv5mnv3rl3rNOniC+9JQ5PomabUJt+MPdUEuY25R/txwa8fGFJs+eeNASCgdH4hvpchNJxMmo2ueY8sqgAeUBxHiX8HbWPZFGn5+1qEhWONm7NBf3+BhiJV41ZcVX6fJUh/ICjc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id C88146732A; Fri, 20 Mar 2026 08:51:20 +0100 (CET)
Date: Fri, 20 Mar 2026 08:51:20 +0100
From: Christoph Hellwig <hch@lst.de>
To: Alistair Francis <alistair23@gmail.com>
Cc: Hannes Reinecke <hare@suse.de>, chuck.lever@oracle.com, hare@kernel.org,
	kernel-tls-handshake@lists.linux.dev, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-nvme@lists.infradead.org, linux-nfs@vger.kernel.org,
	kbusch@kernel.org, axboe@kernel.dk, hch@lst.de, sagi@grimberg.me,
	kch@nvidia.com, Alistair Francis <alistair.francis@wdc.com>
Subject: Re: [PATCH v7 4/5] nvme-tcp: Support KeyUpdate
Message-ID: <20260320075120.GB14616@lst.de>
References: <20260304053500.590630-1-alistair.francis@wdc.com> <20260304053500.590630-5-alistair.francis@wdc.com> <103c958f-d5f9-47d3-9be8-dd7225368fd5@suse.de> <CAKmqyKPdJ2bgT2JaXi_38obyFTjRQ_rR5EdGmP81so8MEJNRVw@mail.gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKmqyKPdJ2bgT2JaXi_38obyFTjRQ_rR5EdGmP81so8MEJNRVw@mail.gmail.com>
User-Agent: Mutt/1.5.17 (2007-11-01)

On Wed, Mar 04, 2026 at 09:37:22PM +1000, Alistair Francis wrote:
> > I think a simple 'if' condition would be sufficient here, or do you have
> > handling of other TLS record types queued somewhere?
> > And we should log unhandled TLS records.
> 
> I like this approach as it makes it really easy to handle more types
> in the future. I don't have any more record types queued anywhere so I
> can change it to an if statement.

Agreed. OTOH having more than a handful of lines in switches like this
is a always a bad idea, so factoring this out into a type-specific
helper would be much preferred.

