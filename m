Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5CDF8342514
	for <linux-nfs@vger.kernel.org>; Fri,  9 Oct 2026 15:28:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791559723; cv=none; b=BCCIFRrs9VduOUi2nkjhFYORiqaXwgG+k1ZwKa9Qw/Jj7jTu/femDTcwcW9RmBv2AuDHnDy0QZ0kQV+yZ5nRvi8fRZCgMYwbv7lZupXT2+c0Z2TlDnx6PFDbk0E2V9HQTn6R43cfJ9xad5V1eR7CIt4U2IRCAS3oyZW/tcZkUN0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791559723; c=relaxed/simple;
	bh=8RPt+/PlNrSgHbdGWnS2DFQ7B9xfdZbHfBIqeRPOLVk=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=qUMurGwW5QSohWQrhXGDET+z/yVwC8vajaTjbrJA/Hilx2TZHfAACpRKAGn/WvKKb+/woMkrHm8SGI0U7kJiBioe8Wv2jJmypCYS3RQYLuZmYoUgeTrxWGY0BTXhqlQU8Cc8edFhYI4HTa+4T/XRT0Jlwuc5F+SUtICIf+3KZvM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ai2th17v; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ai2th17v"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id ADF701F000FF;
	Fri,  9 Oct 2026 15:28:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791559722;
	bh=j3HUCAo3crAD4FOT0N0Zagxa6p5ZOdbvapjbOJ6uJlM=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=ai2th17vNy2ryf4zNrdOsOZgmQ0TMtUUoEmonkPeKWZP1WDAfnwNsbyJCq/SAvVeO
	 i7Hp6MDaaWmcvzxHXkNr1s3KrICFVKMketL4U9Zg/BWMbi5ILS/aLOr+h+hqWBLkGy
	 jDGf9kO8eav+bkDCcZn9P0ny3tArj1ni3S3CCJjV1I3jxE7moDvZEpq0sGwtleSuax
	 Ileg8A7A3eswEYXLkCib97G5/tMnTG8XLuC9h85qXxksmxHrDCfe9DqXCBqbIFcH55
	 wySc1j+6BCaNm5Tt3L7F/WNNqfiAohSt7impa+ZdjTK/dpebIAy7z/Fdsv75JvK0dT
	 wPzcZx7TMU4Kg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 0FBABF40066;
	Fri,  9 Oct 2026 11:28:41 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 09 Oct 2026 11:28:41 -0400
X-ME-Sender: <xms:KAjJatiJwrS6SfVxtS7Ard8HL8yK0XmdNhQFx4lN1s9CocCpMU9YZA>
    <xme:KAjJas2UW_1S4PcYmVrbSUv-f92Y3BFRVP_XytwWBqtN_dz32hqzAEoLVO-VIF6v-
    4dzkuW94zMbz6ZPigN3p73xNuNnO7pUJAxJV3k9o458plf_8ty6CvgF>
X-ME-Proxy-Cause: dmFkZTEVXIsShheL1smuCkfY0DyIXIGEheTQW11K8v+1meWSO1oci+Mn24W/8xy5rCfyOh
    mtsvRZw6XHKxHAXLfwTUtu8V7evvEU0+ZKLHkOxFxoftfu4GlaXFZcLGnP7Jwkich+Dc+t
    6kc1oKvuv9+MTDSGYshnfXWRzsTKsSLgHfIF9A+xt3qRX2FUH6+p8yjp6ByJ4EecEH9Q7/
    X4zKDz7qfgN2RAuF8FeHOt1g8S182SMgdtM1KpdmCWJJKyrcaWHH+7cn2m5OdMBdmHPW3Y
    Nx8+3xJKtUs3DvLhsTdP8As9PAiTzFy5PaTSBmGcrQ5sWM8InPkFIADS4/71xuveShpBa6
    1sbMFgp4RPJLTBKFEbwW56r2WTwte+Id1E2gnq1Fo8+eSW2Z5MuiPFNC/hLg/HUAOfpzCN
    A1TFLg97k0+TA836XFRgVupoKTGtX+LLu+ae8zY3L3JTLarPXpJ1gRHo2Y62uoeN+QyJ0R
    rgfhxIW06eY66Y+wvbJQ9FwP/gBbFRva/nZZgzhivAokM+k9h7+3xZler6QUMrbC8Qx0No
    YNEFY0dVwKX2Q7cUUPXbl2qXvcZfXsbEhW//O2CT0iwVKuuCWb7xH+q/Tp43lanaeg6gWC
    OhVScVp3oEossNWLHo0+sCLkP6qp7ocsPFiQgwDJNGr1GeiKbncJvkANv/Yw
