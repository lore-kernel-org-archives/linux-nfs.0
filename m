Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C6FD03D9027
	for <linux-nfs@vger.kernel.org>; Tue,  4 Aug 2026 18:06:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785866806; cv=none; b=J3Zv6miK6FNMBBgGOfOhfEKV68L2/k/94ihFWFM/cSY/FUIEcNplDmX+offCYcJe+NNsbWoCZGMKzOfxHrgYlf4aKlhIUXaO2VStSsmeVw0Qh9XmMZ/zNKoa1QsyZhpyLb23zniEvYm78x8PA0gOp77QY3fSR9hjyxR5j5bSOUQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785866806; c=relaxed/simple;
	bh=I3tOB1ICMoJQClNNQA+34YMDPCaYtZ0l0mvSx/IpF0A=;
	h=Subject:From:In-Reply-To:References:Message-Id:Date:To:Cc; b=X1M9cShRHK/eQCsqrgEPcgb8rnSgYW+sTUTVs05alyap3ECAc+ap8EtoY6DGifmGG3/moVuCMo8q9tmX1rYFIku5+Ka+zT96oIgaXNI3cFAD/1BNckhVEvrgQvEgP0VooWRM0YZKUEfG/Vb+plPJQyMcVGqADBJyeRXR2exX7cg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=As3rN9Ww; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="As3rN9Ww"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9A5F11F000E9;
	Tue,  4 Aug 2026 18:06:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785866804;
	bh=MzzbeynpNKDqDRsUWbvBEzkbhNYrsmiLI5dUvdcUyZM=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc;
	b=As3rN9WwMtfIh1+5g2aaNrYDiCaK2Umum39qcHA5fgJ0m3dD2mK35P1ai4I0kQ3EJ
	 M6jX/AeFoFmb5jbFbRsfX//qhKfpcy2SgQUQp3K8Sl4m+BZWhRTQPVcUepz8xPyVfe
	 M9XTyNUJknNWCQI8v/nwBAVwhAt+DpsnDn3HWXekK1LVof4YAP5K+wBYHI20uVFd11
	 UgZym5vWf/w9cjq+/NS+rHNa3VUyq69gfkXMQx6B9rYYM0GEtIytz7bxCO7SkWYjAq
	 rFlO+J221SC2rY+rM03OTlHuT/1BWvRBMVPoQbMxtopzXDS1pMenU4jyl1i/Gu19Dl
	 aytla/QpRx1Vw==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id 568893926398;
	Tue,  4 Aug 2026 18:06:06 +0000 (UTC)
Subject: Re: [GIT PULL] Please Pull More NFS Client Bugfixes for Linux 7.2-rc
From: pr-tracker-bot@kernel.org
In-Reply-To: <20260804164254.463083-1-anna@kernel.org>
References: <20260804164254.463083-1-anna@kernel.org>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <20260804164254.463083-1-anna@kernel.org>
X-PR-Tracked-Remote: git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-7.2-3
X-PR-Tracked-Commit-Id: e053b624f5d36669756990743346157be9f68c34
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 7c350d079e79cccd6a30d7632fb3211e7f6fedb4
Message-Id: <178586676493.3716517.15426650801938719962.pr-tracker-bot@kernel.org>
Date: Tue, 04 Aug 2026 18:06:04 +0000
To: Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, torvalds@linux-foundation.org, anna@kernel.org
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

The pull request you sent on Tue,  4 Aug 2026 12:42:54 -0400:

> git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-7.2-3

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/7c350d079e79cccd6a30d7632fb3211e7f6fedb4

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
