From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 1/3] nfsd: don't try to shut down nfs4 state handling
 unless it's up
Date: Wed, 9 Jun 2010 06:29:22 -0400
Message-ID: <20100609062922.4bae21ac@corrin.poochiereds.net>
References: <1275924800-5214-1-git-send-email-jlayton@redhat.com>
	<1275924800-5214-2-git-send-email-jlayton@redhat.com>
	<20100608235828.GK26435@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7827 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751612Ab0FIK1j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Jun 2010 06:27:39 -0400
In-Reply-To: <20100608235828.GK26435@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 8 Jun 2010 19:58:28 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Jun 07, 2010 at 11:33:18AM -0400, Jeff Layton wrote:
> > If someone tries to shut down the laundry_wq while it isn't up it'll
> > cause an oops.
> 
> OK, thanks.
> 
> Hm: what about the opposite (admittedly probably less crucial) problem:
> are there cases where nfs4_state_start() gets called but never
> nfs4_state_shutdown?
> 
> From a quick look, I don't see what prevents that.
> 
> --b.
> 

I don't see that problem. nfs4_state_shutdown gets called when the
nfsd_serv is torn down, and it only gets brought up in nfsd_svc, so as
far as I can tell it'll always be up as long as there are nfsd kthreads
running.

I should make it clear that this patch is just a prerequisite for the
following patches. I don't know of a way to trigger this oops with the
existing code, but if we call svc_destroy from the write_ports
codepaths like I'm proposing then it can happen.

> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  fs/nfsd/nfs4state.c |    2 ++
> >  1 files changed, 2 insertions(+), 0 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index 1176708..fc52920 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -4124,6 +4124,8 @@ __nfs4_state_shutdown(void)
> >  void
> >  nfs4_state_shutdown(void)
> >  {
> > +	if (!nfs4_init)
> > +		return;
> >  	cancel_rearming_delayed_workqueue(laundry_wq, &laundromat_work);
> >  	destroy_workqueue(laundry_wq);
> >  	locks_end_grace(&nfsd4_manager);
> > -- 
> > 1.5.5.6
> > 


-- 
Jeff Layton <jlayton@redhat.com>
