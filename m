Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794332555;
	b=0epUUxDuNDYD3aBgHUZJk5d+AOFLmiy12xZaOGrIPdeTqSCJDxussOCPoOwD+4H/m6Zn
	 s+FW4G/KK1qmXKpuxfU28kyT37YIJ1G8LXOobTQNFgMFBA3xLr1irUATpfQzOTl7Sewix
	 6/dqpAb0uXnB2aL0MlwDLKGBo2pOSCz61/eBwsP8SJyZE9QbQXoDjbSee5w17LojG2h56
	 kjcqxzkfneAx0Z+oAoUzz0vlLcgd2DcsExd2JPytXLKCIeykT9UIhTYwuAZRQ9E1ESZLx
	 3EpMKFV00UeQyeaNRMKrkJpImoGAGdDHJ1p8BqfWc3ZksLeME0Sp5zu9/D/py1S6Ieg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794332555;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=jbgSuxD4CgBXy0cbPyYVRCuYyNpAOZN/+jBRNG++0S4=;
	b=sZfg4UEi1/3OTL8fWaf6ppXDNmo8wjIw9A2XmornjQYbU4Iu9p096iDYp1tSswHNDaGv
	 yRGYgcSBImBhWveB7KUKEDKeW1K4BTau5xeIr/Eb4Ax77nypvbN/YHfFiTyzcjKe9oQO3
	 JVEpNQCNiAWd/lbI38GLDYTwq6i60nmO+vEHPXnMQfxdi8++Q7hz3XwvE/MWNEqntg5oH
	 w07LYB4opBfKyiTXCaskWBr5/GcSl6RBLxBQANNKxEQW0NNfLSpoPn2I4oY4Ye7TRe7fC
	 /lgtSl6VZ0L6wX/tHMAEyb8zadhSbQS22GBbpZHvxuOhTI3z2Cy3fSgyJXqawr2aX5Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=NhTxZB6I;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ABC0160A380D;
	Tue, 10 Nov 2026 17:42:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=NhTxZB6I
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 44CB61F008BC;
	Tue, 10 Nov 2026 17:42:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794332554;
	bh=jbgSuxD4CgBXy0cbPyYVRCuYyNpAOZN/+jBRNG++0S4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=NhTxZB6IUedUgovEJg9k6mNFtic5HShCTAb6tXk4BdWSsCiIN1b6LDe6G1FFY5Fxd
	 CUS74SGGPpbCakr6xBU0nermj8YvhF1OdK6PrY4t+ZYwfySr/dktF8GC+xvIV+ae1I
	 ZdkVQgIeMT09omFxbgO44Yv4EE24Pq1ADmYYT8r5invSLkATq0ms1UCUhBRk/68XWW
	 rqC0UK552RYWxSvGpy25Gy8CihoB/taDsFkBXlTI7WfxksrtnbY7Jg0LnepX3josy2
	 QesjmYIF+h4Zs5Xhjxo8OC5zvRvrhNEhLPR8H9IL4UDnLusWa/KCkxh4a7GOcy8rlc
	 nrkLfAjHSwzcg==
From: Chuck Lever <cel@kernel.org>
To: Jeff Layton <jlayton@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Sasha Levin <sashal@kernel.org>
Cc: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"kernelci.org bot" <bot@kernelci.org>
Subject: Re: [PATCH] SUNRPC: Load the GSS module by OID only when the mechanism is missing
Date: Tue, 10 Nov 2026 12:42:29 -0500
Message-ID: <179433250776.39465.13251097480716731768.b4-ty@b4>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261110030947.179738-1-sashal@kernel.org>
References: <20261110030947.179738-1-sashal@kernel.org>
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

On Mon, 09 Nov 2026 22:09:47 -0500, Sasha Levin wrote:
> gss_mech_get_by_OID() calls request_module() before it looks at the
> list of registered mechanisms, so every lookup forks a modprobe, even
> when the mechanism is already registered or built in.
> gss_mech_get_by_name() and gss_mech_get_by_pseudoflavor() only load
> the module when the lookup fails.
> 
> The read handler of /proc/net/rpc/gss_krb5_enctypes uses this lookup,
> so every read() of that file runs modprobe, two per cat. The file is
> present in every /proc/<pid>/net/rpc and /proc/<pid>/task/<tid>/net/rpc
> directory, and LTP read_all gives each read one second. On a slow board
> in KernelCI its workers stall on this file and the test times out.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] SUNRPC: Load the GSS module by OID only when the mechanism is missing
      commit: f7ef2ce48812080b87572a2f0fdec93cb2d2a629

--
Chuck Lever <cel@kernel.org>
