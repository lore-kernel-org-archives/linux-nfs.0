Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:40260 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753431Ab2EVK27 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 May 2012 06:28:59 -0400
Subject: [PATCH] NFSd: simplify locking in nfsd_recall_delegations()
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Tue, 22 May 2012 14:28:55 +0400
Message-ID: <20120522102839.12440.14555.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Holding of client_mutex looks redundant here - holding of recall_lock looks
enough.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/nfs4state.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f004e61..fdef9fc 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4744,11 +4744,9 @@ void nfsd_recall_delegations(u64 num)
 {
 	unsigned int count;
 
-	nfs4_lock_state();
 	spin_lock(&recall_lock);
 	count = nfsd_process_n_delegations(num, nfsd_break_one_deleg, NULL);
 	spin_unlock(&recall_lock);
-	nfs4_unlock_state();
 
 	printk(KERN_INFO "NFSD: Recalled %d delegations", count);
 }

