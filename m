Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4163 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759724AbZLORz4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Dec 2009 12:55:56 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] nfs41: fix session fore channel negotiation
Date: Tue, 15 Dec 2009 12:55:02 -0500
Message-Id: <1260899702-3651-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

If the rsize or wsize is not set on the mount command, negotiate the highest
supported rsize and wsize in session creation.

Fixes a bug where the client negotiated nfs41_maxwrite_overhead as
ca_maxrequestsize and nfs41_maxread_overhead as ca_maxresponsesize resulting
in NFS4ERR_REQ_TOO_BIG errors on writes.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d44f107..78155de 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4844,14 +4844,22 @@ int nfs4_init_session(struct nfs_server *server)
 {
 	struct nfs_client *clp = server->nfs_client;
 	struct nfs4_session *session;
+	unsigned int rsize, wsize;
 	int ret;
 
 	if (!nfs4_has_session(clp))
 		return 0;
 
+	rsize = server->rsize;
+	if (rsize == 0)
+		rsize = NFS_MAX_FILE_IO_SIZE;
+	wsize = server->wsize;
+	if (wsize == 0)
+		wsize = NFS_MAX_FILE_IO_SIZE;
+
 	session = clp->cl_session;
-	session->fc_attrs.max_rqst_sz = server->wsize + nfs41_maxwrite_overhead;
-	session->fc_attrs.max_resp_sz = server->rsize + nfs41_maxread_overhead;
+	session->fc_attrs.max_rqst_sz = wsize + nfs41_maxwrite_overhead;
+	session->fc_attrs.max_resp_sz = rsize + nfs41_maxread_overhead;
 
 	ret = nfs4_recover_expired_lease(server);
 	if (!ret)
-- 
1.6.0.6

