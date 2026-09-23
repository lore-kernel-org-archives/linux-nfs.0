Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9A37F485CE9;
	Wed, 23 Sep 2026 18:26:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790187965; cv=none; b=Vs7F7P2CUCAh0qf39EyaMXezVC/itz/DC7famHJTIA7yN71+FIMKm2M87vZeD+5w1e1AQjCFoezf/dHFkxYK54vZ9otvoSUBhv5WRBwN18i8nC76fTdL0Uax2sV2v7jwXrmgWhb7AnJl0sd6Z9GwfmhR25itVbGgPrnek2rcJ4M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790187965; c=relaxed/simple;
	bh=01rDAG0wTRuubOVxF4PhE09IxcOyg4K/LxVdcWIaCmM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=pXlXm/d8HW/5g/FPi/jmXy0Xj3dkVAF6g7gIHhLHPxUpGmaQJP3tO7T/6LPp84Kst9QMmhZ8M2USy7RZzTio/08QPko7FMheXC8xkripGfck0sylSY59YBK+GL2jKFfDvCnauHZeIaU8gziaETT7HAqD34cHwa27Cs/6i/EfSjI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Lq5+SgiA; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Lq5+SgiA"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3AEB51F00893;
	Wed, 23 Sep 2026 18:26:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790187962;
	bh=kZzDOA78Eolu1p40Kp8ad6x3BaucvpkQgSJoFWpPjvY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Lq5+SgiApxVtIh8ElOadW+rlrKR8Xgm0ul7TzIWdLJKPIm6qPXNXW2TpB03xaZ+Sv
	 VrKZQyVfIqR55nZF6WoD3B5bcPczFjNup/CCbu4SxOIWyRE7dmHuT+VQHOB6qJ6auf
	 8lOQjA1O1bPwYeegaHSRZCVuttlEwDCl2eHyNhayojEBLP+V1GGCfbXhRHGoC5nWn6
	 UgaxWYCvtQkyQyWcizqCbtD5KkCeaaRpuqYHAgLztrqwHqbEEJoGdNWuJ+TQf5wpOS
	 pezaJZ7YKArwRtp2FCOguTYWfPMWaBQ3TTrWenCY9EEb4BKsKjnfI7uw5S9uCNOXEC
	 cC9/yfvpJ4DEg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Scott Mayhew <smayhew@redhat.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 0/2] nfsd: remove legacy tracking methods
Date: Wed, 23 Sep 2026 14:25:57 -0400
Message-ID: <179018794942.493305.8750817250267691680.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260923-nfsd-legacy-v1-0-8490c0c12ea5@kernel.org>
References: <20260923-nfsd-legacy-v1-0-8490c0c12ea5@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Wed, 23 Sep 2026 12:14:20 -0400, Jeff Layton wrote:
> Around three years ago, we added CONFIG_NFSD_LEGACY_CLIENT_TRACKING with
> the intent to eventually remove the code that it compiles in when
> enabled. A little over a year ago, we switched the default for it to
> "n".
> 
> All of the major distros now disable this option, so finish the job by
> finally removing the config option altogether. With this, nfsdcld
> becomes the sole way to do v4 recovery tracking.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/2] nfsd: remove the nfsdcltrack usermodehelper tracking backend
      commit: ac71b6474e0a6b62c7075f3745cb8ac9e201ec7b
[2/2] nfsd: remove CONFIG_NFSD_LEGACY_CLIENT_TRACKING
      commit: 21c66e2ece97c0ac8139b44051d565b29574f821

--
Chuck Lever

