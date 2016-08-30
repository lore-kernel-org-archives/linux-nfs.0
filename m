Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39158 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757773AbcH3LNy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 30 Aug 2016 07:13:54 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Subject: [PATCH] NFS4: Avoid migration loops
Date: Tue, 30 Aug 2016 07:13:51 -0400
Message-Id: <C654261E-107D-4CB0-A345-E45BC4401F65@redhat.com>
In-Reply-To: <5BAC7822-0023-4A20-A896-A353483E75C2@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a server returns itself as a location while migrating the client may
end up getting stuck attempting to migrate twice to the same server.  Catch
this by checking if the nfs_client found is the same as the existing
client.  For the other two callers to nfs4_set_client, the nfs_client will
always be ERR_PTR(-EINVAL);

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/nfs4client.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 8d7d08d4f95f..ec8afc43d849 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -817,6 +817,12 @@ static int nfs4_set_client(struct nfs_server *server,
 		goto error;
 	}
 
+	/* This client is already set, is there a migration loop? */
+	if (server->nfs_client == clp) {
+		error = -EEXIST;
+		goto error;
+	}
+
 	/*
 	 * Query for the lease time on clientid setup or renewal
 	 *
-- 
2.5.5

