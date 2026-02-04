Received: from mgamail.intel.com (mgamail.intel.com [198.175.65.21])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ACC6D42982B;
	Wed,  4 Feb 2026 20:24:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.175.65.21
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1770236690; cv=none; b=LcJkr4n7TMRAzrR1uWcyBpV8XjOowh/3VvFord6M/PkxfYXiIaTa8rQtG4rW8uY1jJkdLc54BUV365GLEG4L1Ok+wLYuMRA4tR7cDg/RFQEiGNop/pqWhUqd0gN/6UKB1r26FsoGeXYyo7ocYtt/l2E+QC3NaaNtFz371kgd6tw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1770236690; c=relaxed/simple;
	bh=T/dcOdL7PdKPM1aTApTKDAXOtzj4TI4M3Q4ie+c+VSQ=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=nnjon9VUrqcR/Y7S6TvlP22IkvWDyUCMx93CfrIVUDXVx0NPeq0rGDg+TtbYAoWhu/9gBClKNwkxFPCtkdLEpXaNwyfH2R/dkIJo+YNKLNeB611Y5MpZRLLnXSDW6GBaaImxK90M4S7V5wzVaoi8HyjXYy1oOOkcyy1d6+yv2Rc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.intel.com; spf=pass smtp.mailfrom=linux.intel.com; dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b=mAXpVD0Z; arc=none smtp.client-ip=198.175.65.21
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.intel.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.intel.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b="mAXpVD0Z"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1770236690; x=1801772690;
  h=from:to:cc:subject:date:message-id:mime-version:
   content-transfer-encoding;
  bh=T/dcOdL7PdKPM1aTApTKDAXOtzj4TI4M3Q4ie+c+VSQ=;
  b=mAXpVD0ZON+4i0lLMWkJrSBzttOuZkPClo2B+9DNb7FZqm7LyuBKaDK2
   7PRCr52RhEsWWDvs/wiEJZW32sgWTBsJozwVxsKZiOCovKpCTuQu1c4Hn
   ioMDx3Bh/4Hb1WvfiO4LaztscMk6l8AzEepCRZuYWMqCjNKdwHNX6k8fs
   WxuNs7QcqCTS8aL9VF70og4o3MNSaHfU74N12oqbjHUOmZxticdXuQ6nV
   1j0vQDsjqVYhFwb4I1f9Ak7vMXridYrM+cHv8RXXVKK8XVkMgt6fyVH4J
   hMyt8wwOg94TWU7SS88ZjrY1hmwkBnFZVbbi/5IaDOUY34EinKsXOmfXB
   w==;
X-CSE-ConnectionGUID: 4sWStrhyR/GV6Bt3lgReqw==
X-CSE-MsgGUID: evKBdHrcQ1+iFO9UY35ryw==
X-IronPort-AV: E=McAfee;i="6800,10657,11691"; a="71335489"
X-IronPort-AV: E=Sophos;i="6.21,273,1763452800"; 
   d="scan'208";a="71335489"
Received: from orviesa009.jf.intel.com ([10.64.159.149])
  by orvoesa113.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 04 Feb 2026 12:24:49 -0800
X-CSE-ConnectionGUID: +A/vSLIwQaeyrCWARic52Q==
X-CSE-MsgGUID: AgJQ4IMgQBGw2VwgkEsHAg==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.21,273,1763452800"; 
   d="scan'208";a="210051957"
Received: from black.igk.intel.com ([10.91.253.5])
  by orviesa009.jf.intel.com with ESMTP; 04 Feb 2026 12:24:45 -0800
Received: by black.igk.intel.com (Postfix, from userid 1003)
	id 794E595; Wed, 04 Feb 2026 21:24:43 +0100 (CET)
From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	llvm@lists.linux.dev
Cc: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Simon Horman <horms@kernel.org>,
	Nathan Chancellor <nathan@kernel.org>,
	Nick Desaulniers <nick.desaulniers+lkml@gmail.com>,
	Bill Wendling <morbo@google.com>,
	Justin Stitt <justinstitt@google.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v3 0/3] sunrpc: Fix `make W=1` build issues
Date: Wed,  4 Feb 2026 21:21:48 +0100
Message-ID: <20260204202437.2762161-1-andriy.shevchenko@linux.intel.com>
X-Mailer: git-send-email 2.50.1
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Compiler is not happy about unused variables (especially when
dprintk() call is defined as no-op). Here is the series to
address the issues.

Changelog v3:
- removed ifdeffery to have struct rpc_task::tk_pid available (LKP)
- collected more tags (Anna, Jeff)

v2: 20260204094500.2443455-1-andriy.shevchenko@linux.intel.com

Changelog v2:
- added patch to kill RPC_IFDEBUG() macro (LKP, Geert)
- united separate patches in the series
- collected tags (Geert)

v1: 20260204010402.2149563-1-andriy.shevchenko@linux.intel.com
v1: 20260204010415.2149607-1-andriy.shevchenko@linux.intel.com

Andy Shevchenko (3):
  nfs/blocklayout: Fix compilation error (`make W=1`) in
    bl_write_pagelist()
  sunrpc: Kill RPC_IFDEBUG()
  sunrpc: Fix compilation error (`make W=1`) when dprintk() is no-op

 fs/lockd/svclock.c                       |  5 +++++
 fs/nfs/blocklayout/blocklayout.c         |  4 +---
 fs/nfsd/nfsfh.c                          |  9 +++++---
 include/linux/sunrpc/debug.h             | 10 +++++----
 include/linux/sunrpc/sched.h             |  3 ---
 net/sunrpc/xprtrdma/svc_rdma_transport.c | 27 ++++++++++++------------
 6 files changed, 32 insertions(+), 26 deletions(-)

-- 
2.50.1

