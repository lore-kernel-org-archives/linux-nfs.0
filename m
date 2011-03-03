Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32592 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758085Ab1CCPOr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Mar 2011 10:14:47 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 9/9] NFSv4.1: Clear lseg pointer in ->doio function
Date: Thu,  3 Mar 2011 10:13:49 -0500
Message-Id: <1299165229-3148-10-git-send-email-iisaman@netapp.com>
In-Reply-To: <1299165229-3148-1-git-send-email-iisaman@netapp.com>
References: <1299165229-3148-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Now that we have access to the pointer, clear it immediately after
the put, instead of in caller.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pagelist.c |    1 -
 fs/nfs/read.c     |    2 ++
 fs/nfs/write.c    |    2 ++
 3 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 9f62874..23e7944 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -312,7 +312,6 @@ static void nfs_pageio_doio(struct nfs_pageio_descriptor *desc)
 {
 	if (!list_empty(&desc->pg_list)) {
 		int error = desc->pg_doio(desc);
-		desc->pg_lseg = NULL;
 		if (error < 0)
 			desc->pg_error = error;
 		else
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index ab9c776..4b764c6 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -311,6 +311,7 @@ static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc)
 		nbytes -= rsize;
 	} while (nbytes != 0);
 	put_lseg(lseg);
+	desc->pg_lseg = NULL;
 
 	return ret;
 
@@ -357,6 +358,7 @@ static int nfs_pagein_one(struct nfs_pageio_descriptor *desc)
 				0, lseg);
 out:
 	put_lseg(lseg);
+	desc->pg_lseg = NULL;
 	return ret;
 }
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index ccc7c22..bdb72f3 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -949,6 +949,7 @@ static int nfs_flush_multi(struct nfs_pageio_descriptor *desc)
 	} while (nbytes != 0);
 
 	put_lseg(lseg);
+	desc->pg_lseg = NULL;
 	return ret;
 
 out_bad:
@@ -1005,6 +1006,7 @@ static int nfs_flush_one(struct nfs_pageio_descriptor *desc)
 	ret = nfs_write_rpcsetup(req, data, &nfs_write_full_ops, desc->pg_count, 0, lseg, desc->pg_ioflags);
 out:
 	put_lseg(lseg); /* Cleans any gotten in ->pg_test */
+	desc->pg_lseg = NULL;
 	return ret;
 }
 
-- 
1.7.2.1

