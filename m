Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ED05426CE05;
	Fri, 13 Mar 2026 19:42:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1773430925; cv=none; b=gn2GUyMvRsG30CmpiUfoTFA6q85QwH7i4dWQjoMOa6LTx/3bkmoPn6eSR4VInmc4XvixKs2fQguU6uVVCTHeUfXxJ9C+y/61TICT9M7XE7G068qRzlsGgjkMu1RtYczLvhVV1FslQPsWFdqmqqv9XHv9kWzJ/aHilArjEwuJM9I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1773430925; c=relaxed/simple;
	bh=B+tBDeIq1ucND5RdTgJ0CmmB32Gi1eYZUWFiAQWHNPg=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=BepTj71LdI4mOIDgxqOS1jq/1FjB7dU1M+Ou0aYaJNPcZUjSdArG+AaXRPi3qBMBSHrk7jt9mPaOW2VaWjZYCASIYkxvfXNv/cX3tGTRTNsPUtt87qiY9lTHqK5Is9z9pv5z/o28qL+erbv/UlH+O3ZTgf4gCKYaqCHwljKt0RY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=oIOqnpic; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="oIOqnpic"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9D5A6C19421;
	Fri, 13 Mar 2026 19:42:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1773430924;
	bh=B+tBDeIq1ucND5RdTgJ0CmmB32Gi1eYZUWFiAQWHNPg=;
	h=From:To:Cc:Subject:Date:From;
	b=oIOqnpic+ILManY8GehCAZZy/zAZY/3O3NnCL9EENIdmdvr7S9+/qr+RtbD+/PbuP
	 H4ITAje6MB9b6oEhAljjg73uZZdzLqOFAuvYWKgNZeJ5zTSEMq+T16UkA1IjinR6jB
	 kItCjDVaFkBEKwf4bNAKYhOuiwBavy4PvxqPXYUiieftmj0BWsD6eiu4UyuHksMVzR
	 jWfVSP9QNHWVeZYXGLX0gbaCbQRULYNzYpsjx8Nn+5AjhgSUuQ32rc1nnmwSy248Q1
	 TALLecrqGq684QM3Lm7AvAQ6ygdRNUoAqlB9KB8Mu+dDMSlKY4/vv1veLcbkbiFO76
	 0/r4iE9gKjabA==
From: Chuck Lever <cel@kernel.org>
To: Leon Romanovsky <leon@kernel.org>,
	Christoph Hellwig <hch@lst.de>,
	NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v3 0/4] RDMA/rw: Fix MR pool exhaustion in bvec RDMA READ path
Date: Fri, 13 Mar 2026 15:41:57 -0400
Message-ID: <20260313194201.5818-1-cel@kernel.org>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

This series now carries two MR exhaustion fixes and a proposal for
using contiguous pages for RDMA Read sink buffers in svcrdma.

Fixes for the MR exhaustion issues should go into 7.0-rc and stable,
and the contiguous page patches can wait for the next merge window.

Base commit: v7.0-rc3
---
Changes since v2:
- Fix similar exhaustion issue for SGL
- Add patch that introduces svc_rqst_page_release

Changes since v1:
- Clarify code comments
- Allocate contiguous pages for RDMA Read sink buffers

Chuck Lever (4):
  RDMA/rw: Fall back to direct SGE on MR pool exhaustion
  RDMA/rw: Fix MR pool exhaustion in bvec RDMA READ path
  SUNRPC: Add svc_rqst_page_release() helper
  svcrdma: Use contiguous pages for RDMA Read sink buffers

 drivers/infiniband/core/rw.c      |  43 ++++--
 include/linux/sunrpc/svc.h        |  15 ++
 net/sunrpc/svc.c                  |   7 +-
 net/sunrpc/svcsock.c              |   2 +-
 net/sunrpc/xprtrdma/svc_rdma_rw.c | 220 ++++++++++++++++++++++++++++++
 5 files changed, 268 insertions(+), 19 deletions(-)

-- 
2.53.0

