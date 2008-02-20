From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] lockd: fix race in nlm_release()
Date: Wed, 20 Feb 2008 14:48:38 -0500
Message-ID: <1203536918.15034.11.camel@heimdal.trondhjem.org>
References: <20080220191153.GG30160@fieldses.org>
	 <1203535466.15034.5.camel@heimdal.trondhjem.org>
	 <20080220192759.GI30160@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:45985 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756118AbYBTTsn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Feb 2008 14:48:43 -0500
In-Reply-To: <20080220192759.GI30160@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-02-20 at 14:27 -0500, J. Bruce Fields wrote:
> On Wed, Feb 20, 2008 at 02:24:26PM -0500, Trond Myklebust wrote:
> > 
> > On Wed, 2008-02-20 at 14:11 -0500, J. Bruce Fields wrote:
> > > From: J. Bruce Fields <bfields@citi.umich.edu>
> > > 
> > > The sm_count is decremented to zero but left on the nsm_handles list.
> > > So in the space between decrementing sm_count and acquiring nsm_mutex,
> > > it is possible for another task to find this nsm_handle, increment the
> > > use count and then enter nsm_release itself.
> > > 
> > > Thus there's nothing to prevent the nsm being freed before we acquire
> > > nsm_mutex here.
> > > 
> > > Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> > > ---
> > >  fs/lockd/host.c |   10 ++++------
> > >  1 files changed, 4 insertions(+), 6 deletions(-)
> > > 
> > > Am I missing something here?--b.
> > > 
> > > diff --git a/fs/lockd/host.c b/fs/lockd/host.c
> > > index c3f1194..960911c 100644
> > > --- a/fs/lockd/host.c
> > > +++ b/fs/lockd/host.c
> > > @@ -529,12 +529,10 @@ nsm_release(struct nsm_handle *nsm)
> > >  {
> > >  	if (!nsm)
> > >  		return;
> > > +	mutex_lock(&nsm_mutex);
> > >  	if (atomic_dec_and_test(&nsm->sm_count)) {
> > > -		mutex_lock(&nsm_mutex);
> > > -		if (atomic_read(&nsm->sm_count) == 0) {
> > > -			list_del(&nsm->sm_link);
> > > -			kfree(nsm);
> > > -		}
> > > -		mutex_unlock(&nsm_mutex);
> > > +		list_del(&nsm->sm_link);
> > > +		kfree(nsm);
> > >  	}
> > > +	mutex_unlock(&nsm_mutex);
> > >  }
> > 
> > It would be nice to get rid of that mutex. That should really be either
> > a spinlock or an rcu-protected list...
> 
> OK, I'll look into doing that next.
> 
> If you've got any other suggestions while I'm in the general area, I'm
> all ears.

Just the usual plea to replace the host->h_server flag with 2 separate
lists: one list of client nlm_hosts, and one list of server
nlm_hosts :-)

...Oh and a minor optimisation: If we're using a loopback mount, I don't
think we'll ever need to monitor 'localhost' :-)


