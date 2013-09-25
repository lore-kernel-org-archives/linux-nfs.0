Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:57258 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755291Ab3IYVDL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Sep 2013 17:03:11 -0400
From: <bjschuma@netapp.com>
To: <Trond.Myklebust@netapp.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFS: Give "flavor" an initial value to fix a compile warning
Date: Wed, 25 Sep 2013 17:02:48 -0400
Message-ID: <1380142968-9515-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <bjschuma@netapp.com>

cd3c993 introduces a compile warning by not assigning an initial value
to the "flavor" variable.  This could only be a problem if the server
returns a supported secflavor list of length zero, but it's better to
fix this before it's ever hit.

Signed-off-by: Anna Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f5fe16b..d53d678 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7576,7 +7576,7 @@ nfs41_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
 {
 	int err;
 	struct page *page;
-	rpc_authflavor_t flavor;
+	rpc_authflavor_t flavor = RPC_AUTH_MAXFLAVOR;
 	struct nfs4_secinfo_flavors *flavors;
 	struct nfs4_secinfo4 *secinfo;
 	int i;
-- 
1.8.4

