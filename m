Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:31915 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755255Ab2JOVcx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Oct 2012 17:32:53 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 11/13] lockd: Remove trivial BUG_ON()s from the NSM code
Date: Mon, 15 Oct 2012 17:31:05 -0400
Message-Id: <1350336667-18770-13-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1350336667-18770-12-git-send-email-Trond.Myklebust@netapp.com>
References: <1350336667-18770-1-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-2-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-3-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-4-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-5-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-6-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-7-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-8-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-9-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-10-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-11-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-12-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/lockd/mon.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index e4fb3ba..dd97c93 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -147,8 +147,6 @@ static int nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res,
 		.rpc_resp	= res,
 	};
 
-	BUG_ON(clnt == NULL);
-
 	memset(res, 0, sizeof(*res));
 
 	msg.rpc_proc = &clnt->cl_procinfo[proc];
@@ -459,7 +457,6 @@ static void encode_nsm_string(struct xdr_stream *xdr, const char *string)
 	const u32 len = strlen(string);
 	__be32 *p;
 
-	BUG_ON(len > SM_MAXSTRLEN);
 	p = xdr_reserve_space(xdr, 4 + len);
 	xdr_encode_opaque(p, string, len);
 }
-- 
1.7.11.7

