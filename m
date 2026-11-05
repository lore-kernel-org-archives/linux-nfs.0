Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793846385;
	b=4m+ipG+4bWFXFk6QOykMd34p1yddVhQdG//buGQ8bG6yIdAKvUmGMFVyICtLIBGkC1TU
	 xN4abRQxNQRnjwuKdmqjERC/wIZ44j5bff2sW/PA45m/FZXHlGd1XWiLmV5BuaY1jxybQ
	 St/fdgjvpzv05jdWe6VQ+Ra+6H2Mx2kj7kIkjoX2bBQP3/7STIBjdW8JlMhWi1l5vBEoD
	 /CD4Vaxj0xxfJhVL/nrqMnPXwDPXtN5/ZMHiPfnq+hziwTWxZ5jm0bGI6nPC11z80l+tY
	 OpdFrCiMC/YkA1Ti1b0bGbIlakygHr9VcLR3ZzIHg0KD89FqIgTZFnejcnrphKOAjAQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793846385;
	h=Received:DKIM-Signature:Message-ID:Subject:From:To:Cc:Date:
	 In-Reply-To:References:Content-Type:Content-Transfer-Encoding:
	 User-Agent:MIME-Version;
	bh=DDbyGbw7MuW06WyclY7o5d1Swb0uU+IZxHgQhT6kOYk=;
	b=rM32XFAaHD9JKRNMBvtMC6buDtxlHt4h9CqQa/QUjIA7SpbY+FtsB0UX2vzlNrngIvmW
	 8F+8/KE8geGQb6VgZyQ83oilhlkxqyNKvNhxaAG0g/VWFICVLPg4KlC0amzul5rIhPVfC
	 m6E46sRfnJPuw2yUjhkPUDkGp0jPC+V0Zyldk2SGbJwm6hXDsViguNBLgwp1HsQ8LrNsI
	 CTUQMnviYlHa8qe+H0LvWf86DHK2OkXoheKowY+L7HCj7ZzmE9MERT0ijmHlN/R+Ni1qD
	 2yRba/ZrK3smPhjU+EqtptsR0IQj+ENQSlQ+oyJ6/Z0ejTDKorRm8srqrrxuLX9YaXQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SHUHxqbE;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 93100606A328;
	Thu,  5 Nov 2026 02:39:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SHUHxqbE
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3B8EC1F000C1;
	Thu,  5 Nov 2026 02:39:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793846385;
	bh=DDbyGbw7MuW06WyclY7o5d1Swb0uU+IZxHgQhT6kOYk=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=SHUHxqbE3t3YM5hIEkDdQ8afRpxWqPJNGPxRLe5OwVSvY85UltD8+HcHU87f8oiue
	 qHKEaGcBoYepq22JqOVfqjNQZiFja1TNoob8CGIEEoGBlcbhxoxGIR3Ha78YKSiieZ
	 ZtR2GPMigteigfdl4NP2fhqbL4jLP8HMsCUi0NJJyGoRkjyUrFgnKh/4U5nM8lvqBL
	 36das2JME1XE6XX+X8irQraBPtyhYsSOtUD/XGtN6VOc7zwUoIi8z2N+mMH169sM67
	 hZMPApcfFWh0CqpdChanIOFLfqW1u/hbAbSPBrjj7LmObAg6C6vI58CHjjKP/qw+a+
	 6W0XTOD7OzPMQ==
Message-ID: <0a489565ca1693403d08eaef7c3545f5b8366bb2.camel@kernel.org>
Subject: Re: [PATCH v2] pNFS: avoid repeatedly cancelling I/O for the same
 lseg
From: Trond Myklebust <trondmy@kernel.org>
To: Tim Menninger <tmenninger@everpuredata.com>, anna@kernel.org
Cc: bcodding@hammerspace.com, Eric Badger <ebadger@everpuredata.com>, Jon
 Curley <jcurley@everpuredata.com>, Prabhakar Pujeri
 <prabhakar.pujeri@dell.com>, 	linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org, stable@vger.kernel.org
Date: Wed, 04 Nov 2026 21:39:43 -0500
In-Reply-To: <20261105000131.2512336-1-tmenninger@everpuredata.com>
References: <20261105000131.2512336-1-tmenninger@everpuredata.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.62.1 (3.62.1-1.fc45) 
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0

On Thu, 2026-11-05 at 00:01 +0000, Tim Menninger wrote:
> Commit b739a5bd9d9f ("NFSv4/flexfiles: Cancel I/O if the layout is
> recalled or revoked") added I/O cancellation when a layout segment is
> invalidated while outstanding references remain.
>=20
> The invalid segment stays on the layout's segment list until those
> references drain. Subsequent scans can find it again and repeatedly
> invoke the layout driver's cancel_io() callback. For flexfiles, this
> cancels matching RPC tasks and disconnects data server RPC clients.
> During RPC/RDMA data server recovery, repeated cancellation can cause
> a
> reconnect loop that consumes essentially all client CPU and prevents
> forward progress.

This claim isn't making sense to me.

If a layout segment is recalled or revoked, we should always be
clearing the NFS_LSEG_VALID flag bit in order to prevent it being
looked up again. New RPC calls should not be able to add that layout
segment.

So the only thing that can be found on a second run of
rpc_cancel_tasks() is a task that has been attempted cancelled
previously, but for which that cancel failed.
If you're seeing actual spinning, where the RPC call is just being
requeued by the rpc_call_done() callback, then we need to look at why
the latter is failing to handle the situation correctly.

--=20
Trond Myklebust
Linux NFS client maintainer, Hammerspace
trondmy@kernel.org, trond.myklebust@hammerspace.com
