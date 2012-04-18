Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:4401 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750887Ab2DROu6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Apr 2012 10:50:58 -0400
Date: Wed, 18 Apr 2012 10:51:47 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Luis Henriques <luis.henriques@canonical.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Regretion on NFS in mainline kernel
Message-ID: <20120418105147.2a6f1c55@corrin.poochiereds.net>
In-Reply-To: <1334760105.4701.11.camel@lade.trondhjem.org>
References: <20120418112610.GA3979@zeus>
	<20120418092822.07a4f944@tlielax.poochiereds.net>
	<20120418135738.GB3979@zeus>
	<1334757866.4701.6.camel@lade.trondhjem.org>
	<20120418141313.GC3979@zeus>
	<20120418101554.4aad0849@tlielax.poochiereds.net>
	<1334760105.4701.11.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 18 Apr 2012 14:41:45 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Wed, 2012-04-18 at 10:15 -0400, Jeff Layton wrote:
> > On Wed, 18 Apr 2012 15:13:13 +0100
> > Luis Henriques <luis.henriques@canonical.com> wrote:
> > 
> > > On Wed, Apr 18, 2012 at 02:04:26PM +0000, Myklebust, Trond wrote:
> > > > On Wed, 2012-04-18 at 14:57 +0100, Luis Henriques wrote:
> > > > > Hi Jeff,
> > > > > 
> > > > > On Wed, Apr 18, 2012 at 09:28:22AM -0400, Jeff Layton wrote:
> > > > > > On Wed, 18 Apr 2012 12:26:10 +0100
> > > > > > Luis Henriques <luis.henriques@canonical.com> wrote:
> > > > > > 
> > > > > > > Hi,
> > > > > > > 
> > > > > > > We have a bug reporting a regression in mainline kernel.  Basically, the
> > > > > > > bug reporters are seeing lots of messages:
> > > > > > > 
> > > > > > > [ 48.701213] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> > > > > > > [ 48.701990] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> > > > > > > [ 53.696076] nfs4_reclaim_open_state: 6440 callbacks suppressed
> > > > > > > 
> > > > > > > This happens when mounting a user's home directory over NFS.
> > > > > > > 
> > > > > > > Is this a known issue being addressed at the moment?  Is there any
> > > > > > > information needed to help debugging the issue?
> > > > > > > 
> > > > > > > The original bug report can be found here:
> > > > > > > 
> > > > > > > http://bugs.launchpad.net/bugs/974664
> > > > > > > 
> > > > > > > And there's also a similar report for Fedora:
> > > > > > > 
> > > > > > > https://bugzilla.redhat.com/show_bug.cgi?id=811138
> > > > > > > 
> > > > > > > Cheers,
> > > > > > 
> > > > > > This code in nfs4_reclaim_open_state() looks wrong to me, but I'm not
> > > > > > that familiar with this code so I could be wrong:
> > > > > > 
> > > > > > -------------------[snip]--------------------
> > > > > >                 status = ops->recover_open(sp, state);
> > > > > >                 if (status >= 0) {
> > > > > >                         status = nfs4_reclaim_locks(state, ops);
> > > > > >                         if (status >= 0) {
> > > > > >                                 spin_lock(&state->state_lock);
> > > > > >                                 list_for_each_entry(lock, &state->lock_states, ls_locks) {
> > > > > >                                         if (!(lock->ls_flags & NFS_LOCK_INITIALIZED))
> > > > > >                                                 pr_warn_ratelimited("NFS: "
> > > > > >                                                         "%s: Lock reclaim "
> > > > > >                                                         "failed!\n", __func__);
> > > > > >                                 }
> > > > > >                                 spin_unlock(&state->state_lock);
> > > > > >                                 nfs4_put_open_state(state);
> > > > > >                                 goto restart;
> > > > > >                         }
> > > > > >                 }
> > > > > > -------------------[snip]--------------------
> > > > > > 
> > > > > > Shouldn't the status check after nfs4_reclaim_locks be reversed?
> > > > > 
> > > > > Thanks a lot for your help.  Could you please take a look at the patch
> > > > > below, just to make sure I understood you're suggestion correctly?  I will
> > > > > prepare a test kernel so that we can check whether it actually solves the
> > > > > problem or not.
> > > > > 
> > > > > Cheers,
> > > > > --
> > > > > Luis
> > > > > 
> > > > > 
> > > > > >From a1348f473c157439ac62f502eb45ca48f95e627f Mon Sep 17 00:00:00 2001
> > > > > From: Luis Henriques <luis.henriques@canonical.com>
> > > > > Date: Wed, 18 Apr 2012 14:50:10 +0100
> > > > > Subject: [PATCH 1/1] NFS: Fix status check on nfs4_reclaim_open_state()
> > > > > 
> > > > > There have been several bug reports, with the following messages on the
> > > > > logs:
> > > > > 
> > > > >  [ 48.701213] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> > > > >  [ 48.701990] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> > > > >  [ 53.696076] nfs4_reclaim_open_state: 6440 callbacks suppressed
> > > > > 
> > > > > This happens, for example, when mounting a user's home directory over NFS.
> > > > > 
> > > > > Thanks to Jeff Layton that identified the cause, this patch fixes an
> > > > > incorrect status check on nfs4_reclaim_open_state().
> > > > > 
> > > > > Signed-off-by: Luis Henriques <luis.henriques@canonical.com>
> > > > > ---
> > > > >  fs/nfs/nfs4state.c |    2 +-
> > > > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > > > 
> > > > > diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> > > > > index 07354b7..8b6acec 100644
> > > > > --- a/fs/nfs/nfs4state.c
> > > > > +++ b/fs/nfs/nfs4state.c
> > > > > @@ -1180,7 +1180,7 @@ restart:
> > > > >  		atomic_inc(&state->count);
> > > > >  		spin_unlock(&sp->so_lock);
> > > > >  		status = ops->recover_open(sp, state);
> > > > > -		if (status >= 0) {
> > > > > +		if (status < 0) {
> > > > >  			status = nfs4_reclaim_locks(state, ops);
> > > > >  			if (status >= 0) {
> > > > >  				spin_lock(&state->state_lock);
> > > > 
> > > > Hell no! 
> > > 
> > > Ouch!  Wrong one...
> > > 
> > > From 005918b5eef853fd4d495743fef5a52ae62f825e Mon Sep 17 00:00:00 2001
> > > From: Luis Henriques <luis.henriques@canonical.com>
> > > Date: Wed, 18 Apr 2012 15:08:39 +0100
> > > Subject: [PATCH 1/1] NFS: Fix status check on nfs4_reclaim_open_state()
> > > 
> > > There have been several bug reports, with the following messages on the
> > > logs:
> > > 
> > >  [ 48.701213] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> > >  [ 48.701990] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> > >  [ 53.696076] nfs4_reclaim_open_state: 6440 callbacks suppressed
> > > 
> > > This happens, for example, when mounting a user's home directory over NFS.
> > > 
> > > Thanks to Jeff Layton that identified the cause, this patch fixes an
> > > incorrect status check on nfs4_reclaim_open_state().
> > > 
> > > Signed-off-by: Luis Henriques <luis.henriques@canonical.com>
> > > ---
> > >  fs/nfs/nfs4state.c |    2 +-
> > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > 
> > > diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> > > index 07354b7..023e09f 100644
> > > --- a/fs/nfs/nfs4state.c
> > > +++ b/fs/nfs/nfs4state.c
> > > @@ -1182,7 +1182,7 @@ restart:
> > >  		status = ops->recover_open(sp, state);
> > >  		if (status >= 0) {
> > >  			status = nfs4_reclaim_locks(state, ops);
> > > -			if (status >= 0) {
> > > +			if (status < 0) {
> > >  				spin_lock(&state->state_lock);
> > >  				list_for_each_entry(lock, &state->lock_states, ls_locks) {
> > >  					if (!(lock->ls_flags & NFS_LOCK_INITIALIZED))
> > 
> > Yeah, that looks more reasonable, but again I'm not sure about this
> > either way. This code has been this way for a long time and it's not
> > clear to me why it's only now become a problem if it is wrong.
> 
> Right. Random (and wrong!) changes such as the above won't fix the
> problem. That code is perfectly correct (look at the nfs4_reclaim_locks
> error cases to see why).
> 

Ugh, ok I see and that code is correct even if it's a bit hard to
follow...

We clear the state_flag_bit on the first attempt against that lock so
if it returns 0 (meaning a successful reclaim, we'll skip over it on
the next pass through the loop.

> Have you instead looked into what these applications are doing? Are they
> perhaps opening the file read only, then trying to apply an exclusive
> BSD lock (something which NFSv4 cannot support)?
> 
> IOW: does the problem go away if you mount with 'local_lock=flock'?
> 


I suspect that that is the trigger here. Sadly common among userspace
apps...


-- 
Jeff Layton <jlayton@redhat.com>
