Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 046AA3CD8C6;
	Thu, 23 Apr 2026 05:15:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776921322; cv=none; b=JOF8Krofeqq4lY7edyFelKpnK2T6yvA17cacXuvkIl5m6uvMq4huAiDjbYPeF7TdYqj8dJMFJr0DFY7jNixQOoB4+RX36O+a3qn91FQeuDyPY6PR1U2mixp52yPUS3E3o08SEm3KH/xbSW/TWCM1abRlHmLKaRRykmjH6leOMUU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776921322; c=relaxed/simple;
	bh=B9SaPWmQb7PgWD04dg0gm+H8SIQ5od3kWQQ7dksufTA=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=AyuR1sEcvWNny5vbMIJpqY70t1d3VaJjZqINvvaVEm/qiXvnTiS+edjlfKtai6s9YKynMb5xxeI3cKbXUEnOZ7V1x92s5bGn0r/xdbILGOAO2gDD7SmPS3DBREcUCrAVSgR4jWSs0Ao/RVhoyRnax1z5uvjJkkwAd315m4XKcJc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 902EF68C4E; Thu, 23 Apr 2026 07:15:17 +0200 (CEST)
Date: Thu, 23 Apr 2026 07:15:17 +0200
From: Christoph Hellwig <hch@lst.de>
To: Werner Kasselman <werner@verivus.ai>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
	Christoph Hellwig <hch@lst.de>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>
Subject: Re: [PATCH 1/2] pnfs/blocklayout: validate volume indices and
 limit recursion depth
Message-ID: <20260423051517.GC27929@lst.de>
References: <20260421100338.1227152-1-werner@verivus.com> <20260421100338.1227152-2-werner@verivus.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260421100338.1227152-2-werner@verivus.com>
User-Agent: Mutt/1.5.17 (2007-11-01)

On Tue, Apr 21, 2026 at 10:03:42AM +0000, Werner Kasselman wrote:
>  #define PNFS_BLOCK_MAX_UUIDS	4
>  #define PNFS_BLOCK_MAX_DEVICES	64
> +#define PNFS_BLOCK_MAX_DEPTH	16

I think we can and should reduce the nesting depth.  The only really
useful nesting is mirroring + striping or concatenation.  Giving a little
extra slack is fine, but I think 4 (or 8 if you insist) should be
enough,

> +		int depth, gfp_t gfp_mask);

unsigned?

>  	default:
> @@ -559,6 +581,9 @@ bl_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
>  		goto out_free_scratch;
>  	nr_volumes = be32_to_cpup(p++);
>  
> +	if (nr_volumes <= 0)
> +		goto out_free_scratch;

nr_volumes should be siwtched to an unsigned value, as it is over
the wire.

Otherwise looks good, thanks a lot!
