Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56193 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756222Ab1AKQVp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Jan 2011 11:21:45 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 09/14] nfsd4: re-probe callback on connection loss
Date: Tue, 11 Jan 2011 11:21:29 -0500
Message-Id: <1294762894-21371-10-git-send-email-bfields@redhat.com>
In-Reply-To: <1294762894-21371-1-git-send-email-bfields@redhat.com>
References: <1294762894-21371-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This makes sure we set the sequence flag when necessary.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 15bd1cc..b24f19d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -642,7 +642,7 @@ static void nfsd4_conn_lost(struct svc_xpt_user *u)
 		free_conn(c);
 	}
 	spin_unlock(&clp->cl_lock);
-	/* XXX: mark callback for update, probe callback */
+	nfsd4_probe_callback(clp);
 }
 
 static struct nfsd4_conn *alloc_conn(struct svc_rqst *rqstp, u32 flags)
-- 
1.7.1

