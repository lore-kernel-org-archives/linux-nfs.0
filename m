Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B774035B64E;
	Mon, 16 Mar 2026 20:56:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1773694610; cv=none; b=F5jLFNYSLdARs1fsoH07eH6MjMu5nrvOlaG3m7ug9uUwQL66fgiNhD4eJ6EMleO/rR13ZgA4z+nR+oIxDi4fLBrZJVfNrn4tLZx26Ce2rZNwP4IPrgUiRFLHRDC/pMuh4wSg6Q6Jy0BfHy2VADqzzrOJ8UfLaOv7DKG0arkgw+c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1773694610; c=relaxed/simple;
	bh=qxlH5h5RsDpVAKKzooEbTyCw6wl38yRcEmCwAmeNLjk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=e8QFYglmxKTl23pgeoDb0xypvW1wt7WKUaFTLNVlXvb5eXLRiOHVWphnCV/AR/moXg4F+lJIFj4B7cfwIPYT5e8EMfX+SNZfBlxFsCaQQ6zfaarHl+VFcd+UPcJ76qKtfbNVOI+nH9POZt2CWP7AKyptZryyNpUAZjSKG3ZE0i0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=dlDfVP4h; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="dlDfVP4h"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 469D6C19421;
	Mon, 16 Mar 2026 20:56:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1773694610;
	bh=qxlH5h5RsDpVAKKzooEbTyCw6wl38yRcEmCwAmeNLjk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=dlDfVP4hQVMmXLTOlNUTyYwgBSXkGYeJY7ZHe8ZO0eYPKj+GvX5OfYLl2jhAA5Qx+
	 9OySuC/FlFVetDx8fjeAKjfFy+zxkZJW/JdOoeWdi1xtBvJxbtgLWG5I8t7QsW/8o4
	 A7cHfJ9zGos0z8Lomq/lEIyeY/dA/l1jynjp2O1lIx5sQP1HQlKO2aaqa4wcxbtf+q
	 l8eBXGrqed2Yps36lKMpuXCX6aOxrQWENBALFAYe6O3imS5f6naNPEbLrRE9R3OQ8k
	 +e3QVL6ANXirTjnllkD4TSS2Fgq9U01KC2BlJJqXtesV7FjBRO0t8xfgBZZ7OxS14d
	 Ek2v6u+xfJWEg==
From: Chuck Lever <cel@kernel.org>
To: Jeff Layton <jlayton@kernel.org>,
	Joseph Salisbury <joseph.salisbury@oracle.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: fix comment typo in nfs3xdr
Date: Mon, 16 Mar 2026 16:56:43 -0400
Message-ID: <177369453346.774056.8240280459923640975.b4-ty@oracle.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260316182516.153940-1-joseph.salisbury@oracle.com>
References: <20260316182516.153940-1-joseph.salisbury@oracle.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

On Mon, 16 Mar 2026 14:25:16 -0400, Joseph Salisbury wrote:
> The file contains a spelling error in a source comment (occured).
> 
> Typos in comments reduce readability and make text searches less reliable
> for developers and maintainers.
> 
> Replace 'occured' with 'occurred' in the affected comment. This is a
> comment-only cleanup and does not change behavior.
> 
> [...]

Applied to nfsd-testing, thanks!

Removed Fixes: and Cc: stable -- not appropriate for fixes to
misspellings in code comments.

[1/1] nfsd: fix comment typo in nfs3xdr
      commit: d62daf7b8995e05cca3465a21139f619db860ccb

--
Chuck Lever

