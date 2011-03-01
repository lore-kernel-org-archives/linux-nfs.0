Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41067 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753170Ab1CAEJu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Feb 2011 23:09:50 -0500
Date: Mon, 28 Feb 2011 23:09:45 -0500
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Jim Rees <rees@umich.edu>, Benny Halevy <bhalevy@panasas.com>,
        linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH] zero out delegation in the inode after it has been
 returned
Message-ID: <20110301040945.GC17725@fieldses.org>
References: <20110228213103.GA1256@merit.edu>
 <1298929144.8564.44.camel@heimdal.trondhjem.org>
 <20110228215439.GD1256@merit.edu>
 <1298930494.8564.50.camel@heimdal.trondhjem.org>
 <20110228232258.GA1901@merit.edu>
 <1298937633.18451.9.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1298937633.18451.9.camel@heimdal.trondhjem.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Feb 28, 2011 at 07:00:33PM -0500, Trond Myklebust wrote:
> On Mon, 2011-02-28 at 18:22 -0500, Jim Rees wrote: 
> > Trond Myklebust wrote:
> > 
> >   The procedure for returning delegations is supposed to work as follows:
> >   
> >        1. Remove the nfsi->delegation so that it is no longer visible to
> >           new open() requests 
> >        2. write back any dirty data to the server 
> >        3. Reclaim any locks 
> >        4. Reclaim any open stateids (using CLAIM_DELEGATE_CUR) 
> >        5. delegreturn
> >   
> >   While there may indeed be the odd READ or WRITE that races between 4.
> >   and 5., so that the server receives the delegation stateid after the
> >   delegreturn, that shouldn't matter: the server returns an error, and the
> >   client should retry using the new open stateid.
> >   
> >   What is failing to work correctly here?
> > 
> > That helps, thanks.  I'll see if I can figure out what's going wrong.
> > 
> > At the server, I see a delegreturn followed by a setattr using the returned
> > stateid.  The server returns BAD_STATEID.  I'll look to see if the client
> > then retries.
> > 
> > At the client, I see a non-null nfsi->delegation after the delgreturn, and
> > the application gets a EIO.
> 
> That's because your server is confusing the hell out of us all by giving
> out a delegation as part of the reply (in frame 5328) to the
> OPEN(CLAIM_DELEGATE_CUR) in frame 5325.
> 
> IOW: the client is in the process of returning the delegation, and asks
> to trade in the delegation stateid into an open stateid, then the server
> replies with an open stateid, and the delegation stateid...

Which server is this, Jim?

(I checked the Linux server quickly and it doesn't look like it should
do this....)

--b.
