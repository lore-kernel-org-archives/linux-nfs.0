Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4EFCD3BB13B;
	Thu, 15 Oct 2026 19:36:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792092983; cv=none; b=K8bHvXa7ZWa3CiyrfjqMBPBt9cx49sE8cR8lhPxCo1tfs7jU/P6aSzPiaIXMglDA/ByagBBd2XCfi6IULvJ56LtAXG6hqzE0wBf2lMEqi8RApMOjyE/2wczDnC60RO3/4Ao0LU2+SuT/JOI0TD21H3amkdr7qc5Zm9KmLrR4yDk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792092983; c=relaxed/simple;
	bh=PjIMJV3TxxAldxFtO2r/oyHqaMyuhat0IApdihhjd3c=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=WT3Cm8C1IEzNz+dACdBTVYFj3Qz8/SoBX0XEeWDMmJok6VBWrVm9UGFXvaJVSIq8poig+fZU2TSN7vjfqJr6/ocSVybxWNEuexiGJaxyn936lyq++JCzcysIV4Z7yJuvp4BiF21HThXjAtkisNyTdXDtI77NsYNSS/z0Ho08Osk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=UdRdSz+S; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="UdRdSz+S"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DE4951F000C4;
	Thu, 15 Oct 2026 19:36:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792092981;
	bh=jax/Am4NHQw6XfMYeqSod77H183J1lLhmyS8TV33bSQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=UdRdSz+SLVo4q7NZwiqCHV5Sjl2LD/5Tid5ethLO8za4NcB9VBQxsrJ7KuksFaBOn
	 +KMjvJoSQ78g5t8uU0i5eCVIfpRZGARByuqERT2GzuJn2YwYCEHRxrdY9+yHWdmLS7
	 ShPN3ekuWt+pQ6eMelcaTTud6oehfxfYX0105Sl7KFUkmFu9nDmT4OyauoZTahqrRp
	 1pkPzC9hFKeb8uNo4ZrC0Ke+qPOU936XyF0DaTO1mbIDDAjhhcm6yZbmngyISXsgnI
	 6qid0rkiCBIjnTFeAKkiwZYDDqs03r6we+PwFyxvYiUyA1KwBrKE48dmtERnxmmkhP
	 omgxAK5L0xAog==
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
Subject: Re: [PATCH 7.2.y] nfsd: fix all-zero stateid in CB_OFFLOAD for async COPY
Date: Thu, 15 Oct 2026 15:35:44 -0400
Message-ID: <2026-10-15-1-daily-reply-0001-nfsd-cb-offload-7-2@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20261015005340.550134-1-l.rendek@proxmox.com>
References: <20261015005340.550134-1-l.rendek@proxmox.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

> [ There is no upstream commit: this fixes the 7.2.y backport of
>   d0beaee498e1. Mainline fixed the problem as part of the async COPY

Queued for 7.2, thanks.

-- 
Thanks,
Sasha
