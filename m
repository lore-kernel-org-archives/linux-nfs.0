Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:45534 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751249AbdIPOo3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 16 Sep 2017 10:44:29 -0400
Date: Sat, 16 Sep 2017 10:44:29 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Olga Kornievskaia <aglo@umich.edu>,
        Olga Kornievskaia <kolga@netapp.com>,
        Trond Myklebust <Trond.Myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [RFC v3 27/42] NFSD: allow inter server COPY to have a STALE
 source server fh
Message-ID: <20170916144429.GA3866@fieldses.org>
References: <20170711164416.1982-1-kolga@netapp.com>
 <20170711164416.1982-28-kolga@netapp.com>
 <20170908193836.GB18220@fieldses.org>
 <CAN-5tyE17rgXnkzZJM_TVih1cqC5CL4CSp6i5c7bNe+G2vX-Lg@mail.gmail.com>
 <20170915014722.GF7734@parsley.fieldses.org>
 <CAN-5tyHasLG79AQoduP=Bt=L9Tpwy4KVi39J+47nzH2jQnseUw@mail.gmail.com>
 <20170915200221.GA23720@parsley.fieldses.org>
 <20170915200628.GB23720@parsley.fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170915200628.GB23720@parsley.fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 15, 2017 at 04:06:29PM -0400, J. Bruce Fields wrote:
> By the way, I think the current check in nfsd4_savefh is redundant; we
> can probably apply something like the following.  (Untested.)

Fixed and tested version for 4.15.

--b.

commit 6eb90459308b
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Sep 15 16:02:52 2017 -0400

    nfsd: remove unnecessary nofilehandle checks
    
    These checks should have already be done centrally in
    nfsd4_proc_compound, the checks in each individual operation are
    unnecessary.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 3c69db7d4905..7aff6d383d34 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -485,9 +485,6 @@ static __be32
 nfsd4_getfh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	    union nfsd4_op_u *u)
 {
-	if (!cstate->current_fh.fh_dentry)
-		return nfserr_nofilehandle;
-
 	u->getfh = &cstate->current_fh;
 	return nfs_ok;
 }
@@ -535,9 +532,6 @@ static __be32
 nfsd4_savefh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	     union nfsd4_op_u *u)
 {
-	if (!cstate->current_fh.fh_dentry)
-		return nfserr_nofilehandle;
-
 	fh_dup2(&cstate->save_fh, &cstate->current_fh);
 	if (HAS_STATE_ID(cstate, CURRENT_STATE_ID_FLAG)) {
 		memcpy(&cstate->save_stateid, &cstate->current_stateid, sizeof(stateid_t));
@@ -703,10 +697,8 @@ nfsd4_link(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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
@@ -850,10 +842,8 @@ nfsd4_rename(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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
