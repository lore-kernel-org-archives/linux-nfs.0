Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792980499;
	b=n2JU+x6fYH1B81NCrWiJtsuDqKo24lGo1FhJXtTRNiRk6CUNixlYjBYNKGwOZEcOCREh
	 1ldXeIFfOc3mz3PABVP1+tJ/xjKCTTYSqK7zQOOGeKMEpBPyPratJOKi7eHW8cKZIpKu3
	 smhVu0hZIdKoRReXfNgG0e0LXhlxrOOFjQcCaJwA8GMgcOeFRT80M9SJszPPjB4BXPn8U
	 l795JDB/Qd+F1489YNJhAPjUxA1SxMP9ZLOEfhIPI+GRUNNUwQMR4AECbcgLVVM0fpuQ4
	 uR+EnQ+i+yyrtmgPmmBZDQ8E7SDJC687doJf1VGmNK1HClI72yk+2zaRZTIxcVAd65w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792980499;
	h=Received:DKIM-Signature:Received:Subject:From:In-Reply-To:References:
	 X-PR-Tracked-List-Id:X-PR-Tracked-Message-Id:X-PR-Tracked-Remote:
	 X-PR-Tracked-Commit-Id:X-PR-Merge-Tree:X-PR-Merge-Refname:
	 X-PR-Merge-Commit-Id:Message-Id:Date:To:Cc;
	bh=Ix0wrZzojA4CGxvR1XdARcUpTBNmrQFIhIZivg3bS6I=;
	b=DSMuuQRcQmV0juSDlerctT/gtKE5hH5+K+8bz+5WXUpx4dVOc74Y+nd740/sZghd0sNf
	 SbRXRUFjdpmfb2GiBiv+Xwm6qvR2AKAgsGvEg+1uW8qyqM4whl+h65p+U8DYRFzEDKQUM
	 W8R9aCpufceOpe9cZvcCpbduNd8y4EKoDtxDcI5EwEvlQN2prBv1Q1h7go0UHNMfht5Mz
	 RsmiQDUdL+sE1PybWrDTl9cfDeXs1g0klo1eYHzlSyHC802BPQnv7GdhNdTseN61vjE80
	 YufQRp8ya9MqA9TuKYFXZFcC9M8gm3RxQmADcVrV8QSKN72Ok7rpNJ+vPqudO+gKAmw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Qj1KfF73;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 70F1B606A31A
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 02:08:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Qj1KfF73
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4E0801F01828;
	Mon, 26 Oct 2026 02:08:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792980499;
	bh=Ix0wrZzojA4CGxvR1XdARcUpTBNmrQFIhIZivg3bS6I=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc;
	b=Qj1KfF73GHhj4FWn+F8ZCUs55wN9J3s1sOiq+fb/Xs15aPYTBvGcj6E/NBoPCyFKk
	 1+xHP4UBhfDcI2bzFJdqrD/0xGmXlQWhc43tyIFlMrosRP9yQ7rw2NHa1viB7SrQT3
	 9xp2S82O8SvoX3g24wownppuTXy9cPT5pBiqaWhCJVWcxPU07qNBM1PI0uSS8I8dDp
	 GnsuBe+l23ejYNHgmDaIxiCfoBIYVRTsXfn6o2uacHT3qSELtCtAvkLpTcljdQQX9F
	 RrR4TdItuFAtrncc+NGBvF98jccCSAQ45ut/DlyvPKjoV4hZg7Y6MT3yrZt4HX756R
	 0jBrWdYP1FXsw==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id 445AC39EA760;
	Mon, 26 Oct 2026 02:08:19 +0000 (UTC)
Subject: Re: [GIT PULL] Please Pull NFS Client Updates for Linux 7.4
From: pr-tracker-bot@kernel.org
In-Reply-To: <20261023211150.485518-1-anna@kernel.org>
References: <20261023211150.485518-1-anna@kernel.org>
X-PR-Tracked-List-Id: <linux-nfs.vger.kernel.org>
X-PR-Tracked-Message-Id: <20261023211150.485518-1-anna@kernel.org>
X-PR-Tracked-Remote: git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-7.4-1
X-PR-Tracked-Commit-Id: ef30b3efb7e8bae94d790a6503a595e1051323e7
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 9e089e670e9ad1caf4a5b2b63e01b2dc076efbe3
Message-Id: <179298049774.2358720.2738343874770066025.pr-tracker-bot@kernel.org>
Date: Mon, 26 Oct 2026 02:08:17 +0000
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

The pull request you sent on Fri, 23 Oct 2026 17:11:49 -0400:

> git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-7.4-1

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/9e089e670e9ad1caf4a5b2b63e01b2dc076efbe3

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
