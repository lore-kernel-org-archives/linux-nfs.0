From: Andrea Gelmini <andrea.gelmini@gelma.net>
Subject: [PATCH 12/15] net: sunrpc: removed duplicated #include
Date: Thu,  5 Aug 2010 15:51:36 +0200
Message-ID: <1281016299-23958-12-git-send-email-andrea.gelmini@gelma.net>
References: <1281016299-23958-1-git-send-email-andrea.gelmini@gelma.net>
Cc: Andrea Gelmini <andrea.gelmini@gelma.net>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>,
	"David S. Miller" <davem@davemloft.net>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org
To: gelma@gelma.net
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1281016299-23958-1-git-send-email-andrea.gelmini@gelma.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 net/sunrpc/cache.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 58de76c..b75879b 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -34,7 +34,6 @@
 #include <linux/sunrpc/cache.h>
 #include <linux/sunrpc/stats.h>
 #include <linux/sunrpc/rpc_pipe_fs.h>
-#include <linux/smp_lock.h>
 
 #define	 RPCDBG_FACILITY RPCDBG_CACHE
 
-- 
1.7.2.1.85.g2d089

