From: Olaf Kirch <okir@suse.de>
Subject: Re: NFS suport block sharing
Date: Thu, 19 Feb 2004 10:05:51 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040219090551.GA19999@suse.de>
References: <482A3FA0050D21419C269D13989C611302B07B87@lavender-fe.eng.netapp.com> <36604.207.214.87.84.1077165546.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Charles Lever <Charles.Lever@netapp.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AtkDG-0003Wb-MH
	for nfs@lists.sourceforge.net; Thu, 19 Feb 2004 01:11:18 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1Atk0G-0002oF-EN
	for nfs@lists.sourceforge.net; Thu, 19 Feb 2004 00:57:52 -0800
To: trond.myklebust@fys.uio.no
In-Reply-To: <36604.207.214.87.84.1077165546.squirrel@webmail.uio.no>
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

On Thu, Feb 19, 2004 at 05:39:06AM +0100, Trond Myklebust wrote:
> Sure it is. Just add the equivalent of Olaf's patch for the
> forcedirectio flag into the external patch that adds forcedirectio
> support. "forcedirectio" does indeed not care about inode aliasing, but it
> is the *only* such case.

But it is non-intuitive. You mount something with one set of flags,
but get a totally different behavior. That is arguably a bug.

I concede that we're arguing a very rarely used setup here, so I'm not
going to be religious about it :-)

Let me state my point though: how many people actually do mount a file
system twice? And if they do, wouldn't that be exactly _because_ they
want different semantics on the two mounts?

In general I think sharing the super block itself is not a good idea,
even for block file systems, because flags such as ro and sync get
ignored as well. These flags, as well as the RPC transport stuff,
might be better placed in the vfsmount as they're really per-mount,
not per-filesystem.

Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
