From: andros@netapp.com
Subject: [PATCH 19/22] SQUASHME: nfsd41 rename nfsd4_enc_no_page_replay
Date: Thu,  2 Apr 2009 20:20:00 -0400
Message-ID: <1238718003-8764-19-git-send-email-andros@netapp.com>
References: <1238718003-8764-1-git-send-email-andros@netapp.com>
 <1238718003-8764-2-git-send-email-andros@netapp.com>
 <1238718003-8764-3-git-send-email-andros@netapp.com>
 <1238718003-8764-4-git-send-email-andros@netapp.com>
 <1238718003-8764-5-git-send-email-andros@netapp.com>
 <1238718003-8764-6-git-send-email-andros@netapp.com>
 <1238718003-8764-7-git-send-email-andros@netapp.com>
 <1238718003-8764-8-git-send-email-andros@netapp.com>
 <1238718003-8764-9-git-send-email-andros@netapp.com>
 <1238718003-8764-10-git-send-email-andros@netapp.com>
 <1238718003-8764-11-git-send-email-andros@netapp.com>
 <1238718003-8764-12-git-send-email-andros@netapp.com>
 <1238718003-8764-13-git-send-email-andros@netapp.com>
 <1238718003-8764-14-git-send-email-andros@netapp.com>
 <1238718003-8764-15-git-send-email-andros@netapp.com>
 <1238718003-8764-16-git-send-email-andros@netapp.com>
 <1238718003-8764-17-git-send-email-andros@netapp.com>
 <1238718003-8764-18-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33624 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757645AbZDCAUj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Apr 2009 20:20:39 -0400
In-Reply-To: <1238718003-8764-18-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

March 31 review comments.
squash into nfsd41: non-page DRC for solo sequence responses

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4proc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 03aa76e..a519362 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -873,7 +873,7 @@ static const char *nfsd4_op_name(unsigned opnum);
  * encode the uncache rep error on the next operation.
  */
 static __be32
-nfsd4_enc_no_page_replay(struct nfsd4_compoundargs *args,
+nfsd4_enc_uncached_replay(struct nfsd4_compoundargs *args,
 			 struct nfsd4_compoundres *resp)
 {
 	struct nfsd4_op *op;
@@ -1003,7 +1003,7 @@ encode_op:
 		if (resp->cstate.status == nfserr_replay_cache) {
 			dprintk("%s NFS4.1 replay from cache\n", __func__);
 			if (nfsd4_not_cached(resp))
-				status = nfsd4_enc_no_page_replay(args, resp);
+				status = nfsd4_enc_uncached_replay(args, resp);
 			else
 				status = op->status;
 			goto out;
-- 
1.5.4.3

