Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 41D0F3BD22E;
	Thu, 20 Aug 2026 19:57:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787255846; cv=none; b=C1qTKTsPnW7bS8U0AlGiwXl2iklWAzZ86MySJGwNP9ezwcdsag3qGTZAm7do5I2a8T3kT3vAkzlbiaqknABRGcaCkoA6tFJ36YgJ4z1SSI9Ys4nhoAklS/zn1x3po0aY9kmkBjeIKHt5CdepljFIswMhldevLNmLn7mrEbHuSDs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787255846; c=relaxed/simple;
	bh=dBgxXf18ZGTE8k9A7r7ywOP7IGVlZIvUiIJ0U5vPJI0=;
	h=Subject:From:In-Reply-To:References:Message-Id:Date:To:Cc; b=RaWljkeoYGcKrqLSN6uoTvNFdj+mUC1/JC64XTiE0gTCvOx3276Zss0sViNG4Fp9UK715JYIghf47ofhOKtUWSsfTkT1v1Tf+xU6OpT0B7WjwDSKIRNvybICyJ7Sv34y3mM78BNQsSQ0MJr7tjONA8RfKPQckvCb5xL7ZeMCZFc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=iZdYshV0; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="iZdYshV0"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2A0D41F000E9;
	Thu, 20 Aug 2026 19:57:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787255845;
	bh=3bc/OH8n6qPRDfdS6ZSX/1vVo8oa2q4JXhTWmq/ma3I=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc;
	b=iZdYshV0uyZu7qEE7775C7t18g5pZNbGf4NAwTr8fdwKqs721M1MEK6LKkYid2g/j
	 4QGuYo4S03a/b83URWpb1V/cPzcAdOjzBb3VJSF5KkUx2ZWoj1Udon935Gm2tBi8nZ
	 9sXUKtuxM/hJ+98B9WQ3VQeHB20s+Vv9+v/DYy9R14DHoMC1mTo6Q/TLBBBXuOGxlP
	 adb5CPKDDmKFVaU8J51/idE07Fvt5iHTfhztuxLZ455/UF4s6P3k4mWIFmIaO793zH
	 gqNLN0z80DoOtf8WU4w3FXmj5mbodmcQNfuINX8YTn91SvG1gkDv0LrYRy3KHwaLnW
	 GgYhJE7zfa73Q==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id 93A73392445B;
	Thu, 20 Aug 2026 19:56:36 +0000 (UTC)
Subject: Re: [GIT PULL] NFSD updates for v7.3
From: pr-tracker-bot@kernel.org
In-Reply-To: <20260819132617.2397044-1-cel@kernel.org>
References: <20260819132617.2397044-1-cel@kernel.org>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <20260819132617.2397044-1-cel@kernel.org>
X-PR-Tracked-Remote: https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-7.3
X-PR-Tracked-Commit-Id: 46db3c8a1be96a354758b44b1d4fbb4b70d09a20
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: d141ec2825b4d3ec52f27c43bdd864090159273a
Message-Id: <178725579517.459220.5890818837859986957.pr-tracker-bot@kernel.org>
Date: Thu, 20 Aug 2026 19:56:35 +0000
To: Chuck Lever <cel@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

The pull request you sent on Wed, 19 Aug 2026 09:26:17 -0400:

> https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-7.3

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/d141ec2825b4d3ec52f27c43bdd864090159273a

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
