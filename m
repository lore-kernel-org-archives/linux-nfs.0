From: andros@netapp.com
Subject: [PATCH 18/22] SQUASHME: rename nfsd4_no_page_in_cache
Date: Thu,  2 Apr 2009 20:19:59 -0400
Message-ID: <1238718003-8764-18-git-send-email-andros@netapp.com>
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
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33624 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757876AbZDCAUj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Apr 2009 20:20:39 -0400
In-Reply-To: <1238718003-8764-17-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

March 31 review comments.
squash into nfsd41: non-page DRC for solo sequence responses

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4proc.c        |    2 +-
 fs/nfsd/nfs4state.c       |    4 ++--
 fs/nfsd/nfs4xdr.c         |    2 +-
 include/linux/nfsd/xdr4.h |    2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 29428ab..03aa76e 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1002,7 +1002,7 @@ encode_op:
 		/* Only from SEQUENCE or CREATE_SESSION */
 		if (resp->cstate.status == nfserr_replay_cache) {
 			dprintk("%s NFS4.1 replay from cache\n", __func__);
-			if (nfsd4_no_page_in_cache(resp))
+			if (nfsd4_not_cached(resp))
 				status = nfsd4_enc_no_page_replay(args, resp);
 			else
 				status = op->status;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7110278..b061224 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1077,7 +1077,7 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 	 * does this for us!
 	 */
 
-	if (nfsd4_no_page_in_cache(resp)) {
+	if (nfsd4_not_cached(resp)) {
 		entry->ce_resused = 0;
 		entry->ce_rpchdrlen = 0;
 		dprintk("%s Just cache SEQUENCE. ce_cachethis %d\n", __func__,
@@ -1146,7 +1146,7 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 	 * session inactivity timer fires and a solo sequence operation
 	 * is sent (lease renewal).
 	 */
-	if (seq && nfsd4_no_page_in_cache(resp)) {
+	if (seq && nfsd4_not_cached(resp)) {
 		seq->maxslots = resp->cstate.session->se_fnumslots;
 		return nfs_ok;
 	}
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 8dfa14b..9fb54bf 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3341,7 +3341,7 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 #ifdef CONFIG_NFSD_V4_1
 	if (nfsd4_has_session(&resp->cstate)) {
 		if (resp->cstate.status == nfserr_replay_cache &&
-				!nfsd4_no_page_in_cache(resp)) {
+				!nfsd4_not_cached(resp)) {
 			iov->iov_len = resp->cstate.iovlen;
 		} else {
 			nfsd4_store_cache_entry(resp);
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 845f05e..018a821 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -493,7 +493,7 @@ static inline u32 nfsd4_is_solo_sequence(struct nfsd4_compoundres *resp)
 	return args->opcnt == 1 ? 1 : 0;
 }
 
-static inline u32 nfsd4_no_page_in_cache(struct nfsd4_compoundres *resp)
+static inline u32 nfsd4_not_cached(struct nfsd4_compoundres *resp)
 {
 	return (resp->cstate.slot->sl_cache_entry.ce_cachethis == 0 ||
 			nfsd4_is_solo_sequence(resp));
-- 
1.5.4.3

