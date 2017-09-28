Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:25116 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752433AbdI1RaT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 28 Sep 2017 13:30:19 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 6/8] nfsd: remove unnecessary nofilehandle checks
Date: Thu, 28 Sep 2017 13:30:00 -0400
Message-ID: <20170928173002.50818-7-kolga@netapp.com>
In-Reply-To: <20170928173002.50818-1-kolga@netapp.com>
References: <20170928173002.50818-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These checks should have already be done centrally in
nfsd4_proc_compound, the checks in each individual operation are
unnecessary.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c | 14 ++------------
 1 file changed, 2 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 72a0bc5..a0536a6 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -507,9 +507,6 @@ static __be32 nfsd4_open_omfg(struct svc_rqst *rqstp, struct nfsd4_compound_stat
 nfsd4_getfh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	    union nfsd4_op_u *u)
 {
-	if (!cstate->current_fh.fh_dentry)
-		return nfserr_nofilehandle;
-
 	u->getfh = &cstate->current_fh;
 	return nfs_ok;
 }
@@ -557,9 +554,6 @@ static __be32 nfsd4_open_omfg(struct svc_rqst *rqstp, struct nfsd4_compound_stat
 nfsd4_savefh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	     union nfsd4_op_u *u)
 {
-	if (!cstate->current_fh.fh_dentry)
-		return nfserr_nofilehandle;
-
 	fh_dup2(&cstate->save_fh, &cstate->current_fh);
 	if (HAS_CSTATE_FLAG(cstate, CURRENT_STATE_ID_FLAG)) {
 		memcpy(&cstate->save_stateid, &cstate->current_stateid, sizeof(stateid_t));
@@ -725,10 +719,8 @@ static void gen_boot_verifier(nfs4_verifier *verifier, struct net *net)
 	   union nfsd4_op_u *u)
 {
 	struct nfsd4_link *link = &u->link;
-	__be32 status = nfserr_nofilehandle;
+	__be32 status;
 
-	if (!cstate->save_fh.fh_dentry)
-		return status;
 	status = nfsd_link(rqstp, &cstate->current_fh,
 			   link->li_name, link->li_namelen, &cstate->save_fh);
 	if (!status)
@@ -873,10 +865,8 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
 	     union nfsd4_op_u *u)
 {
 	struct nfsd4_rename *rename = &u->rename;
-	__be32 status = nfserr_nofilehandle;
+	__be32 status;
 
-	if (!cstate->save_fh.fh_dentry)
-		return status;
 	if (opens_in_grace(SVC_NET(rqstp)) &&
 		!(cstate->save_fh.fh_export->ex_flags & NFSEXP_NOSUBTREECHECK))
 		return nfserr_grace;
-- 
1.8.3.1

