From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 32/35] nfs: resolve compile dependency in nfs_xdr.h
Date: Mon,  7 Dec 2009 11:36:53 +0200
Message-ID: <1260178613-16054-1-git-send-email-bhalevy@panasas.com>
References: <4B1CCA52.8020900@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:19170 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934926AbZLGJf4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2009 04:35:56 -0500
In-Reply-To: <4B1CCA52.8020900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Include headers in nfs_xdr.h required for
struct rpc_task, nfs4_verifier, nfs4_stateid

Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/nfs_xdr.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 00a0c81..a2a45d1 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -3,6 +3,8 @@
 
 #include <linux/nfsacl.h>
 #include <linux/nfs3.h>
+#include <linux/nfs4.h>
+#include <linux/sunrpc/sched.h>
 
 /*
  * To change the maximum rsize and wsize supported by the NFS client, adjust
-- 
1.6.5.1

