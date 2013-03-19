Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:19812 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754870Ab3CSNH4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Mar 2013 09:07:56 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 11/11] NFSv4.1: Use CLAIM_DELEG_CUR_FH opens when available
Date: Tue, 19 Mar 2013 09:07:43 -0400
Message-Id: <1363698463-3681-11-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1363698463-3681-10-git-send-email-Trond.Myklebust@netapp.com>
References: <1363698463-3681-1-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-2-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-3-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-4-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-5-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-6-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-7-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-8-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-9-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-10-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that we do CLAIM_FH opens, we may run into situations where we
get a delegation but don't have perfect knowledge of the file path.
When returning the delegation, we might therefore not be able to
us CLAIM_DELEGATE_CUR opens to convert the delegation into OPEN
stateids and locks.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 480b5d0..88c4015 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1383,7 +1383,7 @@ static int _nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs
 	int ret;
 
 	opendata = nfs4_open_recoverdata_alloc(ctx, state,
-			NFS4_OPEN_CLAIM_DELEGATE_CUR);
+			NFS4_OPEN_CLAIM_DELEG_CUR_FH);
 	if (IS_ERR(opendata))
 		return PTR_ERR(opendata);
 	nfs4_stateid_copy(&opendata->o_arg.u.delegation, stateid);
-- 
1.8.1.4

