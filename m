Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792679307;
	b=DNKPn2JDzVkEa2NBB26qDzCCtrtTutuGK2ulLeLcYqE2ucqUzrQYCGBXEtaIxq1faTKD
	 d94scOBqSVI0k2YCZNqYrtk7xdbWcG/q28q4wUafQFu3mt4wEM+z83aWB7NJsaGGbwCqv
	 zpNkKphz6zwI/kPeZm2OhqeGenoQYWKzOQjmfQzTtcoYWfkI7iUYNjqZmWJq21OvwBvi9
	 aCWscDwDpPVXS7w3K15shj+JLNnYDVdwwAZs8yYL5UF9qsYKfHVBV2T3RDTtcg/FF2RPs
	 vGTbtyMKJzmbPsQPVrnPyc1UIor89t1NQd8cVobslrwP2MvG8sT/BEG5SjzDTcApDBg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792679307;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=6kMmhq36VYEj0XOQSzT3CA4zRST8TSDIcFSnbh3nHTY=;
	b=hhQlaq3Rt+SilnPZ+ND36FHlqSFLnaIEoxP/JZnq9Bc6UFfZnM+e9TaXAY5dE8EJ4iMM
	 rK+DTb8lfIyfQ/bEF6tgEQZw4cA6Kcu41VLT0zX+p40uv8Zxmxjb5TcqvoBFEto3TnF1a
	 DymxaPqlITgG9odrZSfsJ2KVHWev3PbuMGum6l05JFhHmc9q0S2M9jom7b3GXx1CfdW8w
	 UQOwJdVT1oYayoZAcqpJ/898iyv/smN8ou/wEWKxtM+c8wslqfmqDKcpwYjmkEAmcB+W/
	 oxoWS+mlE6GkgkzBxtJPgz9RVlxN3otKAdxkOq3032MSnDAw3OekuSpLffik5Kg+o6w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=FQKXY5Y3;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3648C60A3806
	for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 14:28:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=FQKXY5Y3
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 52E0F1F000C6;
	Thu, 22 Oct 2026 14:28:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792679306;
	bh=6kMmhq36VYEj0XOQSzT3CA4zRST8TSDIcFSnbh3nHTY=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=FQKXY5Y3jaDD6bOdfmqj7/w3d0KwDEDdQ5B/4sukBlEXTOm+Uq6PPDWJW2kTGaJw2
	 iki3ReR6nY3844VGnZ/KgezJH9kAblfSaVy0p6VzfZ4EvCXqZ+kaJbxNasGt6pwEnV
	 61nKbeR0N4PL9GzksT1qBTingayfj180/YL4kJhpXpaMRJYkXGuBrKusThk63fxXH/
	 bZF8++foHkbMlbqeOCsRRvM18MPvwAe5+YmiaSaM1ReyixKhOL4LMxgQm+aWIakZYL
	 G3KJkI2pRDj1HS/Gcokt5QwumGZLdNttI+Flt36LeJnMcBgeMO6Fkqwi4tYak54WgB
	 uP7rmf/wMiXeA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 9C2F6F40066;
	Thu, 22 Oct 2026 10:28:25 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 22 Oct 2026 10:28:25 -0400
X-ME-Sender: <xms:iR3aarVjmvMd4uHzTveQm3aUQiMX38v0ZuuqDjEnUbXGXorjgpc0ag>
    <xme:iR3aaubluyphnDtJd7S7j-s2Flmwhr3j9Dv2lsU_q6urwdRVY0cSp8o15KuqQYnbu
    T9sg8cMMFb9rxiIDFDJv641OJHZgXhkvAn3waN6DCIR1y2RYKEhEiOU>
