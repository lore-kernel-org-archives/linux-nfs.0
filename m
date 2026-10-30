Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793396610;
	b=HtNdojVp2EkmQukeAt5qlYzHFdbday5xguOXXhU6+64KP6BJpTzLEgFimYPB5v01dXw2
	 XHsUlHWOXbmQ1uEUUShC9PmfOlZWfE29vzArJa5vbYq2ovL5QP9ZWQkwgXu++B13sj/Zj
	 GTCcTcj7edCxuUZofis4LAyQElGjlouK9jHKp5ijN6YJ+6UIIn3C3cswRQsOkjqQOZ1yJ
	 T4RTxbPjLrIMbGhJo9JKeRGXzpD7i1OUr5t7Is3/H+ooSTDDwOqkwa8c6TDC9qTxXp+eU
	 WRtzvOPlykxUFUQNgzBRcZboNScOMYS96ZFFtx2gITEoSLtMgNA8Wg2+7sOpF41jUqg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793396610;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=j3vbgXbZHnn3iHSQ5pj8qluHvC2nN3z33UCsESnDXSQ=;
	b=3tPAPXt0kzQ2KYsYOu+gwpMTO/tlSnZ0z21R5nYl+fsjps5QbFZ98J6G+83bg4Xl2x11
	 cl95v3+HpcrhuXmuVORoJTfKIb4kLsbxyaUvLHqeiJSxf8HiYM4VLsjhDJ6RCxmVp09Wq
	 H8IZvRgs8TD4KRtxv9thcp5EJRoACmrcAI9wuvKSh8DzJJWvQx9EYn5s0zCogFwO3S7th
	 Bnp1xKJiS73yx9TNNLxBTDHhZkbN1EPMRbBOAvi9gTR5JiYbyk4RVbSwLv+/BdgVYsdoG
	 SubS8OauL2/kZrGESxoY7M1Vdv/9e6xsMFaQ1htAPYMATHqQz7WSkB8ZMREvaM4qKQA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="Ra/sLxGz";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ECA73606A31F;
	Fri, 30 Oct 2026 21:43:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Ra/sLxGz
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 39C7C1F000C1;
	Fri, 30 Oct 2026 21:43:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793396609;
	bh=j3vbgXbZHnn3iHSQ5pj8qluHvC2nN3z33UCsESnDXSQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Ra/sLxGzFSbB7jz9v03ykF1sv5qfxWM9UoTvasDmHzBwutvBCfL0D6iOy5ts908Zp
	 FxI0Pky/2crqsAvJcnWemmGg3cIToXdlmShYZGHM7PJ+s8wRl/vf4efzvn+jfsybvA
	 oIdgkCXivFoVccCwgrSiIYxcJntKXQQO9hneExlfMN5Sa4vAj3GHxr6Z7UG/mVClvI
	 XygBn2c3pQopSvPi32g13wKsRiiF/wBgAllcmjrWl2BTp/Smvccmpp971XNhi00R8N
	 2+fdepBpJOdIIGMoim1bdWfxg6WOqVHWnhOGSYocW1Mt9Qnbk3VBxaAia790swpmjl
	 FsbAugwH6ShUg==
From: Chuck Lever <cel@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@kernel.org>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Simon Horman <horms@kernel.org>,
	Kal Cutter Conley <kalcutterc@nvidia.com>
Cc: linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] sunrpc: fix lost wakeups when stopping service threads
Date: Fri, 30 Oct 2026 17:43:25 -0400
Message-ID: <179339659956.1238745.16155731377940058318.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20261030130629.103716-1-kalcutterc@nvidia.com>
References: <20261030130629.103716-1-kalcutterc@nvidia.com>
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

On Fri, 30 Oct 2026 14:06:28 +0100, Kal Cutter Conley wrote:
> Stopping NFS can leave rpc.nfsd 0 in an uninterruptible wait with
> this stack:
> 
>   svc_stop_kthreads [sunrpc]
>   svc_set_num_threads [sunrpc]
>   nfsd_svc [nfsd]
>   write_threads [nfsd]
>   nfsctl_transaction_write [nfsd]
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] sunrpc: fix lost wakeups when stopping service threads
      commit: 7073ba6c3383159deb5c1fd47b5b91a68bbcfd04

--
Chuck Lever

