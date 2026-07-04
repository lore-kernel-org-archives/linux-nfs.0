Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C7AE63603C3;
	Sat,  4 Jul 2026 02:05:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783130734; cv=none; b=Gw5s0Q79mSOkwmiHHu+cHV/qJW2OgZLbVU/yI+R1boI7FShe7X5n246TVQ6Flfr6zamadfFY5eAuDbonwStfM7dZolFXiFMy90UI8oVv/s5TRIkLKg6rvHv/TcVHifqEiydfw+xHN4kMQawLvKkocscLvLHtMOjTiTBOzlDKtDk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783130734; c=relaxed/simple;
	bh=2RRQ76tPpd+5FEVjxGy0CV4HLbpH92exkwZNxOq6Hlo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=t2HhRWboQREjkcE4Puh8yctmnCat426fyZUrQua8TktHQWmwsTVgPbw7UXiHV1vy1bP5wCtSLobkRqb0ppdaseZJg/MxN5VaY3Hf+MvEJmO58+nZXCm6wAJli0tZ8eww4n3cdtxHvQS79CVkN0NI4WNG4oxZOHs1aLRlvrQJMC8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=WBLJwVmz; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="WBLJwVmz"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E17E41F00A3A;
	Sat,  4 Jul 2026 02:05:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783130733;
	bh=b7giR4IIKgzUqtHYQP2Visi/y16Z1NoOhO57Ql1xkMM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=WBLJwVmzfdIC20G8E5ki2CZI3FbJt0l+BPnYMavBUm+HVhNjvoyFNx31/iboYpSEV
	 eRvBZOpDQuG4gnW+L2G/ODdqj+swUGh/Ir2ioNq9+xAD0EAn82aVUdsCFa1YHkxZAk
	 KmIupbmwMWxhmp2NvaGrkorZ50FVt5791fEjXLLK+6F5Vc6DOQKFO0B5RabZjuBNLo
	 D3arnOnxQk96enJsBTNETwSct0GbUWo98BH93U36Cf3s6wbxWM6qr6Y4eUwx6QHbfw
	 +f+NtlBULZvQj+Dyhu5ThdFRPpPVwAs1jnYLgog3XP2GOauHrnkFAYUowdBjJla1VE
	 ouAg6sncD4+eg==
From: Sasha Levin <sashal@kernel.org>
To: stable@vger.kernel.org
Cc: Sasha Levin <sashal@kernel.org>,
	linux-nfs@vger.kernel.org,
	Olga Kornievskaia <okorniev@redhat.com>,
	Chuck Lever <cel@kernel.org>
Subject: Re: [PATCH 6.18.y 1/3] nfsd: update mtime/ctime on CLONE in presense of delegated attributes
Date: Fri,  3 Jul 2026 22:05:00 -0400
Message-ID: <2026070315-stable-reply-0006@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260702202409.1583677-1-cel@kernel.org>
References: <20260702202409.1583677-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

On Thu, Jul 02, 2026 at 04:24:07PM -0400, Chuck Lever wrote:
> From: Olga Kornievskaia <okorniev@redhat.com>
>
> commit 2863bac7f49c4acd80a048ce52506a2b9c8db015 upstream.

Queued the series for 6.18.y, with the author of 3/3 fixed up to Chris
Mason per your follow-up. Thanks!

-- 
Thanks,
Sasha
