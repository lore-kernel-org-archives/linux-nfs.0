Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D31FD38D690
	for <linux-nfs@vger.kernel.org>; Thu, 12 Mar 2026 19:44:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1773344667; cv=none; b=WZSB3jGEHoImMouJ2FR/Mz2l8DCgyI9wY/HF6YY0sVgqNYri9HXmeAhsi600LWxERkk+6+1deiOQRXFOH7z6uOG0xPX93TwW+1KlNDLSLtfie/V95WqlR6LS2/eUxFQVIv0d0DngmCNkuHs09fYguzUMSmyqHbSSy1k2fsvFSTE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1773344667; c=relaxed/simple;
	bh=ZiLAtNSR0g+8i/l5h1mazlKcZjK8KdzYbnaF+9/M1IQ=;
	h=Subject:From:In-Reply-To:References:Message-Id:Date:To:Cc; b=MBSCcAPDvQOXocZeDB29psMwUZGgle6rcg5zuWk6R3rxnd5EDEmYhmXSTUQZwJPmHDks1c32aeKzAuODYX0OJQAyBKPeOFhm0uczIxQ98+oMQs9FFGhVRv7ga35q6QebSkMa0lJb80/Bmdzdna24A1sRgQLODz+guBZJLlQ1iIA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=uEJPKViT; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="uEJPKViT"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6BB50C4CEF7;
	Thu, 12 Mar 2026 19:44:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1773344667;
	bh=ZiLAtNSR0g+8i/l5h1mazlKcZjK8KdzYbnaF+9/M1IQ=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc:From;
	b=uEJPKViTpF6o5R5kwKbERtpXUJJ2UBk8w7d8LX83bj9DOai/gOZPNbJW10/7956xJ
	 Q7h8FWvtcF3B1qby01EVI46tPV2s3Bz8CFoZZ5Zy9QO/pBhDCNt+4Y1liy6Q+0sWIA
	 RhvR0T4ViFid12nqykwT9Ixxp//lnetrvxeOYWFQ+LQPKrwesbJRSChDSQds00wyv0
	 hdfIt+rx42qkg80LKW07pmITFL/7V1SPUigGx2bDOpr9gcMsxOcNwrnE9xLQYIonQf
	 hQjDvBj21yVLhA3ag2MRehQ6EY31iNqSNddkpEuF4ZDfv3vIwPuZ/TmLfY8qennXQD
	 P0YgndCdBZ76w==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id 030133808200;
	Thu, 12 Mar 2026 19:44:24 +0000 (UTC)
Subject: Re: [GIT PULL] Please Pull NFS CLient Bugfixes for Linux 7.0-rc
From: pr-tracker-bot@kernel.org
In-Reply-To: <20260312174340.310766-1-anna@kernel.org>
References: <20260312174340.310766-1-anna@kernel.org>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <20260312174340.310766-1-anna@kernel.org>
X-PR-Tracked-Remote: git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-7.0-2
X-PR-Tracked-Commit-Id: 4529e0015432977af3ecc3b9f940fc2a1ef1b265
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 8004279c41adf3238ba71931219205cd1f59343b
Message-Id: <177334466260.523191.9942352966327984529.pr-tracker-bot@kernel.org>
Date: Thu, 12 Mar 2026 19:44:22 +0000
To: Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, torvalds@linux-foundation.org, anna@kernel.org
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

The pull request you sent on Thu, 12 Mar 2026 13:43:40 -0400:

> git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-7.0-2

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/8004279c41adf3238ba71931219205cd1f59343b

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
