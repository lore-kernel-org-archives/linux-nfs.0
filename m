Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794781807;
	b=CkQQVL0MS0BsBdWyUht/5iZr98ynU09vMfcxx1mDaci0WwolL5wx7SwKQ8/mxpSRYs42
	 UOYbnrzbXuRjMEG3368unP+OYTaPNieNYTM0/oov/xFoLpamMaGY85LD2nF0amxgAbAR1
	 3B/BlaMnDUgpbQzsjF/0adxnC1QI6SYtGxZxvRnXfyhWAFvezu0lagXNVLJ4FbvAw8upL
	 rwO7EXIa56pAZJGA51vS7Oncp80HQbaxSx92jnqVBP92LaxDYxaKlXo8P8ll9Nprf1aU5
	 K6ePlRJeSfjLhvmohubN09W8XFT/UULCiW6n/9XGvxlQQqBXBL/AN6nAIHo6tqSv6vg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794781807;
	h=Received:DKIM-Signature:Received:Subject:From:In-Reply-To:References:
	 X-PR-Tracked-List-Id:X-PR-Tracked-Message-Id:X-PR-Tracked-Remote:
	 X-PR-Tracked-Commit-Id:X-PR-Merge-Tree:X-PR-Merge-Refname:
	 X-PR-Merge-Commit-Id:Message-Id:Date:To:Cc;
	bh=Y5hvIG8v61heB6aZ7N4+8FEHVrA+BCC6bBlR7NUkHOc=;
	b=rVN68IulyN1BwGNcMIUm8Q921RyaQxNgD2w7PnlF70ACdPmxzNiX6H7KTVGT5Hl/vByh
	 xQc3CADwKYs4LdB8pcjyD3D+TPH9gLMvt5ko43lR2FJMHQlERf2zIVtP+B6fsDKV7yXFG
	 kBsBsd3ATS8lnK02uC6YyL8cOQNEvVe6R9Dbn4MkRuxiL/dopumN1LpUY4C5cxwPBstSo
	 DoHadBs3sHBr16CAuTG8KuOyx2O8c3dACfB9Z+6P6XF+4u2PcFeNK7NIihkUkDRh+t04B
	 Z81sdkQS6E0g6LqSv1dsdn7Y5vg0BUF7XjYHsphLfcCLxeQVL8C7D2QOQOEasnvYjRw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="ZS/PxFhq";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AF079606A884
	for <linux-nfs@vger.kernel.org>; Sun, 15 Nov 2026 22:30:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ZS/PxFhq
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8BD561F000CD;
	Sun, 15 Nov 2026 22:30:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794781807;
	bh=Y5hvIG8v61heB6aZ7N4+8FEHVrA+BCC6bBlR7NUkHOc=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc;
	b=ZS/PxFhqLut9i1s4FMjq7h6q8p3h6Zvrym2P3uZS8zPYIGQDv7BCMrUin+HFDBy0U
	 4xbKfaF+4zqZicizbmO6544xyWSU++z7EiNBELx9A4zsHWmChLZNnEejiCVpwZesEh
	 I/Aj3eA843lUEElj9rieGpHXI0p/yH+xSRSXm22aWz+YJPjnqTjfRlUwhAnTTfGGSP
	 PtJ95nj0UOos3nzuWreKhOxvsqoWy1CuSkYPO8jhzohkNzcxlv6bqYiujopcQeWOqr
	 KRhlS2IhbP3JD5iEnxC0M5WzBr9FKIeO0gXQwcwbR/Y6KUjdYk2Z+itlg0Qwn/zpub
	 K57MgCgj1G5Lg==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id 805A3380823F;
	Sun, 15 Nov 2026 22:30:07 +0000 (UTC)
Subject: Re: [GIT PULL] Please Pull NFS Client Bugfixes for Linux 7.4-rc
From: pr-tracker-bot@kernel.org
In-Reply-To: <20261115182926.1408630-1-anna@kernel.org>
References: <20261115182926.1408630-1-anna@kernel.org>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <20261115182926.1408630-1-anna@kernel.org>
X-PR-Tracked-Remote: git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-7.4-2
X-PR-Tracked-Commit-Id: 151d95a1e696979a7d54b23c96338754be2fcc1f
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: f70886e5a510cd7fc2c3aef91c46a14f4485fe63
Message-Id: <179478180615.2784423.5128567411861228372.pr-tracker-bot@kernel.org>
Date: Sun, 15 Nov 2026 22:30:06 +0000
To: Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, torvalds@linux-foundation.org, anna@kernel.org
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

The pull request you sent on Sun, 15 Nov 2026 13:29:26 -0500:

> git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-7.4-2

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/f70886e5a510cd7fc2c3aef91c46a14f4485fe63

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
