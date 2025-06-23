Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AA5501FAC4A
	for <linux-nfs@vger.kernel.org>; Mon, 23 Jun 2025 07:33:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1750663997; cv=none; b=OmAksfeeqGVQ+gFdPfItanRLDNtwifr/JigiyCgi5s96tfUM6+cIyi10WIhr4Mxk73UdFZheTlwswAEc8BJAZBOLVMMNNkpTlSL5UkAN34Td9+d/WoOX3Qe3UhIKGqJOK+4C451wDmL0y3OaeNTdpQeHtGLSjFf54v6WTnO4FTU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1750663997; c=relaxed/simple;
	bh=0YEuzNKNGQu5E7ko234f4+7y+ydDA3n9zVVlxe+OHCI=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=aM38nZJtvHPhv+XP7xBF73MVz9/B9Tt2oRwz7139r2xTf25i9oS7vyWk4RknNiqi9gr0LTUeuRwddIsr0BQSNthjjDuzql00mBXiKsw7F1NRww31KK21P8O/OjbDFmrfcKRqYltCHaPm98jBzMq7nw9Lg1h0S6/F6vA0+jzZLr0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 1060268AFE; Mon, 23 Jun 2025 09:33:12 +0200 (CEST)
Date: Mon, 23 Jun 2025 09:33:11 +0200
From: Christoph Hellwig <hch@lst.de>
To: Chuck Lever <cel@kernel.org>
Cc: NeilBrown <neil@brown.name>, Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org, Christoph Hellwig <hch@lst.de>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC PATCH 2/2] NFSD: Simplify struct knfsd_fh
Message-ID: <20250623073311.GB32697@lst.de>
References: <20250620123155.271392-1-cel@kernel.org> <20250620123155.271392-3-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20250620123155.271392-3-cel@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

> +#define fh_version		fh_raw[0]
> +#define fh_auth_type		fh_raw[1]
> +#define fh_fsid_type		fh_raw[2]
> +#define fh_fileid_type		fh_raw[3]

I guess that works, even if I find struct field defines a bit confusing.

Either way it is better than what we had before, so:

Reviewed-by: Christoph Hellwig <hch@lst.de>

