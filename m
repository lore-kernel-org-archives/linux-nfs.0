Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B9FB5223708
	for <linux-nfs@vger.kernel.org>; Wed, 24 Jun 2026 01:52:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782265947; cv=none; b=Cfi4kfhchuDVfKP51XfTZBKvHStGFAuafVtTI3NhwDfFCz6UXwbOwuQy9pzixPNiRQCyEsiNIHvmf2fC09Lf6zVZ7PRCOg3JtmOqj3UscFvqZkfUiB4pGDsWB9pN9btkQv9gsAcQZ1s93H0gz3brnaY6Da+4WV0EWVDcP1LDI9w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782265947; c=relaxed/simple;
	bh=2IbFO9AcKyi8n3DpFjO6zgtH39r9Q0qcpSQm6Boedt8=;
	h=Subject:From:In-Reply-To:References:Message-Id:Date:To:Cc; b=syeBmMFfxep2tPY6fEHBO1xwfEqq1Aa5X5DXcN5hk8WhYeGLOWQ0CrIW3Rr3XQUv4dduj2CYI9CmHVmfHt99dBa4OMYEU7XUqUqjENN2mY+LoFfev33Hgg9lvO5cAdOipBHVUpa+Mw3/v6RgJ/Dzjuo4WDdeXuOM2OUNgnCK4UE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=afZJUAzT; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="afZJUAzT"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A07031F00A3A;
	Wed, 24 Jun 2026 01:52:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1782265946;
	bh=iW6GPkyTDiv1X/cELAJYmOEK23nSvEQB76U5pI595R8=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc;
	b=afZJUAzTdSR05UeBwfvn/uxwJJpMekcEwBTdl4/+40Of+/Pg/gqz5TSd/ZojB9ZJw
	 s9nHu5cEwPrRrm83owhQPAUSFtlnHJBl4mU2sYLRQnugjlKN8Bs0XAX+UdKd6zl3pZ
	 9PiJVdZ7AW4MxoBlNvwTDSi4KRY+8c9ubJi56MDMWuR6/GIYvq1SC86l7z/HNhemnf
	 4TkUSu9EwEpZ6sNBfsS7Q+FkcKFB/fmJqsqGox9qyrzwLX7eE+sFWX4N9SiVYbXC8y
	 ZMA3Rvg/xjeMA1NKVnrt5i8HxKfh6b7GgW/LiJlDn6nlU5MG+srnYrkod8/JsTsPe9
	 hb4AEhhvsCZgg==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id 19965393102A;
	Wed, 24 Jun 2026 01:52:17 +0000 (UTC)
Subject: Re: [GIT PULL] Please Pull NFS Client Updates for Linux 7.2
From: pr-tracker-bot@kernel.org
In-Reply-To: <20260623195315.829881-1-anna@kernel.org>
References: <20260623195315.829881-1-anna@kernel.org>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <20260623195315.829881-1-anna@kernel.org>
X-PR-Tracked-Remote: git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-7.2-1
X-PR-Tracked-Commit-Id: 284ea3fb4f6715201e1d9ef3474c25e817ad70e9
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 840ef6c78e6a2f694b578ecb9063241c992aaa9e
Message-Id: <178226593553.2505959.8531779683700473151.pr-tracker-bot@kernel.org>
Date: Wed, 24 Jun 2026 01:52:15 +0000
To: Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, torvalds@linux-foundation.org, anna@kernel.org
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

The pull request you sent on Tue, 23 Jun 2026 15:53:15 -0400:

> git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-7.2-1

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/840ef6c78e6a2f694b578ecb9063241c992aaa9e

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
