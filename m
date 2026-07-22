Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 487193E4506;
	Wed, 22 Jul 2026 20:54:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784753649; cv=none; b=MBVvQ0u10s8gLIE158ncrhW57y0GoKONP/Wsoqnz4YxOXn2BMTWEn7qwsDpEhFizmrq5YY5s5xnXOP6+8zwzShH2vljX/KoR4x1lFRSw4Xz6yPmrjQ7Z1RxM+ZZJCcwYCZKFdp9MFjZJoGDrXGd3S8Crnqivxq/IfrVqZdm/C9w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784753649; c=relaxed/simple;
	bh=152aQocex4S1sLxXVEIEzYrIG/7wCt8eA01OJSLP8nw=;
	h=Subject:From:In-Reply-To:References:Message-Id:Date:To:Cc; b=HKexur7fsn87tEXKbQjD0LwbjDffv4/3JC+boRR6vuV0KErq+ZUJ1EmZDjuELjLKoApP6C0AOfqVY/cki05dD5TAzVFGKNxKYxTqK7ywpXH8S6jM92GLp2/dxkOHfQHr6h7AB9f3KVLX95/Ym9OXZDHAXx7E86Tz6FSB8EMaPFA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=YOkTgBj3; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="YOkTgBj3"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2F01E1F000E9;
	Wed, 22 Jul 2026 20:54:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784753647;
	bh=Laqw04lV0FDXTr66pnhnd9BHYFHhDUUV9fzyMqeRtVE=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc;
	b=YOkTgBj30cYeFWFNTeM+NJLhOhImmtAkAw9EM8oJLLDtLvQOxU+kMx+TH9mfFJlYq
	 EtxdZWHLIhhwI6RgVKMZidFrwzBpP/XKcU7cFuSDMbIOCOSfbjGgSTNNslqgm+ZF29
	 u7hdJI9g9Mtqv1QdEYSLCLNBBiGa5bty8CeamLqKrwhEFVRsLBHozle/zg+ahAznXy
	 S6OcAOEYs+l6XZ3WfT46gkzty6esHFFGM3KmTwOyzvgYxIPFpQOXldHFdJY5LvdXf+
	 fc4H/PV0b/cAkuCTat+O+v/5Ya/gpd6bpeIiJ+70in7eBfDEGicWPs+gaszVLaLvg7
	 3Cl2M7Zh+k4Kw==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id 1988E380CED4;
	Wed, 22 Jul 2026 20:53:37 +0000 (UTC)
Subject: Re: [GIT PULL] Another NFSD fix for v7.2
From: pr-tracker-bot@kernel.org
In-Reply-To: <20260721181544.3048006-1-cel@kernel.org>
References: <20260721181544.3048006-1-cel@kernel.org>
X-PR-Tracked-List-Id: <linux-kernel.vger.kernel.org>
X-PR-Tracked-Message-Id: <20260721181544.3048006-1-cel@kernel.org>
X-PR-Tracked-Remote: https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-7.2-2
X-PR-Tracked-Commit-Id: 5c4851e4cdfc3204128f88991be64a6e3929d3d0
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 5a52217525cb394117d92722b7f0fec510c882b4
Message-Id: <178475361570.2020310.7133634913735896264.pr-tracker-bot@kernel.org>
Date: Wed, 22 Jul 2026 20:53:35 +0000
To: Chuck Lever <cel@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

The pull request you sent on Tue, 21 Jul 2026 14:15:44 -0400:

> https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-7.2-2

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/5a52217525cb394117d92722b7f0fec510c882b4

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
