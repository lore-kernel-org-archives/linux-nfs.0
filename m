Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:33337 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753013AbZDILOf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Apr 2009 07:14:35 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <49dd5b8c.85c2f10a.5f05.1c22@mx.google.com>
References: <49dd5b8c.85c2f10a.5f05.1c22@mx.google.com>
To: Tom Talpey <tmtalpey@gmail.com>
Cc: dhowells@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: NFS fscache offline mode?
Date: Thu, 09 Apr 2009 12:14:31 +0100
Message-ID: <1253.1239275671@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Tom Talpey <tmtalpey@gmail.com> wrote:

> Does the new NFS fscache support offline mode? That is, can
> the client continue to serve cached files even in the absence
> of any service communication at all?

That is not yet supported.  It's quite a tricky problem as the netfs (NFS in
this case) has to do conflict resolution when the server is contacted once
again, and that might require user interaction.

> I see that the fscache itself can do this, but it also seems to
> require the netfs (NFS) to invoke it with "pinning" operations.
> I don't see any pinning calls, or options to request the behavior
> in the NFS code currently.

Pinning and reservations are not yet implemented in the cache.  I've been
holding off on implementing them on the basis that until the code gets
upstream, I have to expect that I might have to make substantial alterations
to the code I do have.

In any case, offline mode isn't something that FS-Cache itself cares about.
It is purely a data store.  The network filesystems using it must implement
offline mode.

> I actually have one other semi-related question. In fscache-index.c, the
> fscache generates keys to match servers by computing an {NFS version,
> transport protocol, port, IP address} tuple.  Have you given thought to how
> this might work with NFSv4.1 sessions?  With 4.1, the session allows
> trunking and reconnection to multiple server addresses. It appears the cache
> basically won't hit on such configurations. I think the nfs_server_key
> structure will require more thought for 4.1.

I've been thinking for a while about how to map multiple server addresses onto
one cache for servers that all serve the same data.  It's not clear how to do
it, since, as far as I know, there's no way to automatically work out that two
servers should be treated as being the same.

With AFS it's easier, since the volumes are defined by the cell they're in,
not by the servers that are serving them.  As far as I know NFS doesn't do
things that way.

One thing I have wondered about is sticking aliases in the cache (symlinks or
whatever) when an NFS mount is made that has a list of server addresses.
However, this assumes:

 (1) The file handles on one server match those of another server serving the
     same set of files.

 (2) If two servers are serving the same data, then overlapping exports match
     completely.

I feel there's another problem with aliases like this in the case of the
address a server that's been added as an alias being reused to server
different data.  What I think I need is consistency data from the server about
the server, so that I can tell that the server is no longer what I thought it
was.


In fact, it might be possible to hide the fact that there are aliases from
FS-Cache entirely.  Say that the NFS client is given a list of IP addresses
that are all serving the same data.  It then uses the lowest IP address it is
given as the key to FS-Cache, no matter which server it is actually talking
to.

David
