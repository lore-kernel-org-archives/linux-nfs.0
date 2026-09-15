Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AE16C4052AF;
	Tue, 15 Sep 2026 19:08:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789499312; cv=none; b=e1fSlpQ7wQqVFI90L1z8r3WGIpMF0I9ULIBYxWETyuXxd/QidcKy5Xb1IL0Tb1/3mWkc+jYqSnHP4zn+gsH8sGWYam9A10L+Y1eTreCT98Xpefr5Ziu8ht7gEWj6r6eFYV4dGuH4mzIawC5CvcA/lRDifAlVOIsDbOxKnhjp7WQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789499312; c=relaxed/simple;
	bh=KKohnUc77AADdttc9Tnbx0MRiy6ZF0unB90rxq2hiog=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=PDQq6ItG7Bfc0f5Hyb+G7Ens2y+rPDpYjvVhxuof9ocI9jROC9M3OcqSzAksusMEnAbQw2F/7P4yzVqJ9oTnb4Lhm1whpDe/9Zg8zhEiWVGhHj7LJLZ1JpsP8jK8WNlfA8k20Kq+uPdWz8v1S/KAC6AsjCBvyWg5pTAEqD42lDU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Yg3VrGuj; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Yg3VrGuj"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0C0431F00893;
	Tue, 15 Sep 2026 19:08:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789499311;
	bh=yRqZazuQGXHRUMoa7dMlMDOODjX6tkzEEDYB7tqTYlg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Yg3VrGujWTK9KnG2i40KwgeI3rPyC9yl43xxjOLZSH1s4Qo7jMgCOP4zYZx+0j67m
	 Fknp6PK7Izj7dYvrhDeuwyM0bl0NxaDa8CIFWZ83Ek+6OCiPrrbiBTLRSso45CAeKj
	 auQnOievPJ8zQ117i5qisKZsexvAZQv7DRXOeg/BwRJWm8CJ1hP+26lpg4uR9+4h0o
	 cl4rroe5OIe5syLhH6b4xL2OhJjLgu/6Zq+S5xa3K8kCXVCrftrLdJ47ma1IBEJXG9
	 8J2JeCcdT+0DiSIvPBe5kzQ4+ZtX6HzCKqTzF1u9TgUbRv4YvmNzsIKMRIogAXcfoz
	 bnBel/A1SlwmQ==
From: Chuck Lever <cel@kernel.org>
To: Jeff Layton <jlayton@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Aldo Ariel Panzardo <qwe.aldo@gmail.com>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Subject: Re: [PATCH] NFSD: copy SETXATTR data from all XDR buffer segments
Date: Tue, 15 Sep 2026 15:08:24 -0400
Message-ID: <178949928861.1538756.15155939147455990311.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260915160022.3105295-1-qwe.aldo@gmail.com>
References: <20260915160022.3105295-1-qwe.aldo@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Tue, 15 Sep 2026 13:00:22 -0300, Aldo Ariel Panzardo wrote:
> nfsd4_vbuf_from_vector() manually copies the head followed by whole
> pages starting at offset zero. This assumes that all remaining data
> starts at the beginning of the page array and that no data is stored
> in the tail.
> 
> However, nfsd4_decode_setxattr() passes an xdr_buf returned by
> xdr_stream_subsegment(). Such a sub-buffer can have a nonzero
> page_base and can span its page and tail segments. Ignoring that
> layout can copy the wrong bytes into the value passed to
> vfs_setxattr().
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] NFSD: copy SETXATTR data from all XDR buffer segments
      commit: e551e7dde7b82be0d3e6b848c9c5fef728d020dd

--
Chuck Lever

