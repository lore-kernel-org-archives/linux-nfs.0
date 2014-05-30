Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f47.google.com ([209.85.192.47]:42665 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932498AbaE3NJu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 May 2014 09:09:50 -0400
Received: by mail-qg0-f47.google.com with SMTP id j107so5121789qga.20
        for <linux-nfs@vger.kernel.org>; Fri, 30 May 2014 06:09:49 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: trond.myklebust@primarydata.com, bhalevy@primarydata.com,
        linux-nfs@vger.kernel.org
Subject: [PATCH 4/9] nfsd: fix setting of NFS4_OO_CONFIRMED in nfsd4_open
Date: Fri, 30 May 2014 09:09:28 -0400
Message-Id: <1401455373-18207-5-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1401455373-18207-1-git-send-email-jlayton@primarydata.com>
References: <1401455373-18207-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In the NFS4_OPEN_CLAIM_PREVIOUS case, we should only mark it confirmed
if the nfs4_check_open_reclaim check succeeds.

In the NFS4_OPEN_CLAIM_DELEG_PREV_FH and NFS4_OPEN_CLAIM_DELEGATE_PREV
cases, I see no point in declaring the openowner confirmed when the
operation is going to fail anyway, and doing so might allow the client
to game things such that it wouldn't need to confirm a subsequent open
with the same owner.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4proc.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 2517e0bf5751..a1e16103a0bf 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -430,12 +430,12 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 				goto out;
 			break;
 		case NFS4_OPEN_CLAIM_PREVIOUS:
-			open->op_openowner->oo_flags |= NFS4_OO_CONFIRMED;
 			status = nfs4_check_open_reclaim(&open->op_clientid,
 							 cstate->minorversion,
 							 nn);
 			if (status)
 				goto out;
+			open->op_openowner->oo_flags |= NFS4_OO_CONFIRMED;
 		case NFS4_OPEN_CLAIM_FH:
 		case NFS4_OPEN_CLAIM_DELEG_CUR_FH:
 			status = do_open_fhandle(rqstp, cstate, open);
@@ -445,7 +445,6 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			break;
 		case NFS4_OPEN_CLAIM_DELEG_PREV_FH:
              	case NFS4_OPEN_CLAIM_DELEGATE_PREV:
-			open->op_openowner->oo_flags |= NFS4_OO_CONFIRMED;
 			dprintk("NFSD: unsupported OPEN claim type %d\n",
 				open->op_claim_type);
 			status = nfserr_notsupp;
-- 
1.9.3

