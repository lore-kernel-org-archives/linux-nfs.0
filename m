Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:51769 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755536Ab2BFU2b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Feb 2012 15:28:31 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] SUNRPC: Change the default limit the number of TCP slots
Date: Mon,  6 Feb 2012 15:28:26 -0500
Message-Id: <1328560106-24066-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1328560106-24066-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1328560106-24066-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since the scheme of limiting the number of TCP slots to whatever will
fit in the current TCP window seems to be working well (Andy reports
getting within 20% of the 'iperf' send performance on a 10GigE link)
we should just let that be the default mode of operation.

Users may still set their own limits using the tcp_max_slot_table_entries
parameter if they need to.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/xprt.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 15518a1..b033f36 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -21,8 +21,8 @@
 
 #define RPC_MIN_SLOT_TABLE	(2U)
 #define RPC_DEF_SLOT_TABLE	(16U)
-#define RPC_MAX_SLOT_TABLE	(128U)
 #define RPC_MAX_SLOT_TABLE_LIMIT	(65536U)
+#define RPC_MAX_SLOT_TABLE	RPC_MAX_SLOT_TABLE_LIMIT
 
 /*
  * This describes a timeout strategy
-- 
1.7.7.6

