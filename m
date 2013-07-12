Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f43.google.com ([209.85.213.43]:43610 "EHLO
	mail-yh0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964817Ab3GLQmD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jul 2013 12:42:03 -0400
Received: by mail-yh0-f43.google.com with SMTP id b12so3806375yha.30
        for <linux-nfs@vger.kernel.org>; Fri, 12 Jul 2013 09:42:02 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe93:815b])
        by mx.google.com with ESMTPSA id g39sm69015357yhb.13.2013.07.12.09.34.13
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 12 Jul 2013 09:34:14 -0700 (PDT)
Subject: [PATCH v1 19/19] NFS: Set EXCHGID4_FLAG_SUPP_MOVED_MIGR
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 12 Jul 2013 12:34:13 -0400
Message-ID: <20130712163413.1444.98938.stgit@seurat.1015granger.net>
In-Reply-To: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
References: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We have all the pieces in place to support NFSv4 minor version 1
migration in our client.  The client should advertise its support
for migration.

Note that v4.1 migration is untested.  There are no servers in the
wild that support NFSv4.1 migration.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4proc.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 80afb9f..8d0fab7 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5876,8 +5876,10 @@ out:
 	return status;
 }
 
-/*
- * nfs4_proc_exchange_id()
+/**
+ * nfs4_proc_exchange_id - Instantiate client ID
+ * @clp: server state
+ * @cred: RPC credential to use for this call
  *
  * Returns zero, a negative errno, or a negative NFS4ERR status code.
  *
@@ -5892,7 +5894,8 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 	struct nfs41_exchange_id_args args = {
 		.verifier = &verifier,
 		.client = clp,
-		.flags = EXCHGID4_FLAG_SUPP_MOVED_REFER,
+		.flags = EXCHGID4_FLAG_SUPP_MOVED_REFER |
+			 EXCHGID4_FLAG_SUPP_MOVED_MIGR,
 	};
 	struct nfs41_exchange_id_res res = {
 		0

