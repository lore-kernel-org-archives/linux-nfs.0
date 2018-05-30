Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:44840 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932091AbeE3SGb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 30 May 2018 14:06:31 -0400
Received: by mail-io0-f194.google.com with SMTP id y2-v6so17396356iob.11
        for <linux-nfs@vger.kernel.org>; Wed, 30 May 2018 11:06:31 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id i201-v6sm8589368ite.33.2018.05.30.11.06.29
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 11:06:29 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 16/19] NFSv4/pnfs: Don't switch off layoutget-on-open for transient errors
Date: Wed, 30 May 2018 14:05:50 -0400
Message-Id: <20180530180553.38769-17-trond.myklebust@hammerspace.com>
In-Reply-To: <20180530180553.38769-16-trond.myklebust@hammerspace.com>
References: <20180530180553.38769-1-trond.myklebust@hammerspace.com>
 <20180530180553.38769-2-trond.myklebust@hammerspace.com>
 <20180530180553.38769-3-trond.myklebust@hammerspace.com>
 <20180530180553.38769-4-trond.myklebust@hammerspace.com>
 <20180530180553.38769-5-trond.myklebust@hammerspace.com>
 <20180530180553.38769-6-trond.myklebust@hammerspace.com>
 <20180530180553.38769-7-trond.myklebust@hammerspace.com>
 <20180530180553.38769-8-trond.myklebust@hammerspace.com>
 <20180530180553.38769-9-trond.myklebust@hammerspace.com>
 <20180530180553.38769-10-trond.myklebust@hammerspace.com>
 <20180530180553.38769-11-trond.myklebust@hammerspace.com>
 <20180530180553.38769-12-trond.myklebust@hammerspace.com>
 <20180530180553.38769-13-trond.myklebust@hammerspace.com>
 <20180530180553.38769-14-trond.myklebust@hammerspace.com>
 <20180530180553.38769-15-trond.myklebust@hammerspace.com>
 <20180530180553.38769-16-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Ensure that we only switch off the LAYOUTGET operation in the OPEN
compound when the server is truly broken, and/or it is complaining
that the compound is too large.
Currently, we end up turning off the functionality permanently,
even for transient errors such as EACCES or ENOSPC.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/pnfs.c | 22 +++++++++++++++-------
 1 file changed, 15 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 3da4f404c2fa..8c6ce63f5ed0 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2061,14 +2061,22 @@ void pnfs_parse_lgopen(struct inode *ino, struct nfs4_layoutget *lgp,
 	dprintk("%s: entered with status %i\n", __func__, lgp->res.status);
 	if (lgp->res.status) {
 		switch (lgp->res.status) {
-		case -NFS4ERR_DELAY:
-		case -NFS4ERR_GRACE:
-		case -NFS4ERR_LAYOUTTRYLATER:
-			break;
 		default:
-			/* FIXME - Any error not listed above permanently
-			 * halts lgopen attempts.
-			 */
+			break;
+		/*
+		 * Halt lgopen attempts if the server doesn't recognise
+		 * the "current stateid" value, the layout type, or the
+		 * layoutget operation as being valid.
+		 * Also if it complains about too many ops in the compound
+		 * or of the request/reply being too big.
+		 */
+		case -NFS4ERR_BAD_STATEID:
+		case -NFS4ERR_NOTSUPP:
+		case -NFS4ERR_REP_TOO_BIG:
+		case -NFS4ERR_REP_TOO_BIG_TO_CACHE:
+		case -NFS4ERR_REQ_TOO_BIG:
+		case -NFS4ERR_TOO_MANY_OPS:
+		case -NFS4ERR_UNKNOWN_LAYOUTTYPE:
 			srv->caps &= ~NFS_CAP_LGOPEN;
 		}
 		return;
-- 
2.17.0

