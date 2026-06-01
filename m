Received: from zeniv.linux.org.uk (zeniv.linux.org.uk [62.89.141.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9F903313283;
	Mon,  1 Jun 2026 17:50:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=62.89.141.173
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780336243; cv=none; b=UpUt4pJNOgEm9rIkaHhmz6bCj6haL3lV+zbXv2pFBkLS9EwajLpK7U8BmuNEnFflO8C2zApi2Icn86b/b8qQbop2/JOlkk0LmAUCMN++s8IHWTJD1a5zK4smY/pX4kLOJHqFN4LG4qEkReYJE8ueu/DSt7f0fKRUFfynY9cX5rI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780336243; c=relaxed/simple;
	bh=vQLIM3nR7YCHZCz6tFlJgaTi0fW+79IrDLnsgQDueBE=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=tAan3OYbxiovkSQhpiFU5FlO8yvyVwJrBhyGidzVhpF0s6FGEJyEwYwUVWEJgefF4DLXVjFoFLNnGXDO6P4hDDq6QRRf0OiMXRqZkgUugGBihVg3RBZJ3tgmzwAopKrtIvAuzre1t0XhsPFhcOYzPL0bhElbjBBCR/IeCQ5Y52c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=zeniv.linux.org.uk; spf=none smtp.mailfrom=ftp.linux.org.uk; dkim=pass (2048-bit key) header.d=linux.org.uk header.i=@linux.org.uk header.b=SOrp/Ufz; arc=none smtp.client-ip=62.89.141.173
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=zeniv.linux.org.uk
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=ftp.linux.org.uk
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=linux.org.uk header.i=@linux.org.uk header.b="SOrp/Ufz"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=linux.org.uk; s=zeniv-20220401; h=Sender:In-Reply-To:Content-Type:
	MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=rA/0wYQp1BstJ4VqNk42bAPAeTLjgqRZ1vyCn+Hz7uo=; b=SOrp/UfzAxtEFRGPVw2ZVjdXnZ
	fD13pads7LEEfk0vAiY5mwkUJfFrAIK2H7RZZq8OB2srF/RSAi5LRAWbGIz4r0vZTIomnsfN15lRB
	K7joqNu3oZC+ts9c3M734P7UVMyFPUOlHIEAGzq4a/L1yLMcdgH3iziEp8F62xIzwJLzZe5ZTrUWg
	RE451lCULdNzy38jastv5C1y2um7u0R8U7zdpOHkV26F8bRaR+leNfXMp9sUocd0riDPUw2mtPne2
	zYt583BETZ5v8nomjqcMg6dx6Upcm2FJsSVCNbDPdytvQ+d1LfQSBpiTeCZBIgbnjRi3ifGtERNp/
	Xj6lSpdA==;
Received: from viro by zeniv.linux.org.uk with local (Exim 4.99.2 #2 (Red Hat Linux))
	id 1wU6mY-00000003RLR-2mRM;
	Mon, 01 Jun 2026 17:50:34 +0000
Date: Mon, 1 Jun 2026 18:50:34 +0100
From: Al Viro <viro@zeniv.linux.org.uk>
To: Jeff Layton <jlayton@kernel.org>
Cc: Chuck Lever <chuck.lever@oracle.com>, NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Lorenzo Bianconi <lorenzo@kernel.org>,
	Anna Schumaker <anna.schumaker@oracle.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>, Mike Snitzer <snitzer@kernel.org>,
	Chris Mason <clm@meta.com>, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Trond Myklebust <trond.myklebust@hammerspace.com>
Subject: Re: [PATCH 8/8] nfsd: hold net namespace reference in nfsd_file
Message-ID: <20260601175034.GI2636677@ZenIV>
References: <20260601-nfsd-testing-v1-0-d0f61e536df8@kernel.org>
 <20260601-nfsd-testing-v1-8-d0f61e536df8@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260601-nfsd-testing-v1-8-d0f61e536df8@kernel.org>
Sender: Al Viro <viro@ftp.linux.org.uk>

On Mon, Jun 01, 2026 at 01:31:11PM -0400, Jeff Layton wrote:
> Take a net-namespace reference in nfsd_file_alloc() (get_net) and
> release it in nfsd_file_free() (put_net), so that nf_net is always
> valid for files that the GC or shrinker has isolated from the hash
> table and LRU -- which __nfsd_file_cache_purge() cannot see.
> 
> Without this, nf_net can dangle for in-flight files whose net namespace
> is torn down concurrently, causing a use-after-free when
> nfsd_file_dispose_list_delayed() calls net_generic(nf->nf_net, ...).
> 
> Because nfsd_file_free() now calls put_net(nf->nf_net), the old
> nfsd_file_put_local() pattern of returning nf->nf_net after
> nfsd_file_put() is unsafe -- put_net() could theoretically drop the
> last net namespace reference, leaving the returned pointer stale.
> Fix this by moving the nfsd_net_put() call into nfsd_file_put_local()
> itself, before the nfsd_file_put() that may trigger nfsd_file_free().
> The function now returns void and the caller no longer needs to handle
> the net reference.

That means that each nfsd_file_alloc()/nfsd_file_free() is now touching
the same cacheline on kernels with netns enabled.  Scalability implications
might be interesting...
