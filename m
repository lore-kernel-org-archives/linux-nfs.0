Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail06.adl2.internode.on.net ([150.101.137.129]:25691 "EHLO
	ipmail06.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754684AbcEFBjz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 May 2016 21:39:55 -0400
Date: Fri, 6 May 2016 11:39:05 +1000
From: Dave Chinner <david@fromorbit.com>
To: David Howells <dhowells@redhat.com>
Cc: Jeff Layton <jlayton@poochiereds.net>, NeilBrown <nfbrown@novell.com>,
        linux-fsdevel@vger.kernel.org, linux-afs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 1/6] statx: Add a system call to make enhanced file info
 available
Message-ID: <20160506013905.GQ18496@dastard>
References: <1462477696.12332.17.camel@poochiereds.net>
 <20160429125736.23636.47874.stgit@warthog.procyon.org.uk>
 <20160429125743.23636.85219.stgit@warthog.procyon.org.uk>
 <20160504225601.GZ26977@dastard>
 <87shxxbc1e.fsf@notabene.neil.brown.name>
 <2052.1462478649@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <2052.1462478649@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 05, 2016 at 09:04:09PM +0100, David Howells wrote:
> Jeff Layton <jlayton@poochiereds.net> wrote:
> 
> > I don't see a real attack vector here either, but OTOH is there a
> > potential user of this at the moment?
> 
> I'm not sure.  BSD stat has an st_gen, so it's possible something out there
> will use it if it exists.

Oh, I know of several userspace applications that use the inode
generation number for some purpose. However, all of them are so
tightly tied to the XFS internal structure, implementation and the
XFS specific bulkstat interface that they cannot be considered
generic applications.

> > An earlier chunk of the patch description says:
> > 
> > (7) Inode generation number: Useful for FUSE and userspace NFS servers
> >      [Bernd Schubert].  This was asked for but later deemed unnecessary
> >      with the open-by-handle capability available
> > 
> > ...the last bit seems to indicate that we don't really need this
> > anyway, as most userland servers now work with filehandles from the
> > kernel.
> > 
> > Maybe leave it out for now? It can always be added later.
> 
> Yeah...  probably a good idea.

Fine by me.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
