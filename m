From: trond.myklebust@fys.uio.no
Subject: Re: NFS suport block sharing
Date: Thu, 19 Feb 2004 17:37:59 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <32947.207.214.87.84.1077208679.squirrel@webmail.uio.no>
References: <482A3FA0050D21419C269D13989C611302B07B87@lavender-fe.eng.netapp.com>
    <36604.207.214.87.84.1077165546.squirrel@webmail.uio.no>
    <20040219090551.GA19999@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Cc: "Charles Lever" <Charles.Lever@netapp.com>,nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AtrH4-0004P6-Ur
	for nfs@lists.sourceforge.net; Thu, 19 Feb 2004 08:43:42 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AtrBe-0006Ye-AW
	for nfs@lists.sourceforge.net; Thu, 19 Feb 2004 08:38:06 -0800
To: "Olaf Kirch" <okir@suse.de>
In-Reply-To: <20040219090551.GA19999@suse.de>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

På to , 19/02/2004 klokka 01:05, skreiv Olaf Kirch:
> On Thu, Feb 19, 2004 at 05:39:06AM +0100, Trond Myklebust wrote:
> > Sure it is. Just add the equivalent of Olaf's patch for the
> > forcedirectio flag into the external patch that adds forcedirectio
support. "forcedirectio" does indeed not care about inode aliasing,
but it
> > is the *only* such case.
>
> But it is non-intuitive. You mount something with one set of flags, but
get a totally different behavior. That is arguably a bug.

So is data corruption. Arguably more so ;-)

> Let me state my point though: how many people actually do mount a file
system twice? And if they do, wouldn't that be exactly _because_ they
want different semantics on the two mounts?

Possibly, but will they want that given the above mentioned expense? The
last thing I want is a bunch of "but when I do this on Solaris, it doesn't
corrupt my file" type of whines. Better then to tell people straight
upfront that this won't work.

> In general I think sharing the super block itself is not a good idea,
even for block file systems, because flags such as ro and sync get
ignored as well. These flags, as well as the RPC transport stuff, might
be better placed in the vfsmount as they're really per-mount, not
per-filesystem.

Some things (rsize/wsize/acdir*/acreg* in particular come to mind) simply
do not make sense in the vfsmount structure because they are inherently
associated with the inode/data space rather than the name space.
"ro" and "sync" could possibly be implemented in a more sane manner, since
you can do the checks at file open time when you do have the full
namespace information. Most others, though (especially those parameters
related to attribute caching) have to be shared.

Note, though, that Linux has *never* previously supported mounting the
same filesystem twice precisely because of the problems of cache
consistency. When Al added in the current scheme, he changed that by
giving remounting in a second place act the same properties as "mount
--bind". AFAICS that is the only sane scheme.

Cheers,
  Trond





-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
