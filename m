Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795106998;
	b=zlTOPNohk0WATlL55Rhu7Uwnp7tMZy+W6Jr000BoFuiFK2rttM5cyK3DPdiSP1N/9TiB
	 XYUr/shmRQAnnjA7fS67UEw5h7nNEmWmcZKmE9rsLqEAjq9UH5zIcwbrvLH6gUacTADje
	 GKDMIHn4KNRhAxoMqHYeL4yLu/eKXKM5/YKmiytzzkgEx0c4zWEtKUiUYmQkMa4LlqEsT
	 bi8J6GeJEg3ckRD0TCeX6uQfsSG58okvb8nhqprE7zDr6PiMeAUyaF5jaKe3SRtxRP775
	 wmB0n6mDR4I0ppRSKe/frqJh7cZ3qaeou/gcy58pF5WPPdb9gncT3+WLPpGW0gqPrdA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795106998;
	h=Received:DKIM-Signature:Received:Subject:From:In-Reply-To:References:
	 X-PR-Tracked-List-Id:X-PR-Tracked-Message-Id:X-PR-Tracked-Remote:
	 X-PR-Tracked-Commit-Id:X-PR-Merge-Tree:X-PR-Merge-Refname:
	 X-PR-Merge-Commit-Id:Message-Id:Date:To:Cc;
	bh=8Y5jO6pqspGSeGd28fIm7Q2/LwTvxGzskmwFkf20NoQ=;
	b=uK7wSyE0DNRwytzjbhP4CQhhxAcwp+qI61LodvZT7aLAazlttGunWTm/G49tEDZGaVeE
	 8Vzy3id2kL62DrF7h8+nESYcgqedsnh3UeeZQ83b9h9Jt4obfeHkB0b3MuLGNhrYnNCmS
	 4G0QNAPkweyaQ4RLMw2pv2OPaJpI83omo0TMltiz4Uc1I5k3tXERAOMIHfpwIm7vFrQeK
	 /+A/B2t/bf7LYsr/fsNfQ9GzEbaaY1OXyqvXr4rXsD/QDwqX1+HdgMx4GCGawhV1PieaD
	 /YW+fxuCSbcWLqDzpe7bm1GYoMwYc8fyeVfc7QQysaio5mv34lVS717dVioV2kW5oJA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XioMgkUo;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A90AB60A380E;
	Thu, 19 Nov 2026 16:49:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XioMgkUo
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 451EC1F000D0;
	Thu, 19 Nov 2026 16:49:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795106998;
	bh=8Y5jO6pqspGSeGd28fIm7Q2/LwTvxGzskmwFkf20NoQ=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc;
	b=XioMgkUoHyd3kFdOfmB4556oTocKshlkUw7j7bbUI9bTPZ1t6V8nXlHn9wmoOVVNQ
	 uAbpXLgtdzywssusEApS2Rqc4GBhF9oPtAuI9Q0dVjds4BYzVlmRbeFbi5YROEQO1s
	 atmFowDDZWa4QoJPPorsCw13CsKAyuFEXWy6UW4djzUuNyN/R1giz3g6t19Ffa/nPN
	 ncSdctTl3mpTG1JzTRQwj73TiVD6CjgPeGNn9GaNawf1954SxKxqasAFtlj1lzkhNa
	 lK0W6Npojjx3JcZ/2khaBOU37NHdBQUOpuu/qSrU+r85kP/AXsPL6C+lRCafL43Z/K
	 9WXq+As5PlCIw==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id 3A3503808210;
	Thu, 19 Nov 2026 16:49:58 +0000 (UTC)
Subject: Re: [GIT PULL] NFSD fix for v7.4-rc
From: pr-tracker-bot@kernel.org
In-Reply-To: <20261119162242.1467-1-cel@kernel.org>
References: <20261119162242.1467-1-cel@kernel.org>
X-PR-Tracked-List-Id: <linux-kernel.vger.kernel.org>
X-PR-Tracked-Message-Id: <20261119162242.1467-1-cel@kernel.org>
X-PR-Tracked-Remote: https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-7.4-1
X-PR-Tracked-Commit-Id: 1ecc5b7c95ae585042ccbf3c587897dd99e2ddb5
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 8dac6df92a2e66e2098bbc69061964cfe7e8375b
Message-Id: <179510699684.3206305.4803049367825862184.pr-tracker-bot@kernel.org>
Date: Thu, 19 Nov 2026 16:49:56 +0000
To: Chuck Lever <cel@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

The pull request you sent on Thu, 19 Nov 2026 11:22:42 -0500:

> https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-7.4-1

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/8dac6df92a2e66e2098bbc69061964cfe7e8375b

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
