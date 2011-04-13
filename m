Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5315 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757042Ab1DMSbe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Apr 2011 14:31:34 -0400
Message-ID: <4DA5EC01.3010704@netapp.com>
Date: Wed, 13 Apr 2011 14:31:29 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH 3/6] NFS: flav_array honors NFS_MAX_SECFLAVORS
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


NFS_MAX_SECFLAVORS should already take into account RPC_AUTH_UNIX
and RPC_AUTH_NULL, so we don't need to set aside extra slots
for them.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8a03ee0..8833472 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2215,7 +2215,7 @@ static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *fhandle,
 			      struct nfs_fsinfo *info)
 {
 	int i, len, status = 0;
-	rpc_authflavor_t flav_array[NFS_MAX_SECFLAVORS + 2];
+	rpc_authflavor_t flav_array[NFS_MAX_SECFLAVORS];
 
 	flav_array[0] = RPC_AUTH_UNIX;
 	len = gss_mech_list_pseudoflavors(&flav_array[1]);
-- 
1.7.4.4

