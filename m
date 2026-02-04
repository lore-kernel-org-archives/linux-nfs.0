Received: from mgamail.intel.com (mgamail.intel.com [198.175.65.10])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 308CB42B75B;
	Wed,  4 Feb 2026 20:24:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.175.65.10
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1770236690; cv=none; b=SMuMvIssbNB3x2tdUcUwT0s4yg852hwznK+PL+VraR9OZmCCORBrxr66K+wWFrQTUAVBXQBtIrvC3Na04F+n/CLqMb41M0vuozkDuJ8R+YeXdlRw7ncUl1ReNgCsIfl7W99YdwUOpKEzaRW7YkVValXpJInx52ENW5h2JFcr6nw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1770236690; c=relaxed/simple;
	bh=dmqGhAEEjvF2kzN6DSWhxs6/5RKAmacfK4jkDSNWMiA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=dwH2sHv5BuMWQpFf4z08xIU63w95QoRo4pVXmHm4JqKiFuWVdXTKx2MtfVlwW6q9cJrms2VKlyA/Pmy+i5xXiXWNcqpw3LtGW1rfhU+30ECnRZohx4UGfUiyZIJ6XXB6Vmhow29OwtFi1HlapQhGqc9ZH40iqpRHhBqkDDKnfYc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.intel.com; spf=pass smtp.mailfrom=linux.intel.com; dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b=L/8YhKye; arc=none smtp.client-ip=198.175.65.10
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.intel.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.intel.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b="L/8YhKye"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1770236691; x=1801772691;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=dmqGhAEEjvF2kzN6DSWhxs6/5RKAmacfK4jkDSNWMiA=;
  b=L/8YhKye2lVRTceLs88/AZrXo6W37rrl1soFUhAZd91SLEkoJxazdE/7
   9fI/audasb/ZsulltsHzZLNToHFRr25/rxvAd8ykxfwvWbjbLDKpd9XE+
   kDalk9ad24qtf81bdml8JY/psY7zcZrblQU81nWKMgTEc/jorqm7aEsC7
   hm9GgpYgjhZueE7LxL4GeA8mvWwSAhw766qP7LdnVIOgO72TpbLrgad1+
   oRQeimSdRyRq6kk94gwnWhSU5762fWirioNfVQnCC/OlNBWOujkBN1qiL
   vxY/SJM7vHfoujtWK6yUbk3ZVSmMSCrekrGLZ3AejskFxh38vlYHhMefz
   Q==;
X-CSE-ConnectionGUID: rYDvZRrTS3yKcO3r6xxOOg==
X-CSE-MsgGUID: bju1qxuoRISkpFUVCsC/4g==
X-IronPort-AV: E=McAfee;i="6800,10657,11691"; a="88853940"
X-IronPort-AV: E=Sophos;i="6.21,273,1763452800"; 
   d="scan'208";a="88853940"
Received: from orviesa010.jf.intel.com ([10.64.159.150])
  by orvoesa102.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 04 Feb 2026 12:24:50 -0800
X-CSE-ConnectionGUID: x+h0fAG4QPK0eHuzGvDJAA==
X-CSE-MsgGUID: TWFc+xevSK6eAz+iEoq87g==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.21,273,1763452800"; 
   d="scan'208";a="209567817"
Received: from black.igk.intel.com ([10.91.253.5])
  by orviesa010.jf.intel.com with ESMTP; 04 Feb 2026 12:24:45 -0800
Received: by black.igk.intel.com (Postfix, from userid 1003)
	id 867CF9B; Wed, 04 Feb 2026 21:24:43 +0100 (CET)
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
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH v3 3/3] sunrpc: Fix compilation error (`make W=1`) when dprintk() is no-op
Date: Wed,  4 Feb 2026 21:21:51 +0100
Message-ID: <20260204202437.2762161-4-andriy.shevchenko@linux.intel.com>
X-Mailer: git-send-email 2.50.1
In-Reply-To: <20260204202437.2762161-1-andriy.shevchenko@linux.intel.com>
References: <20260204202437.2762161-1-andriy.shevchenko@linux.intel.com>
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
Acked-by: Geert Uytterhoeven <geert+renesas@glider.be>
Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 fs/lockd/svclock.c           | 5 +++++
 include/linux/sunrpc/debug.h | 8 ++++++--
 include/linux/sunrpc/sched.h | 3 ---
 3 files changed, 11 insertions(+), 5 deletions(-)

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
index e947d668f7b7..82239d5c262e 100644
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
@@ -48,13 +50,15 @@ do {									\
 		rcu_read_lock();					\
 		__sunrpc_printk(fmt, ##__VA_ARGS__);			\
 		rcu_read_unlock();					\
+	} else {							\
+		no_printk(fmt, ##__VA_ARGS__);				\
 	}								\
 } while (0)
 
 #else
 # define ifdebug(fac)		if (0)
-# define dfprintk(fac, fmt, ...)	do {} while (0)
-# define dfprintk_rcu(fac, fmt, ...)	do {} while (0)
+# define dfprintk(fac, fmt, ...)	no_printk(fmt, ##__VA_ARGS__)
+# define dfprintk_rcu(fac, fmt, ...)	no_printk(fmt, ##__VA_ARGS__)
 #endif
 
 /*
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index ccba79ebf893..0dbdf3722537 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -95,10 +95,7 @@ struct rpc_task {
 	int			tk_rpc_status;	/* Result of last RPC operation */
 	unsigned short		tk_flags;	/* misc flags */
 	unsigned short		tk_timeouts;	/* maj timeouts */
-
-#if IS_ENABLED(CONFIG_SUNRPC_DEBUG) || IS_ENABLED(CONFIG_TRACEPOINTS)
 	unsigned short		tk_pid;		/* debugging aid */
-#endif
 	unsigned char		tk_priority : 2,/* Task priority */
 				tk_garb_retry : 2,
 				tk_cred_retry : 2;
-- 
2.50.1

