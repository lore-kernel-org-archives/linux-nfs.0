Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:56275 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751918Ab0DVT0r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Apr 2010 15:26:47 -0400
Subject: RE: NFSV4 Replica Support?
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Brandon Shandelson <brandon@myshape.com>
Cc: "'J. Bruce Fields'" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
In-Reply-To: <01d801cae250$40e32710$c2a97530$@com>
References: <01c701cae247$e8e50900$baaf1b00$@com>
	 <20100422182213.GA8858@fieldses.org> <01c801cae249$d17ab3d0$74701b70$@com>
	 <20100422183428.GD8858@fieldses.org> <01c901cae24c$7bdd1a00$73974e00$@com>
	 <1271963251.593.8.camel@localhost.localdomain>
	 <01d801cae250$40e32710$c2a97530$@com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 22 Apr 2010 15:26:39 -0400
Message-ID: <1271964399.593.19.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-04-22 at 12:16 -0700, Brandon Shandelson wrote: 
> By allowing the client to use a new/different handle for the same file.

How would it achieve that? The client needs to know where the file is in
order to look it up again. If it got renamed prior to the filehandle
expiring, then the client won't find it without user help.

While we probably will eventually implement client side support for
volatile filehandles on migration, we will never be able to fix all the
problems that they introduce. Relying on them in a production
environment is a crapshoot at best...

Trond 

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Trond Myklebust
> Sent: Thursday, April 22, 2010 12:08 PM
> To: Brandon Shandelson
> Cc: 'J. Bruce Fields'; linux-nfs@vger.kernel.org
> Subject: RE: NFSV4 Replica Support?
> 
> On Thu, 2010-04-22 at 11:49 -0700, Brandon Shandelson wrote: 
> > I thought all of that was handled by NFSV4's "Volatile File Handles" feature.  Seems like "replicas=" is vaporware for all practical uses at this point, although I've read an IBM doc that shows how it works on AIX.
> 
> Handled? How???? All the volatile file handles "feature" does is tell
> you that you can't rely on being able to access your files. If they get
> renamed on the server you are SOL...
> 
> Trond
> 
> > https://publib.boulder.ibm.com/infocenter/pseries/v5r3/index.jsp?topic=/com.ibm.aix.commadmn/doc/commadmndita/nfs_replicas_softmount.htm
> > 
> > Are the NFS server and NFS client code kept functionally in sync?  Would be nice, since I've been hunting this snipe for days now :(
> > 
> > 
> > -Brandon
> > 
> > 
> > -----Original Message-----
> > From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of 'J. Bruce Fields'
> > Sent: Thursday, April 22, 2010 11:34 AM
> > To: Brandon Shandelson
> > Cc: linux-nfs@vger.kernel.org
> > Subject: Re: NFSV4 Replica Support?
> > 
> > On Thu, Apr 22, 2010 at 11:30:00AM -0700, Brandon Shandelson wrote:
> > > I have two NFS servers with NFSV4 exports whose data are synced via Unison.  I want one server to be a hot standby for clients to use in case something happens to the primary NFS server.
> > 
> > That won't work, sorry; even if the file contents are the same, the
> > filehandles are different (unless you copy the actual underlying
> > filesystem images instead of running unison on the two filesystems).
> > And even with that problem fixed, the client probably wouldn't know how
> > to use the replica information.
> > 
> > --b.
> > 
> > > 
> > > The NFS exports look like this:
> > > /home 192.168.0.0/24(rw,fsid=0,insecure,no_subtree_check,async,repli cas=/home@msdevnfs1:/home@msdevnfs2)
> > > 
> > > The mount in fstab looks like this:
> > > msdevnfs1:/ /home nfs4 _netdev,auto 0 0
> > > 
> > > 
> > > -Brandon
> > > 
> > > -----Original Message-----
> > > From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of J. Bruce Fields
> > > Sent: Thursday, April 22, 2010 11:22 AM
> > > To: Brandon Shandelson
> > > Cc: linux-nfs@vger.kernel.org
> > > Subject: Re: NFSV4 Replica Support?
> > > 
> > > On Thu, Apr 22, 2010 at 11:16:20AM -0700, Brandon Shandelson wrote:
> > > > I want to use NFSV4 replicas on Ubuntu 9.10 64-bit servers.  It doesn’t seem
> > > > to work.  It *looks* like the server kernel module supports it, but the NFS
> > > > client does not.  Is this the case, or should I be able to make replicas
> > > > work on Linux?
> > > 
> > > What are you actually trying to do?
> > > 
> > > There's a little support for replication in that the NFSv4 server can be
> > > told to report certain locations as having the same data, but it's not
> > > really supported yet: you need smoething to create the replicas for you
> > > (probably doable with GFS2 as the exported filesystem, or by sharing the
> > > filesystem image if it's read-only).  I don't think the Linux NFSv4
> > > client knows how to use that information yet.
> > > 
> > > --b.
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > > 
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 



