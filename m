Received: from mgamail.intel.com (mgamail.intel.com [198.175.65.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5BA4235D603;
	Wed,  4 Feb 2026 09:45:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.175.65.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1770198317; cv=none; b=riW/JRkMQqIhR1O9ORdI02erNUV6QzSM0CavGLI81CexKL7jf97ranshy9zmJk5WRYfHjIgOD8yXk2rDYaa+mBcWEcVLKDq3EDoaOli3bjXda4jHargCjHsBOWkM83H9sApIXFettejmZKY6TspHNXZqktu6EqXMSIWAqfPZi3k=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1770198317; c=relaxed/simple;
	bh=oHfyB86S699I2l7vasQsJbgTXIDWhFxuxsXjPxNEoW4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=o+vAzFXTYvaA6yGZGnk1G7A2s7pSnf6XfL/J2zuBMdZ6+FXgIu68CEiNeTD8aFF7rgwFLCPfc4gBX0vABqiNnEpaR+xKqjk/S4M/aD87Qc3nzeY5XnD8IG2Ec2LKnhVULjq7DX3zJKvREUlpER6FwEGqXy23jeMVegZ3hMGVP5I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.intel.com; spf=pass smtp.mailfrom=linux.intel.com; dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b=AIJfgXop; arc=none smtp.client-ip=198.175.65.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.intel.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.intel.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b="AIJfgXop"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1770198317; x=1801734317;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=oHfyB86S699I2l7vasQsJbgTXIDWhFxuxsXjPxNEoW4=;
  b=AIJfgXopIoDOWQa7ZoC0irUr1rxw20rtPY8RxLna82MVqJXeJ0EGflZf
   I+i+6ShUWl/a1Sr9pQRIlh/UXUeKHwKeb7PyWX1exuVmnLu9t8JfYyhUc
   jW9b+TJZRE/bqawXMO4aOfADBh7q5+jZfg7LYGKU10p42vL7el1WTlkWB
   4FyVwCvDLoF2OU67bZxcrxT58lVnecJnal2MBiEnG/GZAWiwMG7Ns/N5X
   MGwZqRq0cfdAeIj0QDOs/8ZuCKJPvYCM1+DpTlKyjSiS2yWo8QulWSfe0
   IQQd2Z5NYwtwPRssAMjF7qsRzUZpRRrXUFsx5dru3WY8FlKPcWOoUuN9z
   Q==;
X-CSE-ConnectionGUID: JYiMKY0iTDSh6iBsd/bhVw==
X-CSE-MsgGUID: IqBepv/ZS+O7Er5lxAfr0w==
X-IronPort-AV: E=McAfee;i="6800,10657,11691"; a="71110493"
X-IronPort-AV: E=Sophos;i="6.21,272,1763452800"; 
   d="scan'208";a="71110493"
Received: from fmviesa005.fm.intel.com ([10.60.135.145])
  by orvoesa112.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 04 Feb 2026 01:45:17 -0800
X-CSE-ConnectionGUID: sAn5l725S82scI/jmHTkNw==
X-CSE-MsgGUID: XP6FcHVqRLuBZCHzy7YxUw==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.21,272,1763452800"; 
   d="scan'208";a="214597136"
Received: from black.igk.intel.com ([10.91.253.5])
  by fmviesa005.fm.intel.com with ESMTP; 04 Feb 2026 01:45:12 -0800
Received: by black.igk.intel.com (Postfix, from userid 1003)
	id 132F198; Wed, 04 Feb 2026 10:45:11 +0100 (CET)
From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Chuck Lever <chuck.lever@oracle.com>,
	NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
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
Subject: [PATCH v2 1/3] nfs/blocklayout: Fix compilation error (`make W=1`) in bl_write_pagelist()
Date: Wed,  4 Feb 2026 10:41:21 +0100
Message-ID: <20260204094500.2443455-2-andriy.shevchenko@linux.intel.com>
X-Mailer: git-send-email 2.50.1
In-Reply-To: <20260204094500.2443455-1-andriy.shevchenko@linux.intel.com>
References: <20260204094500.2443455-1-andriy.shevchenko@linux.intel.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Clang compiler is not happy about set but unused variable
(when dprintk() is no-op):

.../blocklayout/blocklayout.c:384:9: error: variable 'count' set but not used [-Werror,-Wunused-but-set-variable]

Remove a leftover from the previous cleanup.

Fixes: 3a6fd1f004fc ("pnfs/blocklayout: remove read-modify-write handling in bl_write_pagelist")
Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 fs/nfs/blocklayout/blocklayout.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 0e4c67373e4f..83e4a32b3018 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -381,14 +381,13 @@ bl_write_pagelist(struct nfs_pgio_header *header, int sync)
 	sector_t isect, extent_length = 0;
 	struct parallel_io *par = NULL;
 	loff_t offset = header->args.offset;
-	size_t count = header->args.count;
 	struct page **pages = header->args.pages;
 	int pg_index = header->args.pgbase >> PAGE_SHIFT;
 	unsigned int pg_len;
 	struct blk_plug plug;
 	int i;
 
-	dprintk("%s enter, %zu@%lld\n", __func__, count, offset);
+	dprintk("%s enter, %u@%lld\n", __func__, header->args.count, offset);
 
 	/* At this point, header->page_aray is a (sequential) list of nfs_pages.
 	 * We want to write each, and if there is an error set pnfs_error
@@ -429,7 +428,6 @@ bl_write_pagelist(struct nfs_pgio_header *header, int sync)
 		}
 
 		offset += pg_len;
-		count -= pg_len;
 		isect += (pg_len >> SECTOR_SHIFT);
 		extent_length -= (pg_len >> SECTOR_SHIFT);
 	}
-- 
2.50.1

