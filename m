Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:29296 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752397Ab1CAMQR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Mar 2011 07:16:17 -0500
Subject: RE: [PATCH] zero out delegation in the inode after it has been
 returned
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: daniel.gardere@emc.com
Cc: bfields@fieldses.org, rees@umich.edu, bhalevy@panasas.com,
        linux-nfs@vger.kernel.org, honey@citi.umich.edu
In-Reply-To: <1037D95241CCD148999713870A5F4A8606EE14E851@MX11A.corp.emc.com>
References: <20110228213103.GA1256@merit.edu>
	 <1298929144.8564.44.camel@heimdal.trondhjem.org>
	 <20110228215439.GD1256@merit.edu>
	 <1298930494.8564.50.camel@heimdal.trondhjem.org>
	 <20110228232258.GA1901@merit.edu>
	 <1298937633.18451.9.camel@heimdal.trondhjem.org>
	 <20110301040945.GC17725@fieldses.org>
	 <1037D95241CCD148999713870A5F4A8606EE14E851@MX11A.corp.emc.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 01 Mar 2011 07:16:01 -0500
Message-ID: <1298981761.9306.20.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-03-01 at 04:52 -0500, daniel.gardere@emc.com wrote: 
> It is EMC server.
> 
> The server returns the delegation to the OPEN CLAIM_DELEGATE_CUR operation. At this point the delegation is still valid. This is far before the DELEGRETURN; so this doesn't explain why
> the delegation is used in SETATTR (frame 5596) after the DELEGRETURN (frame 5589, reply in 5592).

It explains _exactly_ what is happening...

The server hands out a delegation in step 4. of the recovery process,
which causes the client to attach a new delegation to the
nfsi->delegation. You can argue that the client shouldn't be doing that
while it is in the middle of a recovery process, but as far as our
client is concerned, it doesn't expect the server to violate the
protocol in this manner.

> Returning a delegation to OPEN CLAIM_DELEGATE_CUR is probably useless, as the client already has this delegation. But, I don't think that it is illegal.
> If this creates the confusion, we can avoid returning the delegation in this case.

See section 8.1.8 (as I noted in my followup email). The server is not
supposed to send a delegation as part of a CLAIM_DELEGATE_CUR request.
You are violating the spec.

Sending a delegation more than once is neither necessary, nor is it
really a good idea even if the client sends multiple CLAIM_NULL calls.
In fact it is a recipe for creating races...
The reasons are:

      * Unlike layouts, there is no 'forgetful' model for delegations.
        Once the client receives a delegation, it is expected to keep
        track of that delegation and return it when it no longer needs
        it. 
      * In NFSv4.0, there is no good way of dealing with races between
        OPEN and CB_RECALL. If the server is handing out a delegation,
        but then needs to recall it for some reason, then it has no way
        of ensuring that the client processes the CB_RECALL _after_ the
        reply to the OPEN in which the delegation was handed out for the
        second time.

IOW: there is a danger of something like the following race occurring:

Client					Server

Send OPEN(CLAIM_NULL)
				hands out delegation
process open result
client now thinks it
holds a delegation

				Server now thinks client
				holds a delegation

Send OPEN(CLAIM_NULL)
				hands out delegation again
				Send CB_RECALL
process CB_RECALL
Send DELEGRETURN

process open result
client now thinks it
holds a delegation

Server thinks client doesn't hold
a delegation.



> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of J. Bruce Fields
> Sent: mardi 1 mars 2011 05:10
> To: Trond Myklebust
> Cc: Jim Rees; Benny Halevy; linux-nfs@vger.kernel.org; peter honeyman
> Subject: Re: [PATCH] zero out delegation in the inode after it has been returned
> 
> On Mon, Feb 28, 2011 at 07:00:33PM -0500, Trond Myklebust wrote:
> > On Mon, 2011-02-28 at 18:22 -0500, Jim Rees wrote: 
> > > Trond Myklebust wrote:
> > > 
> > >   The procedure for returning delegations is supposed to work as follows:
> > >   
> > >        1. Remove the nfsi->delegation so that it is no longer visible to
> > >           new open() requests 
> > >        2. write back any dirty data to the server 
> > >        3. Reclaim any locks 
> > >        4. Reclaim any open stateids (using CLAIM_DELEGATE_CUR) 
> > >        5. delegreturn
> > >   
> > >   While there may indeed be the odd READ or WRITE that races between 4.
> > >   and 5., so that the server receives the delegation stateid after the
> > >   delegreturn, that shouldn't matter: the server returns an error, and the
> > >   client should retry using the new open stateid.
> > >   
> > >   What is failing to work correctly here?
> > > 
> > > That helps, thanks.  I'll see if I can figure out what's going wrong.
> > > 
> > > At the server, I see a delegreturn followed by a setattr using the returned
> > > stateid.  The server returns BAD_STATEID.  I'll look to see if the client
> > > then retries.
> > > 
> > > At the client, I see a non-null nfsi->delegation after the delgreturn, and
> > > the application gets a EIO.
> > 
> > That's because your server is confusing the hell out of us all by giving
> > out a delegation as part of the reply (in frame 5328) to the
> > OPEN(CLAIM_DELEGATE_CUR) in frame 5325.
> > 
> > IOW: the client is in the process of returning the delegation, and asks
> > to trade in the delegation stateid into an open stateid, then the server
> > replies with an open stateid, and the delegation stateid...
> 
> Which server is this, Jim?
> 
> (I checked the Linux server quickly and it doesn't look like it should
> do this....)
> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

