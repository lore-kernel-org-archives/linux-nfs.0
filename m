Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36056 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031568Ab2CFXO4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Mar 2012 18:14:56 -0500
Date: Tue, 6 Mar 2012 18:14:54 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] nfsd: convert nfs4_client->cl_cb_flags to a
 generic flags field
Message-ID: <20120306231454.GA26981@fieldses.org>
References: <1330965756-24180-1-git-send-email-jlayton@redhat.com>
 <1330965756-24180-2-git-send-email-jlayton@redhat.com>
 <20120306201119.GA24741@fieldses.org>
 <20120306201438.GB24741@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120306201438.GB24741@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 06, 2012 at 03:14:38PM -0500, J. Bruce Fields wrote:
> On Tue, Mar 06, 2012 at 03:11:19PM -0500, J. Bruce Fields wrote:
> > On Mon, Mar 05, 2012 at 11:42:35AM -0500, Jeff Layton wrote:
> > > We'll need a way to flag the nfs4_client as already being recorded on
> > > stable storage so that we don't continually upcall. Currently, that's
> > > recorded in the cl_firststate field of the client struct. Using an
> > > entire u32 to store a flag is rather wasteful though.
> > > 
> > > The cl_cb_flags field is only using 2 bits right now, so repurpose that
> > > to a generic flags field. Rename NFSD4_CLIENT_KILL to
> > > NFSD4_CLIENT_CB_KILL to make it evident that it's part of the callback
> > > flags. Add a mask that we can use for existing checks that look to see
> > > whether any flags are set, so that the new flags don't interfere.
> > > 
> > > Convert all references to cl_firstate to the NFSD4_CLIENT_STABLE flag,
> > > and add a new NFSD4_CLIENT_RECLAIM_COMPLETE flag. I believe there's an
> > > existing bug here too that this should fix:
> > > 
> > > nfs4_set_claim_prev sets cl_firststate on the first CLAIM_PREV open.
> > > nfsd4_reclaim_complete looks for that flag though, and returns
> > > NFS4ERR_COMPLETE_ALREADY if it's set. The upshot here is that once a
> > > client does a CLAIM_PREV open, the RECLAIM_COMPLETE call will fail.
> > > Let's fix this by adding a new RECLAIM_COMPLETE flag on the client to
> > > indicate that that's already been done.
> > 
> > I think this is right, and agree that flags make more sense.  But as a
> > quick bugfix only, how about this?
> 
> Also I think there's another preexisting bug here.  Yuch.

And one more minor leak on error.

commit a8ae08ebf1f336808e20c1c275f68d36d88e0682
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Tue Mar 6 15:52:04 2012 -0500

    nfsd4: fix recovery-entry leak nfsd startup failure
    
    Another leak on error
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ffb46d6..90c7e06 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4706,6 +4706,7 @@ nfs4_state_start(void)
 out_free_laundry:
 	destroy_workqueue(laundry_wq);
 out_recovery:
+	nfs4_release_reclaim();
 	nfsd4_shutdown_recdir();
 	return ret;
 }
