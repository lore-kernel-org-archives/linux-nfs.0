Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:45456 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751860Ab0JBWuN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 2 Oct 2010 18:50:13 -0400
Date: Sat, 2 Oct 2010 18:49:55 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Bian Naimeng <biannm@cn.fujitsu.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Revert "nfsd4: distinguish expired from stale stateids"
Message-ID: <20101002224954.GD18079@fieldses.org>
References: <20100518233746.GC26911@fieldses.org>
 <4C563CE5.1010101@cn.fujitsu.com>
 <20100802135036.GA12637@fieldses.org>
 <4C57DD66.1070001@cn.fujitsu.com>
 <20100922193933.GJ26903@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100922193933.GJ26903@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Sep 22, 2010 at 03:39:33PM -0400, J. Bruce Fields wrote:
> On Tue, Aug 03, 2010 at 05:12:06PM +0800, Bian Naimeng wrote:
> >   As i see, this question is difficult to slove. Freebsd looks like nerver return 
> >   the NFSERR_EXPIRED error.  And solaris more than happy to return NFSERR_EXPIRED 
> >   rather than NFSERR_BAD_STATEID when the stateid is not found at server.
> > 
> >   I mean it's difficult to distinguish expired_stateid and bad_stateid(they are not
> >   exist at server), so maybe we have not a exactly solution to solve it.
> > 
> >   Maybe we should choose which error we are more needed, NFSERR_EXPIRED  or NFSERR_BAD_STATEID?
> 
> Yes, that would probably be simplest.

So, like this?

--b.

commit 3d5bdf44f73f2e4136d27fe7bd45b9ca6674e590
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Sat Oct 2 18:42:39 2010 -0400

    nfsd4: return expired on unfound stateid's
    
    Commit 78155ed75f470710f2aecb3e75e3d97107ba8374 "nfsd4: distinguish
    expired from stale stateids" attempted to distinguish expired and stale
    stateid's using time information that may not have been completely
    reliable, so I reverted it.
    
    That was throwing out the baby with the bathwater; we still do want to
    return expired, but let's do that using the simpler approach of just
    assuming any stateid is expired if it looks like it was given out by the
    current server instance, but we can't find it any more.
    
    This may help clients that are recovering from network partitions.
    
    Reported-by: Bian Naimeng <biannm@cn.fujitsu.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 596702e..02c23b7 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3046,7 +3046,11 @@ nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
 	if (STALE_STATEID(stateid)) 
 		goto out;
 
-	status = nfserr_bad_stateid;
+	/*
+	 * We assume that any stateid that has the current boot time,
+	 * but that we can't find, is expired:
+	 */
+	status = nfserr_expired;
 	if (is_delegation_stateid(stateid)) {
 		dp = find_delegation_stateid(ino, stateid);
 		if (!dp)
@@ -3066,6 +3070,7 @@ nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
 		stp = find_stateid(stateid, flags);
 		if (!stp)
 			goto out;
+		status = nfserr_bad_stateid;
 		if (nfs4_check_fh(current_fh, stp))
 			goto out;
 		if (!stp->st_stateowner->so_confirmed)
@@ -3140,8 +3145,9 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 		 * a replayed close:
 		 */
 		sop = search_close_lru(stateid->si_stateownerid, flags);
+		/* It's not stale; let's assume it's expired: */
 		if (sop == NULL)
-			return nfserr_bad_stateid;
+			return nfserr_expired;
 		*sopp = sop;
 		goto check_replay;
 	}
@@ -3406,6 +3412,7 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	status = nfserr_bad_stateid;
 	if (!is_delegation_stateid(stateid))
 		goto out;
+	status = nfserr_expired;
 	dp = find_delegation_stateid(inode, stateid);
 	if (!dp)
 		goto out;
