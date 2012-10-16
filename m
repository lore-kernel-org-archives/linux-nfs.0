Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:15962 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755123Ab2JPQbK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Oct 2012 12:31:10 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 14/25] SUNRPC: remove BUG_ON() from svc_pool_map_set_cpumask()
Date: Tue, 16 Oct 2012 12:30:32 -0400
Message-Id: <1350405043-39316-14-git-send-email-dros@netapp.com>
In-Reply-To: <1350405043-39316-1-git-send-email-dros@netapp.com>
References: <1350405043-39316-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace BUG_ON() with a WARN() and early return.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 net/sunrpc/svc.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 3ee7461..664979b 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -324,7 +324,9 @@ svc_pool_map_set_cpumask(struct task_struct *task, unsigned int pidx)
 	 * The caller checks for sv_nrpools > 1, which
 	 * implies that we've been initialized.
 	 */
-	BUG_ON(m->count == 0);
+	WARN_ON_ONCE(m->count == 0);
+	if (m->count == 0)
+		return;
 
 	switch (m->mode) {
 	case SVC_POOL_PERCPU:
-- 
1.7.9.6 (Apple Git-31.1)

