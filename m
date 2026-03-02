Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D1199310655;
	Mon,  2 Mar 2026 17:48:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772473731; cv=none; b=B5FmyX9y9G2zxsPBSOfakJ58+hKL+jHUFfvSumxXWnZL7GTdabwMxttSB728MrSLMzp9uVECP4MOwDJWqal9U1jr0qgsu8TPIbqYKyn47KUmMGasIR4FfmvlSILS+PAF4K4vUtM+iFUVQ2OZSc2lFfX1LkWnM0vQxakh5uavAvU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772473731; c=relaxed/simple;
	bh=3pKr1N4/NZKKXGgTkdcCgNcSv9xEXouxH5xvYoPy5UQ=;
	h=Subject:From:In-Reply-To:References:Message-Id:Date:To:Cc; b=kthzrntN/+lkt+aC1CMlL96sxQ0nFKvtyR6k1vX7r8w4PtwREeJZgzD2eu1akf5/8NrQ3NREuqywt1I8+I5mFPLzZKcpEeThpEEBvAeTvNjNt2P3rYw45MjQnrrlcULIHWBhLufTKd6qQN9x3ynCuAcDJS+EBVSYuhIb7WoZ5mE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Dv7dblvb; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Dv7dblvb"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 79D27C19425;
	Mon,  2 Mar 2026 17:48:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1772473731;
	bh=3pKr1N4/NZKKXGgTkdcCgNcSv9xEXouxH5xvYoPy5UQ=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc:From;
	b=Dv7dblvb4BmmGUG/oxqN8Yt0pliKXVEIvAX5VE5kAmTzTUbZS9IzMnCu73DK6hoGC
	 FiP95uSaXpRVOt+xVHKsfUtEDccQEkiavc5SOKchXvhORD+45wnC+gCvHFcl2wKB6L
	 XTT4zslftJw7elXTXegwP6MIKDo+s1pT3IiXkmIUNVn7EwICaKp1SbWNgBcCaW/q+k
	 qEbY8xOtQ15kCG8t6bRJ7s/H7Nd22b5Iit74FvBbU/Fw5gH2DskadWfOlDDmeKbHpW
	 gayde5OsNGUUX+0GctlMPZlrXitID30efyT058Usafn2I8jBcux5Z4jDlBaQed3/+r
	 prBFJD1V1J3eA==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id 7D1283809A80;
	Mon,  2 Mar 2026 17:48:54 +0000 (UTC)
Subject: Re: [GIT PULL] First round of NFSD fixes for v7.0
From: pr-tracker-bot@kernel.org
In-Reply-To: <20260302141130.9098-1-cel@kernel.org>
References: <20260302141130.9098-1-cel@kernel.org>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <20260302141130.9098-1-cel@kernel.org>
X-PR-Tracked-Remote: https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-7.0-1
X-PR-Tracked-Commit-Id: 364410170ab33f6e7ef0eb2afb12bf89b0feb3a6
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 1b37ac211a22d4c65aad1ae2da07f078197e7394
Message-Id: <177247373300.423959.342022586887100392.pr-tracker-bot@kernel.org>
Date: Mon, 02 Mar 2026 17:48:53 +0000
To: Chuck Lever <cel@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

The pull request you sent on Mon,  2 Mar 2026 09:11:29 -0500:

> https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-7.0-1

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/1b37ac211a22d4c65aad1ae2da07f078197e7394

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
