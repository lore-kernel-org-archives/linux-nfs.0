From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 13/15] NFSv41: Clean up exclusive create
Date: Mon, 14 Jun 2010 17:51:37 -0400
Message-ID: <1276552299-6625-13-git-send-email-Trond.Myklebust@netapp.com>
References: <1276552299-6625-1-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-2-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-3-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-4-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-5-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-6-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-7-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-8-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-9-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-10-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-11-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-12-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53421 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756726Ab0FNVvr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jun 2010 17:51:47 -0400
In-Reply-To: <1276552299-6625-12-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c       |   17 ++++++-----------
 include/linux/nfs_xdr.h |    6 ++++--
 2 files changed, 10 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ef613ea..e9913de 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -744,19 +744,14 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct path *path,
 	p->o_arg.server = server;
 	p->o_arg.bitmask = server->attr_bitmask;
 	p->o_arg.claim = NFS4_OPEN_CLAIM_NULL;
-	if (flags & O_EXCL) {
-		if (nfs4_has_persistent_session(server->nfs_client)) {
-			/* GUARDED */
-			p->o_arg.u.attrs = &p->attrs;
-			memcpy(&p->attrs, attrs, sizeof(p->attrs));
-		} else { /* EXCLUSIVE4_1 */
-			u32 *s = (u32 *) p->o_arg.u.verifier.data;
-			s[0] = jiffies;
-			s[1] = current->pid;
-		}
-	} else if (flags & O_CREAT) {
+	if (flags & O_CREAT) {
+		u32 *s;
+
 		p->o_arg.u.attrs = &p->attrs;
 		memcpy(&p->attrs, attrs, sizeof(p->attrs));
+		s = (u32 *) p->o_arg.u.verifier.data;
+		s[0] = jiffies;
+		s[1] = current->pid;
 	}
 	p->c_arg.fh = &p->o_res.fh;
 	p->c_arg.stateid = &p->o_res.stateid;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 51914d7..a319cb9 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -196,8 +196,10 @@ struct nfs_openargs {
 	__u64                   clientid;
 	__u64                   id;
 	union {
-		struct iattr *  attrs;    /* UNCHECKED, GUARDED */
-		nfs4_verifier   verifier; /* EXCLUSIVE */
+		struct {
+			struct iattr *  attrs;    /* UNCHECKED, GUARDED */
+			nfs4_verifier   verifier; /* EXCLUSIVE */
+		};
 		nfs4_stateid	delegation;		/* CLAIM_DELEGATE_CUR */
 		fmode_t		delegation_type;	/* CLAIM_PREVIOUS */
 	} u;
-- 
1.7.0.1

