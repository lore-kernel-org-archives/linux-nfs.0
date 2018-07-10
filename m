Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:33922 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1732454AbeGJS7s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 10 Jul 2018 14:59:48 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.rdu2.redhat.com [10.11.54.4])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id A71D4401DEB9
        for <linux-nfs@vger.kernel.org>; Tue, 10 Jul 2018 18:59:26 +0000 (UTC)
Received: from f27-node1.dwysocha.net (dhcp145-42.rdu.redhat.com [10.13.145.42])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 9F2F52026D6B
        for <linux-nfs@vger.kernel.org>; Tue, 10 Jul 2018 18:59:26 +0000 (UTC)
From: Dave Wysochanski <dwysocha@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/3] sunrpc: Add _add_rpc_iostats() to add rpc_iostats metrics
Date: Tue, 10 Jul 2018 14:59:24 -0400
Message-Id: <20180710185925.4047-3-dwysocha@redhat.com>
In-Reply-To: <20180710185925.4047-1-dwysocha@redhat.com>
References: <20180710185925.4047-1-dwysocha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a helper function to add the metrics in two rpc_iostats structures.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 net/sunrpc/stats.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/net/sunrpc/stats.c b/net/sunrpc/stats.c
index 6606d7b3113a..32adddd7fb78 100644
--- a/net/sunrpc/stats.c
+++ b/net/sunrpc/stats.c
@@ -208,6 +208,18 @@ static void _print_name(struct seq_file *seq, unsigned int op,
 		seq_printf(seq, "\t%12u: ", op);
 }
 
+static void _add_rpc_iostats(struct rpc_iostats *a, struct rpc_iostats *b)
+{
+	a->om_ops += b->om_ops;
+	a->om_ntrans += b->om_ntrans;
+	a->om_timeouts += b->om_timeouts;
+	a->om_bytes_sent += b->om_bytes_sent;
+	a->om_bytes_recv += b->om_bytes_recv;
+	a->om_queue = ktime_add(a->om_queue, b->om_queue);
+	a->om_rtt = ktime_add(a->om_rtt, b->om_rtt);
+	a->om_execute = ktime_add(a->om_execute, b->om_execute);
+}
+
 static void _print_rpc_iostats(struct seq_file *seq, struct rpc_iostats *stats,
 			       int op, const struct rpc_procinfo *procs)
 {
-- 
2.14.3

