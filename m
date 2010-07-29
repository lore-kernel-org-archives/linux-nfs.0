Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53253 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754888Ab0G2WWh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Jul 2010 18:22:37 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/5] nfsd4: don't pretend to support write delegations
Date: Thu, 29 Jul 2010 18:21:21 -0400
Message-Id: <1280442084-17867-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1280442084-17867-1-git-send-email-bfields@redhat.com>
References: <1280442084-17867-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The delegation code mostly pretends to support either read or write
delegations.  However, correct support for write delegations would
require, for example, breaking of delegations (and/or implementation of
cb_getattr) on stat.  Currently all that stops us from handing out
delegations is a subtle reference-counting issue.

Avoid confusion by adding an earlier check that explicitly refuses write
delegations.

For now, though, I'm not going so far as to rip out existing
half-support for write delegations, in case we get around to using that
soon.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9cc3b78..c07c988 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -170,6 +170,13 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_stateid *stp, struct svc_f
 	struct nfs4_cb_conn *cb = &stp->st_stateowner->so_client->cl_cb_conn;
 
 	dprintk("NFSD alloc_init_deleg\n");
+	/*
+	 * Major work on the lease subsystem (for example, to support
+	 * calbacks on stat) will be required before we can support
+	 * write delegations properly.
+	 */
+	if (type != NFS4_OPEN_DELEGATE_READ)
+		return NULL;
 	if (fp->fi_had_conflict)
 		return NULL;
 	if (num_delegations > max_delegations)
-- 
1.7.0.4

