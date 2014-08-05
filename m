Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33906 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753377AbaHES4t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Aug 2014 14:56:49 -0400
Date: Tue, 5 Aug 2014 14:56:47 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: [PATCH 37/37] nfsd: add some comments to the nfsd4 object
 definitions
Message-ID: <20140805185647.GS23341@fieldses.org>
References: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
 <1406723258-8512-38-git-send-email-jlayton@primarydata.com>
 <20140805153628.GP23341@fieldses.org>
 <20140805130105.7eeef9ea@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140805130105.7eeef9ea@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 05, 2014 at 01:01:05PM -0400, Jeff Layton wrote:
> On Tue, 5 Aug 2014 11:36:28 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > Thanks for the documentation!  A couple comments:
> > 
> > On Wed, Jul 30, 2014 at 08:27:38AM -0400, Jeff Layton wrote:
> > > Add some comments that describe what each of these objects is, and how
> > > they related to one another.
> > > 
> > > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> > > ---
> > >  fs/nfsd/netns.h |  8 +++++
> > >  fs/nfsd/state.h | 91 ++++++++++++++++++++++++++++++++++++++++++++++++++++-----
> > >  2 files changed, 92 insertions(+), 7 deletions(-)
> > > 
> > > diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
> > > index 3831ef6e5c75..46680da55cd7 100644
> > > --- a/fs/nfsd/netns.h
> > > +++ b/fs/nfsd/netns.h
> > > @@ -34,6 +34,14 @@
> > >  struct cld_net;
> > >  struct nfsd4_client_tracking_ops;
> > >  
> > > +/*
> > > + * Represents a nfsd "container". With respect to nfsv4 state tracking, the
> > > + * fields of interest are the *_id_hashtbls and the *_name_tree. These track
> > > + * the nfs4_client objects by either short or long form clientid.
> > > + *
> > > + * Each nfsd_net runs a nfs4_laundromat workqueue job every lease period to
> > 
> > It's a little more complicated than that suggests--maybe replace "every
> > lease period" by "when necessary"?
> > 
> 
> Ok, sure...
> 
> > > + * clean up expired clients and delegations within the container.
> > > + */
> > >  struct nfsd_net {
> > >  	struct cld_net *cld_net;
> > >  
> > > diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> > > index a363f6bb621e..52ccd07d92ed 100644
> > > --- a/fs/nfsd/state.h
> > > +++ b/fs/nfsd/state.h
> > > @@ -72,6 +72,11 @@ struct nfsd4_callback {
> > >  	bool cb_done;
> > >  };
> > >  
> > > +/*
> > > + * A core object that represents a "common" stateid. These are generally
> > > + * embedded within the different (more specific) stateid objects and contain
> > > + * fields that are of general use to any stateid.
> > > + */
> > >  struct nfs4_stid {
> > >  	atomic_t sc_count;
> > >  #define NFS4_OPEN_STID 1
> > > @@ -89,6 +94,18 @@ struct nfs4_stid {
> > >  	void (*sc_free)(struct nfs4_stid *);
> > >  };
> > >  
> > > +/*
> > > + * Represents a delegation stateid. The nfs4_client holds references to these
> > > + * and they are put when it is being destroyed or when the delegation is
> > > + * returned by the client.
> > 
> > This might be worth another sentence or two.  I believe the references
> > are:
> > 
> > 	- 1 reference as long as a delegation is still in force (taken
> > 	  when it's alloc'd, put when it's returned or revoked)
> > 	- 1 reference as long as a recall rpc is in progress (taken when
> > 	  the lease is broken, put when the rpc exits.
> > 	- 1 more ephemeral reference for each nfsd thread currently
> > 	  doing something with that delegation without holding
> > 	  cl_lock?
> > 
> 
> Sounds about right. Would you rather just add that and the other
> changes you suggested above, or do you want me to resend the patch?

Would you mind resending?

> > (By the way, I wonder if that list_for_each_entry() at the end of
> > nfsd4_process_cb_update actually does anything: hasn't
> > nfsd4_cb_recall_release() already run and removed any delegation from
> > the cl_callbacks list?  I may just be forgetting how this works.)
> > 
> 
> Oh, hm. I'm not sure about that. I didn't touch that bit of code, so I
> don't profess to really understand it either.
> 
> Let's see...
> 
> It's only going to remove it from the list if cb_done is true, and that
> doesn't happen if there was an error and dl_retries isn't exhausted
> yet. So no, I don't think it's dead code...

Ah, I think you're right.  So "when the rpc exits" above should be
something like "when we get a reply to the recall or give up trying".

Thanks again for the documentation here.  Notes on the various data
structures' lifetimes are especially useful, I think.

--b.
