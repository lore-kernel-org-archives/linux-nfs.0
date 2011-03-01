Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:29651 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756093Ab1CAJxK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Mar 2011 04:53:10 -0500
From: <daniel.gardere@emc.com>
To: <bfields@fieldses.org>, <Trond.Myklebust@netapp.com>
CC: <rees@umich.edu>, <bhalevy@panasas.com>, <linux-nfs@vger.kernel.org>,
        <honey@citi.umich.edu>
Date: Tue, 1 Mar 2011 04:52:21 -0500
Subject: RE: [PATCH] zero out delegation in the inode after it has been
 returned
Message-ID: <1037D95241CCD148999713870A5F4A8606EE14E851@MX11A.corp.emc.com>
References: <20110228213103.GA1256@merit.edu>
 <1298929144.8564.44.camel@heimdal.trondhjem.org>
 <20110228215439.GD1256@merit.edu>
 <1298930494.8564.50.camel@heimdal.trondhjem.org>
 <20110228232258.GA1901@merit.edu>
 <1298937633.18451.9.camel@heimdal.trondhjem.org>
 <20110301040945.GC17725@fieldses.org>
In-Reply-To: <20110301040945.GC17725@fieldses.org>
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

It is EMC server.

The server returns the delegation to the OPEN CLAIM_DELEGATE_CUR operation. At this point the delegation is still valid. This is far before the DELEGRETURN; so this doesn't explain why
the delegation is used in SETATTR (frame 5596) after the DELEGRETURN (frame 5589, reply in 5592).

Returning a delegation to OPEN CLAIM_DELEGATE_CUR is probably useless, as the client already has this delegation. But, I don't think that it is illegal.
If this creates the confusion, we can avoid returning the delegation in this case.


-----Original Message-----
From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of J. Bruce Fields
Sent: mardi 1 mars 2011 05:10
To: Trond Myklebust
Cc: Jim Rees; Benny Halevy; linux-nfs@vger.kernel.org; peter honeyman
Subject: Re: [PATCH] zero out delegation in the inode after it has been returned

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
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

