Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47546 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755270Ab0IISKn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Sep 2010 14:10:43 -0400
Received: from localhost.localdomain (surajit-lxp.hq.netapp.com [10.58.50.95] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o89IAW1W002948
	for <linux-nfs@vger.kernel.org>; Thu, 9 Sep 2010 11:10:42 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 11/13] RFC: nfs: retry on certain pnfs errors
Date: Thu,  2 Sep 2010 14:00:17 -0400
Message-Id: <1283450419-5648-12-git-send-email-iisaman@netapp.com>
In-Reply-To: <1283450419-5648-1-git-send-email-iisaman@netapp.com>
References: <1283450419-5648-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Add to the list of errors that cause the client to keep
retrying with exponential backoff.

Signed-off-by: TBD - melding/reorganization of several patches
---
 fs/nfs/nfs4proc.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9e6b086..c7c7277 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -286,6 +286,8 @@ static int nfs4_handle_exception(const struct nfs_server *server, int errorcode,
 		case -NFS4ERR_GRACE:
 		case -NFS4ERR_DELAY:
 		case -EKEYEXPIRED:
+		case -NFS4ERR_LAYOUTTRYLATER:
+		case -NFS4ERR_RECALLCONFLICT:
 			ret = nfs4_delay(server->client, &exception->timeout);
 			if (ret != 0)
 				break;
-- 
1.7.2.1

