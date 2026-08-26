Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EC32A2FE057;
	Wed, 26 Aug 2026 23:11:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787785872; cv=none; b=JuDgG/QuXavwbrplyB7lj7HzpsSC+BQw4aWO6QFn7ykHnxo4RQ4Csoq5sE8bGzPUVOazHetMDxKOohPl443ze+y+CbfuMT+1RYYrUk9RLnbv/X1BmUrBH+zVdlYeJ0jMCJy96LP27YC6E+mDYVDukDWuyyCcT+i81/d6N/7+0j0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787785872; c=relaxed/simple;
	bh=8a4LE4I3jPVeONT7v33ZmATQKteUZv/ExNkogskQH5E=;
	h=Subject:From:In-Reply-To:References:Message-Id:Date:To:Cc; b=OQthyyWrtUbMI56dQmTSlBm1X8lBZi1RKYCW2xQ+FWKYdszXF5gCpbPF2EjITTvqHlpRWKBRNNIdnofK2dXvrjCwL3g9N3rlWekFbW7q15QSeTNR8+tqXQsLkRLG8PGpR638C+CqPVRG9+GDdGJJx0fs42njzDV6sa6xvIwaPl4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=mXlVVSqL; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="mXlVVSqL"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D307A1F000E9;
	Wed, 26 Aug 2026 23:11:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787785870;
	bh=oAMg1JIKqX+6FaQXbgHvBmk50uu25nCH9dLJRGf+QWw=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc;
	b=mXlVVSqL0Ti4aNDNvnCvmfi6sic0rGzUxDaCouHgGV9crZEAgNkPQWkFzVw+Lnz95
	 FFO7K6AHXU8YTmUbImnSePPN3+drh2IbxVhdpo0XhYED6lckRjGR+a0zE9Pe5hL28d
	 YqFJawXhpcEkmveH0oXx8cmYtpHiEBPHeQJubHs/P+JGXceE2GwZ8ug0A0jw06l0nh
	 M5tw8ThDAGigIvJaUL7xq8h2FLD5NTHD6mgRgA9/EGNuaJhWRHRLxKNJkWtIQokEDK
	 VSWqeVD5OIg3VFDRFXBIoLNZ6n1I7c4rGeDeKjI0zz5Y84MWY1J1eapKAZOQnd6GlA
	 dVa4Hr6Pq+Xpw==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id 19B623809A09;
	Wed, 26 Aug 2026 23:10:18 +0000 (UTC)
Subject: Re: [GIT PULL] Please pull NFS client fixes for Linux 7.3
From: pr-tracker-bot@kernel.org
In-Reply-To: <ebcd172da92ef6a8aafb5f0c6f84d0c6a735cb01.camel@kernel.org>
References: <ebcd172da92ef6a8aafb5f0c6f84d0c6a735cb01.camel@kernel.org>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <ebcd172da92ef6a8aafb5f0c6f84d0c6a735cb01.camel@kernel.org>
X-PR-Tracked-Remote: git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-7.3-1
X-PR-Tracked-Commit-Id: ee5a386cfe60f3f8286de16a9db8e1a08f0bc124
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 73e3f0710014fe6d4ed98cfc02292f6121db7558
Message-Id: <178778581696.934580.17826649784106000918.pr-tracker-bot@kernel.org>
Date: Wed, 26 Aug 2026 23:10:16 +0000
To: Trond Myklebust <trondmy@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux NFS mailing list <linux-nfs@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

The pull request you sent on Wed, 26 Aug 2026 16:57:09 -0400:

> git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-7.3-1

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/73e3f0710014fe6d4ed98cfc02292f6121db7558

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
