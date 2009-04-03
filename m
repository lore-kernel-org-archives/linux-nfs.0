From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v3 05/35] nfsd41: introduce nfs4_client cl_sessions list
Date: Fri,  3 Apr 2009 08:27:46 +0300
Message-ID: <1238736466-17233-1-git-send-email-bhalevy@panasas.com>
References: <49D599EA.6060705@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:21912 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753441AbZDCF1v (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Apr 2009 01:27:51 -0400
In-Reply-To: <49D599EA.6060705@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Marc Eshel <eshel@almaden.ibm.com>

[get rid of CONFIG_NFSD_V4_1]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c        |    1 +
 include/linux/nfsd/state.h |    3 +++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8c70f12..b261199 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -528,6 +528,7 @@ static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir)
 	INIT_LIST_HEAD(&clp->cl_strhash);
 	INIT_LIST_HEAD(&clp->cl_openowners);
 	INIT_LIST_HEAD(&clp->cl_delegations);
+	INIT_LIST_HEAD(&clp->cl_sessions);
 	INIT_LIST_HEAD(&clp->cl_lru);
 	return clp;
 }
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index baea7f1..7faefc7 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -163,6 +163,9 @@ struct nfs4_client {
 	struct nfs4_callback	cl_callback;    /* callback info */
 	atomic_t		cl_count;	/* ref count */
 	u32			cl_firststate;	/* recovery dir creation */
+
+	/* for nfs41 */
+	struct list_head	cl_sessions;
 };
 
 /* struct nfs4_client_reset
-- 
1.6.2.1

