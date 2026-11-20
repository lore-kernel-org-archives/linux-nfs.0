Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795214799;
	b=MZPhYms6vJSANY+gTgP7HVDmmK+OykuLPbiTX3bvKK+xK/gIdQB08q42TpHmLo6PUObD
	 ZStg70vAzTog5yxhJTshm4hq3Ty5wOvOcQRq1s63ChlWVaFhrZkvIA/nYpaAvvqT5RQBY
	 Chc0sNVxRaBtuzTW46ulq64+7oZVIKGrWcGRTwngEt02tgZ2iiRPyQojx8/DMGGcXEw91
	 tQd96FMc9t4qMBjpuDyR2f9vtNnjZk2Y+TTrhw0kZSkixs6ltqeJOO35puORkSetAo+bU
	 MhSGypZyE4FWYcwrXG3N39FyFJPmlUdjKgzsyX3yvWrWJv05x4nepLcI2Z0+hf+59XQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795214799;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=DMfrqVPjPuK+e72+6L9bE14tazO/DZzHZLMmL92Qx8k=;
	b=EuxaMmXa+UgdUaWKrNalCEQaXQEwJWEZ1PU9zpzW3pJnyfv22zFlj0YQ5wwwDPZzB/65
	 fSAEYPSbOvrLH6E9a9QxdM3OBl31aKq24iy186kQY1R48D3wlPc5qt5OKplWDz+fEBkJZ
	 8ZfWx0F2J60YsKjtQuIAiOwAH4cURfPnr2zzdZS10t2G4stwNkip6KGJN/qxgBWU0BLVI
	 Nwxf3vz2OVXnXxKQopqVZPyje1kl6yP4IuSLil3A8bQwUg+IXu0y8poWkCb+ecawgx9mW
	 5OXGH/T+JQFXQVc3bS5P3OqAvw7wMSGqi+ggLQMV1Mg5wSGIiMMNkki+OtuQg1aByCw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=JvHQcD7V;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 237D2606A32C;
	Fri, 20 Nov 2026 22:46:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=JvHQcD7V
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5BE7A1F000C0;
	Fri, 20 Nov 2026 22:46:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795214798;
	bh=DMfrqVPjPuK+e72+6L9bE14tazO/DZzHZLMmL92Qx8k=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=JvHQcD7Vx8eKnvv4+OgD6+g5xBlMnDQM0b4jrgYV34hRsn2Qou+8K4oKOqzPHajUK
	 Yn4ruOx0M0cw17DRuWRjhsrn0wdQHOxNzpJin2VgahG4M3z0wKoNog9oZjlsCoiOYZ
	 6VomTww5ovIyXURdZsUjUCvMPUldcrGQme48v02T9RMmNBsAIzuweB0cBJPK8vScXV
	 JJub+6RaKo/ollYJiGEX/13sQF1Do0A50Jsgd0uv3mClUVOhf9r/1VtT94lzUQk0Cr
	 duUTIn4M1UQOvzw2ef+bvs/hclEtn+3q0xv7m2SpP2OsutK+SwCimFGXHp3r+jhR5c
	 3mKNrQGwe/k/g==
From: Chuck Lever <cel@kernel.org>
To: jlayton@kernel.org,
	Yiran Qiu <eritque-arcus@ikuyo.dev>
Cc: neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: copy the GSS init token with read_bytes_from_xdr_buf()
Date: Fri, 20 Nov 2026 17:46:36 -0500
Message-ID: <179521478676.60322.17225332794263348687.b4-ty@b4>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261120060007.302599-1-eritque-arcus@ikuyo.dev>
References: <20261120060007.302599-1-eritque-arcus@ikuyo.dev>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Fri, 20 Nov 2026 01:00:07 -0500, Yiran Qiu wrote:
> gss_read_proxy_verf() copies the token from the head of rq_arg and then
> from rq_arg.pages, assuming the rest of the token is in the page list.
> svcrdma rebuilds a Call that carries one Read chunk as head (inline data
> before the chunk position), pages (the chunk) and tail (inline data
> after it), and xdr_stream_remaining() counts the tail. When the token
> starts at the chunk and continues into the tail, the copy runs past the
> chunk's pages. If the chunk fills rq_pages, the copy takes the NULL
> entry at rq_pages[rq_maxpages] and memcpy() reads from
> page_address(NULL); otherwise the stale contents of the next page go to
> gssproxy in place of the tail. This runs in svcauth_gss_proxy_init()
> before any credential is checked, so a client of an NFS/RDMA server that
> uses gssproxy can oops nfsd threads without authenticating.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] SUNRPC: copy the GSS init token with read_bytes_from_xdr_buf()
      commit: 6d817b9ca893bc2603446e340030e149e5c8b207

--
Chuck Lever <cel@kernel.org>
