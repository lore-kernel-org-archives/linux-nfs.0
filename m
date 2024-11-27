Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 046A91BC3F
	for <linux-nfs@vger.kernel.org>; Wed, 27 Nov 2024 02:34:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1732674900; cv=none; b=gCZ8xvPLheRy2mAXMYTIpuC9uz9HZXOJXoKOjSlV83RCmonFvPGpcPeo2Bq6FHMBJhtKOKZrkqNwSdJbgJt30NL5Ff1af/1ueIKS9yZZHXiMGy8Yu1/3VlxSjVnKN0HF61gQL3AnqAWEWtgArSLXHCvaCjwnt6EXElD8Q3l3EmQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1732674900; c=relaxed/simple;
	bh=xYEnivOtpD4K12+GJrdi4MSjtco8jLqXVvvjmp97JbQ=;
	h=From:Date:MIME-Version:Content-Type:To:Message-ID:In-Reply-To:
	 References:Subject; b=CQkYjNd8pwDnV8UJNJ4dM9KqtrnkivElonO7fxxwd+UrHn2ok3LpAwJNyq7VipPKvYMVguGiKGd0a6cRSbPBrX/Fl1Izo/I7IzTvElMq3f9NzwZo3GBkCuZFmhwsun+STSN2e7y0aYxyYEawbP/B5EjCaJLMG3G/D76Qjk2DzFY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=lwQrrKSO; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="lwQrrKSO"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 922D1C4CECF;
	Wed, 27 Nov 2024 02:34:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1732674899;
	bh=xYEnivOtpD4K12+GJrdi4MSjtco8jLqXVvvjmp97JbQ=;
	h=From:Date:To:In-Reply-To:References:Subject:From;
	b=lwQrrKSOL809Os1cdxIOHtbbk5wP1gahiPG2I7M3UAKsS4PC82JxPXeu2HXIKltu0
	 uLUmkJv+fKIipKitCwRshWzucmJcYzlKsrB/cYFehFoHhZvjXiOw3t7wd7JgExLQLG
	 yz+UEPRmCi8wLRsjRXybjsuFAXIZwXf0g9ZO8BMGedOpeUh33Z/KBI36Py7MIeoA+T
	 lyVAL4VSPNCLmv6dRZmsOHZTiqybHhcC3a0/GXmFctKrIXNxTcBpjHNFdOfCI8u00B
	 V27FNLUbgTNR7HjAum+zWRt4+RH2PyOlpl1jorOdiUSUB1WwaPExtd5ZbaOKQNwFn7
	 qvkWPbiCrk00Q==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id ADDC13809A00;
	Wed, 27 Nov 2024 02:35:13 +0000 (UTC)
From: Chen Chen via Bugspray Bot <bugbot@kernel.org>
Date: Wed, 27 Nov 2024 02:35:08 +0000
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: linux-nfs@vger.kernel.org, trondmy@kernel.org, jlayton@kernel.org, 
 anna@kernel.org, cel@kernel.org
Message-ID: <20241127-b219535c1-584903aeb011@bugzilla.kernel.org>
In-Reply-To: <20241127-b219535c0-4d5445e74947@bugzilla.kernel.org>
References: <20241127-b219535c0-4d5445e74947@bugzilla.kernel.org>
Subject: Re: Possible memory leak on nfsd
X-Bugzilla-Product: File System
X-Bugzilla-Component: NFSD
X-Mailer: bugspray 0.1-dev

Chen Chen added an attachment on Kernel.org Bugzilla:

Created attachment 307284
lsmod

File: lsmod (text/plain)
Size: 4.96 KiB
Link: https://bugzilla.kernel.org/attachment.cgi?id=307284
---
lsmod

You can reply to this message to join the discussion.
-- 
Deet-doot-dot, I am a bot.
Kernel.org Bugzilla (bugspray 0.1-dev)

