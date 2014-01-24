Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e39.co.us.ibm.com ([32.97.110.160]:58430 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769AbaAXDu6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Jan 2014 22:50:58 -0500
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Thu, 23 Jan 2014 20:50:58 -0700
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 72E63C90026
	for <linux-nfs@vger.kernel.org>; Thu, 23 Jan 2014 22:50:52 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp22036.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0O3osnp6422790
	for <linux-nfs@vger.kernel.org>; Fri, 24 Jan 2014 03:50:54 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0O3osXK021277
	for <linux-nfs@vger.kernel.org>; Thu, 23 Jan 2014 22:50:54 -0500
Received: from malahal (malahal.austin.ibm.com [9.41.105.170])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVin) with ESMTP id s0O3os2I021266
	for <linux-nfs@vger.kernel.org>; Thu, 23 Jan 2014 22:50:54 -0500
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: handle servers that support either ALLOW or DENY ACE types.
Date: Thu, 23 Jan 2014 21:50:53 -0600
Message-Id: <1390535453-15585-1-git-send-email-malahal@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently we support ACLs if the NFS server file system supports
ALLOW and DENY ACE types. This patch makes the Linux client work with
ACLs if the server supports either ALLOW or DENY ACE types.

Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
---
 fs/nfs/nfs4proc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 15052b8..4504685 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4321,9 +4321,9 @@ static int nfs4_proc_renew(struct nfs_client *clp, struct rpc_cred *cred)
 
 static inline int nfs4_server_supports_acls(struct nfs_server *server)
 {
-	return (server->caps & NFS_CAP_ACLS)
-		&& (server->acl_bitmask & ACL4_SUPPORT_ALLOW_ACL)
-		&& (server->acl_bitmask & ACL4_SUPPORT_DENY_ACL);
+	return server->caps & NFS_CAP_ACLS &&
+			(server->acl_bitmask & ACL4_SUPPORT_ALLOW_ACL ||
+			 server->acl_bitmask & ACL4_SUPPORT_DENY_ACL);
 }
 
 /* Assuming that XATTR_SIZE_MAX is a multiple of PAGE_SIZE, and that
-- 
1.8.3.1

