From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NFS suport block sharing
Date: Wed, 18 Feb 2004 18:27:48 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C611302B07B87@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>, "Olaf Kirch" <okir@suse.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ate06-0001wL-Md
	for nfs@lists.sourceforge.net; Wed, 18 Feb 2004 18:33:18 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1Atdv2-0004fz-56
	for nfs@lists.sourceforge.net; Wed, 18 Feb 2004 18:28:04 -0800
To: <trond.myklebust@fys.uio.no>
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

> We should aim only to have 1 super block per filesystem. Anything else
> will lead to inode aliasing, and hence potential data=20
> corruption problems
> when two processes try to write to the same file on different super
> blocks.
>=20
> Is there really any sane application that requires you to=20
> have different
> rsize/wsize for the same filesystem?

an application suite may want to mount one file system with
forcedirectio (if such an option might exist), and another
normally.  with the shared super block scheme, this is no
longer possible.

another typical use for having two unshared cached copies of
a file is to test NFS client caching (and yes, we do this
all the time).

so there are some "sane" cases i can think of where separate
caches and/or mount options for the same export make some
sense.

if nothing else, /proc/mounts and /etc/mtab should reflect
the true mount options in effect, and there should be some
explanation of this bizarre phenomenon in the man page.  the
way it works now is totally confusing.


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
