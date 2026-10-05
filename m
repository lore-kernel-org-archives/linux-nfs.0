Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3CDB24BC007
	for <linux-nfs@vger.kernel.org>; Mon,  5 Oct 2026 15:05:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791212737; cv=none; b=ktdM5dx9HoH47P49V5c8+aKdYt2F741B/XZaE1saiGDejAcw18jJ3WbNGT1qVnP6suwchu9ulrJUnNkIB11ukPEM4bM9gj5xPq8ppX+IeLYs0545lLEHSCnjm5nCnyyGqqn7iVWBq7Nw+pyKl+hs/PZLnGHxTUz4zbtBAElz1c0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791212737; c=relaxed/simple;
	bh=+zaAJHqiAoD9aabBLUGQoqpRLKKDfIVLwY6Cx+g8g2c=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=lWMcFQyzTS5ipW/clbBCJuI1ToJ08H0F4Ri2xafjkEonN6YRlE8jD+JqsdOoU/wROprzWMPLf04KttKqE0hM0LDA7xqhMBq/8PVK7c1+xKFxuzcB07wObQti5MhVM3UOcrDpCcSltgb1Mb3mpHVLEa4IERjhS6W41MDtfvq4LXw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=mpCd6PxI; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="mpCd6PxI"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 535611F000FF;
	Mon,  5 Oct 2026 15:05:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791212736;
	bh=TlxK6Ub4v1wWMWOTXRVR85sOwd68AySAC2mNmlJACTY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=mpCd6PxIw2qMvmzjlKvetiKgeJpyki5qxCyB7F0Xxkn18zzV4PGXsKF0C2kJuYNBB
	 3+e88GdQkJ5PUP9DBmqTh3cd18sMu1wNT9GzHjZnyPoixyUGCKbi31QJPWg2/VblJr
	 QDrWCpHF2FcBaPIW3CKyZMYUP3My1MZusQ9OdnioUNICa+oWtct+lo2nXz2WrJd3kx
	 2Anc56MlwBPH4CRG258BvUqO1ObUqYGfDjbkYS/pSUABcwgWQEZwpeUMw1NmxFkeV9
	 xMhPZRY+6RrRE8o9o88jjoVeyG2N4HidCw7vQHGyx0uqoHocH65vEQ+wKxobV9sFl6
	 X8KJaZvN4XuGw==
From: Chuck Lever <cel@kernel.org>
To: linux-nfs@vger.kernel.org,
	Jiwoong Wi <dwdnlzj@gmail.com>
Cc: Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	bobtobabz@gmail.com
Subject: Re: [PATCH] nfsd: update existing connection flags under client lock
Date: Mon,  5 Oct 2026 11:05:32 -0400
Message-ID: <179121272653.31333.632537111902330482.b4-ty@b4>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20261001041433.74718-1-dwdnlzj@gmail.com>
References: <20261001041433.74718-1-dwdnlzj@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit


On Thu, 01 Oct 2026 13:14:33 +0900, Jiwoong Wi wrote:
> nfsd4_match_existing_connection() searches the session connection list
> while holding clp->cl_lock, but returns the matching nfsd4_conn after
> releasing the lock. nfsd4_bind_conn_to_session() then updates
> conn->cn_flags. Concurrent transport loss can remove and free the
> connection in nfsd4_conn_lost() between the unlock and the update,
> leading to a use-after-free read-modify-write of cn_flags.
> 
> [...]

Applied, thanks!

[1/1] nfsd: update existing connection flags under client lock
      commit: bd9ebf4b2a0e95ee71b5a0d232fbd2e332b001bb

Best regards,
-- 
Chuck Lever <cel@kernel.org>
