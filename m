From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 6/8] nfsd4: introduce nfs4_client.cl_refcount
Date: Wed,  5 May 2010 01:44:42 +0300
Message-ID: <1273013082-32533-1-git-send-email-bhalevy@panasas.com>
References: <4BE0A1AE.4040905@panasas.com>
Cc: linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:48768 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934426Ab0EDWoo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 May 2010 18:44:44 -0400
In-Reply-To: <4BE0A1AE.4040905@panasas.com>
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
index cd02567..4b1d39f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -739,8 +739,10 @@ expire_client(struct nfs4_client *clp)
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
@@ -826,6 +828,7 @@ static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir,
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

