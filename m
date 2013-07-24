Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:63771 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751579Ab3GXUsN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Jul 2013 16:48:13 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
CC: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFSv4: Fix nfs4_init_uniform_client_string for net namespaces
Date: Wed, 24 Jul 2013 16:48:06 -0400
Message-ID: <1374698886-4395-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 6f2ea7f2a (NFS: Add nfs4_unique_id boot parameter) introduces a
boot parameter that allows client administrators to set a string
identifier for use by the EXCHANGE_ID and SETCLIENTID arguments in order
to make them more globally unique.

Unfortunately, that uniquifier is no longer globally unique in the presence
of net namespaces, since each container expects to be able to set up their
own lease when mounting a new NFSv4/4.1 partition.
The fix is to add back in the container-specific hostname in addition to
the unique id.

Cc: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c2fc5dd..0e64ccc 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4662,10 +4662,14 @@ static unsigned int
 nfs4_init_uniform_client_string(const struct nfs_client *clp,
 				char *buf, size_t len)
 {
-	char *nodename = clp->cl_rpcclient->cl_nodename;
+	const char *nodename = clp->cl_rpcclient->cl_nodename;
 
 	if (nfs4_client_id_uniquifier[0] != '\0')
-		nodename = nfs4_client_id_uniquifier;
+		return scnprintf(buf, len, "Linux NFSv%u.%u %s/%s",
+				clp->rpc_ops->version,
+				clp->cl_minorversion,
+				nfs4_client_id_uniquifier,
+				nodename);
 	return scnprintf(buf, len, "Linux NFSv%u.%u %s",
 				clp->rpc_ops->version, clp->cl_minorversion,
 				nodename);
-- 
1.8.3.1

