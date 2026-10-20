Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792535581;
	b=S5zMUgV5P4z899SGbVnVhXkBOzB8ssT4C0LyT0G2lg1U0onm7VxwLrl/mkUmtFzzcV+b
	 FLI87QC0nR34Ow8Y0gvP7TtFDEqLTY4Bb5Jh91hm9HvX5kaD3fD459ftxv9WyxmO4d1c0
	 phGk/qY82oF+iDY4DTgoNvAIr9MiJ1YexzXOYDUa9IFlRyBQKG0HS8lbS32CccHgOZ5At
	 YK2X4gO2PyXHzQ/ey/cYFiefsejU/EdF0dbnkgz1SaY0Ed8ERKc6O8G2MBBZcEzTFFWg0
	 As8lYIMcset2Os/A6mgu3n3zV2JZPycAVVHJNL1kNP2jruPJSOlts6oalGPvhFD0QKQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792535581;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=JF4UX6g9ObsiZAz+vCGAncsIAHEoerbShBdxvkYXzIQ=;
	b=F8JPipsXmcbO2lt6D7FoFFbyBy9/GpJvxtKmPe/hWK7lbIi51tIokdSilr0b16iP/81l
	 wpagwlKt7UopEUsZxsAeIXOgmkD3wSP7kew4wvcRP3oqudoWcnNbVUxTwKi6Xxxd8J57y
	 2UiTXppF/9N8RjWDsQXjebpb50ApIGZ7QodhiNb7yt/ct/jMkWtLNq8lK70g1EKmvyvbP
	 uVZ7pDn2hOYf11nR9kNRGhx0DaWCsXPxYV2+rgI4wf6HI/VgVKBo2f1cQtNoLv5SOemzX
	 g80xNAhHqiZIBdXaKAWAa2aLYVr9oy89AzO4RQY7GenfYg0WkgB7f9Rtpe3Kudhi7/A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DyoV6T06;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5BABA606A319;
	Tue, 20 Oct 2026 22:33:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DyoV6T06
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 07C631F000C9;
	Tue, 20 Oct 2026 22:33:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792535580;
	bh=JF4UX6g9ObsiZAz+vCGAncsIAHEoerbShBdxvkYXzIQ=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References;
	b=DyoV6T06zSvLGm6BIuATBoss44O8NV5EHzJpgG2wx/PC8T4Mz9MUkmYleiPRF1cbj
	 MKWdOZyixuIe9SLb+J82c2644AV3/7HXHkiJdm4RTmT1YykWSrxBSUonB6/5KkDWSz
	 dTOlqI0buhnU7GQ+yEXxlbyXIec0aq1ur4K03sbT7WVa+/eLRS0o4pAmetprmTfLzI
	 6ogGrvps+gYStmbg/Zx2bPfOGnZIIdUSBWJ1tfnzYX5fiDbsnAr/Vk6HlhyR8ZhArr
	 tKc2NheTOfhezvqe1QBfmTatSymR8tL2h1PIPjOX2x8WpfWnFr3OR2ymzQMIRxktCC
	 SRYGUA0p/wOtw==
Date: Tue, 20 Oct 2026 15:32:59 -0700
From: Jakub Kicinski <kuba@kernel.org>
To: Mina Almasry <almasrymina@google.com>
Cc: Josef Bacik <josef@toxicpanda.com>, Andrew Lunn <andrew+netdev@lunn.ch>,
 "David S. Miller" <davem@davemloft.net>, Eric Dumazet
 <edumazet@kernel.org>, Paolo Abeni <pabeni@redhat.com>, Simon Horman
 <horms@kernel.org>, David Ahern <dsahern@kernel.org>, Ido Schimmel
 <idosch@nvidia.com>, Trond Myklebust <trondmy@kernel.org>, Anna Schumaker
 <anna@kernel.org>, Chuck Lever <cel@kernel.org>, Jeff Layton
 <jlayton@kernel.org>, NeilBrown <neil@brown.name>, Olga Kornievskaia
 <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey
 <tom@talpey.com>, Kaiyuan Zhang <kaiyuanz@google.com>, Willem de Bruijn
 <willemb@google.com>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-nfs@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH net v2] net: skbuff: make skb_copy_and_csum_bits()
 report unreadable frags
Message-ID: <20261020153259.3aa2d687@kernel.org>
In-Reply-To: <CAHS8izMCh6UzOz8B8O6Mc=MGtCbxLQN9+V8aiA1nGHY6P4xs9w@mail.gmail.com>
References: <20261013-b4-skb-segment-nosg-unreadable-v2-1-6c28d8ffa51e@toxicpanda.com>
	<CAHS8izMCh6UzOz8B8O6Mc=MGtCbxLQN9+V8aiA1nGHY6P4xs9w@mail.gmail.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Fri, 16 Oct 2026 05:51:02 -0700 Mina Almasry wrote:
> Patch LGTM, but net + stable + fixes is very overkill for me. This is
> a very minor issue and only results in some devmem packets maybe
> having a bad csum and get dropped. I would suggest fixing in net-next
> (and I know the bot will complain it's a fix that's going to net-next,
> but in this case, ignore).

+1, given the volume of crash fixes this is likely net-next material.
Could you please rebase & repost, it doesn't apply right now

