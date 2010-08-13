Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50613 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753225Ab0HMVcF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:32:05 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Fred Isaman <iisaman@citi.umich.edu>
Subject: [PATCH 01/50] nfs41: prevent exchange_id from sending server-only flag
Date: Fri, 13 Aug 2010 17:31:13 -0400
Message-Id: <1281735122-1496-2-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-1-git-send-email-andros@netapp.com>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

clp->cl_exchange_flags is used both for client output and server input.
This causes problems in certain recovery situations, when the server
has sent back EXCHGID4_FLAG_CONFIRMED_R, causing the client to erroneously
use the flag in future EXCHANGE_ID requests.

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ba79c0e..7684817 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4573,7 +4573,7 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 	nfs4_verifier verifier;
 	struct nfs41_exchange_id_args args = {
 		.client = clp,
-		.flags = clp->cl_exchange_flags,
+		.flags = clp->cl_exchange_flags & ~EXCHGID4_FLAG_CONFIRMED_R,
 	};
 	struct nfs41_exchange_id_res res = {
 		.client = clp,
-- 
1.6.2.5

