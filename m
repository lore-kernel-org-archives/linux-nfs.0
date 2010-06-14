From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 14/15] NFSv41: Cleanup for nfs4_alloc_session.
Date: Mon, 14 Jun 2010 17:51:38 -0400
Message-ID: <1276552299-6625-14-git-send-email-Trond.Myklebust@netapp.com>
References: <1276552299-6625-1-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-2-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-3-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-4-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-5-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-6-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-7-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-8-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-9-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-10-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-11-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-12-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-13-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34599 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756757Ab0FNVvr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jun 2010 17:51:47 -0400
In-Reply-To: <1276552299-6625-13-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is no reason to change the nfs_client state every time we allocate a
new session. Move that line into nfs4_init_client_minor_version.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/client.c   |    7 +++++++
 fs/nfs/nfs4proc.c |    7 -------
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 123fcbd..544810f 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1157,6 +1157,13 @@ static int nfs4_init_client_minor_version(struct nfs_client *clp)
 			return -ENOMEM;
 
 		clp->cl_session = session;
+		/*
+		 * The create session reply races with the server back
+		 * channel probe. Mark the client NFS_CS_SESSION_INITING
+		 * so that the client back channel can find the
+		 * nfs_client struct
+		 */
+		clp->cl_cons_state = NFS_CS_SESSION_INITING;
 	}
 #endif /* CONFIG_NFS_V4_1 */
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e9913de..1245939 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4795,13 +4795,6 @@ struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp)
 	if (!session)
 		return NULL;
 
-	/*
-	 * The create session reply races with the server back
-	 * channel probe. Mark the client NFS_CS_SESSION_INITING
-	 * so that the client back channel can find the
-	 * nfs_client struct
-	 */
-	clp->cl_cons_state = NFS_CS_SESSION_INITING;
 	init_completion(&session->complete);
 
 	tbl = &session->fc_slot_table;
-- 
1.7.0.1

