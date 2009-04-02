From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 10/21] SQUASHME: nfsd41: document unenforced nfs41 compound ordering rules.
Date: Fri,  3 Apr 2009 01:38:19 +0300
Message-ID: <1238711899-22334-1-git-send-email-bhalevy@panasas.com>
References: <49D53D44.4030102@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:26437 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756163AbZDBWiY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 18:38:24 -0400
In-Reply-To: <49D53D44.4030102@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 Documentation/filesystems/nfs41-server.txt |    7 +++++++
 fs/nfsd/nfs4proc.c                         |    7 +++++++
 2 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/Documentation/filesystems/nfs41-server.txt b/Documentation/filesystems/nfs41-server.txt
index e62cd13..8124a67 100644
--- a/Documentation/filesystems/nfs41-server.txt
+++ b/Documentation/filesystems/nfs41-server.txt
@@ -146,3 +146,10 @@ CREATE_SESSION:
 
 SEQUENCE:
 * no support for dynamic slot table renegotiation (optional)
+
+nfsv4.1 COMPOUND rules:
+The following cases aren't supported yet:
+* Enforcing of NFS4ERR_NOT_ONLY_OP for: BIND_CONN_TO_SESSION, CREATE_SESSION,
+  DESTROY_CLIENTID, DESTROY_SESSION, EXCHANGE_ID.
+* DESTROY_SESSION MUST be the final operation in the COMPOUND request.
+
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 7619970..b0d5b10 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -895,6 +895,13 @@ nfsd4_enc_no_page_replay(struct nfsd4_compoundargs *args,
 	return op->status;
 }
 
+/*
+ * Enforce NFSv4.1 COMPOUND ordering rules.
+ *
+ * TODO:
+ * - enforce NFS4ERR_NOT_ONLY_OP,
+ * - DESTROY_SESSION MUST be the final operation in the COMPOUND request.
+ */
 static bool nfs41_op_ordering_ok(struct nfsd4_compoundargs *args)
 {
 #if defined(CONFIG_NFSD_V4_1)
-- 
1.6.2.1

