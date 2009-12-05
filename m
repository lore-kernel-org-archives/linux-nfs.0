From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: RE: [PATCH 0/12] Fix session reset deadlocks Version 4
Date: Sat, 05 Dec 2009 15:04:02 -0500
Message-ID: <1260043442.2624.92.camel@localhost>
References: <273FE88A07F5D445824060902F70034408A1A330@SACMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "Adamson, Andy" <William.Adamson@netapp.com>,
	linux-nfs@vger.kernel.org
To: "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6707 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750814AbZLEUKN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 5 Dec 2009 15:10:13 -0500
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id nB5KAJZq028403
	for <linux-nfs@vger.kernel.org>; Sat, 5 Dec 2009 12:10:19 -0800 (PST)
In-Reply-To: <273FE88A07F5D445824060902F70034408A1A330-hX7t0kiaRRpT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-12-04 at 23:05 -0800, Labiaga, Ricardo wrote: 
> I'm seeing a problem with the bits in the nfs-for-next branch when I run
> v4.1.  If a bad session is received after a server reboot, the client
> issues a flood of sequence requests.  The sequence RPCs contain the last
> sequenceID from the previous session with the new sessionID.  This is
> repeated over and over until you ctrl-C the triggering process.  The
> server replies with sequence misordered, but the client issues the exact
> same RPC over and over.
> 
> Also to note is that right after the session is destroyed, the client
> will issue sequence requests with sessionID of 0 right before the create
> session succeeds.

That would indicate a bug in the NFS4CLNT_SESSION_DRAINING code.

OK. I think I see what it is...

Could you try this?

Cheers
  Trond
---------------------------------------------------------------------------- 
NFSv41: nfs4_reset_session must always set NFS4CLNT_SESSION_DRAINING

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Otherwise we have no guarantees that other processes won't start another
RPC call while we're resetting the session.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4state.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)


diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index a86f3ac..bc4ca6f 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1211,8 +1211,8 @@ static int nfs4_reset_session(struct nfs_client *clp)
 
 	INIT_COMPLETION(ses->complete);
 	spin_lock(&tbl->slot_tbl_lock);
+	set_bit(NFS4CLNT_SESSION_DRAINING, &clp->cl_state);
 	if (tbl->highest_used_slotid != -1) {
-		set_bit(NFS4CLNT_SESSION_DRAINING, &clp->cl_state);
 		spin_unlock(&tbl->slot_tbl_lock);
 		status = wait_for_completion_interruptible(&ses->complete);
 		if (status) /* -ERESTARTSYS */

