Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 351C8396585;
	Fri, 22 May 2026 14:56:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779461801; cv=none; b=qJX/LzS4SGRp4XBBZD3dRsvnRn6LoR+jVc3S9j2DZ8vrv+bG652JT+x1P86gwvPC0EezbA5F5OQbaTcMdWOBuROO3ZCSr/g0vIymBC370MFnrttnhQdqXR22PR8e79RnZuhHMPoFBBZJIOdSpMLXPbGi7B+JHPFteZQLorANhe4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779461801; c=relaxed/simple;
	bh=LoQLi2Vxd5rL424g0I14qYHMPrD4+MIL3TKjprCsPig=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=ChUNk02FUCKpPgIc3FRclqIz+mJKHleIONtYYU3z24dZU7BFhMerCmjkT3VQ6A1TZY6TusRRwdjskNrlA/Dasny7w0rJWw7SFnPd1D58irsF3Xii28YM4nTVvyq+YY0TkWFt+xajWSp1fr0NUEDebRUQg/xJVkMCYljja5UNAm4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ghjEWc2B; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ghjEWc2B"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 271CB1F000E9;
	Fri, 22 May 2026 14:56:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1779461799;
	bh=M4AUkmhpFLNBosN32nvGmp9N0vLYJcnYxQVBu5mm6C4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=ghjEWc2BY9m2qG8QtA07z6ZyQl1qWCAm2zNVAJaQd4R/3ngYhwvwIsGO1zvUmnwfL
	 ZwqVSjaSm3Hl6qjxYTz9WlAqO9UEUDpzMliWKs7t/7joVAtYCAMWTUcpFH19sHXL4l
	 qht9ulZOeM1hIa839tsBJ3zTcokSpi64X5x5aKrCsz9rTMg3/FaEKTWA0HMXkzjd+n
	 Et3qANy7oNPR2knWoSI42iANpswxJ10VI2cNgxyvYpMYZiIRqZUbgz/nbRLBK420pl
	 yYLskisHBdb8z7lfXjngEHCa7wjDofDpevcm+TNK8mZgavuTHVBmare/9yDs44udIA
	 wbmeCl7xO4Mwg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Chuck Lever <chuck.lever@oracle.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Chris Mason <clm@meta.com>
Subject: Re: [PATCH] nfsd: avoid leaking pre-allocated openowner on unconfirmed retry race
Date: Fri, 22 May 2026 10:56:35 -0400
Message-ID: <177946177414.349162.15232740993445200855.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260522-find_or_alloc_open_stateowner_unconfirmed_refcount_leak-v1-1-a66645e1e006@kernel.org>
References: <20260522-find_or_alloc_open_stateowner_unconfirmed_refcount_leak-v1-1-a66645e1e006@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

On Fri, 22 May 2026 10:36:14 -0400, Jeff Layton wrote:
> When find_or_alloc_open_stateowner() encounters an unconfirmed owner, it
> calls release_openowner() and sets oo = NULL. Control then falls through
> past the `if (oo)` guard — which would have freed any pre-allocated
> `new` — and unconditionally executes `new = alloc_stateowner(...)`. If
> `new` was already allocated on a prior iteration, the pointer is
> silently overwritten and the previous allocation (slab object + owner
> name buffer) is leaked.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] nfsd: avoid leaking pre-allocated openowner on unconfirmed retry race
      commit: f36ecdd78c6271239579ad7fb3d0a51697160877

--
Chuck Lever <chuck.lever@oracle.com>
