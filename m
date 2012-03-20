Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:1238 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756249Ab2CTTL0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Mar 2012 15:11:26 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org, Bruce Fields <bfields@fieldses.org>
Subject: [PATCH] NFSD: Fix warnings when NFSD_DEBUG is not defined
Date: Tue, 20 Mar 2012 15:11:17 -0400
Message-Id: <1332270677-19044-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfsd/nfs4proc.c  |    4 ++++
 fs/nfsd/nfs4state.c |    8 ++++++++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 896da74..a62aa4f 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1037,7 +1037,9 @@ struct nfsd4_operation {
 
 static struct nfsd4_operation nfsd4_ops[];
 
+#ifdef NFSD_DEBUG
 static const char *nfsd4_op_name(unsigned opnum);
+#endif
 
 /*
  * Enforce NFSv4.1 COMPOUND ordering rules:
@@ -1674,12 +1676,14 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 };
 
+#ifdef NFSD_DEBUG
 static const char *nfsd4_op_name(unsigned opnum)
 {
 	if (opnum < ARRAY_SIZE(nfsd4_ops))
 		return nfsd4_ops[opnum].op_name;
 	return "unknown_operation";
 }
+#endif
 
 #define nfsd4_voidres			nfsd4_voidargs
 struct nfsd4_voidargs { int dummy; };
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c5cddd6..813de8f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -605,12 +605,20 @@ hash_sessionid(struct nfs4_sessionid *sessionid)
 	return sid->sequence % SESSION_HASH_SIZE;
 }
 
+#ifdef NFSD_DEBUG
 static inline void
 dump_sessionid(const char *fn, struct nfs4_sessionid *sessionid)
 {
 	u32 *ptr = (u32 *)(&sessionid->data[0]);
 	dprintk("%s: %u:%u:%u:%u\n", fn, ptr[0], ptr[1], ptr[2], ptr[3]);
 }
+#else
+static inline void
+dump_sessionid(const char *fn, struct nfs4_sessionid *sessionid)
+{
+}
+#endif
+
 
 static void
 gen_sessionid(struct nfsd4_session *ses)
-- 
1.7.7.6

