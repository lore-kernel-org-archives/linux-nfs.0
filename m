Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CBE56286A7
	for <linux-nfs@vger.kernel.org>; Sat, 11 Jul 2026 02:00:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783735226; cv=none; b=p4t14fTSaCY/wVOG7TSeOHivbmxYgskIC3w2a1J7Z1RlJYTo2rkiabyezEZNXf0PZcGTi16zd5QZ0ovxG462zwmV7GqPv51bSrt8KPmwTmHtak62/Lek9CqOeK0hDbeinLg4e8fD+xfAky9y1sKJV8jgZ29F1BbvIQyBfO70y74=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783735226; c=relaxed/simple;
	bh=40qToaYeraAcTsZWIhy5X0VP4HQKqPjp0bCbl1CFt9s=;
	h=Subject:From:In-Reply-To:References:Message-Id:Date:To:Cc; b=tWPLSdFSGy0S12K8VeoQTo08yAqUjoHUDgiblUGoqg9BWfdY0WAytcWs8+xfhEqtgceiTM3U6UdRZZl3Z8E3MsAxYB7NAx2BJ9Vm6EAQ1ZxvpdA/Zb/uYOiA9kLRs/O7ErALwSj1FCdZpq42J6aR/+ju30LLI35siXPh9r380Bw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jDqxs7WF; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jDqxs7WF"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B3A7F1F000E9;
	Sat, 11 Jul 2026 02:00:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783735225;
	bh=5PD5rea4d/hfA78IhjlBlm9hS+YYhKwhnXRbGKViWt4=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc;
	b=jDqxs7WFfkFNCODPcSVpQj8J+odV62SmGM85jl0wy45ipr5qV6qhPR9OaWQsL1DM8
	 s+svn3ubuT3VSNpPFHiNKoBlYlBqEpxmE3FCzzcOknSXFNs3Vu/aS2aVOBgLxulinw
	 5npz4ioa543h3L+eGQ4VfnNGZE+RoGJxPPeAGN3KUHLOBPPmsw6odsmcLuwY8Thus2
	 yLurU0xGJ3gG88ivPIy+6xpR//RLUDFp7xAeBbnLmaTcKzC5m7lsTCOaVK87ckPTZ5
	 n8LhMLk8klOVd000uBL3Bj7l4xUMl45pUJEtSW67gtpvsjDQ5+GHjEjBkpBe6LFD75
	 tr3th2WWULg0Q==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id 5694C39244DF;
	Sat, 11 Jul 2026 02:00:04 +0000 (UTC)
Subject: Re: [GIT PULL] Please Pull NFS Client Bugfixes for Linux 7.2-rc3
From: pr-tracker-bot@kernel.org
In-Reply-To: <20260710205117.622337-1-anna@kernel.org>
References: <20260710205117.622337-1-anna@kernel.org>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <20260710205117.622337-1-anna@kernel.org>
X-PR-Tracked-Remote: git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-7.2-2
X-PR-Tracked-Commit-Id: 27934d02cbeb8a957dd11c985a579e58d30c5270
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 58d9f84279a86b1b24239107a3d1c4d8dccb41e6
Message-Id: <178373520297.951748.14235683308041370655.pr-tracker-bot@kernel.org>
Date: Sat, 11 Jul 2026 02:00:02 +0000
To: Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, torvalds@linux-foundation.org, anna@kernel.org
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

The pull request you sent on Fri, 10 Jul 2026 16:51:17 -0400:

> git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-7.2-2

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/58d9f84279a86b1b24239107a3d1c4d8dccb41e6

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
