Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D800417B4FC
	for <linux-nfs@vger.kernel.org>; Wed,  3 Jul 2024 14:16:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1720016194; cv=none; b=Sid/WdOkNh6yx85WH1NJM0b2ES26RHLE0C2NHEYMgjqk3ps7yONqHA6Yp9h0hsKOpsh9KEFgp71+oLS0/+4pCxWN9rZ8HFsiRRWFYADVLvQZhxGBsUjX4Jp9zskn/5a1Cwi1MJSYBxeXnGhRb469EIz7/bBc/Vw5QeHwvzHk65w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1720016194; c=relaxed/simple;
	bh=gYgccBVYCSGs1hSEvh39dXCYYcYpRhea7SbtSRckGCk=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=m8gSXB1zg3caNhY026dxkNNDnGJDM6dl019LKe7EFEHfC8VCX5fAPXZp6kFcJUfJO8JFwqTFaK4zK7T1P+GlbJiYFY5rmqUXaiMpxYCWzhwmCCICTi55BinRAVVwk4t8Ab01fGkvIx+dG4Edm4yboElUkyaaRDSW/D+OE5JU/iw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=xNaYGO2T; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="xNaYGO2T"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=sloAm/veWfEmQCpXZp+D6Nyo3CrZ3ZEN/riIYa9xrZo=; b=xNaYGO2TCnozOzAlA7inJioHmI
	CntQm1alWZmBsBGJc2RYndX4y+MlRqr3RTeLB5TrNSnVx+IF/rgoBPQka8JY7ybIPOeytXb4e3dmh
	Jw7e9sKaFl/jOb2KnRtnRqEQI9rV6jNHVsF1jwmDbbIb95ulFLN2EWfA4oSZgj/AejrO2kIeW3spu
	wYH2VWoWqPfqw4Drrl7SoYgnY+B5UhbyXFFgWhpEOqt1XD9tgo9oe351TXwKpLi69OUdxRum90cCE
	rnvBTV6T+3oi9PX/lCsBUjfWj+BLoK14BH216q3tzQdvZ7jHqgOvSpZ6SEXbvGpdGwfyyHJnHXm4N
	BFgOkSfA==;
Received: from hch by bombadil.infradead.org with local (Exim 4.97.1 #2 (Red Hat Linux))
	id 1sP0md-0000000ARQV-3tdr;
	Wed, 03 Jul 2024 14:16:31 +0000
Date: Wed, 3 Jul 2024 07:16:31 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Mike Snitzer <snitzer@kernel.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Chuck Lever III <chuck.lever@oracle.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Jeff Layton <jlayton@kernel.org>, Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@hammerspace.com>,
	Neil Brown <neilb@suse.de>, Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v11 00/20] nfs/nfsd: add support for localio
Message-ID: <ZoVdP-S01NOyZqlQ@infradead.org>
References: <20240702162831.91604-1-snitzer@kernel.org>
 <3A583EDC-519C-4820-87E9-F4DC164656DB@oracle.com>
 <ZoTb-OiUB5z4N8Jy@infradead.org>
 <ZoURUoz1ZBTZ2sr_@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ZoURUoz1ZBTZ2sr_@kernel.org>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

On Wed, Jul 03, 2024 at 04:52:34AM -0400, Mike Snitzer wrote:
> Ultimately I simply wanted to keep momentum up, I'm sure you can
> relate to having a vision for phasing changes in without missing a
> cycle.  But happy to just continue working it into the 6.12
> development window.

It just feels really rushed to have something with cross-subsystem
communication going in past -rc6 in a US holiday week.  Sometimes
not rushing things too much will lead to much better results.
