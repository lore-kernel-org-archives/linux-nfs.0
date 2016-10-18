Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.130]:55252 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934965AbcJRPV4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Oct 2016 11:21:56 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>,
        Andreas Gruenbacher <agruenba@redhat.com>,
        Andy Adamson <andros@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH] nfs4: fix missing-braces warning
Date: Tue, 18 Oct 2016 17:21:30 +0200
Message-Id: <20161018152141.2774735-1-arnd@arndb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A bugfix introduced a harmless warning for update_open_stateid:

fs/nfs/nfs4proc.c:1548:2: error: missing braces around initializer [-Werror=missing-braces]

Removing the zero in the initializer will do the right thing here
and initialize the entire structure to zero.

Fixes: 1393d9612ba0 ("NFSv4: Fix a race when updating an open_stateid")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ad917bd72b38..7897826d7c51 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1545,7 +1545,7 @@ static int update_open_stateid(struct nfs4_state *state,
 	struct nfs_client *clp = server->nfs_client;
 	struct nfs_inode *nfsi = NFS_I(state->inode);
 	struct nfs_delegation *deleg_cur;
-	nfs4_stateid freeme = {0};
+	nfs4_stateid freeme = { };
 	int ret = 0;
 
 	fmode &= (FMODE_READ|FMODE_WRITE);
-- 
2.9.0

