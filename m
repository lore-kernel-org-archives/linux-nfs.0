Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60644 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760902Ab2EWVkn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 May 2012 17:40:43 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 10/10] nfsd4: clarify that renewing expired client is a bug
Date: Wed, 23 May 2012 17:40:40 -0400
Message-Id: <1337809240-15770-11-git-send-email-bfields@redhat.com>
In-Reply-To: <1337809240-15770-1-git-send-email-bfields@redhat.com>
References: <1337809240-15770-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

This can't happen:
	- cl_time is zeroed only by unhash_client_locked, which is only
	  ever called under both the state lock and the client lock.
	- every caller of renew_client() should have looked up a
	  (non-expired) client and then called renew_client() all
	  without dropping the state lock.
	- the only other caller of renew_client_locked() is
	  release_session_client(), which first checks under the
	  client_lock that the cl_time is nonzero.

So make it clear that this is a bug, not something we handle.  I can't
quite bring myself to make this a BUG(), though, as there are a lot of
renew_client() callers, and returning here is probably safer than a
BUG().

We'll consider making it a BUG() after some more cleanup.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 72bc277..be1fc97 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1022,7 +1022,8 @@ static inline void
 renew_client_locked(struct nfs4_client *clp)
 {
 	if (is_client_expired(clp)) {
-		dprintk("%s: client (clientid %08x/%08x) already expired\n",
+		WARN_ON(1);
+		printk("%s: client (clientid %08x/%08x) already expired\n",
 			__func__,
 			clp->cl_clientid.cl_boot,
 			clp->cl_clientid.cl_id);
-- 
1.7.9.5

