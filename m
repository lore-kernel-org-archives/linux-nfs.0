Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793213491;
	b=fUYjbl7j7RpfgJIgZeMiDaapKWUXiRLnbwMNwYp8Uoy42tsq9DFAHvExGgB9rP3vbSCA
	 oDJMInRjhE2gmYEFbIva5MpKGLfHv0VV4gil27CXbeJpYUdWlBJyF8mnhpT2ZH75ErCWO
	 qi3YB5pnU8QwLx7vU/SBlM5PdryN9dHOMUv6i+DcrpOUMjpW2jtJxZyajdpoNRU2xHLWp
	 Hr9b7RYmT38tgKlr8uSQSTMemA3QFB7FawgiKC45z6tVPSrvZVPvZlwS7FLOi4CEOfkJ9
	 F4leX1uWlaKC5giFfA/5IOG8ai5UlZLrQ1zOFaFyZc2ikryWRB1hpTpayd84ZJ0/I0A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793213491;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=XMy7Wy380HQK0w/tg1fZWig26G0inD7N9DgxTlifRoo=;
	b=4qgVpQKttZggrc+NbK9HOEjk3OxGWUuKHfeIblvgWCxQqXXKVDMeuYig2LyU8N+mLEGc
	 GA6yGD22SPzoKMvobWDvlH6+T5zRpMG6MQFV436J7VGV/JTxLJA8ePxub1mV/7JAdFtWZ
	 3yD8YbSUi3PyKVb3WH2erkucN8IWcd8sfAyZeP7a1fyLe23wCM0HUcKhV/o0e6n5RqcLs
	 iZpJVjgBRZr/dlOkLXypvh/gQaklZ0wjXmVUBds4Ph0eAokdpMrE1Rdev3NG7dvXNDPV0
	 EOX7FzOnhSlo1fLH+r0ln/rbEiAkSuVUyqF2fomAp4DOPEaitXaNt1B0s4mcwcBKBtQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=k4HV1sUl;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 96756606A31A;
	Wed, 28 Oct 2026 18:51:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=k4HV1sUl
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A710C1F01825;
	Wed, 28 Oct 2026 18:51:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793213491;
	bh=XMy7Wy380HQK0w/tg1fZWig26G0inD7N9DgxTlifRoo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=k4HV1sUlE4F3Ui68P31EX47lFJ4IT24uJvOTJsjtsd+L9A/NDpehYMWXhfeo+Uwie
	 tsEAMUgvqj6Mh9Nv7e7v20eueKU7V2AgtNdCKdbgi7YkXl1C69s6QjW+e9hKSe8jVd
	 ieDa095VGPSKquzkkTYwLIohUc4oK1yp5/GssAkgvBzp95ENsyfHHNEIX4JjKiOjia
	 Dtr/A76ZvAza+I10JBXs3OeiaEDHNwCF6lt1DsomIG8navcLpFWW5l3clCmX4SWT81
	 0kX+v9zyio0+sVmmiC4ZT4LEVHE7UbTqKQqGGOzFT6axYF+VpJjTVcHrNCybbjd8Jk
	 uikjFbCT0njtw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Yifan Zhang <yfzhang23@stu.pku.edu.cn>
Subject: Re: [PATCH] NFSD: Don't dereference cp_clp in async COPY tracepoints
Date: Wed, 28 Oct 2026 14:51:27 -0400
Message-ID: <179321347995.402520.11252065440486684929.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20261028-nfsd-testing-v1-1-9116f59c4f77@kernel.org>
References: <20261028-nfsd-testing-v1-1-9116f59c4f77@kernel.org>
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

On Wed, 28 Oct 2026 10:10:38 -0400, Jeff Layton wrote:
> nfsd4_unhash_copy() and find_async_copy() clear cp_clp before
> nfsd4_stop_copy() fires trace_nfsd_copy_async_cancel(), which reads
> copy->cp_clp->cl_addr: NULL deref on shutdown or OFFLOAD_CANCEL. The
> kthread's nfsd_copy_async{,_done} events race the same clear.
> 
> Pass the client explicitly: cp_stid.sc_client for async copies (never
> cleared), cstate->clp for the sync paths.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] NFSD: Don't dereference cp_clp in async COPY tracepoints
      commit: 944812cf2b775193097bd4d1f1dd96ab928d1d97

--
Chuck Lever

