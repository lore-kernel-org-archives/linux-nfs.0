From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 38/39] nfs41: Backchannel: New find_client_with_session()
Date: Fri,  1 May 2009 02:25:40 +0300
Message-ID: <1241133940-1555-1-git-send-email-bhalevy@panasas.com>
References: <49FA3180.5030404@panasas.com>
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:4214 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755468AbZD3XZr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 19:25:47 -0400
In-Reply-To: <49FA3180.5030404@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

Finds the 'struct nfs_client' that matches the server's address, major
version number, and session ID.

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback_proc.c |   36 ++++++++++++++++++++++++++++++++++++
 1 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index f731bbe..6b342e8 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -104,6 +104,42 @@ out:
 
 #if defined(CONFIG_NFS_V4_1)
 
+/*
+ * Returns a pointer to a held 'struct nfs_client' that matches the server's
+ * address, major version number, and session ID.  It is the caller's
+ * responsibility to release the returned reference.
+ *
+ * Returns NULL if there are no connections with sessions, or if no session
+ * matches the one of interest.
+ */
+ static struct nfs_client *find_client_with_session(
+	const struct sockaddr *addr, u32 nfsversion,
+	struct nfs4_sessionid *sessionid)
+{
+	struct nfs_client *clp;
+
+	clp = nfs_find_client(addr, 4);
+	if (clp == NULL)
+		return NULL;
+
+	do {
+		struct nfs_client *prev = clp;
+
+		if (clp->cl_session != NULL) {
+			if (memcmp(clp->cl_session->sess_id.data,
+					sessionid->data,
+					NFS4_MAX_SESSIONID_LEN) == 0) {
+				/* Returns a held reference to clp */
+				return clp;
+			}
+		}
+		clp = nfs_find_client_next(prev);
+		nfs_put_client(prev);
+	} while (clp != NULL);
+
+	return NULL;
+}
+
 /* FIXME: validate args->cbs_{sequence,slot}id */
 /* FIXME: referring calls should be processed */
 unsigned nfs4_callback_sequence(struct cb_sequenceargs *args,
-- 
1.6.2.1

