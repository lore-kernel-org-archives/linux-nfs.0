Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 686C83A9DAB;
	Mon, 20 Apr 2026 18:14:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776708845; cv=none; b=S2GC4021hD7VeIm2G4V4m5MQAwd8D4qt9mTi+e2tagdDLNOi8kPyYLqPwTb1Uu8PoEBpLUXuf6ZgkzqJAII1a0kMh5VeRX6pS8fjzwbCrnKKX+rfunHpQsytKd/0qcfFN7TmCRSUFqWMAUYiOfzAOUAYtdyfmu8QaZJBtBYSclM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776708845; c=relaxed/simple;
	bh=O6cQG/v6Makun44214DwURYqa0oRKN7CJIjOJY8FWDA=;
	h=Subject:From:In-Reply-To:References:Message-Id:Date:To:Cc; b=CpjZWuOVQap/eLBwGKbCEhQiroKqExq4d39HIHcM3xHaJuzprgbzBR4ZwcXciQEzGIOQjy3ewdCLsvbFwpRZuBVUqDo3RqKDavZtPNL4fANAWt1ziqBtUNPcn/9OQEmE3bqDLeNbOffUoYz9p9CthtK6qqKjBHpXaKZbXvoLqrc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=EFQ15cRL; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="EFQ15cRL"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 49293C19425;
	Mon, 20 Apr 2026 18:14:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1776708845;
	bh=O6cQG/v6Makun44214DwURYqa0oRKN7CJIjOJY8FWDA=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc:From;
	b=EFQ15cRLuFZq+1+8j3LhoP0TmGPzYL7Ya7q7BSijwzMpIoA+vjQlK2qrQvrZM3JMI
	 8uMlm+Bq6IJDU1L14cubxodDHr5HDI4f+Ln8HGL+adtuuWA3sHyPzVtWWU2/E3YmES
	 g+etsDIHda27GE4i160hW5gGgF4vzUupKXXwNb+/+XmAG3vXi8x4Gb1SAJI4EHmHZY
	 LbfjbBu2wEf3cV4r3p5eyyYrKW2ou9rEJLQCupSEBsCLBKmPXp/ojhPm2heen5Arx+
	 TrQ02YFhVx9Mcmk3dg5prc5v73o1NEebKvEG1HNpXVANMCKbmphkoaFkWgBVE3WdJw
	 cdt9X01AvIgPQ==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id 02F07393001F;
	Mon, 20 Apr 2026 18:13:31 +0000 (UTC)
Subject: Re: [GIT PULL] NFSD changes for the v7.1 merge window
From: pr-tracker-bot@kernel.org
In-Reply-To: <20260419180305.2402-1-cel@kernel.org>
References: <20260419180305.2402-1-cel@kernel.org>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <20260419180305.2402-1-cel@kernel.org>
X-PR-Tracked-Remote: https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-7.1
X-PR-Tracked-Commit-Id: d644a698de12e996778657f65a4608299368e138
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 36d179fd6bea35698d53444b7bd3025fa3788266
Message-Id: <177670880967.1799182.17689482400768974689.pr-tracker-bot@kernel.org>
Date: Mon, 20 Apr 2026 18:13:29 +0000
To: Chuck Lever <cel@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

The pull request you sent on Sun, 19 Apr 2026 14:03:05 -0400:

> https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-7.1

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/36d179fd6bea35698d53444b7bd3025fa3788266

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
