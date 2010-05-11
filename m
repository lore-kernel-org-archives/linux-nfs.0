From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 6/9] nfsd4: introduce nfs4_client.cl_refcount
Date: Wed, 12 May 2010 00:13:29 +0300
Message-ID: <1273612409-13647-1-git-send-email-bhalevy@panasas.com>
References: <4BE9C7A2.8030801@panasas.com>
Cc: linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:25814 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751621Ab0EKVNb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 May 2010 17:13:31 -0400
In-Reply-To: <4BE9C7A2.8030801@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently just initialize the cl_refcount to 1
and decrement in expire_client(), conditionally freeing the
client when the refcount reaches 0.

To be used later by nfsv4.1 compounds to keep the client from
timing out while in use.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |    5 ++++-
 fs/nfsd/state.h     |    1 +
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index dede43c..295e8d9 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -740,8 +740,10 @@ expire_client(struct nfs4_client *clp)
 	list_del(&clp->cl_strhash);
 	spin_lock(&client_lock);
 	unhash_client_locked(clp);
+	BUG_ON(clp->cl_refcount <= 0);
+	if (--clp->cl_refcount <= 0)
+		free_client(clp);
 	spin_unlock(&client_lock);
-	free_client(clp);
 }
 
 static void copy_verf(struct nfs4_client *target, nfs4_verifier *source)
@@ -827,6 +829,7 @@ static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir,
 	}
 
 	memcpy(clp->cl_recdir, recdir, HEXDIR_LEN);
+	clp->cl_refcount = 1;
 	atomic_set(&clp->cl_cb_set, 0);
 	INIT_LIST_HEAD(&clp->cl_idhash);
 	INIT_LIST_HEAD(&clp->cl_strhash);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 98836fd..09c827d 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -233,6 +233,7 @@ struct nfs4_client {
 	struct nfsd4_clid_slot	cl_cs_slot;	/* create_session slot */
 	u32			cl_exchange_flags;
 	struct nfs4_sessionid	cl_sessionid;
+	int			cl_refcount;	/* use under client_lock */
 
 	/* for nfs41 callbacks */
 	/* We currently support a single back channel with a single slot */
-- 
1.6.5.1

