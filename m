Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:36002 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756608AbcEETsU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 May 2016 15:48:20 -0400
Received: by mail-qg0-f50.google.com with SMTP id w36so45708673qge.3
        for <linux-nfs@vger.kernel.org>; Thu, 05 May 2016 12:48:20 -0700 (PDT)
Message-ID: <1462477696.12332.17.camel@poochiereds.net>
Subject: Re: [PATCH 1/6] statx: Add a system call to make enhanced file info
 available
From: Jeff Layton <jlayton@poochiereds.net>
To: NeilBrown <nfbrown@novell.com>, Dave Chinner <david@fromorbit.com>,
        David Howells <dhowells@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-afs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org
Date: Thu, 05 May 2016 15:48:16 -0400
In-Reply-To: <87shxxbc1e.fsf@notabene.neil.brown.name>
References: <20160429125736.23636.47874.stgit@warthog.procyon.org.uk>
	 <20160429125743.23636.85219.stgit@warthog.procyon.org.uk>
	 <20160504225601.GZ26977@dastard> <87shxxbc1e.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2016-05-05 at 10:09 +1000, NeilBrown wrote:
> On Thu, May 05 2016, Dave Chinner wrote:
> 
> > 
> > On Fri, Apr 29, 2016 at 01:57:43PM +0100, David Howells wrote:
> > > 
> > >  (4) File creation time (st_btime*), data version (st_version), inode
> > >      generation number (st_gen).
> > > 
> > >      These will be returned if available whether the caller asked for them or
> > >      not.  The corresponding bits in st_mask will be set or cleared as
> > >      appropriate to indicate a valid value.
> > IMO, exposing the inode generation number to anyone is a potential
> > security problem because they are used in file handles.
> "security through obscurity".  We have Kerberos working really nicely
> for NFS these days.  Do we still care?
> 
> What if the generation number were only made available to "root"?  Would
> that allay your concerns?
> Would that still be useful?
> We already have name_to_handle_at().  Exposing the generation number
> could/should follow the same rules at that.  Or maybe the exposure of
> each field should be guided by the filesystem, depending on (for
> example) whether it is used to provide uniqueness to the filehandle.
> 
> > 
> > 
> > > 
> > >      If the caller didn't ask for them, then they may be approximated.  For
> > >      example, NFS won't waste any time updating them from the server, unless
> > >      as a byproduct of updating something requested.
> > I would suggest that exposing them from the NFS server is something
> > we most definitely don't want to do because they are the only thing
> > that keeps remote users from guessing filehandles with ease....
> Given that the NFS protocol does not define a "generation number"
> attribute, I think there is no risk for them being exposed from the NFS
> server ... except implicitly within the filehandle of course.
> 
> NeilBrown



I don't see a real attack vector here either, but OTOH is there a
potential user of this at the moment? An earlier chunk of the patch
description says:

(7) Inode generation number: Useful for FUSE and userspace NFS servers
     [Bernd Schubert].  This was asked for but later deemed unnecessary
     with the open-by-handle capability available

...the last bit seems to indicate that we don't really need this
anyway, as most userland servers now work with filehandles from the
kernel.

Maybe leave it out for now? It can always be added later.

-- 
Jeff Layton <jlayton@poochiereds.net>

