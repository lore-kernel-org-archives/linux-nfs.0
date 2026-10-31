Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793472147;
	b=VJ+iFkofKwWDXzIGS1+G51+hf0d7NzmlqG4oSj426XUiRqxkeDuke0TQc2HbcISMm0KR
	 wzgQ50Ic90JsffmZHwDRoCRrFXgZOzctrImjoSOBcwmflOQ/dIbU3tJtfbq/Dmq70eFIi
	 Nd2Sh/NuXpx4owc78jdpfjgPCliOfVS2CpG/amD97ih8ov/E9rLFkaOzUiIw6jjysijQF
	 r/cLfb6Cqml6sTuhQ+BeE1Z/r6gEf1l5lOSqpRGMmgxnCHwClcwUAuswKr6LsuPKvcz5R
	 J0X+iolsuEC2XERc/uQfnuQZHrb+ykQwz7eqaugJHzGP6piNAa/q4s3GJXyWuHNCFtw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793472147;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=v1eiqX8docxBHA/MpMD1bL0iQ8o/6yCcGdWuSGen3JU=;
	b=U7RToMfMYDJrHPzMRXRbLxg1u1xYPFYfzD0EYaFTxF2E1pgOSCpf4iTJoa9Np4uTEBGe
	 LGnGaEe2uuJclJxEYFQiiQfspzJSYOX6DF0S7EztYU/5Lq13eU3ckYwzmPYzVWQXSAd3b
	 oOQU5B70RgAMN7glOLGt9+PepQ+GywPPn2l8M+u0V8u8rN2pb6ParrD/ufDiu2xhs327h
	 EtZB0f7gx8GgFu0V///V10al4C4Af6tUyrWgdX6F/rDo4wEeMKvi+EiQdDaMVSPtTtY/b
	 DeNzekmQj3qGEpDJEeTqQ/6nfi+FkFnXTBXrRM6O5IleMYyRfu9GmRpIOQLWE8zKf3w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=GhuL52v2;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 54E53606A31A;
	Sat, 31 Oct 2026 18:42:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=GhuL52v2
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 293DF1F00A15;
	Sat, 31 Oct 2026 18:42:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793472146;
	bh=v1eiqX8docxBHA/MpMD1bL0iQ8o/6yCcGdWuSGen3JU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=GhuL52v2tQWHHqDpMVCXdBVQ4AbXs9TMKrb40xfRUznVL1o/fAv4bB3n3nTL2bpjc
	 VJa6fe93AdpEARFLu+PIO0rzcOgKidBjuiOmmP7a4wkCUVVmdykCs6xb+SWkhaOtf0
	 kMzZMMGI8mq/0YVunxnYL6KORTJUVFR7waThwAtT3jSmAPoqXShJTljyxf/TBSmuGd
	 of/wl5agA4whtCWy82/QlJtgf90syzkhP6zKMzFAN2OyThsSfiZpWCESt0XQbajrT7
	 Lv8provko+SP0lo80o7ePoBNhh+HumYqotP+8PXzghtvZLvz9QW8Pe5klUEZ5fLUau
	 zUUmkSO4SSOWQ==
From: Chuck Lever <cel@kernel.org>
To: Jeff Layton <jlayton@kernel.org>,
	=?UTF-8?q?J=C3=A9r=C3=A9my=20Jean?= <Jeremy.Jean@oss.cyber.gouv.fr>
Cc: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Subject: Re: [PATCH] nfsd: fix XDR tail bounds after spliced READ
Date: Sat, 31 Oct 2026 14:42:23 -0400
Message-ID: <179347213462.1463036.1895447020089582210.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20261031171057.1562342-3-Jeremy.Jean@oss.cyber.gouv.fr>
References: <20261031171057.1562342-3-Jeremy.Jean@oss.cyber.gouv.fr>
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

On Sat, 31 Oct 2026 17:10:59 +0000, Jérémy Jean wrote:
> After a successful spliced READ, nfsd points the XDR tail at the
> unused bytes remaining in the first response page, so that later
> operation results are written into that space.
> nfsd4_encode_splice_read() correctly computes how much space is left
> there, but then moves xdr->end from its old value instead of using
> xdr->p. This gives the tail an incorrect size limit, which can cause
> an OOB write past the end of the page.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] nfsd: fix XDR tail bounds after spliced READ
      commit: d650fb277960ef221f7fa2160072493aec418d65

--
Chuck Lever

