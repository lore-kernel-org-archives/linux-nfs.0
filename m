Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A7123440628;
	Mon, 12 Oct 2026 07:10:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791789025; cv=none; b=Vhe7rBJn1oLk7V8hKcdv8mpfeKlmfnLoukC/7ty7xfNbJNw7/c8db5eaPeeGS1dj16ODyxIoAqvVImY/QGPz6uDJE3wai2/6IyWE8Z3+Q8DgM9VNAuDy+ZhMxP9DgdsjFHCR/uwTyBV2+4PxRpXs56n5SlUR8ah/Nbo8yj9LVWE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791789025; c=relaxed/simple;
	bh=omZ7B44BTjksikzdLiQUM1HIGTVrF5fygEDWLWHAffw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=Gm3CAjlG6Ic7Wg5SYhnOSJ0f/t1EcNMfhVGHMrPIyY4FZi9FslBWvWbFdKvHppsg+iwopAasOftMrnR0iocWLkI7JsIpC1+3iUx5VERXypfgTr5KAKCradYyFFRllZHDlyBJQ/Cq+G/KfJkWZpq5YbmoH8KVE1X71j3QarSPwr4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=iJ4ZJ+9T; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="iJ4ZJ+9T"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 78FBD1F0089B;
	Mon, 12 Oct 2026 07:10:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791789024;
	bh=EZWLh8ZtcEyLbgkyy8mpGa6zyzZlvRQ5iu92TZ5q1tw=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=iJ4ZJ+9T0IuPjoE/MMgLlFRx+Ik3f1GcSsNvLZr53mf1/+olSG6Re3/+WjjJ9rzkh
	 HtgSeV2bXLWRaztBvFGpsm5q0kWbcpk6+NPOr75WbPC+Ywh0ymzLY3BwzItzvBPwdo
	 TS1qOdLnuhU/Ph/bg9CcCuvlzUtV8gbFo7/C4B0yU6TuzMLgiX9AuG2tay2YDTc6+z
	 Osyyq+sYyQPaxBUrkzRQp1vQaEeClmxFVASeh+EH2ePtYnNQac7pcjvdN7303bY69s
	 id/eKXAa+WrueOfG2hSBBYTHTxeSlQK/gIXMvOko+zB5fFtPl8MOtkv/M+EtxZhIC9
	 YeyCaIvlay32w==
Date: Mon, 12 Oct 2026 10:10:20 +0300
From: Leon Romanovsky <leon@kernel.org>
To: Pranjal Shrivastava <praan@google.com>, Chuck Lever <cel@kernel.org>,
	Christoph Hellwig <hch@lst.de>,
	Matthew Wilcox <willy@infradead.org>
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>, Jeff Layton <jlayton@kernel.org>,
	linux-kernel@vger.kernel.org, Logan Gunthorpe <logang@deltatee.com>,
	Jason Gunthorpe <jgg@ziepe.ca>, linux-pci@vger.kernel.org,
	linux-rdma@vger.kernel.org, Shivaji Kant <shivajikant@google.com>,
	Tom Talpey <tom@talpey.com>,
	Unnati Sachan <unnatisachan@google.com>
Subject: Re: [RFC PATCH v1 5/8] nfs: tag READ/WRITE RPCs carrying P2PDMA pages
Message-ID: <20261012071020.GH27033@unreal>
References: <20261006233248.705086-1-praan@google.com>
 <20261006233248.705086-6-praan@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261006233248.705086-6-praan@google.com>

On Tue, Oct 06, 2026 at 11:32:45PM +0000, Pranjal Shrivastava wrote:
> A transport must know when an RPC's payload pages are P2PDMA memory,
> so it can move them by DMA or refuse the RPC.
> 
> Check each page as nfs_generic_pgio() builds the page array, and
> record the result in nfs_pgio_args. The READ and WRITE encoders of
> every NFS version then set XDRBUF_P2PDMA on the buffer holding the
> payload.
> 
> Additionally, avoid using READ_PLUS when the pages are P2PDMA memory.
> 
> Signed-off-by: Pranjal Shrivastava <praan@google.com>
> ---
>  fs/nfs/nfs2xdr.c        | 4 ++++
>  fs/nfs/nfs3xdr.c        | 4 ++++
>  fs/nfs/nfs4proc.c       | 3 +++
>  fs/nfs/nfs4xdr.c        | 4 ++++
>  fs/nfs/pagelist.c       | 2 ++
>  include/linux/nfs_xdr.h | 1 +
>  6 files changed, 18 insertions(+)

<...>

> +++ b/fs/nfs/pagelist.c
> @@ -970,6 +970,8 @@ int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
>  				if (pageused > pagecount)
>  					goto full;
>  				*pages++ = last_page = page;
> +				if (is_pci_p2pdma_page(page))
> +					hdr->args.p2pdma = true;

Should we allow wider use of is_pci_p2pdma_page()? Does NFS require
`struct page`?

Thanks
