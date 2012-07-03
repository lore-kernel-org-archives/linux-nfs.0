Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:19884 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932443Ab2GCNFh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Jul 2012 09:05:37 -0400
Subject: [PATCH v2] NFSd: simplify locking in nfsd_recall_delegations()
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Tue, 03 Jul 2012 17:02:24 +0400
Message-ID: <20120703130215.4035.8190.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v2: rebased on 3.5-rc3 kernel

Holding of client_mutex looks redundant here - recall_lock looks enough.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/nfs4state.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 33eccee..480ecc9 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4622,7 +4622,6 @@ void nfsd_recall_delegations(u64 num)
 	LIST_HEAD(victims);
 	struct nfs4_delegation *dp, *dnext;
 
-	nfs4_lock_state();
 	spin_lock(&recall_lock);
 	count = nfsd_process_n_delegations(num, &victims);
 	list_for_each_entry_safe(dp, dnext, &victims, dl_recall_lru) {
@@ -4630,7 +4629,6 @@ void nfsd_recall_delegations(u64 num)
 		nfsd_break_one_deleg(dp);
 	}
 	spin_unlock(&recall_lock);
-	nfs4_unlock_state();
 
 	printk(KERN_INFO "NFSD: Recalled %d delegations", count);
 }

