From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 1/1] SQUASHME pnfs-submit: pnfs4_proc_layoutcommit was using freed memory
Date: Wed, 16 Jun 2010 18:43:31 -0400
Message-ID: <1276728211-31092-1-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.212.112.111]:49035 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932475Ab0FRPbF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Jun 2010 11:31:05 -0400
Received: from localhost.localdomain (netapp-61.citi.umich.edu [141.212.112.250])
	by citi.umich.edu (Postfix) with ESMTP id DCB7F18091
	for <linux-nfs@vger.kernel.org>; Fri, 18 Jun 2010 11:31:02 -0400 (EDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

_pnfs4_proc_layoutcommit frees data when called with issync==true.
This resulted in setting server from the freed memory.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4proc.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b85239a..5ffdfe1 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5607,10 +5607,11 @@ out:
 int pnfs4_proc_layoutcommit(struct pnfs_layoutcommit_data *data, int issync)
 {
 	struct nfs4_exception exception = { };
+	struct nfs_server *server = NFS_SERVER(data->args.inode);
 	int err;
 
 	do {
-		err = nfs4_handle_exception(NFS_SERVER(data->args.inode),
+		err = nfs4_handle_exception(server,
 					_pnfs4_proc_layoutcommit(data, issync),
 					&exception);
 	} while (exception.retry);
-- 
1.6.6.1

