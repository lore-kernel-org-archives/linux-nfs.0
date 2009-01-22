From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2/2] nfsd: only set file_lock.fl_lmops in nfsd4_lockt
	if a stateowner is found
Date: Thu, 22 Jan 2009 14:12:03 -0500
Message-ID: <20090122191203.GD15279@fieldses.org>
References: <1232555691-29859-1-git-send-email-jlayton@redhat.com> <1232555691-29859-3-git-send-email-jlayton@redhat.com> <20090122185232.GC15279@fieldses.org> <20090122135838.7aa9d9f3@barsoom.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org, cluster-devel@redhat.com,
	linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:50711 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755457AbZAVTMB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2009 14:12:01 -0500
In-Reply-To: <20090122135838.7aa9d9f3-xSBYVWDuneFaJnirhKH9O4GKTjYczspe@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 22, 2009 at 01:58:38PM -0500, Jeff Layton wrote:
> On Thu, 22 Jan 2009 13:52:32 -0500
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Wed, Jan 21, 2009 at 11:34:51AM -0500, Jeff Layton wrote:
> > > nfsd4_lockt does a search for a lockstateowner when building the lock
> > > struct to test. If one is found, it'll set fl_owner to it. Regardless of
> > > whether that happens, it'll also set fl_lmops.
> > > 
> > > If a lockstateowner is not found, then we'll have fl_owner set to NULL
> > > and fl_lmops set pointing to nfsd_posix_mng_ops. Other parts of the
> > > NFSv4 server code assume that fl_owner will point to a valid
> > > nfs4_stateowner if fl_lmops is set this way.
> > > 
> > > This behavior exposed a bug in DLM's GETLK implementation where it
> > > wasn't clearing out the fields in the file_lock before filling in
> > > conflicting lock info. While we were able to fix this in DLM, it
> > > still seems pointless and dangerous to set the fl_lmops this way
> > > when we have a NULL lockstateowner.
> > > 
> > > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > > ---
> > >  fs/nfsd/nfs4state.c |    6 ++++--
> > >  1 files changed, 4 insertions(+), 2 deletions(-)
> > > 
> > > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > > index 88db7d3..07d196a 100644
> > > --- a/fs/nfsd/nfs4state.c
> > > +++ b/fs/nfsd/nfs4state.c
> > > @@ -2867,11 +2867,13 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> > >  
> > >  	lockt->lt_stateowner = find_lockstateowner_str(inode,
> > >  			&lockt->lt_clientid, &lockt->lt_owner);
> > > -	if (lockt->lt_stateowner)
> > > +	if (lockt->lt_stateowner) {
> > >  		file_lock.fl_owner = (fl_owner_t)lockt->lt_stateowner;
> > > +		file_lock.fl_lmops = &nfsd_posix_mng_ops;
> > 
> > So I think we just shouldn't need this second assignment at all.
> > 
> > --b.
> > 
> 
> Do we even need to worry about the lockstateowner at all then? If
> fl_lmops isn't set then I think the fl_owner will be basically ignored
> by nfs4_set_lock_denied anyway.

Yeah, I think nfs4_set_lock_denied should just set dummy values for now.

If we don't, then nfsd_test_lock is passing back a lock with a pointer
to a real reference-counted object, and I worry about what happens if
e.g.  locks are being freed concurrently with our processing of the
conflicting lock here.

Our holding the nfs4_state_lock() here may be enough to prevent
problems, but it seems fragile.

And getting the conflicting lock completely right just isn't that high a
priority.

--b.
