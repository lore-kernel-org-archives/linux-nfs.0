Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55892 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030936Ab2CFULU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Mar 2012 15:11:20 -0500
Date: Tue, 6 Mar 2012 15:11:19 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] nfsd: convert nfs4_client->cl_cb_flags to a
 generic flags field
Message-ID: <20120306201119.GA24741@fieldses.org>
References: <1330965756-24180-1-git-send-email-jlayton@redhat.com>
 <1330965756-24180-2-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1330965756-24180-2-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 05, 2012 at 11:42:35AM -0500, Jeff Layton wrote:
> We'll need a way to flag the nfs4_client as already being recorded on
> stable storage so that we don't continually upcall. Currently, that's
> recorded in the cl_firststate field of the client struct. Using an
> entire u32 to store a flag is rather wasteful though.
> 
> The cl_cb_flags field is only using 2 bits right now, so repurpose that
> to a generic flags field. Rename NFSD4_CLIENT_KILL to
> NFSD4_CLIENT_CB_KILL to make it evident that it's part of the callback
> flags. Add a mask that we can use for existing checks that look to see
> whether any flags are set, so that the new flags don't interfere.
> 
> Convert all references to cl_firstate to the NFSD4_CLIENT_STABLE flag,
> and add a new NFSD4_CLIENT_RECLAIM_COMPLETE flag. I believe there's an
> existing bug here too that this should fix:
> 
> nfs4_set_claim_prev sets cl_firststate on the first CLAIM_PREV open.
> nfsd4_reclaim_complete looks for that flag though, and returns
> NFS4ERR_COMPLETE_ALREADY if it's set. The upshot here is that once a
> client does a CLAIM_PREV open, the RECLAIM_COMPLETE call will fail.
> Let's fix this by adding a new RECLAIM_COMPLETE flag on the client to
> indicate that that's already been done.

I think this is right, and agree that flags make more sense.  But as a
quick bugfix only, how about this?

--b.

commit a61eba426304acb3f6ef32e0505e2001fc695107
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Tue Mar 6 14:35:16 2012 -0500

    nfsd4: don't set cl_firststate on first reclaim in 4.1 case
    
    We set cl_firststate when we first decide that a client will be
    permitted to reclaim state on next boot.  This happens:
    
    	- for new 4.0 clients, when they confirm their first open
    	- for returning 4.0 clients, when they reclaim their first open
    	- for 4.1+ clients, when they perform reclaim_complete
    
    We also use cl_firststate to decide whether a reclaim_complete has
    already been performed, in the 4.1+ case.
    
    We were setting it on 4.1 open reclaims, which caused spurious
    COMPLETE_ALREADY errors on RECLAIM_COMPLETE from an nfs4.1 client with
    anything to reclaim.
    
    Reported-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 967c677..207c3bd 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2778,10 +2778,15 @@ nfs4_upgrade_open(struct svc_rqst *rqstp, struct nfs4_file *fp, struct svc_fh *c
 
 
 static void
-nfs4_set_claim_prev(struct nfsd4_open *open)
+nfs4_set_claim_prev(struct nfsd4_open *open, bool has_session)
 {
 	open->op_openowner->oo_flags |= NFS4_OO_CONFIRMED;
-	open->op_openowner->oo_owner.so_client->cl_firststate = 1;
+	/*
+	 * On a 4.1+ client, we don't create a state record for a client
+	 * until it performs RECLAIM_COMPLETE:
+	 */
+	if (!has_session)
+		open->op_openowner->oo_owner.so_client->cl_firststate = 1;
 }
 
 /* Should we give out recallable state?: */
@@ -3044,7 +3049,7 @@ out:
 	if (fp)
 		put_nfs4_file(fp);
 	if (status == 0 && open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS)
-		nfs4_set_claim_prev(open);
+		nfs4_set_claim_prev(open, nfsd4_has_session(&resp->cstate));
 	/*
 	* To finish the open response, we just need to set the rflags.
 	*/
