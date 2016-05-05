Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57146 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754076AbcEEUEN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 May 2016 16:04:13 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1462477696.12332.17.camel@poochiereds.net>
References: <1462477696.12332.17.camel@poochiereds.net> <20160429125736.23636.47874.stgit@warthog.procyon.org.uk> <20160429125743.23636.85219.stgit@warthog.procyon.org.uk> <20160504225601.GZ26977@dastard> <87shxxbc1e.fsf@notabene.neil.brown.name>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: dhowells@redhat.com, NeilBrown <nfbrown@novell.com>,
        Dave Chinner <david@fromorbit.com>, linux-fsdevel@vger.kernel.org,
        linux-afs@vger.kernel.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Subject: Re: [PATCH 1/6] statx: Add a system call to make enhanced file info available
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Date: Thu, 05 May 2016 21:04:09 +0100
Message-ID: <2052.1462478649@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton <jlayton@poochiereds.net> wrote:

> I don't see a real attack vector here either, but OTOH is there a
> potential user of this at the moment?

I'm not sure.  BSD stat has an st_gen, so it's possible something out there
will use it if it exists.

> An earlier chunk of the patch description says:
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

Yeah...  probably a good idea.

David
