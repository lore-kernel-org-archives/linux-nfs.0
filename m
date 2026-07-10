Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C15FD2E7394;
	Fri, 10 Jul 2026 19:51:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783713120; cv=none; b=KuTM4Lh0Ozh0zteijTmuc1mMOxKwQ4Zpm10vdpds9zEi5AOm0CdmoTWyIvQo+IUHsBpkBq8yRaqdGYDTvEkKWPPB6SUe1jTS3JLd4cjm7g7A2D1IUUlu0Hj0e+rgRXDtSa/qsVlJwssFKRtdvrr5Ox/k2tl30xNYUHvMqCQ+8vk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783713120; c=relaxed/simple;
	bh=FDpm1mkuSo1w7TyKHUKoK1nnbVMoH95ahHccAVHNcKk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=GdY3ngm5dUV7al3savcaU5rebdwSoEDk4RuD3DgIIPB2mTDG2m8VCganiV7HUKC47dgDZlggqA2TyE0OV86pwTbx0gaOkB3Eg4j8jIi0xTZjWk4Y2DG485pOIr0dwUn966GO0z8eXe5n1UCK2M1l0uK/Wh/a29oYnIbPo6PcOgA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ofOJRGVa; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ofOJRGVa"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BF7A11F00A3A;
	Fri, 10 Jul 2026 19:51:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783713119;
	bh=dswdJqdyyLehMDU6x0rjBEhJUMCOAo3KbOtfnsVAcQ4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=ofOJRGVacKIkwuVUR33Vyx+gIpEsJ8sa5ptd18xsRQpMKVEgBTF7TBS/E6P5LDFXf
	 KYDoAqQ3Ed+DTHmo24ZtSAcLu3AzPPCEmwvGenhSltwy8QyjGy50+bRFL4du+Pbf9A
	 MHq5XaYrB8du9LWNAAiTSFYCRgkI0Kxm9rxOg/Ro0azliB2aRvP97dLiU3rumICuib
	 l651u55/zf140VxpXXquyADOzI9TVkYRIkhbcio7a7Gnl1rm6Xt5hyytfd5SxDvdTb
	 b5yyd/UMBbmXm1vVDColQmAYPbR1T2xZagesTFcSRHa942a7YtrR1Tial8GyruydoX
	 GylJHR2BOE9zQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Chris Mason <clm@meta.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3 00/10] nfsd: copy offload fixes
Date: Fri, 10 Jul 2026 15:51:55 -0400
Message-ID: <178371305588.2007097.11587521927052686944.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260710-nfsd-testing-v3-0-a0ff7db6aa3e@kernel.org>
References: <20260710-nfsd-testing-v3-0-a0ff7db6aa3e@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Fri, 10 Jul 2026 10:00:04 -0400, Jeff Layton wrote:
> This version fixes a couple of problems noticed by Sashiko.
> 
> These patches fix bugs in inter-server copy offload code noticed by LLM
> inspection. The first 3 were found via kres, and the next 4 fix problems
> that were flagged in agentic review of those patches (and some via
> testing).
> 
> [...]

Applied to nfsd-testing, thanks!

[01/10] nfsd: fix cpntf publish race in nfs4_init_cp_state
        commit: 2644ead835d12198cceef3c407c25ed94717b378
[02/10] nfsd: fix UAF in async copy cancel and shutdown
        commit: a3cddbf9713ae5ac03915b29975dc200ea6493fe
[03/10] nfsd: fix stale s2s_cp_stateids IDR entry for async COPY
        commit: 527c422ddaa3e0a452658faca10d1634f151ca6b
[04/10] nfsd: initialize copy-notify stateid before publishing it
        commit: 23fc79d2a8869ab25f0de5642a0f10d030d67d05
[05/10] nfsd: check client ownership when cancelling a copy-notify stateid
        commit: ee6c8255190685955762f66d23a887c4f86d24c6
[06/10] nfsd: revoke copy-notify stateids before dropping their reference
        commit: 24dd7409daafc00a0f19b61cb91d8f051cdc6b4b
[07/10] nfsd: return NFS4ERR_NOTSUPP for unsupported netloc4 types
        commit: 673c92979f3ab32c92df687625eee76ce42e55ed
[08/10] nfsd: split nfsd4_copy into transient and durable async copy objects
        commit: bf9b4f03a032cc111a6ec707627964f23c9b1209
[09/10] nfsd: make the copy offload stateid a first-class nfs4_stid
        commit: 74d681696ac194f355a2fc21693a44c816715bd2
[10/10] nfsd: drop dead COPY-vs-COPYNOTIFY type handling from s2s stateid IDR
        commit: 9b33df55dcac6950d1e176c7bb02a127d2d3dc1f

--
Chuck Lever

