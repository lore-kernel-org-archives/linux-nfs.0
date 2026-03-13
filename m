Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 76F4239099A
	for <linux-nfs@vger.kernel.org>; Fri, 13 Mar 2026 16:31:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1773419511; cv=none; b=MFwk5937qfM0sSMa9Eg+8/HhYdcpyzTCXQrTZo1cDn7vay7MZAgToKiMdzDnXrKYJRIueZv0QCSjMzwOyjv88LuolAf1SJB56dqv8Y0lEWfX5+Zp5N0ygjqiTmO21OhO4yDNC1UTxUMY58fStO3xnGqUjym+Dr2t0JTXwdJsxiI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1773419511; c=relaxed/simple;
	bh=cEfHniTPRHNGyKRzIFefgTaDIdF6n6+jMAAXqgfMwkQ=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=QeBJVW/MrQck9LfG47t8WqXg5KjmikycoZ8T2OsGBzdoi7q8DXCTNVYPKsKERVtoxF0HuyFyObUkywWRkD7DfE2LS0vWQ+Uy//BsMLJTHsqRqkBxJ9yjeFVX0hSfQM3zc1XcIn6nw8nCBmtawiF5QQh2cKp7W6Zz2HJn3dLyPXo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=a48ExEbV; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="a48ExEbV"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4E60FC19421;
	Fri, 13 Mar 2026 16:31:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1773419511;
	bh=cEfHniTPRHNGyKRzIFefgTaDIdF6n6+jMAAXqgfMwkQ=;
	h=From:To:Cc:Subject:Date:From;
	b=a48ExEbVXARIu10wuBDbAp+Hr0wWJXvT2t13u49x2njhG/LBX/vF3Ai2a1T9r+har
	 34KidRTdKA556x2x/uZxGzQEEGzM/AIqytZ3gzXHHYvFPXE8rDQs3pfwEMekxJ2N5W
	 MZV7YRWjUlpX81cO31pTeeobDtkKetQICBTCTjgmqRdHZ8ZHlPVyCBGdlRjtAwVJr1
	 NDCjlMArwlt3ymqa27KFUbTWo7NVJXejCVzABSSUqMMaQpRq1Sd0qCcfU9R99gYq4m
	 1zCdf2iB9aJFMqq+Ms17zP0nhB7ZACG8eQ0YTNpTmuqcb88ixGJVgZ3sPA+rG9xjR2
	 NCN5zHdwpR91Q==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v7 0/2] NFSD: move accumulated callback ops to per-net namespace
Date: Fri, 13 Mar 2026 12:31:46 -0400
Message-ID: <20260313163148.281676-1-cel@kernel.org>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

In preparation to merge Dai's patch, I've updated it to address
several outstanding review comments.

Base commit: 01b8a53aac4e46f04bcde3049d300ed81479aeb7
---
v2:
  . free memory allocated for nn->nfsd_cb_version4.counts in
    nfsd_net_cb_stats_init() on error in nfsd_net_init().
v3:
  . reword commit message. 
  . fix initialization of nn->nfsd_cb_program.nrvers.
v4:
  . fix merge conflict in nfsd_net_exit in nfsd-testing branch.
v5:
  . restore commit message to the original in v1
v6:
  . put the call nfsd_net_cb_stats_init and nfsd_net_cb_stats_shutdown
    under CONFIG_NFSD_V4.
  . reword commit message to clarify the intention of the patch.
v7:
  . Use proper symbolic constants instead of raw integers
  . Split the .p_statidx change into a pre-requisite patch
  . Add kernel-doc comments to new non-static functions

Chuck Lever (1):
  NFSD: use per-operation statidx for callback procedures

Dai Ngo (1):
  NFSD: convert callback RPC program to per-net namespace

 fs/nfsd/netns.h        |   3 ++
 fs/nfsd/nfs4callback.c | 113 ++++++++++++++++++++++++++++-------------
 fs/nfsd/nfsctl.c       |   5 ++
 fs/nfsd/state.h        |   9 ++++
 4 files changed, 95 insertions(+), 35 deletions(-)

-- 
2.53.0

