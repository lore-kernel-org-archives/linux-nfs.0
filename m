Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5D0A643E9F9;
	Mon, 13 Jul 2026 16:58:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783961917; cv=none; b=e+dOBPG0c1spCcHsI6FWEd3VqtbhOtO5UjkDVcoe7pethuxyu2lBSQzCbhRIIT4ACR88nwr7N8RCxyq681Skw5P/FmYsXa15kP+Z6f9tin3WFm0wXoNMaErufeJZRcO+O7gBGjNiBP3OlHRiiyQ0qwRMXSbbtFL1sWpFLPibvcE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783961917; c=relaxed/simple;
	bh=NBiCUabamImYJ8YFLdzFqgmzKdYSzeFsvdEwcWEmTXA=;
	h=Subject:From:In-Reply-To:References:Message-Id:Date:To:Cc; b=ERjLFq73dLrxdLo/BSauMy+82w8JdOsxalBrASG+klKLYWPIHRR0N62T3Y4RITnhdIKyFdf91Cg70oOC608cd00z1oj9Fw6J/h/mc3UXFdMEGFNac0v/z1G8+jcOsolRuu/dIA6MHJ9POLQlZs/Fk9Z3AB3XHd2Xfzf8Z3tR0MI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=OoxtLEd5; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="OoxtLEd5"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0D9F11F000E9;
	Mon, 13 Jul 2026 16:58:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783961916;
	bh=8PbYY7P5Mcys1i2Rwm0Tvgd1W5HcjEyI8YN/4YSoYhs=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc;
	b=OoxtLEd50t0yvioRJywbYiNCIn0xgb5ZGjlNKuOkm97XGstvHoKjAmZ2lwYCOb/ab
	 6DwQyhQu7/Nd7VyzrNFG+NRF6Fu5K+M0jcp4hnb293RIXvcM7D+McK+69PvfC0eV3f
	 sRdTyE0FR84VVxkNpqS1/xhsA5Qncs5qC6V+XITq/omMuV5qKgYPGnjg3a/W6558ue
	 004B4Tdy3NEuKaJjjxYYOwsXjcGm1vfhqAia0HoxlF7gvMHoa4NKQaY+Kap2b5LDIp
	 0VzELVMvwNfsNesojE2Cj3as/fLP+sB5OrGdbWcyPyevgh5tELgcT06qruMEPHVutV
	 T69Mjo+tzRzQg==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id 93A1F3924F84;
	Mon, 13 Jul 2026 16:58:12 +0000 (UTC)
Subject: Re: [GIT PULL] NFSD fix for v7.2-rc
From: pr-tracker-bot@kernel.org
In-Reply-To: <20260713135701.2280016-1-cel@kernel.org>
References: <20260713135701.2280016-1-cel@kernel.org>
X-PR-Tracked-List-Id: <linux-kernel.vger.kernel.org>
X-PR-Tracked-Message-Id: <20260713135701.2280016-1-cel@kernel.org>
X-PR-Tracked-Remote: https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-7.2-1
X-PR-Tracked-Commit-Id: 92ea163c773cb4d0d5eaf103ed80c49d6758b96f
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 0f26556c5eeea62cc934fa8938b148aa5844a6b6
Message-Id: <178396189125.2325401.9814670735132451467.pr-tracker-bot@kernel.org>
Date: Mon, 13 Jul 2026 16:58:11 +0000
To: Chuck Lever <cel@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

The pull request you sent on Mon, 13 Jul 2026 09:57:01 -0400:

> https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-7.2-1

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/0f26556c5eeea62cc934fa8938b148aa5844a6b6

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
