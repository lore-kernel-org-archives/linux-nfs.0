Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:34698 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932468AbcK1OCy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 28 Nov 2016 09:02:54 -0500
Date: Mon, 28 Nov 2016 09:02:52 -0500
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: fix false positives in nfs40_walk_client_list()
Message-ID: <20161128140252.GA28629@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

It's possible that two different servers can return the same (clientid,
verifier) pair purely by coincidence.  Both are 64-bit values, but
depending on the server implementation, they can be highly predictable
and collisions may be quite likely, especially when there are lots of
servers.

So, check for this case.  If the clientid and verifier both match, then
we actually know they *can't* be the same server, since a new
SETCLIENTID to an already-known server should have changed the verifier.

This helps fix a bug that could cause the client to mount a filesystem
from the wrong server.

Reviewed-by: Jeff Layton <jlayton@redhat.com>
Tested-by: Yongcheng Yang <yoyang@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfs/nfs4client.c | 22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 074ac7131459..5e2747644432 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -464,6 +464,11 @@ static bool nfs4_match_client_owner_id(const struct nfs_client *clp1,
 	return strcmp(clp1->cl_owner_id, clp2->cl_owner_id) == 0;
 }
 
+static bool nfs4_same_verifier(nfs4_verifier *v1, nfs4_verifier *v2)
+{
+	return 0 == memcmp(v1->data, v2->data, sizeof(v1->data));
+}
+
 /**
  * nfs40_walk_client_list - Find server that recognizes a client ID
  *
@@ -521,7 +526,21 @@ int nfs40_walk_client_list(struct nfs_client *new,
 
 		if (!nfs4_match_client_owner_id(pos, new))
 			continue;
-
+		/*
+		 * We just sent a new SETCLIENTID, which should have
+		 * caused the server to return a new cl_confirm.  So if
+		 * cl_confirm is the same, then this is a different
+		 * server that just returned the same cl_confirm by
+		 * coincidence:
+		 */
+		if ((new != pos) && nfs4_same_verifier(&pos->cl_confirm,
+						       &new->cl_confirm))
+			continue;
+		/*
+		 * But if the cl_confirm's are different, then the only
+		 * way that a SETCLIENTID_CONFIRM to pos can succeed is
+		 * if new and pos point to the same server:
+		 */
 		atomic_inc(&pos->cl_count);
 		spin_unlock(&nn->nfs_client_lock);
 
@@ -534,6 +553,7 @@ int nfs40_walk_client_list(struct nfs_client *new,
 			break;
 		case 0:
 			nfs4_swap_callback_idents(pos, new);
+			pos->cl_confirm = new->cl_confirm;
 
 			prev = NULL;
 			*result = pos;
-- 
2.9.3

