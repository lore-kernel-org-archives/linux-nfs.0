Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 17B1D3AEF4E;
	Thu, 10 Sep 2026 18:50:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789066218; cv=none; b=eM/oP7MwLRLyNK/oAsla0K4oXgudJrsmtjl1Aq+qVJvdJuG+vXXb6NTMpKZ6zyylGZYBOJ/h0S2ysMISMDUwl31bAKDCcMtByN4I7grflyubRKkrGCBYMqwLcUb/L0xnioUDi+soMmbpHqGJ1ASdGDwbIUs0xC+bHjsSQalhW/E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789066218; c=relaxed/simple;
	bh=ujiGK2mBYN4D55njNpMD3K7pFUyZOa+rQTtUSV7HoKg=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=W6HB2tMaZR2dna5dsD4pJx1EkAxYed4ZHI8tfAMuFKoWczNEw1mZxczGgBZ1jvB3IdFhsuqBVTC67BCRfbj8lhldA8Zg15m9JscQnqvLc11VODI+CmM3AVr30otM9/2NhuFU7az+hZcICDoV3zbz9oc02EHqLx/f78CHACk/U68=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=lsmhCSIn; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="lsmhCSIn"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BFAD81F000FF;
	Thu, 10 Sep 2026 18:50:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789066216;
	bh=IvGQBiibe9hRfTfJ0Q5aUjiQ0v4Xpo133PdLOJEaro0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=lsmhCSInLsszf/SGtlkqcKzoDwG0eXEvU5K2mrPXFiLOVOCfQZUbsaYWJA60ElK2L
	 scq2ykZjK86blJQBai1zVSaUI5F/D5oHiZebbwj/G5vYAhdvnnAm4EtK08l21uden9
	 tqqK8N7dvWwfMLE+WniP2wOMifgdFJty13ct0sb2OUt03uhrIniksayHKXnlfhMz03
	 mj+F/W4/pw+cGEA9KTMx3MoZLnNQQsnHY7XrEZs5QUymlvaUHzET5ZATKGCBGWeqyi
	 ZdBathoh7vie+uMvbF0VWlu5mbHpleUk8YNljaL3SvqVNeii+WhX2HssjhA6JWph7n
	 ExTN0pFdcC44Q==
From: Chuck Lever <cel@kernel.org>
To: jlayton@kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=A9my=20Jean?= <Jeremy.Jean@oss.cyber.gouv.fr>
Cc: neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: fix oversized GSS proxy token copy
Date: Thu, 10 Sep 2026 14:50:12 -0400
Message-ID: <178906620412.930124.10133388743745728205.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260910125120.3798995-1-Jeremy.Jean@oss.cyber.gouv.fr>
References: <20260910125120.3798995-1-Jeremy.Jean@oss.cyber.gouv.fr>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Thu, 10 Sep 2026 12:51:20 +0000, Jérémy Jean wrote:
> gss_read_proxy_verf() allocates one page per token chunk, but it copies the
> entire linear head of an RPC request into in_token->pages[0]. A UDP datagram
> can leave more than PAGE_SIZE bytes in the linear head, so a large
> RPCSEC_GSS INIT token overwrites following pages.
> 
> Copy the linear head in page-sized chunks before switching to the request
> page array. The linear head itself can span multiple pages.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] SUNRPC: fix oversized GSS proxy token copy
      commit: c01472559c0e38174c89d86adc698cae0551cae6

--
Chuck Lever

