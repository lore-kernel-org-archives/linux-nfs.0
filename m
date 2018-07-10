Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:37538 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1732378AbeGJS7s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 10 Jul 2018 14:59:48 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.rdu2.redhat.com [10.11.54.4])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id A003E818F03C
        for <linux-nfs@vger.kernel.org>; Tue, 10 Jul 2018 18:59:26 +0000 (UTC)
Received: from f27-node1.dwysocha.net (dhcp145-42.rdu.redhat.com [10.13.145.42])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 975CF2026D76
        for <linux-nfs@vger.kernel.org>; Tue, 10 Jul 2018 18:59:26 +0000 (UTC)
From: Dave Wysochanski <dwysocha@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/3] sunrpc: add _print_rpc_iostats() to output metrics for one RPC op
Date: Tue, 10 Jul 2018 14:59:23 -0400
Message-Id: <20180710185925.4047-2-dwysocha@redhat.com>
In-Reply-To: <20180710185925.4047-1-dwysocha@redhat.com>
References: <20180710185925.4047-1-dwysocha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Refactor the output of the metrics for one RPC op into an internal
function.  No functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 net/sunrpc/stats.c | 27 ++++++++++++++++-----------
 1 file changed, 16 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/stats.c b/net/sunrpc/stats.c
index f68aa46c9dd7..6606d7b3113a 100644
--- a/net/sunrpc/stats.c
+++ b/net/sunrpc/stats.c
@@ -208,6 +208,21 @@ static void _print_name(struct seq_file *seq, unsigned int op,
 		seq_printf(seq, "\t%12u: ", op);
 }
 
+static void _print_rpc_iostats(struct seq_file *seq, struct rpc_iostats *stats,
+			       int op, const struct rpc_procinfo *procs)
+{
+	_print_name(seq, op, procs);
+	seq_printf(seq, "%lu %lu %lu %Lu %Lu %Lu %Lu %Lu\n",
+		   stats->om_ops,
+		   stats->om_ntrans,
+		   stats->om_timeouts,
+		   stats->om_bytes_sent,
+		   stats->om_bytes_recv,
+		   ktime_to_ms(stats->om_queue),
+		   ktime_to_ms(stats->om_rtt),
+		   ktime_to_ms(stats->om_execute));
+}
+
 void rpc_print_iostats(struct seq_file *seq, struct rpc_clnt *clnt)
 {
 	struct rpc_iostats *stats = clnt->cl_metrics;
@@ -229,17 +244,7 @@ void rpc_print_iostats(struct seq_file *seq, struct rpc_clnt *clnt)
 
 	seq_printf(seq, "\tper-op statistics\n");
 	for (op = 0; op < maxproc; op++) {
-		struct rpc_iostats *metrics = &stats[op];
-		_print_name(seq, op, clnt->cl_procinfo);
-		seq_printf(seq, "%lu %lu %lu %Lu %Lu %Lu %Lu %Lu\n",
-				metrics->om_ops,
-				metrics->om_ntrans,
-				metrics->om_timeouts,
-				metrics->om_bytes_sent,
-				metrics->om_bytes_recv,
-				ktime_to_ms(metrics->om_queue),
-				ktime_to_ms(metrics->om_rtt),
-				ktime_to_ms(metrics->om_execute));
+		_print_rpc_iostats(seq, &stats[op], op, clnt->cl_procinfo);
 	}
 }
 EXPORT_SYMBOL_GPL(rpc_print_iostats);
-- 
2.14.3

