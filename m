From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NFS suport block sharing
Date: Thu, 19 Feb 2004 06:51:49 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C611302B07B89@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AtpcQ-0005Aw-Gi
	for nfs@lists.sourceforge.net; Thu, 19 Feb 2004 06:57:38 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AtpX2-0001Ea-QC
	for nfs@lists.sourceforge.net; Thu, 19 Feb 2004 06:52:04 -0800
To: "Olaf Kirch" <okir@suse.de>, <trond.myklebust@fys.uio.no>
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

> On Thu, Feb 19, 2004 at 05:39:06AM +0100, Trond Myklebust wrote:
> > Sure it is. Just add the equivalent of Olaf's patch for the
> > forcedirectio flag into the external patch that adds forcedirectio
> > support. "forcedirectio" does indeed not care about inode=20
> aliasing, but it
> > is the *only* such case.
>=20
> But it is non-intuitive. You mount something with one set of flags,
> but get a totally different behavior. That is arguably a bug.
>=20
> I concede that we're arguing a very rarely used setup here, so I'm not
> going to be religious about it :-)
>=20
> Let me state my point though: how many people actually do mount a file
> system twice? And if they do, wouldn't that be exactly _because_ they
> want different semantics on the two mounts?

exactly.

> In general I think sharing the super block itself is not a good idea,
> even for block file systems, because flags such as ro and sync get
> ignored as well. These flags, as well as the RPC transport stuff,
> might be better placed in the vfsmount as they're really per-mount,
> not per-filesystem.

i have to agree completely.

there are cases where the dentry/inode & page cache can/should be
shared for two mounted file systems, but that does not match the
set of cases where it is appropriate to share mount options (which
is almost never).  the mount option behavior is just weird and
should be fixed.  i can't think of another client implementation
that behaves this way.

i object to placing these options in vfsmount, though.  the client
can't get to the vfsmount struct in any easy way.  (we hit this
problem trying to implement the nfs client metrics patch -- no
way for the client to find out what export a given file system
is mounted on subsequent to the mount operation, for example).


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
