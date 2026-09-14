Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BD2E749C4C0;
	Mon, 14 Sep 2026 18:08:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789409317; cv=none; b=s/ITucvXM728EKxd1fA5zYWz+TzFXNp738c2sjOHuFaT6baDicVku8jfCm6sNvW8YpqevhW5ovLAkswU3+scozy7mSXwEx774GRbCmpwQEEc3oOwRZyI7JYzszWYDxCejhYOOLKzrtJoC7/4fEG5qekgRkGIOUoPxo62KiHn/To=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789409317; c=relaxed/simple;
	bh=Xu6EQFRNKcV6mlQ6nw5k8bWmKnQaxlp6TYwdmxPJk34=;
	h=Subject:From:In-Reply-To:References:Message-Id:Date:To:Cc; b=PEm97ag6p6Lr1obwlVuIR/sWU3lZof0Sz05WbPo+D2ugu76mJKgdhgoDEjBfQcYWTD+kZnoLWrYkeFxGZK9XRO1VA3CgMADy/J1zSJKKaMJOipREgwaMIiJJokM7B2oC5cmt2rS04rCT78gqcx8uj70HVo2TrdihttVqvgfB0ew=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=TggVttoR; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="TggVttoR"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 42EAF1F000FF;
	Mon, 14 Sep 2026 18:08:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789409304;
	bh=8dRD72AHK3JXDSzc9m2omPOcblgT9eCbUihFpysWzzQ=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc;
	b=TggVttoRoJkITi4IsguWOMdUptiMX57VQj+NaiISl3qMnsk9x9z4RpbIb4uOvdvz4
	 N7dqRSzYr16EUGYwbP0/P+tkmh7xR+z0eqXitj18D9/56Z34NJxrWwQ8S78ExZiimc
	 piTXPEVb7fFUMHrV1ur3KMEmHqjTfiXFokQDp3sBygPblWwaxg4If1NWFIlhKuld2Z
	 +9otnKbOpt8jpmy23qFL1PkpzO4negG3AgwS4JrS+wmDIMS8axjxbROfI+luDw2esJ
	 zcydBoQvKF/OJ+lh2N8PfBmrklnFpatT8CHIvWtv3Q4cDR5SZqZhbcE05F92KTR/BV
	 yffyIXTmZcY/Q==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id 9392C3924FD1;
	Mon, 14 Sep 2026 18:07:20 +0000 (UTC)
Subject: Re: [GIT PULL] Fixes for NFSD in v7.3-rc
From: pr-tracker-bot@kernel.org
In-Reply-To: <20260914135336.350043-1-cel@kernel.org>
References: <20260914135336.350043-1-cel@kernel.org>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <20260914135336.350043-1-cel@kernel.org>
X-PR-Tracked-Remote: https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-7.3-1
X-PR-Tracked-Commit-Id: f76017a7663c4ce5e379f8a8d39f032bdb1fd865
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 587858367581b9c55c3690f4e63382ad622719d4
Message-Id: <178940923926.1155813.16396481088091852580.pr-tracker-bot@kernel.org>
Date: Mon, 14 Sep 2026 18:07:19 +0000
To: Chuck Lever <cel@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

The pull request you sent on Mon, 14 Sep 2026 09:53:36 -0400:

> https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-7.3-1

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/587858367581b9c55c3690f4e63382ad622719d4

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
