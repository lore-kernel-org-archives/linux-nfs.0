From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,PATCH 0/14] A transport switch for knfsd
Date: Thu, 17 May 2007 17:00:04 +1000
Message-ID: <20070517070004.GC27247@sgi.com>
References: <20070516191821.GF9626@sgi.com>
	<20070516205316.GC18927@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Thomas Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HoZy8-0007M6-7r
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 00:00:12 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX1/2Zy59QSfEs/6yvrT+zz7+3oQLbrUPSiE=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HoZy9-0002cV-VQ
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 00:00:15 -0700
In-Reply-To: <20070516205316.GC18927@fieldses.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, May 16, 2007 at 04:53:17PM -0400, J. Bruce Fields wrote:
> On Thu, May 17, 2007 at 05:18:21AM +1000, Greg Banks wrote:
> > These 14 patches are an experimental transport switch for knfsd.
> > They're based on Tom Tucker's 01-svc-xprt-switch.patch from the
> > nfsrdma project November release, but redesigned to provide as simple
> > and clean an abstraction as possible to new transport-specific code.
> > Various messy details of flags, reference counts and other behaviour
> > which are currently redundantly handled in both TCP and UDP code,
> > will be handled in generic code now.  This makes the task of writing
> > new transport code easier and less prone to breakage.
> 
> Are there other conjectured future users besides rdma?

I don't know of any being planned, but you could imagine support for
DCCP or SCTP (although to be frank those would probably be simple
extensions of existing UDP and TCP code respectively).

You could also imagine transport code that made NFS work fast on
various cluster interconnects that aren't IB or deliberately designed
to pretend to be IB.  One example is xpmem, which uses the block
copy offload in Altix hardware to communicate between partitions.
It's a very fast transport but the way IP is encoded on it limits
NFS transfer rates to a small fraction of what the hardware can do.

But basically RDMA is the one that's driving the need for a transport
switch because it's really very different, e.g. it doesn't use sockets.

> What's happened to server-side ipv6, by the way?

Unsure.  There's certainly a lot of code support for it, I kept
tripping over it when forward porting these patches.  It looks like
you'd need to have rpc.nfsd create it's own socket in userspace and
pass it down via /proc/fs/nfsd/ports.

It's intertesting to note that ipv6 support was added without a
serverside transport switch; on Irix the addition of ipv6 was what
justified a transport switch.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
