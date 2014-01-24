Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e8.ny.us.ibm.com ([32.97.182.138]:41430 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751147AbaAXRTj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Jan 2014 12:19:39 -0500
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Fri, 24 Jan 2014 12:19:39 -0500
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 2A9E438C8051
	for <linux-nfs@vger.kernel.org>; Fri, 24 Jan 2014 12:19:37 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp23033.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0OHJbMZ9961750
	for <linux-nfs@vger.kernel.org>; Fri, 24 Jan 2014 17:19:37 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0OHJamY020956
	for <linux-nfs@vger.kernel.org>; Fri, 24 Jan 2014 12:19:36 -0500
Received: from malahal (malahal.austin.ibm.com [9.41.105.170])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVin) with ESMTP id s0OHJaJq020939
	for <linux-nfs@vger.kernel.org>; Fri, 24 Jan 2014 12:19:36 -0500
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: handle servers that support only ALLOW ACE type.
Date: Fri, 24 Jan 2014 11:19:35 -0600
Message-Id: <1390583975-8914-1-git-send-email-malahal@us.ibm.com>
In-Reply-To: <EDB5CCCD-0940-46F2-B102-7094AE029170@primarydata.com>
References: <EDB5CCCD-0940-46F2-B102-7094AE029170@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently we support ACLs if the NFS server file system supports both
ALLOW and DENY ACE types. This patch makes the Linux client work with
ACLs even if the server supports only 'ALLOW' ACE type.

Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
---
 fs/nfs/nfs4proc.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 15052b8..e3b8fa6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4321,9 +4321,8 @@ static int nfs4_proc_renew(struct nfs_client *clp, struct rpc_cred *cred)
 
 static inline int nfs4_server_supports_acls(struct nfs_server *server)
 {
-	return (server->caps & NFS_CAP_ACLS)
-		&& (server->acl_bitmask & ACL4_SUPPORT_ALLOW_ACL)
-		&& (server->acl_bitmask & ACL4_SUPPORT_DENY_ACL);
+	return server->caps & NFS_CAP_ACLS &&
+		server->acl_bitmask & ACL4_SUPPORT_ALLOW_ACL;
 }
 
 /* Assuming that XATTR_SIZE_MAX is a multiple of PAGE_SIZE, and that
-- 
1.8.3.1