X-ME-Proxy-Cause: dmFkZTEBkP7DGtODa2WUaVOxDTTxBpmdRrLk4G+uNgRAvwhvKqbcfXe3M1e+wE4og1hlaN
    LHFUNwMS/uWFyo83mTkNFdUj+sVDJyhjvWgFa5vGpyohYMiKAroubejRm9VsrozcW/L+Of
    1XoOnaPcgjw3htHF39OwaRCec9ItjkG5efEzKfZp8vTfeXUVhbQF2xqn3vhWviRuEjhKzd
    hwPZu+3TybMjOXkdRuFVdQxV5IUPAsF7p87ZwU4pgZtWN8B0XrT/5fkoMBFP/3UpZyGOBv
    zw2lg0sAeRo1dnL/cGi2ECHFEN9sw5IryS8uMHczlA1qYaESeXOTlSB95IdaNATEbxblts
    Y5tg9Uhtu4fWaXj/4LF7sh6i370e3nP2Fpj95o87kH5eYDNbaq/RUvTdTq3lmpwNk172Uc
    l5SmhHaS/waf4n6hiNmM15JJt5uy1MmWd0TjTrhuOw4iq34ENFzmxGC5OdiWxXU11lbgW0
    1z6hOFcFtiKlhG+IUX68rOwlyBhv/FWxusA3vTQ1iFCTymLE19TzeqqilXKplXNDlaYhBm
    l5Bb2ZNXFcepVydP5SvP7ZV0wTL8SuEWEbHzUrSnxCIQ760f+MtDIIfmAKkP8pEs1Rf37u
    lG+UtVKcjimUMTR9PNrLjkMcVdZ+nYV90jCVPt+m9KEqfqiCC8gSAVKwi82g
X-ME-Proxy: <xmx:iR3aarAItw2CSSZ-8-Eq5TPxs3-YwZBFH1RILGhKHquUrFRQe7uXWA>
    <xmx:iR3aagARg8pB8czUmCtU-N0LSmo0bqTH81fTJEX5E-72hc8hekXOcQ>
    <xmx:iR3aatZYEB1s5GS5JQyj3bKxh1WjBh0ngCP5w6nj2IlweaTQ5GY37Q>
    <xmx:iR3aatxidFqBbSC3PGXzQ037wSyyR9n--gHp1fMnxRaD0xhvSVzJGQ>
    <xmx:iR3aaof9Ls-ekSXVkHKcluBSVAZBltSwfyjfpnBBRNuGYwntfQCnQ5vx>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 78C7C782738; Thu, 22 Oct 2026 10:28:25 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: AXYV5AzNqYhJ
Date: Thu, 22 Oct 2026 10:28:05 -0400
From: "Chuck Lever" <cel@kernel.org>
To: michael.d.lowman@gmail.com, "Jeff Layton" <jlayton@kernel.org>,
 NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "David S. Miller" <davem@davemloft.net>,
 "Eric Dumazet" <edumazet@kernel.org>, "Jakub Kicinski" <kuba@kernel.org>,
 "Paolo Abeni" <pabeni@redhat.com>, "Simon Horman" <horms@kernel.org>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org
Message-Id: <bfc542d3-4be3-4887-bc93-81403b5a8c11@app.fastmail.com>
In-Reply-To: <20261022-integ-page-reuse-v1-1-fbe571857d4f@gmail.com>
References: <20261022-integ-page-reuse-v1-1-fbe571857d4f@gmail.com>
Subject: Re: [PATCH] SUNRPC: avoid possible page reuse from svcauth_gss_wrap_integ()
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Thu, Oct 22, 2026, at 9:10 AM, Michael Lowman via B4 Relay wrote:
> From: Michael Lowman <michael.d.lowman@gmail.com>
>
> Commit 7702378ac4d4 ("SUNRPC: Convert svcauth_gss_wrap_integ() to
> use xdr_stream()") and its parent changed from calculating the
> integrity checksum in-place in an unused part of the response buffer
> to calculating in a scratch buffer and appending it to the response
> stream. While the unused part of the response buffer happened to
> always end on the first page, the append always occurs on the last.
>
> If less than 32 bytes remain before the page boundary, some or all
> of the checksum will be written to the next page. But since the xdr
> functions do not update the response's page accounting, the page
> will be immediately available for reuse. Data from another request
> will overwrite the portion of the checksum on the new page.
>
> Avoid this by marking the page as used when needed.
>
> Signed-off-by: Michael Lowman <michael.d.lowman@gmail.com>
> Fixes: 7702378ac4d4 ("SUNRPC: Convert svcauth_gss_wrap_integ() to use 
> xdr_stream()")

Commit d1eafc3bab9f "SUNRPC: in svcauth_gss_wrap_integ() resync
rq_next_page after the GSS wrap", now in the nfsd-testing branch,
already addresses this issue. Thanks for confirming the finding!


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
