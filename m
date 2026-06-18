Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 204CD285CBC;
	Thu, 18 Jun 2026 14:10:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781791847; cv=none; b=uwUDVEpIxj+ZICBzgEWW4TYfiYg5y+fqbRTKokThzU7I6iy9MBQERnel7LXPi8AGECNwgCUwE8Hg+6vzt+iVP6lPphNfVAVj+o0/0NCgJqUGdESBMMJS1/6Kg/0FhaQQY7/R0QiA0NOqca1o+0YtSk95axfmqBqAt4FjWKbbO3Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781791847; c=relaxed/simple;
	bh=U4b/gq0UsZANc0ZMnl8fQkDohkeI7MCWvJ9TkF4OeNU=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=ZMqAvREOhWRiZqjITCOiKdTTCKikglP5KW6y5WL7qKN1JRI8bKJzXk9PmWSnuPlqWsyTn1ISdRgI6v3ug6NcS6D6VBGLx90dVtmfoaX4h1ptk8gf3xgU+WnIy+POqvXHZnfpU1svDV2HtkP76Gl1TlKtWH9Of1WrZw7IgJcJ2d8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=IfYIYKU2; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="IfYIYKU2"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=yEL3vTDX3RN/4Op4vWPybqIcJPUjup3Ov++9PioHs+A=; b=IfYIYKU2ALGIFRhPuheYA7hAId
	aJEqQ76FJ/aKk2bhvAJ6Q1jmT0wFhi8rZKpfUT9sQlVZT0JQ837VKnmpIJQOHYfLO4aPxXk8MQ/Pt
	v9LOcM9No1/NQkLT6bt71v9Pj3HA5DYr/HoG7u4wBjGDjdmFUEqs+TtZZ59fDqDDae5pWigUIoCl1
	n3/pfBXWpxmW0Bh+sfzJhP8osf4ec8D3APKmfAA/g/OiCPGuPqmNIl6jkr+qL/APKC+ODnhZq3ggI
	kWLYMqW0WKv4+eEtRx8Ln2HU9Nvd0AyRzFN/Nb4CJwHy4C/bZ60UmSk5py88LvCkvM0Rz504q2XWt
	0/U0Tcaw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1waDS9-00000001Plj-2kRI;
	Thu, 18 Jun 2026 14:10:45 +0000
Date: Thu, 18 Jun 2026 07:10:45 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Pranjal Shrivastava <praan@google.com>
Cc: Trond Myklebust <trondmy@kernel.org>, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, Anna Schumaker <anna@kernel.org>,
	Shivaji Kant <shivajikant@google.com>,
	Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v2 6/7] nfs: Optimize direct I/O to use folios for
 requests
Message-ID: <ajP8ZTTLYkICFTO_@infradead.org>
References: <20260616134000.2733403-1-praan@google.com>
 <20260616134000.2733403-7-praan@google.com>
 <7ee3bcfdd6126c93cbb1c219bf601182b95c10d9.camel@kernel.org>
 <ajGGpDvzZdkGtSbN@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ajGGpDvzZdkGtSbN@google.com>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

On Tue, Jun 16, 2026 at 05:23:48PM +0000, Pranjal Shrivastava wrote:
> AFAIU, the MM subsystem explicitly ensures that every valid struct page
> is part of a folio.

It is definitively not what the vision for the folio is, although if
I'm not mistaken it actually is still true right now.  This whole
area is a minefield unfortunately, and we also ran into it with
iov_iter_extract_bvecs and the earlier block code it was extracted
from.  Adding the relevant people and lists, but for now your best
bet is to stick to what the block code does or even better reuse
as much as possible of that code.