X-ME-Proxy: <xmx:KQjJavbBPk8oV8UOtCl1B75TMc-nxMt9yAVYq6fOPj19CryDrgCN-A>
    <xmx:KQjJamhrwm1gjmMNiCPdo5r3l_dTz3Wn59ywM6_BlWT7XhfJM2jbwA>
    <xmx:KQjJahc5wGU1pxPFqeDDh_evJ0saRLgwGKrLynXGmrMCFF21DKXS5w>
    <xmx:KQjJall3wetpAT8CZhvL-NM8DHr9ad6fms1kDJIPSdTaEs7LqrzMbA>
    <xmx:KQjJamzoleM2AEs-K4Xu9wyrag1phBNp-ofit89pqTCGbIDP1mgUTfj4>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id E448E780070; Fri,  9 Oct 2026 11:28:40 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AgBbH0lsTNlc
Date: Fri, 09 Oct 2026 11:28:20 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "J Louis Kaplan" <Louis.Kaplan@arm.com>, "Dai Ngo" <dai.ngo@oracle.com>,
 "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Tom Talpey" <tom@talpey.com>
Cc: "Anna Schumaker" <anna@kernel.org>, "Jason Gunthorpe" <jgg@ziepe.ca>,
 "Leon Romanovsky" <leon@kernel.org>, linux-nfs@vger.kernel.org,
 linux-rdma@vger.kernel.org, "Trond Myklebust" <trondmy@kernel.org>
Message-Id: <5e38bf5a-1662-40c3-bc00-060c49cfc0c0@app.fastmail.com>
In-Reply-To: <20261008225833.682794-1-Louis.Kaplan@arm.com>
References: <d189ba0e-6215-433e-b27e-859502db67e5@app.fastmail.com>
 <20261008225833.682794-1-Louis.Kaplan@arm.com>
Subject: Re: [RFC PATCH 6/6] sunrpc: Allocate svc request pages from large folios
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Thu, Oct 8, 2026, at 6:58 PM, J Louis Kaplan wrote:
>> Given past experience with contention in the page free path, IMO
>> this one needs careful macro and micro benchmarking.
>
> Makes sense to me after reading through the links you posted in the
> other reply.
>
>> I wonder if this change should get merged first instead of last.
>> It's probably going to have broad impact and high risk, and will
>> need testing across all hardware platforms and on large- and small-
>> memory configurations.
>
> Happy to do that. Should I consider a separate single-commit submission
> for this change?

I'm rethinking the patch ordering suggestion. The biovec changes
by themselves are desirable refactoring. This change, while also
desirable in concept, needs guidance from the MM folks and might
take some time and careful thought.

The lock contention in page free is because of the way NFSD handles
pages in its receive and send buffers:

During the initial fill of rq_pages when each thread is created,
all of the array elements are empty, and a folio allocation is
likely to be efficient.

However, when handling a small NFS request, NFSD frees and
reallocates only one or two pages at the front of the thread's
receive and buffers. Refilling those using folio allocation is
likely to get a small folio that is not contiguous with the
pages that remain in rq_pages from previous allocations.

So over time, the front of the buffer tends to become a
handful of individual pages.

Allocating from a large folio and then freeing just a few
of those pages is an anti-pattern for the page allocator.
It's optimized for the case where an entire folio is
allocated and then freed together.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
