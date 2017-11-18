Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35074 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161145AbdKRSuQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 18 Nov 2017 13:50:16 -0500
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <anna.schumaker@netapp.com>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>,
        "linux-nfs @ vger . kernel . org" <linux-nfs@vger.kernel.org>,
        "linux-kernel @ vger . kernel . org" <linux-kernel@vger.kernel.org>
Subject: [PATCH] NFSv4: Ensure gcc 4.4.4 can compile initialiser for "invalid_stateid"
Date: Sat, 18 Nov 2017 13:50:11 -0500
Message-Id: <20171118185011.4729-1-trond.myklebust@primarydata.com>
In-Reply-To: <cce6f1be-0481-4ecc-85e2-a626cf381ce3@oracle.com>
References: <cce6f1be-0481-4ecc-85e2-a626cf381ce3@oracle.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

gcc 4.4.4 is too old to have full C11 anonymous union support, so
the current initialiser fails to compile.

Reported-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4state.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 980462d577ca..231b5ea2464a 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -71,8 +71,8 @@ const nfs4_stateid zero_stateid = {
 };
 const nfs4_stateid invalid_stateid = {
 	{
-		.seqid = cpu_to_be32(0xffffffffU),
-		.other = { 0 },
+		/* Funky initialiser keeps older gcc versions happy */
+		.data = { 0xff, 0xff, 0xff, 0xff, 0 },
 	},
 	.type = NFS4_INVALID_STATEID_TYPE,
 };
-- 
2.14.3

