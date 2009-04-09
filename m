Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58579 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755171AbZDITPG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Apr 2009 15:15:06 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: NFS fscache offline mode?
Date: Thu, 9 Apr 2009 12:13:59 -0700
Message-ID: <7A24DF798E223B4C9864E8F92E8C93EC029314E5@SACMVEXC1-PRD.hq.netapp.com>
In-Reply-To: <1253.1239275671@redhat.com>
References: <49dd5b8c.85c2f10a.5f05.1c22@mx.google.com> <1253.1239275671@redhat.com>
From: "Muntz, Daniel" <Dan.Muntz@netapp.com>
To: "David Howells" <dhowells@redhat.com>, "Tom Talpey" <tmtalpey@gmail.com>
Cc: <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

 

> -----Original Message-----
> From: David Howells [mailto:dhowells@redhat.com] 
> Sent: Thursday, April 09, 2009 4:15 AM
> To: Tom Talpey
> Cc: dhowells@redhat.com; linux-nfs@vger.kernel.org
> Subject: Re: NFS fscache offline mode?
> 
> Tom Talpey <tmtalpey@gmail.com> wrote:
> 
> > Does the new NFS fscache support offline mode? That is, can 
> the client 
> > continue to serve cached files even in the absence of any service 
> > communication at all?
> 
> That is not yet supported.  It's quite a tricky problem as 
> the netfs (NFS in this case) has to do conflict resolution 
> when the server is contacted once again, and that might 
> require user interaction.

It's not _so_ tricky for the read-only case, and is quite useful (see
papers by Huston+Honeyman re: disconnected AFS).  For writes, my
recollection is that you pretty much need human intervention to resolve
conflicts unless a trivial resolution mechanism is defined.

> 
> > I see that the fscache itself can do this, but it also seems to 
> > require the netfs (NFS) to invoke it with "pinning" operations.
> > I don't see any pinning calls, or options to request the 
> behavior in 
> > the NFS code currently.
> 
> Pinning and reservations are not yet implemented in the 
> cache.  I've been holding off on implementing them on the 
> basis that until the code gets upstream, I have to expect 
> that I might have to make substantial alterations to the code 
> I do have.
> 
> In any case, offline mode isn't something that FS-Cache 
> itself cares about.
> It is purely a data store.  The network filesystems using it 
> must implement offline mode.

That's a bit flippant.  You could just as well say that the "network"
file system should implement its own disk cache.  If you're going to
cache under the fs, you could also do a lot to hide the disconnected
status from the fs, once again, not too bad if you're doing read-only.

BTW: could we not use the term "network" file system when discussing
FS-Cache?  You've also mentioned using it for iso9660, so it's not just
for network file systems.

> 
> > I actually have one other semi-related question. In 
> fscache-index.c, 
> > the fscache generates keys to match servers by computing an {NFS 
> > version, transport protocol, port, IP address} tuple.  Have 
> you given 
> > thought to how this might work with NFSv4.1 sessions?  With 
> 4.1, the 
> > session allows trunking and reconnection to multiple server 
> addresses. 
> > It appears the cache basically won't hit on such configurations. I 
> > think the nfs_server_key structure will require more 
> thought for 4.1.
> 
> I've been thinking for a while about how to map multiple 
> server addresses onto one cache for servers that all serve 
> the same data.  It's not clear how to do it, since, as far as 
> I know, there's no way to automatically work out that two 
> servers should be treated as being the same.
> 
> With AFS it's easier, since the volumes are defined by the 
> cell they're in, not by the servers that are serving them.  
> As far as I know NFS doesn't do things that way.
> 
> One thing I have wondered about is sticking aliases in the 
> cache (symlinks or
> whatever) when an NFS mount is made that has a list of server 
> addresses.
> However, this assumes:
> 
>  (1) The file handles on one server match those of another 
> server serving the
>      same set of files.
> 
>  (2) If two servers are serving the same data, then 
> overlapping exports match
>      completely.
> 
> I feel there's another problem with aliases like this in the 
> case of the address a server that's been added as an alias 
> being reused to server different data.  What I think I need 
> is consistency data from the server about the server, so that 
> I can tell that the server is no longer what I thought it was.
> 
> 
> In fact, it might be possible to hide the fact that there are 
> aliases from FS-Cache entirely.  Say that the NFS client is 
> given a list of IP addresses that are all serving the same 
> data.  It then uses the lowest IP address it is given as the 
> key to FS-Cache, no matter which server it is actually talking to.
> 
> David
> --
> To unsubscribe from this list: send the line "unsubscribe 
> linux-nfs" in the body of a message to 
> majordomo@vger.kernel.org More majordomo info at  
> http://vger.kernel.org/majordomo-info.html
> 
