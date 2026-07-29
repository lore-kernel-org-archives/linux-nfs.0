Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8CBF3397946
	for <linux-nfs@vger.kernel.org>; Wed, 29 Jul 2026 14:38:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785335905; cv=none; b=phpsIAlQBt+lGhZdLacpa1CjjRI0QobZQcl6ySuLPq2IjrXDaY2jSiyP1t4GETKn5/RIJK8M+PKvvId6YMm3kyseMfm9Ktu6JYdGHH2aetlZdUro6lmBL4V3GPj/fs1MoT2epW/EBw3jPfPS1oAIZn90nIdYdHUJuiShKtqI7c8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785335905; c=relaxed/simple;
	bh=R+6PRP9G+w8J/bCGFOIWUgkpaI+MFzJzl9twsHNcwwg=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=ZOAc3yDivz7NqvKzktp5TDDvHHWfwlfI9++0ckq0f0w+Iho6SKwbFQ7y/aDd7pfCUOg+/5GYQl1VGIbcdrn4xsNQ16lIVL+uIaaafsT9QH2iet6pcMiwHj4qBZqx4IjHsJH0usTwN//TI4ttaMSoLUCjlDj8VYYGaBZ95Uh5A6w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=CLsrKR8d; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="CLsrKR8d"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CD7991F000E9;
	Wed, 29 Jul 2026 14:38:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785335903;
	bh=XB16pYywxnXsacrLnDEVK6ip83A98MOrNRS+bD5Ayqk=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=CLsrKR8dxNlQFkDYaMKTkH+ePiaOaIx+bRxAMKVbu7qzDFs6V0alg+TBOgUni5JBd
	 nLqwTBUrcTVPpxORkPCCYbZWS1DmrlD4Wxz+x5jUmdRnGZ6LWmZG319DcwrOz22t9j
	 2+QRU69dR/P+nAioRYoxqXj3f/9r+subDCQ2K1qxk6IcCxsR/WKGez6r901JdTbl9k
	 Cn2BPyJ42tZ8YsQmfZXlJ3n92c8XJYqQaqHNQDY0oreFA1zyVsFgvlDo8W0hZO5JFu
	 g8RuT12bUeiYyss2KgpfuiWiCfhBR6hxJIA0Kq+lBaYPXk4F2k6WzNIjsnKn58aH9u
	 XQ+6JRZFFuEgg==
Date: Wed, 29 Jul 2026 10:38:21 -0400
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>
Cc: NeilBrown <neil@brown.name>, Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/5] Remove NFS client header dependencies from LOCALIO
Message-ID: <amoQXSPTFYdlO34D@kernel.org>
References: <20260728165911.462534-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260728165911.462534-1-cel@kernel.org>

On Tue, Jul 28, 2026 at 12:59:06PM -0400, Chuck Lever wrote:
> Clean up: fs/nfsd/localio.c is a server-side component, so it should
> avoid dependency on client-specific headers and XDR utilities.
> 
> No change in behavior is expected.

Nicely done (but patch 5 makes fh_getattr more efficient for LOCALIO
right? So favorable change in behavior).

For the series:

Reviewed-by: Mike Snitzer <snitzer@kernel.org>
