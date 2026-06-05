Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 61B871A3154;
	Fri,  5 Jun 2026 17:32:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780680768; cv=none; b=YCrl4oUtPSu2AeBNp25EZQavgSY2eqzygeDCxgwuoRSvUGim+Y1xvo+tfKNOnLegTMr+z+irF8eMsEBRKPDV92LeIJFM49OFbZNYgShOdtPWnU0HQ/ufgFLBlXVHshl8EsBswmIz2ialy1ijf2uing6lZKVxx0I8AcnTO86ryMY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780680768; c=relaxed/simple;
	bh=/+/NNqEjun5z1Oyxwa8VYtTh3xkyVzE239uQnw+ubSw=;
	h=Subject:From:In-Reply-To:References:Message-Id:Date:To:Cc; b=OyUFNIF0C+OCkpCmkmKQ3EOXxybFDa6N0VDF5/x39yXq++c+fczo3D2+LUPTR4YhTR8mAMmVd14s3GX+Ni4peCDtOAm7HfbEAgFMU62zyI/7Srd0yfZT1wkoie63yhdrlFoR4eO2+/yfuWrsHkKtpLUPim9ytbhzLLuUpAoJSNs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Bx+ExevD; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Bx+ExevD"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4B4981F00893;
	Fri,  5 Jun 2026 17:32:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1780680767;
	bh=yoFGQAsFx+OFw6LdMfRS6WkTMETWKH4H6QL0Nc46E5A=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc;
	b=Bx+ExevD2y2hLbMK6z6Zzu5qHC3cJMJ2DR8gwdDIPkPifC2mWPgAQkgRRzRc3iuss
	 v1o0/JROjsjxFaAw8ShjYNeDBOc2o4sz6RLwNFY4D0pIQy8yRu+xxGw6uNPrlGyXB7
	 BKXYhlB8AR1p1C+ESDgA/Rh60wAbFs/MOubo0XYz+/pKB1B9/vZPg+QF5t3E/6A8qP
	 Bmc7VdEDMDClRZo6W5mOCBNps6YLWy9qrz1HIYYf93NY4GVc0Jv0azJ5t68BlVeb4J
	 jirjwKEcAcoHJdU1pLObh7Bea8xaoZxroLrBg4hTnoRotrb0i2TsRrnu4XYJVxE3Aa
	 vzJxcWDhvH/qA==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id D0CA33930BAF;
	Fri,  5 Jun 2026 17:32:48 +0000 (UTC)
Subject: Re: [GIT PULL] Please pull a NFS client bugfix for 7.1
From: pr-tracker-bot@kernel.org
In-Reply-To: <17a6eb87940db2a6306e087998b82a6da35d755c.camel@kernel.org>
References: <17a6eb87940db2a6306e087998b82a6da35d755c.camel@kernel.org>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <17a6eb87940db2a6306e087998b82a6da35d755c.camel@kernel.org>
X-PR-Tracked-Remote: git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-7.1-2
X-PR-Tracked-Commit-Id: 317d5146fb399ad1e87b310ee7d018fe648d40ba
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: a8dc5f60d127f1d147a8e778563fcef7715d1316
Message-Id: <178068076747.3853150.12801531036179895212.pr-tracker-bot@kernel.org>
Date: Fri, 05 Jun 2026 17:32:47 +0000
To: Trond Myklebust <trondmy@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

The pull request you sent on Fri, 05 Jun 2026 12:14:01 -0400:

> git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-7.1-2

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/a8dc5f60d127f1d147a8e778563fcef7715d1316

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
