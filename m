From: andros@netapp.com
Subject: [PATCH 19/29] nfsd41: rename nfsd4_enc_uncached_replay
Date: Thu, 23 Apr 2009 12:42:58 -0400
Message-ID: <1240504988-9572-20-git-send-email-andros@netapp.com>
References: <>
 <1240504988-9572-1-git-send-email-andros@netapp.com>
 <1240504988-9572-2-git-send-email-andros@netapp.com>
 <1240504988-9572-3-git-send-email-andros@netapp.com>
 <1240504988-9572-4-git-send-email-andros@netapp.com>
 <1240504988-9572-5-git-send-email-andros@netapp.com>
 <1240504988-9572-6-git-send-email-andros@netapp.com>
 <1240504988-9572-7-git-send-email-andros@netapp.com>
 <1240504988-9572-8-git-send-email-andros@netapp.com>
 <1240504988-9572-9-git-send-email-andros@netapp.com>
 <1240504988-9572-10-git-send-email-andros@netapp.com>
 <1240504988-9572-11-git-send-email-andros@netapp.com>
 <1240504988-9572-12-git-send-email-andros@netapp.com>
 <1240504988-9572-13-git-send-email-andros@netapp.com>
 <1240504988-9572-14-git-send-email-andros@netapp.com>
 <1240504988-9572-15-git-send-email-andros@netapp.com>
 <1240504988-9572-16-git-send-email-andros@netapp.com>
 <1240504988-9572-17-git-send-email-andros@netapp.com>
 <1240504988-9572-18-git-send-email-andros@netapp.com>
 <1240504988-9572-19-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46174 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755881AbZDWQn2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Apr 2009 12:43:28 -0400
In-Reply-To: <1240504988-9572-19-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

This function is only used for SEQUENCE replay.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4proc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 32d5866..f8e7720 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -865,7 +865,7 @@ static const char *nfsd4_op_name(unsigned opnum);
  * encode the uncache rep error on the next operation.
  */
 static __be32
-nfsd4_enc_uncached_replay(struct nfsd4_compoundargs *args,
+nfsd4_enc_sequence_replay(struct nfsd4_compoundargs *args,
 			 struct nfsd4_compoundres *resp)
 {
 	struct nfsd4_op *op;
@@ -1000,7 +1000,7 @@ encode_op:
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

