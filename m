Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9FBDD1822DA;
	Sat, 31 Aug 2024 19:14:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1725131640; cv=none; b=uqNxkwQiliCiN8jmUle08FkajEtgvK4Frsip4ky1Vkuy01w0WvhwIlcYxbfHgzsmFbEPm8KPaXW+mKeLVIK2Kq4qe6PAIHfow2Ii3PswHsHKW4BUqHTYeHKb99JTGLW/OCm8JXZ1O95ISw22PKnLND9pT6ogNfZdKsFDy8Znrq0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1725131640; c=relaxed/simple;
	bh=LZwWVPsCaAnWMlbQWeBASTDhYBkoDpbvPC/yxL2kXdM=;
	h=Subject:From:In-Reply-To:References:Message-Id:Date:To:Cc; b=ECHweX4srxMSyzvV2rlGL7pPvaecre0Ghtg8trRkAC2BLLdAAtWimH1VJ95xjSBAVvh3J7b4Z8G1tBKpbRYePiVDRNPpejOpGgjqlTVmcnJT+1Jtz5nD5RbIwCNbsTmEoDk13zhOSLE+i9XkafnOB43/txadaOM/1L1L2PI+5PY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=BiGMqZzl; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="BiGMqZzl"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 33BFDC4CEC9;
	Sat, 31 Aug 2024 19:14:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1725131640;
	bh=LZwWVPsCaAnWMlbQWeBASTDhYBkoDpbvPC/yxL2kXdM=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc:From;
	b=BiGMqZzlvPP+iwTw8+b4ARJpDDxwSMtdUjoSkKor9Xcg0btI8X47Z2dkuaJREuXXr
	 43uB/mj2dFKOvbuZtg8aakbsShV0UAIAEnzc+Jw/i6Xsey61PexuOmJmRrfzyUqWDw
	 g3/3oex5AVdTtkbU1/J03k57p92i4CvoHKqslc+N8YeZIkKZMNzfWwkgkSR7baUBlc
	 txXi8cRFK294RFIL6OedAtVIdlGe6qi62BRECdm0pZuB9Sb4XbSiHqeFOEcPtHa00z
	 g7Cqy4rTgQBilOxmH3YDpz01G2c2kPeQk0y0+pevEnYTtMROtB6VinSJswKYkDAO37
	 io1UQnHuZ0S6A==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id EB0C23809A80;
	Sat, 31 Aug 2024 19:14:01 +0000 (UTC)
Subject: Re: [GIT PULL] one more NFSD fix for v6.11-rc
From: pr-tracker-bot@kernel.org
In-Reply-To: <ZtM885jgMNOUddZH@tissot.1015granger.net>
References: <ZtM885jgMNOUddZH@tissot.1015granger.net>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <ZtM885jgMNOUddZH@tissot.1015granger.net>
X-PR-Tracked-Remote: https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-6.11-3
X-PR-Tracked-Commit-Id: 40927f3d0972bf86357a32a5749be71a551241b6
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 6a2fcc51a7a1e92984350e7dd94122db5b8927f2
Message-Id: <172513164037.2915779.490390301903286833.pr-tracker-bot@kernel.org>
Date: Sat, 31 Aug 2024 19:14:00 +0000
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

The pull request you sent on Sat, 31 Aug 2024 11:55:31 -0400:

> https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-6.11-3

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/6a2fcc51a7a1e92984350e7dd94122db5b8927f2

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
