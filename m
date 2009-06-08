From: "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>
Subject: RE: [pnfs] [RFC 07/39] nfs41: New backchannel helper routines
Date: Mon, 8 Jun 2009 13:49:59 -0700
Message-ID: <273FE88A07F5D445824060902F7003440627B9EA@SACMVEXC1-PRD.hq.netapp.com>
References: <1244205630.5410.23.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Benny Halevy" <bhalevy@panasas.com>, <linux-nfs@vger.kernel.org>,
	<pnfs@linux-nfs.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37380 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752072AbZFHUx1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jun 2009 16:53:27 -0400
In-Reply-To: <1244205630.5410.23.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Myklebust, Trond
> Sent: Friday, June 05, 2009 5:41 AM
> To: Labiaga, Ricardo
> Cc: Benny Halevy; linux-nfs@vger.kernel.org; pnfs@linux-nfs.org
> Subject: RE: [pnfs] [RFC 07/39] nfs41: New backchannel helper routines
> 
> On Thu, 2009-06-04 at 19:17 -0700, Labiaga, Ricardo wrote:
> > > > +/*
> > > > + * Helper routines that track the number of preallocation
elements
> > > > + * on the transport.
> > > > + */
> > > > +static inline int xprt_need_to_requeue(struct rpc_xprt *xprt)
> > > > +{
> > > > +	return xprt->bc_alloc_count > 0;
> > > > +}
> > >
> > > Shouldn't this be 'xprt->bc_alloc_count < min_reqs' or something
like
> > > that?
> >
> > xprt->bc_alloc_count is correct because 'bc_alloc_count' tracks the
> > number of backchannels that have been setup.  In other words, return
the
> > preallocated structure to the queue if there are backchannels that
will
> > eventually consume the 'struct rpc_xprt'.  Otherwise it gets freed.
> > 'bc_alloc_count' does not track the number of 'struct rpc_xprt'.
> 
> OK... I think I now understand what this is doing.
> 
> Basically, you are keeping a count of the number of requests that you
> want to keep preallocated. 

Correct.

> When you destroy the back channel, then you
                     ^^^
                     last

> set it to zero, and destroy all those requests that are on the
'unused'
> list, then you destroy all remaining requests in the xprt_release()
> callback instead of requeuing them in the 'unused' list.

Correct.

> 
> Hmm... Wouldn't just a flag have been sufficient here? Why do you need
> to make bc_alloc_count a counter?
> 

We can have more than one session, and more than one backchannel.
That's why I'm using a counter and not a flag.

> > > Why are we allocating full pages here? 99.9999999% of all
callbacks
> > are
> > > going to be small. The only exception is CB_NOTIFY, and we're not
yet
> > > sure we're ever going to want those...
> >
> > CB_NOTIFY_DEVICEID can also get long if the server uses multiple
> > deviceids.  It can be an unbound list, but the client does have the
> > ability of telling the server the maximum size of the callback
requests.
> > Each deviceID is 16 bytes, so it doesn't take many to fill a page.
Is
> > it an overkill just for this case?  I could change it if you really
want
> > us to.
> 
> All right, let's keep it for the moment then, but please add a comment
> explaining how you pulled this particular number out of your hat.
> 

Will do.

- ricardo

> Trond
> --
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
