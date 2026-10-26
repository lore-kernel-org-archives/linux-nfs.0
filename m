Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792980497;
	b=wdnrxN8pPFJ1xXdJuBQ6dwIKCHYPbJB/JMp3rZe7pNzananwXmP1iIk2ZqsCruZqI5LB
	 EPbziDgiO1vrQ07mYGQ/90aKwYsDw6rpnk0SEdPuvZtmvKjt15HKPMCW3EdJQh/giSnH7
	 gmACQiWU5Qwh3bwzuavOPwt9yqbwXTh/OMAx7rw6q/+a2Mw/TdJopmXvT+g6Ydt4n+HZZ
	 /rY1+4enTj+GZHL3KOb4ZBf6IhOQ2jBme4OnQAjDor0Hqt8I1ei5Gd/Vu2WISIyRxbIHt
	 69kRdP6pYxow0bU3Nw21N/8tXo7zCt6VU+MivvLgIknRWUhkKctjfsiO5sA6xC1ScZQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792980497;
	h=Received:DKIM-Signature:Received:Subject:From:In-Reply-To:References:
	 X-PR-Tracked-List-Id:X-PR-Tracked-Message-Id:X-PR-Tracked-Remote:
	 X-PR-Tracked-Commit-Id:X-PR-Merge-Tree:X-PR-Merge-Refname:
	 X-PR-Merge-Commit-Id:Message-Id:Date:To:Cc;
	bh=JZdgU67qob6kn/VjqI3UCA4WD0zpmq/v6zWQjdyTZS8=;
	b=UnmLpq+7sH05hfszEqn6tddiW10bhH3+6cuD2jKgzdMRRZlLp3sgfv20j3jwPWV0NQv8
	 7boc7TG7CF68SDrAH6hBV157KhZzrQRnfYc92zID96E+eBd+7rWX9JOwvgLWzdlZgUfYD
	 1XylRNnqmAoR34V/PKN8sNLbrzsN2ntAUQJ59SbwAQZhX8xO30XQqz99UxOtYMnj25DT/
	 Lqn1lTbe5Y+yrLcE2twiB617GCJ6ofN4Zg54h3E2RPXGdqrM1u89FNV8vGZBvnhy36/b9
	 L7dSOV1GMUl3CZlEfpGPwtyKtfvVlisPO3CoYlDKKxgFDSLOFFNuxVtB/A1mJc6iMJQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KTFiKYXq;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3519F606A31B;
	Mon, 26 Oct 2026 02:08:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KTFiKYXq
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 112E61F01825;
	Mon, 26 Oct 2026 02:08:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792980497;
	bh=JZdgU67qob6kn/VjqI3UCA4WD0zpmq/v6zWQjdyTZS8=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc;
	b=KTFiKYXqKIrBlmkE46MRf6Hy5BAoKP3XYHX9gfX+tkicOOKTXXM3MO90UpuEWMGV2
	 nmjnuUxrWst+e7nFj5/JZETeOT353N4/0DkBf7Ff1ISQeFeg6QAAAZb0jmd7zoX43u
	 N4wbjW1SZQW2L+YGI7DvBzhHM8HweRHwSUqwUnSQ4tSMmYVSH6OTbf6n5MuhQEfYUp
	 Z2C2ln7nYz5HNByW1z2IapufsZ07niboZr2OK7PRoHByg9bgnUZBKGJr8lRNJrl/eT
	 tnBgrFLKv77ES6WH0CnftNDJAgOAwUDKwXzc76l9VRnrMzjQj14P+YsSfTu54OTj51
	 +ErJmScni2KRw==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id 0753539EA760;
	Mon, 26 Oct 2026 02:08:17 +0000 (UTC)
Subject: Re: [GIT PULL] NFSD changes for v7.4
From: pr-tracker-bot@kernel.org
In-Reply-To: <20261022191536.3094786-1-cel@kernel.org>
References: <20261022191536.3094786-1-cel@kernel.org>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <20261022191536.3094786-1-cel@kernel.org>
X-PR-Tracked-Remote: https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-7.4
X-PR-Tracked-Commit-Id: eafb6de800781f0a1be5cdd98d150620041d8b27
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 47439bb1635e8dd9245e876c2046b66a9b6f9400
Message-Id: <179298049550.2358720.3288328915599756924.pr-tracker-bot@kernel.org>
Date: Mon, 26 Oct 2026 02:08:15 +0000
To: Chuck Lever <cel@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

The pull request you sent on Thu, 22 Oct 2026 15:15:30 -0400:

> https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-7.4

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/47439bb1635e8dd9245e876c2046b66a9b6f9400

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
