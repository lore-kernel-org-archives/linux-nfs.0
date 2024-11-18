Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3FC6C154BF0;
	Mon, 18 Nov 2024 21:19:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1731964746; cv=none; b=FpEiLfr17kZJG1aAavqjAsmHdqvbxA3sETfCcKIbf8dbbMW5q2SQZQ7mHaY3WbRsi493aIKqsLty7EJLQo0SJOBIaAmHse7LMNrIWY4tcDODKgQmVULL0TAT2VflBOiZLhWfiVOxYVPOu/WeUbWu+tG1gTs5IkU5yxnJurO3mAY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1731964746; c=relaxed/simple;
	bh=GFdywPDt/DV4WcBGDX/bMizY3+b0W7G7827H3STBdUw=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=YbkOVsnGwkhmt1Td89dlQ+m9J7bYzUtH22H2Swiz2kjQTYgQr4ClhNi4APDungegeEXUUUkMaZ1bds1x0LR5tu4k5Kf4Q0JqQ4W9os5xUddJT7kD3TwQDOl85eydqN56b2u3d5j4hbXGEUSHVxflsQdvZeQEhrGjDXYIrG1j6lU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=fIWyZzN3; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="fIWyZzN3"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9E713C4CECF;
	Mon, 18 Nov 2024 21:19:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1731964746;
	bh=GFdywPDt/DV4WcBGDX/bMizY3+b0W7G7827H3STBdUw=;
	h=From:To:Cc:Subject:Date:From;
	b=fIWyZzN37KAloQCsVT7QyGurrLrx5i/eMpTpAGofGmPkRXU/Tepy4CbygTupHuKuX
	 JaOLGyigW94q646eggclRX4T3my75EsB4aRBVWsuZaUT989+V8qxQn16ZUkKC3VSZK
	 XojTZ5XSsdmKRra6szlsgizqdbxX8Rl9o983RWK99iqJZU3Y19To2L1HGun9pSZOSd
	 zbI8P/qva6CqD1qpVqyh0heg+hQKJbAO09Ma2djPyA4yxYt1seLYvaFIY2KuJVSrTk
	 YpXmyjVA/aie5nPk/l+0DsT9JPbjdNG2WOu76nyyTKNStu6DZkk6k7N12Vbyrbdgzn
	 /8CuVI7VVaPdQ==
From: cel@kernel.org
To: <stable@vger.kernel.org>
Cc: <linux-nfs@vger.kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6.1 0/5] Address CVE-2024-49974
Date: Mon, 18 Nov 2024 16:18:55 -0500
Message-ID: <20241118211900.3808-1-cel@kernel.org>
X-Mailer: git-send-email 2.47.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

Backport the set of upstream patches that cap the number of
concurrent background NFSv4.2 COPY operations.

Chuck Lever (4):
  NFSD: Async COPY result needs to return a write verifier
  NFSD: Limit the number of concurrent async COPY operations
  NFSD: Initialize struct nfsd4_copy earlier
  NFSD: Never decrement pending_async_copies on error

Dai Ngo (1):
  NFSD: initialize copy->cp_clp early in nfsd4_copy for use by trace
    point

 fs/nfsd/netns.h     |  1 +
 fs/nfsd/nfs4proc.c  | 36 +++++++++++++++++-------------------
 fs/nfsd/nfs4state.c |  1 +
 fs/nfsd/xdr4.h      |  1 +
 4 files changed, 20 insertions(+), 19 deletions(-)

-- 
2.47.0

