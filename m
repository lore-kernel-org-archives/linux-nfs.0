Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BC7AD2AF00;
	Thu, 23 Apr 2026 05:19:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776921542; cv=none; b=Ov75x+wVonpTlxJlNoKwC1Xfpomwtu6iBWC0FnNs4+YqeAp2d9KDEa3THfkAm3jKSOepVKXs03kcvyK0D2bxNqm3BuLshy3DZtZwWTvHE6PYSo12I8JRV//Tzhee4aFsY4Lx3OWZkQN2VS6UDaUB/frTKL0mv5ER1ytNRemVfDU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776921542; c=relaxed/simple;
	bh=pvxp33B8cWcXWn5ImyQ23eqkmxf7tdx74HxzPnzzlVo=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=qKG7Pa+bd/ryrEbRFpjNd1hmuMlD9B8/M5oTF/BKvz/9czLcN37zgimebG+e0ti6vwlcUx16Z/ogeb0tBIy3+D0mVkrKCg/IlYQNlRR7iNBoKqcI1VK4fMcUjpGW13c2sOm9v19XmmWt0qWllsVL0Ze0oi/rMU9LLiX6TGfzdG4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 7302168B05; Thu, 23 Apr 2026 07:18:58 +0200 (CEST)
Date: Thu, 23 Apr 2026 07:18:58 +0200
From: Christoph Hellwig <hch@lst.de>
To: Werner Kasselman <werner@verivus.ai>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
	Christoph Hellwig <hch@lst.de>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>
Subject: Re: [PATCH 2/2] pnfs/blocklayout: cap total parse operations in
 volume topology
Message-ID: <20260423051858.GD27929@lst.de>
References: <20260421100338.1227152-1-werner@verivus.com> <20260421100338.1227152-3-werner@verivus.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260421100338.1227152-3-werner@verivus.com>
User-Agent: Mutt/1.5.17 (2007-11-01)

On Tue, Apr 21, 2026 at 10:03:44AM +0000, Werner Kasselman wrote:
> The recursive-descent volume parser materializes a separate device
> tree node for every volume reference.  When CONCAT or STRIPE volumes
> reference the same child index, the parser re-parses that subtree for
> each reference, causing work exponential in nesting depth.
> 
> Cap the total number of bl_parse_deviceid() calls at
> PNFS_BLOCK_MAX_PARSE_OPS (1024) to bound CPU and memory consumption
> from server-controlled GETDEVICEINFO topologies.

The OPS naming is a bit odd, these are called 'volumes' in the specs.
Which isn't a great name, but it generally helps to stick to the
spec terms.  So maybe rename the constant, and also add a comment
explaining the limit to the code?

> +		int depth, int *remaining, gfp_t gfp_mask);

Also use unsigned here as well.  And maybe we should group the depth
and ops into a struct instead of adding more and more parameters?

Otherwise this looks good.

