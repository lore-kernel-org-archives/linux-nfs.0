From: andros@netapp.com
Subject: [PATCH 09/14] nfsd41: rename nfsd4_enc_uncached_replay
Date: Wed, 24 Jun 2009 15:37:53 -0400
Message-ID: <1245872278-18743-10-git-send-email-andros@netapp.com>
References: <>
 <1245872278-18743-1-git-send-email-andros@netapp.com>
 <1245872278-18743-2-git-send-email-andros@netapp.com>
 <1245872278-18743-3-git-send-email-andros@netapp.com>
 <1245872278-18743-4-git-send-email-andros@netapp.com>
 <1245872278-18743-5-git-send-email-andros@netapp.com>
 <1245872278-18743-6-git-send-email-andros@netapp.com>
 <1245872278-18743-7-git-send-email-andros@netapp.com>
 <1245872278-18743-8-git-send-email-andros@netapp.com>
 <1245872278-18743-9-git-send-email-andros@netapp.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:15303 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752742AbZFXTiE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Jun 2009 15:38:04 -0400
In-Reply-To: <1245872278-18743-9-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

This function is only used for SEQUENCE replay.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4proc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 6285106..386deb5 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -952,7 +952,7 @@ static const char *nfsd4_op_name(unsigned opnum);
  * encode the uncache rep error on the next operation.
  */
 static __be32
-nfsd4_enc_uncached_replay(struct nfsd4_compoundargs *args,
+nfsd4_enc_sequence_replay(struct nfsd4_compoundargs *args,
 			 struct nfsd4_compoundres *resp)
 {
 	struct nfsd4_op *op;
@@ -1087,7 +1087,7 @@ encode_op:
 		if (resp->cstate.status == nfserr_replay_cache) {
 			dprintk("%s NFS4.1 replay from cache\n", __func__);
 			if (nfsd4_not_cached(resp))
-				status = nfsd4_enc_uncached_replay(args, resp);
+				status = nfsd4_enc_sequence_replay(args, resp);
 			else
 				status = op->status;
 			goto out;
-- 
1.5.4.3

