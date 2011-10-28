Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:54787 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755120Ab1J1GIj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Oct 2011 02:08:39 -0400
From: Jeff Layton <jlayton@redhat.com>
To: rjw@sisk.pl
Cc: trond.myklebust@netapp.com, linux-pm@lists.linux-foundation.org,
        linux-nfs@vger.kernel.org, john@calva.com,
        linux-kernel@vger.kernel.org
Subject: [PATCH 1/2] sunrpc: make rpc_wait_bit_killable handle freeze events
Date: Fri, 28 Oct 2011 02:08:31 -0400
Message-Id: <1319782112-15094-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow the wait_on_bit_killable sleeps in SUNRPC layer to respect the
freezer. This should allow suspend and hibernate events to occur, even
when there are RPC's pending on the wire.

Tested-by: John Hughes <john@Calva.COM>
Acked-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/sched.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index d12ffa5..09bb64e 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -18,6 +18,7 @@
 #include <linux/smp.h>
 #include <linux/spinlock.h>
 #include <linux/mutex.h>
+#include <linux/freezer.h>
 
 #include <linux/sunrpc/clnt.h>
 
@@ -231,7 +232,8 @@ static int rpc_wait_bit_killable(void *word)
 {
 	if (fatal_signal_pending(current))
 		return -ERESTARTSYS;
-	schedule();
+	if (!try_to_freeze())
+		schedule();
 	return 0;
 }
 
-- 
1.7.6.4

