From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 02/47] sunrpc: add cl_private field to struct rpc_clnt
Date: Sat, 28 Mar 2009 16:37:39 -0400
Message-ID: <1238272659.14792.29.camel@heimdal.trondhjem.org>
References: <49CC40E5.2080506@panasas.com>
	 <1238122908-6967-1-git-send-email-bhalevy@panasas.com>
	 <20090328000552.GJ18222@fieldses.org>
	 <E166DD1F-96CC-4F61-B215-7CE5FCEF20C4@netapp.com>
	 <49CDDDBB.9060706@panasas.com>
	 <1238261035.6679.4.camel@heimdal.trondhjem.org>
	 <49CE5E6D.7080806@panasas.com>
	 <1238261753.6679.13.camel@heimdal.trondhjem.org>
	 <49CE79F4.1060106@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52549 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751007AbZC1Uhw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 28 Mar 2009 16:37:52 -0400
In-Reply-To: <49CE79F4.1060106@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2009-03-28 at 22:26 +0300, Benny Halevy wrote:
> On Mar. 28, 2009, 20:35 +0300, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> > On Sat, 2009-03-28 at 20:29 +0300, Benny Halevy wrote:
> >> On Mar. 28, 2009, 20:23 +0300, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> >>> On Sat, 2009-03-28 at 11:20 +0300, Benny Halevy wrote:
> >>>> On Mar. 28, 2009, 3:39 +0300, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> >>>>> On Mar 27, 2009, at 8:06 PM, "J. Bruce Fields" <bfields@fieldses.org>  
> >>>>> wrote:
> >>>>>
> >>>>>> On Fri, Mar 27, 2009 at 06:01:48AM +0300, Benny Halevy wrote:
> >>>>>>> From: Andy Adamson <andros@netapp.com>
> >>>>>>>
> >>>>>>> Note: the NFSv4.1 client also uses (and declares) this pointer.
> >>>>>> OK.  Ack from trond?
> >>>>> First, someone would need to remind me why it is necessary, and add  
> >>>>> that justification to the changelog.
> >>>> First time this is used in this patchset is here:
> >>>> [PATCH 35/47] nfsd: minorversion support for the back channel
> >>>>
> >>>> The client uses cl_private to determine the minorversion
> >>>> (via a struct nfs_client *) to be set in the compound header,
> >>>> and to know when to generate a SEQUENCE op.
> >>>> Similarly, the server puts a struct nfs4_callback * in
> >>>> there for callback compounds' CB_COMPOUND and CB_SEQUENCE.
> >>> Why would the rpc_client need to know and track minor versions? That is
> >>> an NFS protocol specific thing.
> >> Agreed.  the rpc_client doesn't know anything about the minor version.
> >> This is why we store it in a void *cl_private.
> >>
> >>> Besides, the caller should always know what minor version it is using.
> >>> It shouldn't need a back-pointer in the rpc_client...
> >>>
> >> The back pointer is used in the xdr layer like this:
> >>  	struct xdr_stream xdr;
> >> +	struct nfs_client *clp =
> >> +		(struct nfs_client *)req->rq_task->tk_client->cl_private;
> >>  	struct compound_hdr hdr = {
> >> -		.nops = 0,
> >> +		.minorversion = clp->cl_minorversion,
> >>  	};
> > 
> > Just put that information in the RPC arguments where it _BELONGS_.
> > 
> 
> BTW, we are going back and forth on this...
> cl_private was suggested on the review we did on November '08:
> http://linux-nfs.org/pipermail/pnfs/2008-November/005435.html

No. I've never acked the idea of putting RPC function arguments into
private fields in the rpc_client. That's simply unacceptably ugly. If
you and Andy got that impression, then one of us must have misunderstood
what the other party was saying.

I do seem to remember talk about needing back-pointers to the session in
order to support the NFSv4.1 backchannel, but that's an entirely
different matter.

Note that it is probably worth caching the minor version inside the
session pointer instead of having to dereference the nfs_client on every
RPC call.
That can be a separate patch, though.

> Anyway, the following adds a *session to the nfs4_sequence_args
> and res. It increases the memory footprint of all rpc args and res
> but I agree it's cleaner.

The session is clearly an argument to the sequence op, and so deserves
to be kept in the rpc_args.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
