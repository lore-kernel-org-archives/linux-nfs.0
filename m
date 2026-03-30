Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7A2743DFC88
	for <linux-nfs@vger.kernel.org>; Mon, 30 Mar 2026 18:57:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1774897052; cv=none; b=B7IoeKuXQPCy4mVusDi9dIfPjSyv/D9XYCuRjfTOzPR0JfFZ8yEiNI8D3aCVxGDveaeup81XSZdPlCzqfa6Z6CV6d1KMH4pgX6FszOn+X31MO+inkNcdiljOHQfsTRjzfH6Df4isAxYo1BU09fHltNXFJBhuIBYjBdjz5I/wd6I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1774897052; c=relaxed/simple;
	bh=UsR4g/+bIxalzicLwGG6554B7wLFufQ8s33dQiyxIBE=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=RqP1mAkEeYB2RI5S9uvQi5DprBXUe8WJ672Vv6tHM+h+2lESEal6ckX+oAuWPQu5vgrqDg0IW80QYYBdU9ZpgzpEfqe94oaUORxuMhkee2K+9HXKbEOJqc0xj/MoeRz4Thgt6wtoy6Z7sAreCjpyeRncgqe5rDjdb7ergrwnkK0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=K1B2htr0; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="K1B2htr0"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E03F6C4CEF7;
	Mon, 30 Mar 2026 18:57:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1774897052;
	bh=UsR4g/+bIxalzicLwGG6554B7wLFufQ8s33dQiyxIBE=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=K1B2htr0Ts1aNLxV6RlYC2XObvc47GArXPwMooc8MHKD/JWM5z+qSFgvx322NTWiB
	 NkGf4VYz1bCaht5EJRPlVs+Zs/V6welWKD4dlFoceoOFhJwGQgFsq8o2nNcGzOpgp0
	 IiBysffQanvrnVfqTPrnU1aXewHSpL9H3rHRVFLCccnhZWtvjOAJjPujv/vt2JTx1W
	 FoXi7Sbr8eUvjo+SQlJIwSvep6O7XsHC49Y9BuXbR6G6cKw1ivR7qlTyIFtalb14zP
	 JIJTYO4NDLjmpEB2X0VI8x26QLVo6QLosuPo+BjhBsUHLhXr5k0xwFJkDPTxF8Xwrm
	 /htjz4iJQz7og==
Date: Mon, 30 Mar 2026 14:57:30 -0400
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>
Cc: NeilBrown <neilb@ownmail.net>, Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	daire@dneg.com, linux-nfs@vger.kernel.org,
	Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC PATCH 0/7] sunrpc: Reduce lock contention for NFSD TCP
 sockets
Message-ID: <acrHmvgWjJijCo1U@kernel.org>
References: <20260205155729.6841-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260205155729.6841-1-cel@kernel.org>

Hi Chuck,

On Thu, Feb 05, 2026 at 10:57:22AM -0500, Chuck Lever wrote:
> From: Chuck Lever <chuck.lever@oracle.com>
> 
> High-throughput NFSD workloads exhibit significant lock contention on
> TCP connections. Worker threads compete for the socket lock during
> receives and serialize on xpt_mutex during sends, limiting scalability.
> 
> This series addresses both paths:
> 
>  - Receive: A dedicated kernel thread per TCP connection owns all
>    sock_recvmsg() calls and queues complete RPC messages for workers
>    via lock-free llist. This eliminates socket lock contention among
>    workers.
> 
>  - Transmit: Flat combining allows one thread to send on behalf of
>    multiple waiters. Threads enqueue requests; the mutex holder
>    ("combiner") processes the batch, amortizing lock acquisition and
>    enabling TCP segment coalescing via MSG_MORE.
> 
> Supporting changes include a workqueue affinity fix for single-LLC
> systems, a page recycling pool for receive buffers, and explicit TCP
> buffer sizing for high bandwidth-delay product networks.
> 
> Base commit: v6.19-rc8
> 
> ---
> 
> Chuck Lever (7):
>   workqueue: Automatic affinity scope fallback for single-pod topologies
>   sunrpc: split svc_data_ready into protocol-specific callbacks
>   sunrpc: add per-transport page recycling pool
>   sunrpc: add dedicated TCP receiver thread
>   sunrpc: implement flat combining for TCP socket sends
>   sunrpc: unify fore and backchannel server TCP send paths
>   SUNRPC: Set explicit TCP socket buffer sizes for NFSD

Curious to know your thinking on this patchset?  Can you post v2 given
your note about having adapted based on Tejun's feedback here?

https://lore.kernel.org/linux-nfs/af3a034c-4829-469d-b55d-9414409ee425@app.fastmail.com/

Thanks,
Mike
