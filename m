Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f175.google.com ([209.85.223.175]:49812 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751294AbbACVKD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Jan 2015 16:10:03 -0500
Received: by mail-ie0-f175.google.com with SMTP id x19so18051877ier.34
        for <linux-nfs@vger.kernel.org>; Sat, 03 Jan 2015 13:10:02 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 3/4] NFSv4/v4.1: Verify the client owner id during trunking detection
Date: Sat,  3 Jan 2015 16:09:56 -0500
Message-Id: <1420319397-37704-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1420319397-37704-2-git-send-email-trond.myklebust@primarydata.com>
References: <1420319397-37704-1-git-send-email-trond.myklebust@primarydata.com>
 <1420319397-37704-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

While we normally expect the NFSv4 client to always send the same client
owner to all servers, there are a couple of situations where that is not
the case:
 1) In NFSv4.0, switching between use of '-omigration' and not will cause
    the kernel to switch between using the non-uniform and uniform client
    strings.
 2) In NFSv4.1, or NFSv4.0 when using uniform client strings, if the
    uniquifier string is suddenly changed.

This patch will catch those situations by checking the client owner id
in the trunking detection code, and will do the right thing if it notices
that the strings differ.

Cc: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4client.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 6ee9bf69a7a6..b1024bcc65c8 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -453,6 +453,14 @@ static void nfs4_swap_callback_idents(struct nfs_client *keep,
 	spin_unlock(&nn->nfs_client_lock);
 }
 
+static bool nfs4_match_client_owner_id(const struct nfs_client *clp1,
+		const struct nfs_client *clp2)
+{
+	if (clp1->cl_owner_id == NULL || clp2->cl_owner_id == NULL)
+		return true;
+	return strcmp(clp1->cl_owner_id, clp2->cl_owner_id) == 0;
+}
+
 /**
  * nfs40_walk_client_list - Find server that recognizes a client ID
  *
@@ -511,6 +519,9 @@ int nfs40_walk_client_list(struct nfs_client *new,
 		if (pos->cl_clientid != new->cl_clientid)
 			continue;
 
+		if (!nfs4_match_client_owner_id(pos, new))
+			continue;
+
 		atomic_inc(&pos->cl_count);
 		spin_unlock(&nn->nfs_client_lock);
 
@@ -657,6 +668,13 @@ int nfs41_walk_client_list(struct nfs_client *new,
 		if (!nfs4_check_clientid_trunking(pos, new))
 			continue;
 
+		/* Unlike NFSv4.0, we know that NFSv4.1 always uses the
+		 * uniform string, however someone might switch the
+		 * uniquifier string on us.
+		 */
+		if (!nfs4_match_client_owner_id(pos, new))
+			continue;
+
 		atomic_inc(&pos->cl_count);
 		*result = pos;
 		status = 0;
-- 
2.1.0

