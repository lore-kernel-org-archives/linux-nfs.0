Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 38E613A0B35;
	Tue, 24 Feb 2026 14:59:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771945184; cv=none; b=HRI79sKcP3WF96B1ZGoPktbpq6zedVQi2DmwOgyavB3mQ4K1ib0G+rm6vuvux7Iepbm4+LbltZKSOcjsU5BVrCxipUaT0seYyT2gIYVn3F+wOeNhmzf8u09S+AKIDe3Ji51U0plu67xg+oSaC4gl478w5bA+bMAzxMHxRePWjgg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771945184; c=relaxed/simple;
	bh=D5PDCQbFkNwg+HLZMrnHSQUeSqn+nGl5kbt86Elj880=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=RWxmXjN4plOI05RjFObMfTU10sVtBKtq550/9pWGwSQmtWLfCGsccxfoaDvpDPHdRPDuJG+r3G/IeBOLxSL4Gcr1M/irAB4O8YqWEwTnVErYXHoiV96qCeKm3Ty3sK607kgizZNRgo5UC+X3+Qj55FNLWO8g2hweBdmwa39z4Z0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=HKxmuMnU; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="HKxmuMnU"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1B272C116D0;
	Tue, 24 Feb 2026 14:59:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1771945183;
	bh=D5PDCQbFkNwg+HLZMrnHSQUeSqn+nGl5kbt86Elj880=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=HKxmuMnU7WYXn34p+w/dJ9w/LSkAMDSGtdNb8Av/oaELpho9ir3btSkD21EO688ZJ
	 whqRyGGr6fZr7AbHjdvMscgWGvH+gb5KT45CCllt2uvralVCnh7D7Ia59Jm4oUHEJc
	 KDAkxdDr86VQ2iK3TCrKsYpTezlG67E484gYjd8qCMkLNFqPVQADymwblIBvlZm2pJ
	 slPMpAg3+7jPs6JxHRHsX4a+MR7L3D7HWntJs6JUews/Qyy0JRRA4GGeJXHN5B3nOV
	 W3HW6CWQx6o/qGjv6sgPcGpFYrkSeNdXhciObc4vfR8LfpzG4TaGuwDY+apenemB7S
	 R2QZJn7Ierr4A==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Chuck Lever <chuck.lever@oracle.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: convert global state_lock to per-net deleg_lock
Date: Tue, 24 Feb 2026 09:59:39 -0500
Message-ID: <177194516167.41341.6571531573880972602.b4-ty@oracle.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260224-nfsd-deleg-lock-v1-1-1df17c1daa47@kernel.org>
References: <20260224-nfsd-deleg-lock-v1-1-1df17c1daa47@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

On Tue, 24 Feb 2026 08:28:11 -0500, Jeff Layton wrote:
> Replace the global state_lock spinlock with a per-nfsd_net deleg_lock.
> The state_lock was only used to protect delegation lifecycle operations
> (the del_recall_lru list and delegation hash/unhash), all of which are
> scoped to a single network namespace. Making the lock per-net removes
> a source of unnecessary contention between containers.
> 
> 
> [...]

Applied to nfsd-testing with minor changes, thanks!

[1/1] nfsd: convert global state_lock to per-net deleg_lock
      commit: 87d8659010fe5ba78759ad7b8780656f1c3d350a

--
Chuck Lever

