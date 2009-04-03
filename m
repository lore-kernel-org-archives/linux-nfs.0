From: andros@netapp.com
Subject: [PATCH 09/22] SQUASHME: nfsd41 set cstate session
Date: Thu,  2 Apr 2009 20:19:50 -0400
Message-ID: <1238718003-8764-9-git-send-email-andros@netapp.com>
References: <1238718003-8764-1-git-send-email-andros@netapp.com>
 <1238718003-8764-2-git-send-email-andros@netapp.com>
 <1238718003-8764-3-git-send-email-andros@netapp.com>
 <1238718003-8764-4-git-send-email-andros@netapp.com>
 <1238718003-8764-5-git-send-email-andros@netapp.com>
 <1238718003-8764-6-git-send-email-andros@netapp.com>
 <1238718003-8764-7-git-send-email-andros@netapp.com>
 <1238718003-8764-8-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33624 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756572AbZDCAUb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Apr 2009 20:20:31 -0400
In-Reply-To: <1238718003-8764-8-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

March 31 review by Bruce:
squash into nfsd41: sequence operation

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f70c10f..1fec767 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1509,6 +1509,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	status = check_slot_seqid(seq->seqid, slot);
 	if (status == nfserr_replay_cache) {
 		cstate->slot = slot;
+		cstate->session = session;
 		/* Return the cached reply status and set cstate->status
 		 * for nfsd4_svc_encode_compoundres processing */
 		status = nfsd4_replay_cache_entry(resp, seq);
@@ -1527,6 +1528,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 		slot->sl_cache_entry.ce_cachethis = 1;
 
 	cstate->slot = slot;
+	cstate->session = session;
 
 replay_cache:
 	/* Renew the clientid on success and on replay.
-- 
1.5.4.3

