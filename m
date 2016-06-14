Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:56374 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750968AbcFNO5V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Jun 2016 10:57:21 -0400
Date: Tue, 14 Jun 2016 10:57:20 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: sebastien cabaniols <sebastien.cabaniols@gmail.com>,
        linux-nfs@vger.kernel.org
Subject: Re: does the linux NFS client support for failover to a replica
 share (read-only share)
Message-ID: <20160614145720.GC25973@fieldses.org>
References: <CALipME=i0H5bAHf3AuXU2EnEDOmmzK58x4D7Oz+YDp5MsUao4g@mail.gmail.com>
 <20160613155237.GC17866@fieldses.org>
 <20160614001055.GB2634@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160614001055.GB2634@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 13, 2016 at 07:10:56PM -0500, Malahal Naineni wrote:
> J. Bruce Fields [bfields@fieldses.org] wrote:
> > On Tue, Jun 07, 2016 at 10:02:19PM +0200, sebastien cabaniols wrote:
> > > Hello linux-nfs mailing list.
> > > 
> > > I would like to know if the linux nfs client included in current
> > > versions of the kernel supports fail-over to a replica on another nfs
> > > server, I am using (manually) synchronized read-only shares...
> > > 
> > > I found very few information on Google about this topic and I suspect
> > > this is not implemented.
> > 
> > That's correct (unless I've missed something!).
> > 
> > > I actually tried to setup this using SLES12SP1 (3.12.49 kernel) but I
> > > failed so far. I am not attached to this distribution/version in
> > > particular, just trying to see it working for real.
> > > 
> > > ( I did some "rpcdebug -m nfs" session and it seems the fs_locations
> > > is not getting properly populated on my setup )
> > > 
> > > Any confirmation this should work or not would actually help me.
> > > 
> > > THX.
> > > 
> > > 
> > > note from the exports man page:
> > > 
> > >        replicas=path@host[+host][:path@host[+host]]
> > >               If  the  client  asks for alternative locations for the
> > > export point, it will be given this list of alternatives.
> > >               (Note that actual replication of the filesystem must be
> > > handled elsewhere.)
> > 
> > Yes, the server side (assuming you've got the backend replication
> > working) is pretty easy, and should work (though I don't know if it's
> > gotten any testing).
> 
> Bruce, we did test the server side couple years ago. I don't remember
> any issues on the server side. We did some rudimentary support on the
> client side (we were using rsync for replication and our exports were
> read-only!). I remember "find" having an issue with inode number change
> while it was running, but don't remember any other issues. The client
> patches never made it to mainline though.

Oh, thanks for the reminder.

I wonder if the client's closer to ready for failover support now.  I
don't remember what the issues were.

--b.
