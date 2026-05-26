Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 31F0637DEAD;
	Tue, 26 May 2026 20:20:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779826836; cv=none; b=BZyxep1EBI62NLRLp/JQihgM7FIp2Yn/KDZ2Fi9z1Jo9yWyRnsgzctJZ06sK5cQHBaEEYwVjgS7ijP1dIIhdVQc1LuT/7/k2qlrRwbXfrXh27MvvxJhAzltG9RfKpzRortdFPS+T+Zv0b54C708JagGUnhqwspw95fTknPin3aQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779826836; c=relaxed/simple;
	bh=NAVpQmgqHU+cSB5F3TvP0gwvF2WqfwF90c9rkp2lRUc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=CpEOhEoERwogcyPiCXM8rqa8nvxHgjGN8ZjwjRnxpdlJzKFT08qezBQm/kwghBceN+dLaHwLMK96VDmmJH6Dr5mxHQzeCsWlCqbbe7fxMyy7jXVGEBQ5eZRJnGMd1lOXuFxGrMx+QCkQMPPT1b3S15sJ8sJshEDQxkfH9rrV5+Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=NiuIJ3Wu; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="NiuIJ3Wu"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0BD2F1F000E9;
	Tue, 26 May 2026 20:20:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1779826834;
	bh=xzbddjpoIxopARytS3J4L+SFO2BZHupaPlusp4YLgTA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=NiuIJ3Wu8RK/Akq1kFRY2w6vk2VoJXLOnkxLfOqDQUTiJhN+3QaOoqtsmRJdn5USF
	 UTwY1Ac1AZioQZeny7plfqwMI3cui4NtalEg6vehAFUGbHmJ5n6xjSHm1iDJ02N2n1
	 CaPOWLoD9IpHTDtTsq36ehOh6eGPJihIUiuxDARI81HMBkBoiWhv8/TU9atGvtSOie
	 ophP7CozYNg42Doqu0XX41PqBA1q7Fem3S9WvELDj+fr8hDJy1QVevDbVZRkwxeuWK
	 MEUQqr6hEcUQ7RZPnxxXEdDKOTOhRFB14LwaUVZrrvFZtdZka1Xluxoy6qZsxQBYDP
	 7FNrMC4OJB2AQ==
From: Chuck Lever <cel@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Chuck Lever <chuck.lever@oracle.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: always drain cache_cleaner before destroying a cache_detail
Date: Tue, 26 May 2026 16:20:30 -0400
Message-ID: <177982682339.113495.2552876064434419203.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260526-cache_cleaner_vs_destroy_no_sync-v1-1-a707a6fcfd32@kernel.org>
References: <20260526-cache_cleaner_vs_destroy_no_sync-v1-1-a707a6fcfd32@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

On Tue, 26 May 2026 15:35:06 -0400, Jeff Layton wrote:
> sunrpc_destroy_cache_detail() only cancels the global cache_cleaner
> delayed_work when cache_list is empty.  During per-netns teardown
> cache_list is never empty because init_net's caches remain registered,
> so the cancel never fires.  After unlink, the caller proceeds to
> cache_destroy_net() which kfrees the cache_detail while cache_clean()
> may still hold a dangling pointer to it.  The result is a
> use-after-free: cache_dequeue() takes cd->queue_lock on freed memory,
> and cache_put() dereferences cd->cache_put as a function pointer from
> freed slab.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] SUNRPC: always drain cache_cleaner before destroying a cache_detail
      commit: a6a67f4010de2424ae856d5e857079fe89f1178d

--
Chuck Lever <chuck.lever@oracle.com>
