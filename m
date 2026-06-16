Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AB8B73AB47B
	for <linux-nfs@vger.kernel.org>; Tue, 16 Jun 2026 22:31:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781649107; cv=none; b=RWPX7tz7gj8j2Mi14XCDw2mmEZV38Mr+SqtPshD8pgVGXMmlZswBWlnIUBV705Zpcg/PwyC5CumqWG3spsqisSl0heaYchJvn5ryjslShm38HoGP0jAe+9C1/cYpfh9hRYur5PHwx4WpJ2ef/fMzsxpw9HVs3GUXWWx2/5jEpxo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781649107; c=relaxed/simple;
	bh=6pLkKdpLzTQMXWoptcUd76uBEHUgojgBxUWXo57ri1A=;
	h=From:To:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=r9PKB99epvOBDKbkSfT0HZ9TP+bamXO6d3O+VstoiRRLrJp1OPyABt8TQqN1TOf1mOD1AQEvnNcz4nTP8lvWHLKWG470Xv5tn7CVgmu0THTjZlRmQRym40kZ229QzHLIWUUbugALXp5cqBM3V70Iuup6N95m+JEprTN6liBGk3s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=hMBWJ7dC; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="hMBWJ7dC"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 174D11F000E9;
	Tue, 16 Jun 2026 22:31:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781649106;
	bh=pVgZr6mBtU4Dw+g1EVqjGeVAJyldhDKGmNdfEOaLCZs=;
	h=From:To:Subject:Date:In-Reply-To:References;
	b=hMBWJ7dC4umWdQRIBf2xyiw18KILI6Bl389AGhY1A8xIsInFLxKXgChBgbYNjftIl
	 Dd8Fa426Up5glbAojMf6NWIutOMgdaTZUsKCu/kI2K0Th6rhun6mm/rSjSbn407uyY
	 oEeeX6iCTVFK+J3GGe0ZjJhUo7YLoo/5lfr5oiHhXcNvYpUxrrKnhK8aW9HSzt6P1y
	 06/dWAV9aWs9yik1A0FDSBsR+xTAGMXpl1ZcMmOEKcjSPpD0FZdetx2h6JoQH9Dqle
	 LpcBBmwEDmnQY3T0j8VbTsFe1VJ2J9JBic4lcs881Z8ZCsY2srIDD0icfshqo/050n
	 4TGvkrzI0o/7w==
From: Chuck Lever <cel@kernel.org>
To: linux-nfs@vger.kernel.org,
	robbieko <robbieko@synology.com>
Subject: Re: [PATCH v3 1/3] nfsd: reject out-of-range useconds in NFSv2 SETATTR/CREATE
Date: Tue, 16 Jun 2026 18:31:43 -0400
Message-ID: <178164909508.424942.9440635362510515285.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260616054027.2360930-1-robbieko@synology.com>
References: <20260616054027.2360930-1-robbieko@synology.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Tue, 16 Jun 2026 13:39:58 +0800, robbieko wrote:
> The NFSv2 sattr decoder converts the wire useconds to nanoseconds in
> svcxdr_decode_sattr():
> 
> 	iap->ia_atime.tv_nsec = tmp2 * NSEC_PER_USEC;
> 
> tmp2 is a u32 and NSEC_PER_USEC is 1000, so the product is computed in
> unsigned long. On ILP32 that is 32 bits, and an out-of-range useconds
> value such as 4294968 wraps to tv_nsec == 704. The corruption therefore
> happens during decode, before any proc function can inspect the value,
> and a later range check on tv_nsec would see an in-range result and
> accept it.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/3] nfsd: reject out-of-range useconds in NFSv2 SETATTR/CREATE
      commit: 5a6e45730d33afefe6ac1208173365840314dfd9
[2/3] nfsd: reject out-of-range nseconds in NFSv3 SETATTR and create ops
      commit: ccf2a0a8a51b8fa23bd4e4413e01b57a81451c7f
[3/3] nfsd: use NSEC_PER_SEC in nfsd4_decode_nfstime4()
      commit: 324975079e798c30a15d23396c51216937389baf

--
Chuck Lever

