Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40268 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758852AbcEFSHt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 May 2016 14:07:49 -0400
Date: Fri, 6 May 2016 14:07:42 -0400
To: Jeff Layton <jlayton@poochiereds.net>
Cc: NeilBrown <nfbrown@novell.com>, Dave Chinner <david@fromorbit.com>,
        David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-afs@vger.kernel.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Subject: Re: [PATCH 1/6] statx: Add a system call to make enhanced file info
 available
Message-ID: <20160506180742.GA13350@fieldses.org>
References: <20160429125736.23636.47874.stgit@warthog.procyon.org.uk>
 <20160429125743.23636.85219.stgit@warthog.procyon.org.uk>
 <20160504225601.GZ26977@dastard>
 <87shxxbc1e.fsf@notabene.neil.brown.name>
 <1462477696.12332.17.camel@poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1462477696.12332.17.camel@poochiereds.net>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 05, 2016 at 03:48:16PM -0400, Jeff Layton wrote:
> On Thu, 2016-05-05 at 10:09 +1000, NeilBrown wrote:
> > On Thu, May 05 2016, Dave Chinner wrote:
> > 
> > > 
> > > On Fri, Apr 29, 2016 at 01:57:43PM +0100, David Howells wrote:
> > > > 
> > > >  (4) File creation time (st_btime*), data version (st_version), inode
> > > >      generation number (st_gen).
> > > > 
> > > >      These will be returned if available whether the caller asked for them or
> > > >      not.  The corresponding bits in st_mask will be set or cleared as
> > > >      appropriate to indicate a valid value.
> > > IMO, exposing the inode generation number to anyone is a potential
> > > security problem because they are used in file handles.
> > "security through obscurity".  We have Kerberos working really nicely
> > for NFS these days.  Do we still care?
> > 
> > What if the generation number were only made available to "root"?  Would
> > that allay your concerns?
> > Would that still be useful?
> > We already have name_to_handle_at().  Exposing the generation number
> > could/should follow the same rules at that.  Or maybe the exposure of
> > each field should be guided by the filesystem, depending on (for
> > example) whether it is used to provide uniqueness to the filehandle.
> > 
> > > 
> > > 
> > > > 
> > > >      If the caller didn't ask for them, then they may be approximated.  For
> > > >      example, NFS won't waste any time updating them from the server, unless
> > > >      as a byproduct of updating something requested.
> > > I would suggest that exposing them from the NFS server is something
> > > we most definitely don't want to do because they are the only thing
> > > that keeps remote users from guessing filehandles with ease....
> > Given that the NFS protocol does not define a "generation number"
> > attribute, I think there is no risk for them being exposed from the NFS
> > server ... except implicitly within the filehandle of course.
> > 
> > NeilBrown
> 
> 
> 
> I don't see a real attack vector here either, but OTOH is there a
> potential user of this at the moment? An earlier chunk of the patch
> description says:
> 
> (7) Inode generation number: Useful for FUSE and userspace NFS servers
>      [Bernd Schubert].  This was asked for but later deemed unnecessary
>      with the open-by-handle capability available
> 
> ...the last bit seems to indicate that we don't really need this
> anyway, as most userland servers now work with filehandles from the
> kernel.
> 
> Maybe leave it out for now? It can always be added later.

Sounds like a good compromise to me!

That said, filehandles can never be changed, and generally have to be
exposed on the network, so I don't think it's worth going to great
lengths to try keep them secret.

--b.
