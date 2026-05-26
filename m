Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1ACF63D34A5;
	Tue, 26 May 2026 23:41:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779838909; cv=none; b=phRhN2Bli2OhrHuG5TQ7R2b7Hj+7iWQhnM1zLchRKYL3rVuplGyiz3K5xVya3jxm5lCc8u4xfUb5xOvmRS8PDa40UgltQ8pejtAScQSjIYdX5R/lEI4qEHfy7eTRoe2bJelRFp2efGiGnzXtmAGAJEdJ8BVOHR3pXrFlZVQEfcg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779838909; c=relaxed/simple;
	bh=wAVwAsNj5ehNg31RlsJxMBbkglJxKQC6kPweYJ0362A=;
	h=Subject:From:In-Reply-To:References:Message-Id:Date:To:Cc; b=vCrvI49GjA3CCSLXLOlFMNpWLzv4cW3OZ0i+LhrAVoeN74C1i5GFF54fWixiDFij+BSVXooIJDblTIJQ7RMuTY4d31cNCPo9tmugSzK+Uev+Jh76tHlqdvsRC8G+z1HDEtM4ZZc5JnaZ2AbxJCf+jNy+CbVUUxS8a3r/HNYq0Gc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=kGEdP1Al; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="kGEdP1Al"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D409A1F000E9;
	Tue, 26 May 2026 23:41:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1779838907;
	bh=XD3AJFIuXudh50oRh+KKEDtp5Bb3FLj3WnzxbuPqaI4=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc;
	b=kGEdP1AlP040WkzVh5bV26ZjKZFSWSKF7/UkCGj2GIZ9a4+zlChM/7LEYYNsMuCKO
	 hJ9kGKFjDrjydWPj/UwPovgy+QdLGbqXgXYTW7Us0JpDPZAPVV3u8RRt1IaaCbnfxD
	 Hh8WiVk9Usa0PWCKqTUYPiO2evv/6BtwS+CemB9VE7gSeOyeHdEzxoskmn2+qfNP8/
	 QrGaTO/XIOsivQmFsgcVtVH6BeeiQsaGmd/nd3SGRnSBiOiWqkgysuKAnz7zzINGSJ
	 mZnbgPlxF3BuHt6z1ts5ljo2IQ3CdrLEwpNA48wlus9I9LYGODMjJF+h/DBcvdWDva
	 qOZMlAg1YO4Aw==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id D0A2E380CEEC;
	Tue, 26 May 2026 23:41:54 +0000 (UTC)
Subject: Re: [GIT PULL] More NFSD fixes for 7.1-rc
From: pr-tracker-bot@kernel.org
In-Reply-To: <20260526194642.108872-1-cel@kernel.org>
References: <20260526194642.108872-1-cel@kernel.org>
X-PR-Tracked-List-Id: <linux-kernel.vger.kernel.org>
X-PR-Tracked-Message-Id: <20260526194642.108872-1-cel@kernel.org>
X-PR-Tracked-Remote: https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-7.1-2
X-PR-Tracked-Commit-Id: 0b474240327cebeff08ad429e8ed3cfc6c8ee816
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: eb3f4b7426cfd2b79d65b7d37155480b32259a11
Message-Id: <177983891342.4014102.6693190537712993076.pr-tracker-bot@kernel.org>
Date: Tue, 26 May 2026 23:41:53 +0000
To: Chuck Lever <cel@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

The pull request you sent on Tue, 26 May 2026 15:46:42 -0400:

> https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-7.1-2

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/eb3f4b7426cfd2b79d65b7d37155480b32259a11

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
