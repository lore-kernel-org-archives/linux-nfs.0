Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5E27154857A;
	Thu, 15 Oct 2026 19:36:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792092984; cv=none; b=CM26fzSdEMPhgLXdSEpycELqCkkuGDEd+8HNOFGuvtvunsVQTFRsPvPl7kecshNWVTrGOpAHyOxpkcQ5TnQ3sq8J66XFKq7C9QKicL68JmQ9ukkDYERXREusdlKNuIynKCFXwR3GgBfz7Q77rh35+oeR5AjNgeQvBBKTMWtmLOw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792092984; c=relaxed/simple;
	bh=/XmKqd+AeeMarCKLh8geg4KRCS/4fi9ZGtYX1pUaFHA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=kaRO9WW550UW8z7k0kxKHbdNC490E0X0UaewHYWBivWqa+aXXeCE5loY6OzGM6VXiFynUeltohPS06NbnYnTGZd7RvF6D23LJQ6y51HRId1CS2D30uId0wpDuz/vZFShK4f8Q979SHK8G569wiAiQJ7Yv80ws4elWTKE+jh7ACE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Rda84AJj; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Rda84AJj"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1CCE91F000C5;
	Thu, 15 Oct 2026 19:36:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792092983;
	bh=ldL5OxLWg7bOAW/ntJKKMRxWGCqyVIFbmgTCdkcd7LI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Rda84AJj4UeLH7dXmif0l75MDWDZ/UEPUEEFCnjJqpJGFZLAbA56DC5PTazkyZgWZ
	 BIHgqwrRIS9pnTDfRZh0GWZtAsttwzFvX4r26UcL0RuzDUIXNMomP+Uh1Vy6KNEmSh
	 ATun0uVdcNE38+a9F0PQfZhiKr1bDRmRBWWKkA8G2CKnFir4Lg/tYJw2lke/HouDAJ
	 +1glGFeR2uIAfYNUSO3XFJ8yrqrk0uulmwYvTVtIG5R4v5zqi7LRDDNWg2FFiJBT7/
	 fdzjMQua9lEuv6uI1VGPCinWDeZa0blr8mMqahtwjJ5vggcJ+bvCn7oxxDG2JOH837
	 yF3tdC4Utk7Yw==
From: Sasha Levin <sashal@kernel.org>
To: stable@vger.kernel.org
Cc: Sasha Levin <sashal@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	linux-nfs@vger.kernel.org,
	regressions@lists.linux.dev,
	linux-kernel@vger.kernel.org,
	=?UTF-8?q?Fabian=20Gr=C3=BCnbichler?= <f.gruenbichler@proxmox.com>,
	Lubos Rendek <l.rendek@proxmox.com>
Subject: Re: [PATCH 6.18.y] nfsd: fix all-zero stateid in CB_OFFLOAD for async COPY
Date: Thu, 15 Oct 2026 15:35:45 -0400
Message-ID: <2026-10-15-1-daily-reply-0002-nfsd-cb-offload-6-18@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20261015005725.550511-1-l.rendek@proxmox.com>
References: <20261015005725.550511-1-l.rendek@proxmox.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

> [ There is no upstream commit: this fixes the 6.18.y backport of
>   d0beaee498e1. Mainline fixed the problem as part of the async COPY

Queued for 6.18, thanks.

-- 
Thanks,
Sasha
