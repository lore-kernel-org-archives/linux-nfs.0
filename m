Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 73BFE4CDDCC
	for <linux-nfs@vger.kernel.org>; Mon,  5 Oct 2026 15:58:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791215883; cv=none; b=tIxREh+x5hsSTAUXcbaAWDQS0xcQC7djFvRUiZEK2yaFVNsQMHrZPgSOw2SJckNVyRw8xFvr2X5roa/vdbBi+YTCshyW2kOA/czO2kT96PUikRq8cMv1GUQHDi4EJJkJcEhEgT/32W4ehNcWa+XVtKboQNpVek/hZJ4HzTl2tsE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791215883; c=relaxed/simple;
	bh=Iu5obSDEMmLF3OjncrkdyhjJ9BxhWlwAZKAxQ5qS//c=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=WUvjEyyC9d817T3K08kZzsMF9q7JEy1b1pUDD/9NOiJx69WMYnITApPbMk9y7L1v8mWp0y5QY0/ysui5Y7bTap+cqowVaY8VcG62nMGFR2b51uBgqm6jrq8qzi3kR7DPHMxtfudiQ9eiKBBFSRs5+GErLAusnQ5glrrJevzHTvY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=KKL24YMz; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="KKL24YMz"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 33B741F000FF;
	Mon,  5 Oct 2026 15:58:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791215882;
	bh=7BaDkeYjOq1CsElGc4TOxg5VJ75F1EyrbHJt/h8KX40=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=KKL24YMzk9UfDla75O6TBzzM3TtB3y3SXz+Bb1CSq/QULTouT8+5BoOTzPVkF2RHM
	 TmL+jpA8XZp69V2NVlvAnxcZQZYkdA4aqLRVyXQnv+r4xh5+6hDw+2mTm1lDLmtVN2
	 dyzrE18o7AXecYZOF2c5SgfUIeLYqCNUxfdKflwHOKEfjwIGLQPRG7AawjUVS5M9YX
	 oTZlkpXdHcEayKAij/gUN7IejtcsKO1oPfX2FSJujKnJlxce2ZnyBhWo9/0sOIXBqf
	 0gHOTkP+JSkH+awks6WqnqkqBSW6ehq5/Q/KdjP27TZFosFWYMxhrlz7B/g3OlvLyk
	 BCoWzzOaZ92xQ==
From: Chuck Lever <cel@kernel.org>
To: linux-nfs@vger.kernel.org,
	Jinpyo Lee <bint4b13@gmail.com>
Cc: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	bobtobabz@gmail.com
Subject: Re: [PATCH v2] nfs/localio: hold auth domain while opening a local filehandle
Date: Mon,  5 Oct 2026 11:57:58 -0400
Message-ID: <179121586926.1849468.434180866060193022.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260930054849.133920-1-bint4b13@gmail.com>
References: <20260930054849.133920-1-bint4b13@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Wed, 30 Sep 2026 14:48:49 +0900, Jinpyo Lee wrote:
> nfs_open_local_fh() stabilizes uuid->net under RCU, but uses uuid->dom
> after leaving the read-side critical section without holding uuid->lock
> or an independent auth-domain reference.
> 
> Concurrent LOCALIO invalidation can clear uuid->dom and release the
> association's reference before nfsd_open_local_fh() uses the domain.
> Generic KASAN reported a four-byte use-after-free write in expkey_init()
> when it attempted to acquire a reference through the stale pointer.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] nfs/localio: hold auth domain while opening a local filehandle
      commit: 57784b365e9b4fb31e7e485148164900ed793350

--
Chuck Lever

