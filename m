Received: from mgamail.intel.com (mgamail.intel.com [192.198.163.7])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 29DFA21ABB9;
	Wed,  4 Feb 2026 01:04:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=192.198.163.7
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1770167066; cv=none; b=SyGhNln9zkf7nony/CY9GeFMdb+OoriMATEfUaR7zt4tGNvBbtBRfr8OXbPWTTl0KCshv25YUhX9qEjIXfJYW82zSIyRHAkDZKJl2UPty3w4vOIbn8stwl69yzrgwxolUCgVAc9pUiSM3TnkD+FGxf6QF6haLCdyEkewS3RJHgw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1770167066; c=relaxed/simple;
	bh=tT1hnwTqOAd5aF07+Vx5aa7HpTZUz7Q9k3tfQZICrcM=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=CU4Nr1yCVVpEGftztg1oUtkLgfSgDMQdagcKxr/2d/jgNKQiKV4gikksMrkvjvWWz8oH9d+U/5iZ5VxY8zmyKvwXy1a1YBeP3hGAUjfLKmiRWnSBlNRI9/55K0U8ZprhnIze7DO/xcqSY9s81VmEKwAgLGqVREr0m3+0GsiJ7TI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.intel.com; spf=pass smtp.mailfrom=linux.intel.com; dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b=VqUB/UDq; arc=none smtp.client-ip=192.198.163.7
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.intel.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.intel.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b="VqUB/UDq"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1770167065; x=1801703065;
  h=from:to:cc:subject:date:message-id:mime-version:
   content-transfer-encoding;
  bh=tT1hnwTqOAd5aF07+Vx5aa7HpTZUz7Q9k3tfQZICrcM=;
  b=VqUB/UDqyHHiRZPho+Ypn5I4Vl3cV5XT5BSftb6nj5rkDGlyt1HK87HE
   NMhXMM3x1d4P1iPeDsi000XSES07tb7g63Jh9bfTCqGLXh0wLFw99rWqJ
   pHdg2uTVpKN2niQZ9ktv935FwDNh5fUzsiXjLHkqG8RtUchyWroUVmo64
   QyJndLws2mgLfBvxQytBvg+VE0w608+v5Ywy8XULPg7GmVfalZx5WMamR
   +cSDsm+0gSReEVVTvVszEBoY7p+2HKwalD4S3OWsMLiKr5DNrHTAklYWF
   jXVn+RtS3P2CvaO5mgmqGZYyr6Ku7+oZrg81Gh8G5bzUv7xZt9LoOFASP
   Q==;
X-CSE-ConnectionGUID: 97o88Jn+RGKsYKPnjlLBZA==
X-CSE-MsgGUID: a80pWwj7TQa0wBR+g0NDsA==
X-IronPort-AV: E=McAfee;i="6800,10657,11691"; a="96805000"
X-IronPort-AV: E=Sophos;i="6.21,271,1763452800"; 
   d="scan'208";a="96805000"
Received: from orviesa004.jf.intel.com ([10.64.159.144])
  by fmvoesa101.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 03 Feb 2026 17:04:24 -0800
X-CSE-ConnectionGUID: CRH29FtiScaEQl3Anu25jA==
X-CSE-MsgGUID: 0KtCuMRSTjSrbDl2kdSAxA==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.21,271,1763452800"; 
   d="scan'208";a="214556544"
Received: from black.igk.intel.com ([10.91.253.5])
  by orviesa004.jf.intel.com with ESMTP; 03 Feb 2026 17:04:21 -0800
Received: by black.igk.intel.com (Postfix, from userid 1003)
	id CE84095; Wed, 04 Feb 2026 02:04:19 +0100 (CET)
From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Chuck Lever <chuck.lever@oracle.com>,
	NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	llvm@lists.linux.dev
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Nathan Chancellor <nathan@kernel.org>,
	Nick Desaulniers <nick.desaulniers+lkml@gmail.com>,
	Bill Wendling <morbo@google.com>,
	Justin Stitt <justinstitt@google.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v1 1/1] sunrpc: Fix compilation error (`make W=1`) when dprintk() is no-op
Date: Wed,  4 Feb 2026 02:04:15 +0100
Message-ID: <20260204010415.2149607-1-andriy.shevchenko@linux.intel.com>
X-Mailer: git-send-email 2.50.1
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Clang compiler is not happy about set but unused variables:

.../flexfilelayout/flexfilelayoutdev.c:56:9: error: variable 'ret' set but not used [-Werror,-Wunused-but-set-variable]
.../flexfilelayout/flexfilelayout.c:1505:6: error: variable 'err' set but not used [-Werror,-Wunused-but-set-variable]
.../nfs4proc.c:9244:12: error: variable 'ptr' set but not used [-Werror,-Wunused-but-set-variable]

Fix these by forwarding parameters of dprintk() to no_printk().
The positive side-effect is a format-string checker enabled even for the cases
when dprintk() is no-op.

Fixes: d67ae825a59d ("pnfs/flexfiles: Add the FlexFile Layout Driver")
Fixes: fc931582c260 ("nfs41: create_session operation")
Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 fs/lockd/svclock.c           | 5 +++++
 include/linux/sunrpc/debug.h | 8 ++++++--
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index 712df1e025d8..dcd3e0b4d997 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -80,6 +80,11 @@ static const char *nlmdbg_cookie2a(const struct nlm_cookie *cookie)
 
 	return buf;
 }
+#else
+static inline const char *nlmdbg_cookie2a(const struct nlm_cookie *cookie)
+{
+	return "???";
+}
 #endif
 
 /*
diff --git a/include/linux/sunrpc/debug.h b/include/linux/sunrpc/debug.h
index 891f6173c951..070b2d20191b 100644
--- a/include/linux/sunrpc/debug.h
+++ b/include/linux/sunrpc/debug.h
@@ -40,6 +40,8 @@ extern unsigned int		nlm_debug;
 do {									\
 	ifdebug(fac)							\
 		__sunrpc_printk(fmt, ##__VA_ARGS__);			\
+	else								\
+		no_printk(fmt, ##__VA_ARGS__);				\
 } while (0)
 
 # define dfprintk_rcu(fac, fmt, ...)					\
@@ -48,14 +50,16 @@ do {									\
 		rcu_read_lock();					\
 		__sunrpc_printk(fmt, ##__VA_ARGS__);			\
 		rcu_read_unlock();					\
+	} else {							\
+		no_printk(fmt, ##__VA_ARGS__);				\
 	}								\
 } while (0)
 
 # define RPC_IFDEBUG(x)		x
 #else
 # define ifdebug(fac)		if (0)
-# define dfprintk(fac, fmt, ...)	do {} while (0)
-# define dfprintk_rcu(fac, fmt, ...)	do {} while (0)
+# define dfprintk(fac, fmt, ...)	no_printk(fmt, ##__VA_ARGS__)
+# define dfprintk_rcu(fac, fmt, ...)	no_printk(fmt, ##__VA_ARGS__)
 # define RPC_IFDEBUG(x)
 #endif
 
-- 
2.50.1

