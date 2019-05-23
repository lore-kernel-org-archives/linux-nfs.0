Return-Path: <SRS0=OKGc=TX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 719D2C282E1
	for <linux-nfs@archiver.kernel.org>; Thu, 23 May 2019 20:14:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 52FE620881
	for <linux-nfs@archiver.kernel.org>; Thu, 23 May 2019 20:14:08 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2387412AbfEWUOH (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 23 May 2019 16:14:07 -0400
Received: from mx1.redhat.com ([209.132.183.28]:42242 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727001AbfEWUOH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 23 May 2019 16:14:07 -0400
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 2B05B285B4
        for <linux-nfs@vger.kernel.org>; Thu, 23 May 2019 20:14:07 +0000 (UTC)
Received: from f29-node1.dwysocha.net (dhcp145-42.rdu.redhat.com [10.13.145.42])
        by smtp.corp.redhat.com (Postfix) with ESMTP id F370B6012C
        for <linux-nfs@vger.kernel.org>; Thu, 23 May 2019 20:14:06 +0000 (UTC)
From:   Dave Wysochanski <dwysocha@redhat.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] SUNRPC: Use proper printk specifiers for unsigned long long
Date:   Thu, 23 May 2019 16:13:49 -0400
Message-Id: <20190523201351.12232-2-dwysocha@redhat.com>
In-Reply-To: <20190523201351.12232-1-dwysocha@redhat.com>
References: <20190523201351.12232-1-dwysocha@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Thu, 23 May 2019 20:14:07 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Update the printk specifiers inside _print_rpc_iostats to avoid
a checkpatch warning.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 net/sunrpc/stats.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/stats.c b/net/sunrpc/stats.c
index 71166b393732..8b2d3c58ffae 100644
--- a/net/sunrpc/stats.c
+++ b/net/sunrpc/stats.c
@@ -224,7 +224,7 @@ static void _print_rpc_iostats(struct seq_file *seq, struct rpc_iostats *stats,
 			       int op, const struct rpc_procinfo *procs)
 {
 	_print_name(seq, op, procs);
-	seq_printf(seq, "%lu %lu %lu %Lu %Lu %Lu %Lu %Lu\n",
+	seq_printf(seq, "%lu %lu %lu %llu %llu %llu %llu %llu\n",
 		   stats->om_ops,
 		   stats->om_ntrans,
 		   stats->om_timeouts,
-- 
2.20.1

