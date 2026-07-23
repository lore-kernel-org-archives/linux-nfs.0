Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3154834A3D6;
	Thu, 23 Jul 2026 05:27:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784784431; cv=none; b=PS1sCQZDnH/r9NSF/cy7zDFK4pIyJ9GsisiqLkRCZtj39aFtpwxHHfBXGzHa/K5njH2TJ5MYG3YTreGKKz+825uLR/jkHxUFso9sL6hGmPKwSUXHveWESEjJqKkB88PDRufr8iuaGGxK6u/aDbmSLVCKxVihmQJ3uL8qRJGLlX8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784784431; c=relaxed/simple;
	bh=1s54FKqhmPEHVAu14u8FW8evYGofnXqQnSa4Z/i0CqU=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=h8RaJ++HP8uf8CPiCwlZCtL9knCzorBxTL9f0bRBiHSg41UQAeO9IqMfKrs+EoxAnce14CaqeUXgvBEqIrnzWC++P9J6Rwf9dfvI0/rU4jFblGt1DxHuGiVasx4LIwqsYyHHDarVIOSlL0EvSPVZsHIUB64ikZRbfEqeIOQPSuc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 03E6F68D1F; Thu, 23 Jul 2026 07:27:07 +0200 (CEST)
Date: Thu, 23 Jul 2026 07:27:06 +0200
From: Christoph Hellwig <hch@lst.de>
To: Usama Arif <usama.arif@linux.dev>
Cc: Christoph Hellwig <hch@lst.de>, baoquan.he@linux.dev,
	akpm@linux-foundation.org, chrisl@kernel.org, kasong@tencent.com,
	nphamcs@gmail.com, shikemeng@huaweicloud.com, youngjun.park@lge.com,
	ryncsn@gmail.com, trondmy@kernel.org, anna@kernel.org,
	sfrench@samba.org, linux-mm@kvack.org, linux-cifs@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/3] mm/swap: add a new swap_ops.h header to allow for
 pluggable swap ops
Message-ID: <20260723052706.GB7565@lst.de>
References: <20260722130615.3163560-3-hch@lst.de> <20260722163218.1240273-1-usama.arif@linux.dev>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260722163218.1240273-1-usama.arif@linux.dev>
User-Agent: Mutt/1.5.17 (2007-11-01)

On Wed, Jul 22, 2026 at 09:32:17AM -0700, Usama Arif wrote:
> > +struct swap_io_ctx {
> > +	struct swap_iocb	*sio;
> > +	struct swap_info_struct	*sis;
> > +};
> 
> zswap uses this struct, I think you need to include the header in zswap.c
> as well, good to check if the build is passing with CONFIG_ZSWAP=y

Yes.  The buildbot was nice enough to remind me of that just a little
after it gave an all ok...

