Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 529722E6CB8;
	Tue, 22 Sep 2026 15:50:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790092244; cv=none; b=kuitTnUb/A0HapxlRlSVlgZx3qzDKhZMxaTWhdsL3lAXhUxky3gbWEwMIrF2MyXJ27UGdhd7WjwaSaSE2UdHKVmLbSreucVa6p7t1rnhs4Kp1N9YCttsw+Q2D1EFQNSuBLCV2tr7Kp6/UiUhcOSDjTMDXJz7zA2w5dDVJLsb9RU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790092244; c=relaxed/simple;
	bh=3koSCElWwOESrX6xKxAFez6jkHyqhK64tzuKR0ZxK2c=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=CBPN3w9OZalOaOcC3UAQbvI8n7Bftr6GFn2BuRf/YFLwuoe+Z2yRchQyi0igvNbXR+qM10bFes3KxO5/ck1Kh6oemvanLKLgZMkUoBW6mKSGMvdPj7Q0O6Cfu2betrAIaGYkgrP2aNeMJkKixKNuIEm7oopBvwURA7NEdOlRbUI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Jqtz5ujv; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Jqtz5ujv"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 50ECB1F000FF;
	Tue, 22 Sep 2026 15:50:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790092243;
	bh=PI2eHKt8GbAK3l0itKjZZ7s4QDykuR/MteUj6qpA6AE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Jqtz5ujvhaQUnpTtkJcRyfDsHoRaaJZwdPnoTCsnaNdzVKTgSrFOytF+vxsV8MqpQ
	 ASyJdn6kEoROKucok2ZYyZ86qCPtjrrp1d+71Qu5HFW1mUS5rXUaIqC9e7ZF1+ib9u
	 8QxNew/R9aA6GeoDXDP+6C1eI0fPThcRT2HSDAUOBA7EYN6Olc4E9T9W1+BaYpqqMY
	 fNHmBUBlbDCFSD5uaHbwUfHjd37WdkE0ZYSAzh4kZh5QhnAS8COTJybNlN4YasxwI2
	 FvnRi7OXoHPo5FGY8umS6LAsqpY1t2kE59/V1Ndt0rkNUzmHnWNrhUngMR5kHGxfcM
	 jORdlzflKQolA==
From: Chuck Lever <cel@kernel.org>
To: jlayton@kernel.org,
	trondmy@kernel.org,
	anna@kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=A9my=20Jean?= <Jeremy.Jean@oss.cyber.gouv.fr>
Cc: linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] SUNRPC: restrict integrity replies to authenticated payload
Date: Tue, 22 Sep 2026 11:50:35 -0400
Message-ID: <179009210779.3799844.7254205023997766038.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260920210712.2887738-2-Jeremy.Jean@oss.cyber.gouv.fr>
References: <20260920210712.2887738-2-Jeremy.Jean@oss.cyber.gouv.fr>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Sun, 20 Sep 2026 21:07:13 +0000, Jérémy Jean wrote:
> gss_unwrap_resp_integ() authenticates only databody_integ. The checksum
> object and any bytes after it are not covered by the integrity check, but
> remain visible to the XDR decoder.
> 
> This makes RPCSEC_GSS reply payloads malleable by bypassing crypto
> integrity. A modified reply can contain only the RPCSEC_GSS sequence
> number in databody_integ, reuse the reply verifier MIC as the body MIC,
> and append bytes that the decoder consumes without invalidating the MIC.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] SUNRPC: restrict integrity replies to authenticated payload
      (no commit info)

--
Chuck Lever

