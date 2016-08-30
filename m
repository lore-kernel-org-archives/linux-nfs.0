Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7447 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750969AbcH3NUe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 30 Aug 2016 09:20:34 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Subject: [PATCH v2] NFS4: Avoid migration loops
Date: Tue, 30 Aug 2016 09:20:32 -0400
Message-Id: <2d5aa23805b845cff3c28c4d6c71bb06173f0f15.1472563050.git.bcodding@redhat.com>
References: <C654261E-107D-4CB0-A345-E45BC4401F65@redhat.com>
In-Reply-To: <C654261E-107D-4CB0-A345-E45BC4401F65@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Change from v1:
	Use ELOOP rather than EEXIST, and drop the now-redundant comment.

8<-------------------------------------------------------------------------

If a server returns itself as a location while migrating, the client may
end up getting stuck attempting to migrate twice to the same server.  Catch
this by checking if the nfs_client found is the same as the existing
client.  For the other two callers to nfs4_set_client, the nfs_client will
always be ERR_PTR(-EINVAL).

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/nfs4client.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 8d7d08d4f95f..cd3b7cfdde16 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -817,6 +817,11 @@ static int nfs4_set_client(struct nfs_server *server,
 		goto error;
 	}
 
+	if (server->nfs_client == clp) {
+		error = -ELOOP;
+		goto error;
+	}
+
 	/*
 	 * Query for the lease time on clientid setup or renewal
 	 *
-- 
2.5.5

