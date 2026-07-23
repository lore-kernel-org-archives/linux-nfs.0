Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 56C5233E37A;
	Thu, 23 Jul 2026 05:25:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784784342; cv=none; b=ac0wXj/762j0wmuKjaCj5j2AsoNsqRM0Csrf1mp8RX1Yphgp5QcnMVHbbhx+DdvA6ogVb+rWvUATCcackGV5jbiqHzHqw9PDjwRNekrrg3GjXXs9Rn6U1d6u4f04Avh3j31SqwyWwOiRB3YZcxvPtSwHXOV36/QYYRhL6q6ztTU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784784342; c=relaxed/simple;
	bh=r5kBJw0402r+xeDN4CbHtr9DtuRZlQydlGOmXW7ofXA=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=b7ebZ8VeUV2KN2kgqiskkELsQasjwxt9ABHgEuPbacam/4qY6eI+Lt0WLZ5SSUvavBWNAsTy7lWdpRzyucLuRLcN7QiHbXFMYPQAvryfB2IAtfaY6VyBu/53eR6Wdy6ZRBuRR4RfSkkBMeGS1Mnr5wWI66BFwaq+iceiGsslLy0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 14D7C68AFE; Thu, 23 Jul 2026 07:25:37 +0200 (CEST)
Date: Thu, 23 Jul 2026 07:25:36 +0200
From: Christoph Hellwig <hch@lst.de>
To: Usama Arif <usama.arif@linux.dev>
Cc: Christoph Hellwig <hch@lst.de>, baoquan.he@linux.dev,
	akpm@linux-foundation.org, chrisl@kernel.org, kasong@tencent.com,
	nphamcs@gmail.com, shikemeng@huaweicloud.com, youngjun.park@lge.com,
	ryncsn@gmail.com, trondmy@kernel.org, anna@kernel.org,
	sfrench@samba.org, linux-mm@kvack.org, linux-cifs@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] mm/swap: revert to single-folio writes for
 synchronous swap devices
Message-ID: <20260723052536.GA7565@lst.de>
References: <20260722130615.3163560-2-hch@lst.de> <20260722163601.1421253-1-usama.arif@linux.dev>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260722163601.1421253-1-usama.arif@linux.dev>
User-Agent: Mutt/1.5.17 (2007-11-01)

On Wed, Jul 22, 2026 at 09:36:00AM -0700, Usama Arif wrote:
> On Wed, 22 Jul 2026 15:06:07 +0200 Christoph Hellwig <hch@lst.de> wrote:
> 
> > Kairui Song reported that zram benefits from submitting each folio
> > directly instead of batching up I/O because the classic LRU scanning
> > benefits from clearing the folio writeback bit in the scan loop.
> > 
> > Accommodate that by kicking off reads for synchronous devices for
> 
> s/reads/writes/ ?

Yes, fixed.

