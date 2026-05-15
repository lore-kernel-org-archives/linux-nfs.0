Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 79AAD3EB801;
	Fri, 15 May 2026 22:14:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1778883241; cv=none; b=V4M98zoKzjwZIHufgasbDYUe+u+TR0xSxTcGf/05zFY58MmNQFH0jXUTwYuI+rcPUfpHfkAmAcdwRirALY/5c5c/xWw6y9Alo8mHJeHJwU9aWzDDS82SNQ5PNandeX+o2HdZ7JFuytle8Rum/VfJBOwLdCB/A96QiyFpZm8ARkE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1778883241; c=relaxed/simple;
	bh=/eeLGz2iot39XwJYc4BQauKoJW6OZKpHj3T2Uc2J8nk=;
	h=Subject:From:In-Reply-To:References:Message-Id:Date:To:Cc; b=drE4IMGzsc4tlBU6Ez0TBixW4KNgDPkSK6rTx7DFLuQ5tSjVQthgYVs+v8N1Wq6ao9W/RfjemPCK3J8TtabXwO+EBo//5slBIn53rMO9W9qci7VCeW6hhadj0137hhpP8du3hZ09X+GMHPIgSlh6Grt1xSzk60erm1C4yM/8rJE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=nGr9NPnh; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="nGr9NPnh"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5C4C6C2BCB7;
	Fri, 15 May 2026 22:14:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1778883241;
	bh=/eeLGz2iot39XwJYc4BQauKoJW6OZKpHj3T2Uc2J8nk=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc:From;
	b=nGr9NPnhvPr+JTJMuCiNrt0UM2MLnlCRr9Q5/l+wcE07VkkbhvQGK/oZ6/wQdzvMt
	 L3b35IhXwnUKTmMYE1QjIdAV+kL/fMSm+6furyBI0ll3B48ayT7JNZZ07VUiT6gpl8
	 m5bilXGc+cSrGYe1UWWnkTin58X5k1WbsnwTLohEDkDNiwvP4u9x8fBZeE2ZZ/exkZ
	 ipYVl/g45U3dtaT4yKoIoQJJ8AShUh7ISYD1jG/M5NGUtKeTJ/hYCHyOX8TRiojGhn
	 tKvzb6PlG+L9X0TdZvVdLdTtpyRvOjOgO32LjPBgqrO1YgBHx6uGC2wYl7steE/rc3
	 jDnP3X7+89QiQ==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id D0A7E3930A12;
	Fri, 15 May 2026 22:14:15 +0000 (UTC)
Subject: Re: [GIT PULL] NFSD fixes for v7.1-rc
From: pr-tracker-bot@kernel.org
In-Reply-To: <20260515141426.357776-1-cel@kernel.org>
References: <20260515141426.357776-1-cel@kernel.org>
X-PR-Tracked-List-Id: <linux-kernel.vger.kernel.org>
X-PR-Tracked-Message-Id: <20260515141426.357776-1-cel@kernel.org>
X-PR-Tracked-Remote: https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-7.1-1
X-PR-Tracked-Commit-Id: 4f8ef58c10bfe5f86a643c7c8331b37e69e3dae1
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 56ec2b646de6349c8c8c05c8df17b4d8998c467a
Message-Id: <177888325441.173168.4275722633916915407.pr-tracker-bot@kernel.org>
Date: Fri, 15 May 2026 22:14:14 +0000
To: Chuck Lever <cel@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

The pull request you sent on Fri, 15 May 2026 10:14:26 -0400:

> https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-7.1-1

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/56ec2b646de6349c8c8c05c8df17b4d8998c467a

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
