Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f173.google.com ([209.85.213.173]:35274 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754305AbaDRSp5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:45:57 -0400
Received: by mail-ig0-f173.google.com with SMTP id hl10so937637igb.6
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:45:56 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 32/70] NFSd: Ensure stateids remain unique until they are freed
Date: Fri, 18 Apr 2014 14:44:26 -0400
Message-Id: <1397846704-14567-33-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-32-git-send-email-trond.myklebust@primarydata.com>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-2-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-3-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-4-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-5-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-6-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-7-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-8-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-9-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-10-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-11-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-12-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-13-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-14-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-15-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-16-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-17-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-18-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-19-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-20-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-21-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-22-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-23-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-24-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-25-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-26-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-27-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-28-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-29-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-30-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-31-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-32-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add an extra delegation state to allow the stateid to remain in the idr
tree until the last reference has been released.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 8 ++++----
 fs/nfsd/state.h     | 1 +
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2cb4124276d0..7b897ff03a27 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -473,6 +473,7 @@ static void remove_stid(struct nfs4_stid *s)
 
 static void nfs4_free_stid(struct kmem_cache *slab, struct nfs4_stid *s)
 {
+	remove_stid(s);
 	if (s->sc_file)
 		put_nfs4_file(s->sc_file);
 	kmem_cache_free(slab, s);
@@ -541,7 +542,7 @@ unhash_delegation(struct nfs4_delegation *dp)
 
 static void destroy_delegation(struct nfs4_delegation *dp)
 {
-	remove_stid(&dp->dl_stid);
+	dp->dl_stid.sc_type = NFS4_CLOSED_DELEG_STID;
 	nfs4_put_delegation(dp);
 }
 
@@ -554,7 +555,7 @@ static void unhash_and_destroy_delegation(struct nfs4_delegation *dp)
 static void destroy_revoked_delegation(struct nfs4_delegation *dp)
 {
 	list_del_init(&dp->dl_recall_lru);
-	destroy_delegation(dp);
+	nfs4_put_delegation(dp);
 }
 
 static void revoke_delegation(struct nfs4_delegation *dp)
@@ -713,7 +714,6 @@ static void put_generic_stateid(struct nfs4_ol_stateid *stp)
 {
 	if (!atomic_dec_and_test(&stp->st_stid.sc_count))
 		return;
-	remove_stid(&stp->st_stid);
 	nfs4_free_stid(stateid_slab, &stp->st_stid);
 }
 
@@ -3359,7 +3359,6 @@ nfs4_open_delegation(struct net *net, struct svc_fh *fh,
 	open->op_delegate_type = NFS4_OPEN_DELEGATE_READ;
 	return;
 out_free:
-	remove_stid(&dp->dl_stid);
 	nfs4_put_delegation(dp);
 out_no_deleg:
 	open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE;
@@ -3803,6 +3802,7 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
 	default:
 		printk("unknown stateid type %x\n", s->sc_type);
 	case NFS4_CLOSED_STID:
+	case NFS4_CLOSED_DELEG_STID:
 		return nfserr_bad_stateid;
 	}
 }
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 0539db97f7d3..a4ac75a0de21 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -82,6 +82,7 @@ struct nfs4_stid {
 #define NFS4_CLOSED_STID 8
 /* For a deleg stateid kept around only to process free_stateid's: */
 #define NFS4_REVOKED_DELEG_STID 16
+#define NFS4_CLOSED_DELEG_STID 32
 	unsigned char sc_type;
 	stateid_t sc_stateid;
 	struct nfs4_client *sc_client;
-- 
1.9.0

