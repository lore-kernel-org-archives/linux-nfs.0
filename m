Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 023CC47988B
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 23:56:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789516614; cv=none; b=OcABI/vrT3TwpLXm+CscI8vuHsMZ8YOry1rKfzohzckuHljSI9g3yWKqzlJ1VUrcEygURFMoLExrLQLOkjEWDGVcd2Pd3wQbb94NFtr50iniGeCSD0CpotvreDdGm3bmBoUas3YqsyhFt8krC46cGhMLsZsRoxL7FWoVXDYCuZE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789516614; c=relaxed/simple;
	bh=P5Z8SJxzcPvxK7Hlwxfwunh5Qmw8TDGeFq8Ff8LFxn0=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=rVCKz1G5gf+H80aWWyC20aoUXx8HgP1bRgtYzURbL05MIzkDTYv1s4s1/Iohx/in7Zsh1jYItdXjRVs/oCTunxk3toVPapScSGQDNMAfOQjQoErkoMxgvnVT7ZyE1onglNBPaeb+Ibk35svvQtp2Wq6T5c4dGdeCjTeljo1X80s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Xxbg1l9n; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Xxbg1l9n"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6820B1F000FF
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 23:56:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789516612;
	bh=+Xy1DakDTU7A4Q8JMyseCCnavxX8Hzwk0mQlvbuNYaY=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Xxbg1l9nuokGrF+FOq1R3E/5PZRAoX9OfEOfsyVQWXMvlroyIl0ls99SaWmcSEv1E
	 gUSoZ2xr9ADM8rZoiQUBp0+CwtzecCzsaEONOkOpgF5hdtU4fZicxRPHN+fKMnXjwi
	 KkLVQPdXwDvMhwq4iXIYmLBsb/p5or5t5CG2WjWCztPcGpKfRPQNHhcHGx8kMwtGnP
	 GlVAeFOBIn4r7Xua4M30ZTr/DKkuyvpNAdLAe+7NuMi+UEv+jNMQW+H42z6nd8NSpx
	 ehRLJ017aRS0ZsbKE34bDmi9J8sGPtbiylgPAp2E+0GpffvQl+miZwa0g/zAU+xN/x
	 HxDEalgxzza+Q==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 75A31F40066;
	Tue, 15 Sep 2026 19:56:51 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 15 Sep 2026 19:56:51 -0400
X-ME-Sender: <xms:Q9upapJ1pfewTshe36uTppayLlummrgzlbw7Z6a2YqQTq3k6ZYP6fA>
    <xme:Q9upav8OO_MkECCS0rTQ-M-1KTL1D9X93_oAMfl3q5CEd7X83Vc_NK-WUnoz32YJr
    FNlMHkN0Hn3BoAdNBuwbRzJkWMrFroh3IdUp6K00YdLzO217FbKLYqs>
X-ME-Proxy-Cause: dmFkZTGmsPq5DgRq8no1htCziDiV+kvVsXzKEfveyBYJD9kJN2wUSLt4g7Z2vyyDVhlePt
    gFkcmIdqG46pLVhAKrgMmnE2tcXOVQrdHFT+TCf20dxQQVWXWwOOeuqJ/XOaJ9+/0JkA8N
    kOEbI+POmIaOmj/86X6pzXOt2nmy0B7XXCCQ5+7/MvurUXGzwiLfobOPfiKAhA0gMcRujj
    ZeaPKXHexYarnFDBdIMSx6vGpJ5TTx6TGPpVqbbxtP9g47mBvHNPsASA8eS8+59t1vtzNd
    J1J8BH6fSWQNFhY855hdZcBiAZ6Ra7Xu40rrlNIvGO8vxdA/EmBdWWn6TAEWQG+y/9gPAK
    8BIEgUR2tLSZ+hC+N/+HCCK6aJOjj1IJU+1uUQaZ5SOJaYWmQyyhsiWrxNb9MCxPmu+H+2
    go2dQMZuR1bGHeB/LtqvijjQ2N3jlWAYevgMMQ47xQ0KRfV9ZuqE6qdSjnwZv495OjXNi9
    Fn54ODo3KAbZ+ICncfkR/8fw1+fdcG5rvUxAUHNAi36xz4+WfuKuISJ5qC1e5zW5NIoLFM
    74u9S1xNOibMDPSRzhUhKCPy4GgMmDSELf/Td2BBqqdcJnqcLxOvT4hYR0TwbiTmFKuTL1
    fUls+Kl5B8J/VK2agB+mCdSByV0pY7VteZiLsGjuoGw6tSlnUsMdsQHaNf0A
X-ME-Proxy: <xmx:Q9upatCaxLqgZjLYas_19Wgm_f3sICNY0dKhW7NR1E-K-vsKqqFemw>
    <xmx:Q9upasM4PM8AbH4P4SQN19ApdHL4qJ7fpveM-JWSaYTs5uEl9PqC5Q>
    <xmx:Q9upamwxHA2Aq7IUKNSR1kP1fGF3w_stV_69NL-UawzNG0tfkF_EDQ>
    <xmx:Q9upasVyRXMcb2IksSZstZgsaNFkEqU67-y8xZQUTTwYoQNZMhqeRw>
    <xmx:Q9upaoM3JZGtigzkMdfJcBever5KD3PhD5fStzhn73NEQwODu_s7jiyb>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 547F8780070; Tue, 15 Sep 2026 19:56:51 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Date: Tue, 15 Sep 2026 19:56:31 -0400
From: "Chuck Lever" <cel@kernel.org>
To: NeilBrown <neil@brown.name>
Cc: "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Rick Macklem" <rmacklem@uoguelph.ca>,
 linux-nfs@vger.kernel.org
Message-Id: <e9d27cad-634c-4c0a-8f51-a59e4a963c06@slotpi15m67>
In-Reply-To: <178944919634.207413.1627415312248503752@noble.neil.brown.name>
References: <20260914-duplicate-reply-cache-v4-0-bcf9d2628a94@kernel.org>
 <178944919634.207413.1627415312248503752@noble.neil.brown.name>
Subject: Re: [PATCH v4 00/11] Improve the scalability of NFSD's classic DRC
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Tue, 15 Sep 2026, NeilBrown wrote:
> You actually made the xpt_id 32-bit and the reply-position 64 bit.
> I would swap those, or at least make them 48bits each.

The changelog described what I intended rather than what I built. Oops.


> As a connection can exist for an arbitrarily long time, if the xpt_id
> counter ever wraps you can get a collision.  The age of cache entries
> isn't the important age - it is the age of the connection.

Agreed. Two live connections sharing an id would let one connection's
acknowledged position evict the other's entries for as long as both
live. I=E2=80=99ll make xpt_id a u64. A 64-bit counter cannot wrap withi=
n the
life of a connection, which is the property the v3 xarray provided.
The DRC entry will carry the full 64 bits.


> 48 bits would only cycle after 3 days at 10Gbit, which is much longer
> than the cache residency time.

I'll keep the reply position at 64 bits as well. Nothing depends on
the width, and packing both into 48 bits saves four bytes per entry
at the cost of a comparison that needs explaining.


> (I haven't properly looked at the pruning algorithms yet, but I will).

Thanks. I'll hold posting v5 for that.


--=20
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
