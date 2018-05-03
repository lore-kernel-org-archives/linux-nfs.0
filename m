Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from usa-sjc-mx-foss1.foss.arm.com ([217.140.101.70]:42328 "EHLO
        foss.arm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750978AbeECNu6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 3 May 2018 09:50:58 -0400
From: Mark Rutland <mark.rutland@arm.com>
To: linux-kernel@vger.kernel.org
Cc: Mark Rutland <mark.rutland@arm.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        "David S . Miller" <davem@davemloft.net>,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Subject: [PATCH RESEND] SUNRPC: fix include for cmpxchg_relaxed()
Date: Thu,  3 May 2018 14:50:50 +0100
Message-Id: <20180503135050.15778-1-mark.rutland@arm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently net/sunrpc/xprtmultipath.c is the only file outside of arch/
headers and asm-generic/ headers to include <asm/cmpxhcg.h>, apparently
for the use of cmpxchg_relaxed().

However, many architectures do not provide cmpxchg_relaxed() in their
<asm/cmpxhcg.h>, and it is necessary to include <linux/atomic.h> to get
this definition, as noted in Documentation/core-api/atomic_ops.rst:

  If someone wants to use xchg(), cmpxchg() and their variants,
  linux/atomic.h should be included rather than asm/cmpxchg.h, unless
  the code is in arch/* and can take care of itself.

Evidently we're getting the right header this via some transitive
include today, but this isn't something we can/should rely upon,
especially with ongoing rework of the atomic headers for KASAN
instrumentation.

Let's fix the code to include <linux/atomic.h>, avoiding fragility.

Signed-off-by: Mark Rutland <mark.rutland@arm.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>
Cc: J. Bruce Fields <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@poochiereds.net>
Cc: David S. Miller <davem@davemloft.net>
Cc: linux-nfs@vger.kernel.org
Cc: netdev@vger.kernel.org
---
 net/sunrpc/xprtmultipath.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

I sent this about a year ago [1], but got no response. This still applies atop
of v4.17-rc3.

I'm currently trying to implement instrumented atomics for arm64, and it would
be great to have this fixed.

Mark.

[1] https://lkml.kernel.org/r/1489574142-20856-1-git-send-email-mark.rutland@arm.com

diff --git a/net/sunrpc/xprtmultipath.c b/net/sunrpc/xprtmultipath.c
index e2d64c7138c3..d897f41be244 100644
--- a/net/sunrpc/xprtmultipath.c
+++ b/net/sunrpc/xprtmultipath.c
@@ -13,7 +13,7 @@
 #include <linux/rcupdate.h>
 #include <linux/rculist.h>
 #include <linux/slab.h>
-#include <asm/cmpxchg.h>
+#include <linux/atomic.h>
 #include <linux/spinlock.h>
 #include <linux/sunrpc/xprt.h>
 #include <linux/sunrpc/addr.h>
-- 
2.11.0

