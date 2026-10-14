Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8764C30F803;
	Wed, 14 Oct 2026 18:58:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792004288; cv=none; b=NxQMh6J2kRbaMSMQtHQCX43b3GMzVgkreBZvwqkhYe7NaAMkqvdcfJnY2KnLBz5MXZBF64nzXx0iXh8SpSldo3zBTeUwYZt1SaVpRPQKf3nvxEJD2UoywARofN0PfnUhmbNLUEpFMMGGEvOpxAywYcuo2CsOeVN/QZ+exrE1Eac=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792004288; c=relaxed/simple;
	bh=MwfXVO9E9wkGdobiO9ttbl3ENSedQbx4/oYV2u2i6Ig=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=BCW0XGUu1K8VdVr4dbWvLFz61XGn8o++JLVHoJWRPMIjUZKv59aLaIyJFHWa270iaCFXHnvZsvCov7Il/k3dsA/ybQFX5e4O6Z7TkJb2r7VAgSNSP2+KnEh93gsWxB3fVaReHZ9COfSQOTYIpOyoF4C7v6Y2zqpsZZmwp2gt76k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=fKzUjAuq; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="fKzUjAuq"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4C3F71F000C4;
	Wed, 14 Oct 2026 18:58:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792004287;
	bh=vjs8lyQhEismr9iRxVNLO4fuIhMVuDvIiCjUSnFacIw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=fKzUjAuqr3QF1o2vvYQDv1zA2kys+FOV0Z+JGJoOBv2FWGB9jy3/5zrLiCH30gTfS
	 khIrR+WLHrQRD25Y4FuzoUh2gOsYl7/GDutIN1tTHrYxyP75Sy8QFtuZbKHSQr+TJs
	 coZCq5Id4SXamcIumybjOkxGUFe0QxgQS1UK0/t39WuZyeVB4aqngWSsi6hcLRB9/H
	 h3+LYwqoZZeq1KmWtv+bXSnCPYUUCPQn2Sfk5TYAebnJA8Mc7a9SOwgxu2q7A032Up
	 OpAcR9gWxMXv2TyD4107MKzQ2MjT3gpok2pzwRGp8MxmyKgztbr8pmLeIU3jINZ3pU
	 sWZ2hQnolJfYQ==
From: Chuck Lever <cel@kernel.org>
To: linux-nfs@vger.kernel.org,
	Jinpyo Lee <bint4b13@gmail.com>
Cc: Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-kernel@vger.kernel.org,
	stable@vger.kernel.org,
	bobtobabz@gmail.com
Subject: Re: [PATCH v3] nfsd: prevent a double put of revoked layout stateids
Date: Wed, 14 Oct 2026 14:58:03 -0400
Message-ID: <179200427841.1506272.16281341311609982045.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20261014061218.102648-1-bint4b13@gmail.com>
References: <20261014061218.102648-1-bint4b13@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Wed, 14 Oct 2026 15:12:18 +0900, Jinpyo Lee wrote:
> nfsd4_free_stateid() finds an admin-revoked layout stateid with
> find_stateid_locked(), which does not acquire a reference. The layout
> case drops cl_lock without marking the stateid closed, then stops fence
> work and calls nfs4_put_stid() without owning a reference. Concurrent
> disposal can therefore access a freed layout stateid or drop a reference
> owned by another holder.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] nfsd: prevent a double put of revoked layout stateids
      commit: d6f7f9b5c41466f3f54219f7968b26f2587794ee

--
Chuck Lever

