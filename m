Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821489;
	b=rthKtUytHbNLBB3zE8vupFxtAGqFYQ1IvCuRACBArlL80tCDqIgpnJKG+dGNcfcrmYV5
	 iNgI0t67gCRIpn66uJdOI5Cv8pzppkOR57BVhNyCMHNRVjXsBwiNXtTyyl/dUVVc79OBw
	 nrGplqULhbPBCNMPo0t+zgpUKP+WE/FssDSQcPfKIsc0jZFQfZ/+EfbaYRhJqzWbsLaWc
	 jEP8ieKjI/hPvbOKTIif0GxN2pkJWoSAmNMZrCDg/b/5D3gh3rYsPOViRyPKuG8EAbYiP
	 ijqkYqP44XROoIwJrLcC8pXhgiI80SAJR/Ge4lRa961Kc3kGAlCQs1PM7zIZf73i0Bw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821489;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=2DIFJ5jJlYzJPMIdKPauqvXkqYFBoNwC9ez6FNjCYHo=;
	b=0nqYzct48TELmjkG3kY4G+XkKAmuEdrZBi7uF5IpH8Xx0pSWlfr5haAHN5DI0TZM4Tq0
	 fjZypgz2mAhSjHn3OnYh9GZ1Feykc03xwzM8kAkVSkcslc1YMgYzfqbDSmlO1qCGkkFgO
	 vsQqzzv1ZjlW0fLrMoB1Bb4B7/E7gJriYHxu4x4YhaYUstRq4qXsRFnqk2wvwnsAz2MMh
	 qZxz6mCpt6v4/EnXeCq41NG6O6dKxMb+cEZqV/DMYhyJYz6WRbwOrUNl+4UFQsymi+NsK
	 d4k0DJt6TQhK4lPCUOuqGaFIPKydULUswITOSmQTfbDsIrET8UdgBtby4HTOo+cobIw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WPFcLzfV;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1BB81607030D;
	Wed,  4 Nov 2026 19:44:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WPFcLzfV
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BE5BA1F0093A;
	Wed,  4 Nov 2026 19:44:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793821489;
	bh=2DIFJ5jJlYzJPMIdKPauqvXkqYFBoNwC9ez6FNjCYHo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=WPFcLzfVP97NGPz4uvfD0tn9TF3oxy56k585OeuIzguUPQaggjZVy88Ocm9si3KAv
	 HjirZCHxtf8CmlysGGeGTR+lVLOxQOhUuaQa2kPDnnLuc7RZF7ZhDPThO8eJGFW+s1
	 SXZL8Yh1XKy6Yfz55+sG8WnlJ06y7qeKlt4+3ALvc4WcsjUqzizcg3/wadY1Ce0Aq1
	 /eRWEnrDYSmQUyns2otho3fX9Pm1WAHF2DPeqyEG2GKaBrL4qoNR0e7vrnqxB2etmh
	 Gw4NwKB0AZCZqpmwrRyt82yVVTMYh7h3+XKHjEc21+opDAoPUnIGeLKkfpRBeUo3sh
	 sXo3bwBl2WXgw==
From: Chuck Lever <cel@kernel.org>
To: Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@kernel.org>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Simon Horman <horms@kernel.org>,
	Kal Cutter Conley <kalcutterc@nvidia.com>
Cc: linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3] sunrpc: fix lost wakeups when stopping service threads
Date: Wed,  4 Nov 2026 14:44:45 -0500
Message-ID: <179382147228.3451569.5508122836969560967.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20261103121915.25298-1-kalcutterc@nvidia.com>
References: <20261103121915.25298-1-kalcutterc@nvidia.com>
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

On Tue, 03 Nov 2026 13:19:14 +0100, Kal Cutter Conley wrote:
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
      commit: ba6c77b2d53faed23912074f0853dc7b798b671d

--
Chuck Lever

