Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 12EC943C04D;
	Thu, 28 May 2026 15:14:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779981368; cv=none; b=K1zc1aauOdXTcZQk2o0X6wYZtRSPaP4yWGcHRo38gutEjWAreuNZoqzhWenQr22AA+q3VtTDbTNNzuRwk8hyRNgu5KSYeYM0FkHcKM/5d+sw/RUzsR4YgOfGYb7LsWJUe/GYAREE2mchfHlDRCkCTmuuc9q6fYr8MajMozEBQXY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779981368; c=relaxed/simple;
	bh=lsACNw3Kny884qrxCSGzjR+h43nF5DaVUfVI0otup5M=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=tfTLycydr2wuc6s6EUNCZN/L1Revx8loq4+2TOf+i0FismhH8SK55bAC63/ghckhhjDMQK9rETDgOsuoRWhLczqtwMoi6ITuCitfwii5oot26Mzi7uopJ+Tfq55i+gU4KpJAYLiGyvSXtuxDCzNO0boqXhZS9mVfaEMNTyuh1eM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=BTPLAvqa; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="BTPLAvqa"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E3B531F00A3F;
	Thu, 28 May 2026 15:14:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1779981263;
	bh=MdXFBNzr9iEuTLwXtx8mjHOI8CNpKvQL8EW2H9NZvFo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=BTPLAvqauGt1tA8wFuTuwlq1GUGgqEqZZ7H020tXUgSiTV3FicD7sbU1N+EYWIISs
	 n7tuuzipU+zWlQs2T2w+qgeHPHwxGWiH7PWX4TH8hgSwruIlxM97BUAUoaj0D+E2gV
	 zY0Ge0oQVS8zhOFm8IEgaANXHzN8X8LXuV3qDtahdTifTsoChbHU2awCU3coSB9F5d
	 7kX9xbIqBSzuw/+tCUC6O6bLXW1iIhpNVs7N4J7EXMenFr3QSu3nH+nPoZu6HyJeiW
	 D4Ktmfe7uhpsnx3quJDmuGiVbDK7YlDNDj8NxbZpGkaTiS1YIGYRlEO3zUykx4/xAV
	 +1dnklH9TvzNQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Chuck Lever <chuck.lever@oracle.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: fix XDR length calculation in nfsd4_ff_encode_layoutget
Date: Thu, 28 May 2026 11:14:20 -0400
Message-ID: <177998122994.340259.8082786758412696206.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260528-pnfs-fixes-v1-1-8a1255ae2f16@kernel.org>
References: <20260528-pnfs-fixes-v1-1-8a1255ae2f16@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

On Thu, 28 May 2026 10:38:15 -0400, Jeff Layton wrote:
> The XDR buffer size calculation in nfsd4_ff_encode_layoutget() has
> multiple errors that can result in either an out-of-bounds write or
> leaking uninitialized kernel memory to the client:
> 
>  - fh_len doesn't account for XDR padding on the file handle data
>  - uid and gid lengths use "8 + len" but xdr_encode_opaque() actually
>    writes "4 + xdr_align_size(len)" bytes
>  - ds_len omits the flags and stats_collect_hint fields (8 bytes),
>    while len's header constant overestimates by 8 bytes -- these
>    partially cancel but leave a net mismatch
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] nfsd: fix XDR length calculation in nfsd4_ff_encode_layoutget
      commit: c8bb9d5360bfb534065aed091579199ad2843f43

--
Chuck Lever <chuck.lever@oracle.com>
