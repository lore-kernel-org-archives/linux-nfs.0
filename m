From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/3] nfsd: don't try to shut down nfs4 state handling
	unless it's up
Date: Wed, 9 Jun 2010 14:09:07 -0400
Message-ID: <20100609180907.GB10953@fieldses.org>
References: <1275924800-5214-1-git-send-email-jlayton@redhat.com> <1275924800-5214-2-git-send-email-jlayton@redhat.com> <20100608235828.GK26435@fieldses.org> <20100609062922.4bae21ac@corrin.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54635 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752222Ab0FISJJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Jun 2010 14:09:09 -0400
In-Reply-To: <20100609062922.4bae21ac-4QP7MXygkU+dMjc06nkz3ljfA9RmPOcC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 09, 2010 at 06:29:22AM -0400, Jeff Layton wrote:
> On Tue, 8 Jun 2010 19:58:28 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Mon, Jun 07, 2010 at 11:33:18AM -0400, Jeff Layton wrote:
> > > If someone tries to shut down the laundry_wq while it isn't up it'll
> > > cause an oops.
> > 
> > OK, thanks.
> > 
> > Hm: what about the opposite (admittedly probably less crucial) problem:
> > are there cases where nfs4_state_start() gets called but never
> > nfs4_state_shutdown?
> > 
> > From a quick look, I don't see what prevents that.
> > 
> > --b.
> > 
> 
> I don't see that problem. nfs4_state_shutdown gets called when the
> nfsd_serv is torn down, and it only gets brought up in nfsd_svc,

If nfs4_state_start() succeeds, then nfsd_create_server() is called.  It calls
svc_create_pooled(), which is passed nfsd_last_thread() as a parameter.

If svc_create_pooled succeeds, then I think we're guaranteed nfsd_last_thread()
will get called eventually.

But if svc_create_pooled fails, I don't think nfsd_last_thread() is ever
called.

--b.

> so as
> far as I can tell it'll always be up as long as there are nfsd kthreads
> running.
> 
> I should make it clear that this patch is just a prerequisite for the
> following patches. I don't know of a way to trigger this oops with the
> existing code, but if we call svc_destroy from the write_ports
> codepaths like I'm proposing then it can happen.
> 
> > > 
> > > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > > ---
> > >  fs/nfsd/nfs4state.c |    2 ++
> > >  1 files changed, 2 insertions(+), 0 deletions(-)
> > > 
> > > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > > index 1176708..fc52920 100644
> > > --- a/fs/nfsd/nfs4state.c
> > > +++ b/fs/nfsd/nfs4state.c
> > > @@ -4124,6 +4124,8 @@ __nfs4_state_shutdown(void)
> > >  void
> > >  nfs4_state_shutdown(void)
> > >  {
> > > +	if (!nfs4_init)
> > > +		return;
> > >  	cancel_rearming_delayed_workqueue(laundry_wq, &laundromat_work);
> > >  	destroy_workqueue(laundry_wq);
> > >  	locks_end_grace(&nfsd4_manager);
> > > -- 
> > > 1.5.5.6
> > > 
> 
> 
> -- 
> Jeff Layton <jlayton@redhat.com>
