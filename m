From: Garrick Staples <garrick@usc.edu>
Subject: Re: nfsd, rmtab, failover, and stale filehandles
Date: Fri, 7 May 2004 14:38:12 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040507213811.GL30964@polop.usc.edu>
References: <20040506185603.GM23287@polop.usc.edu> <20040506191351.GP23287@polop.usc.edu> <20040506215311.GA26968@polop.usc.edu> <20040506222455.GP18964@fieldses.org> <20040506230055.GC26968@polop.usc.edu> <20040507182543.GA27341@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="PpocKf6TCvdC9BKE"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BMD6R-0005Jv-Bb
	for nfs@lists.sourceforge.net; Fri, 07 May 2004 14:41:55 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BMD6R-000689-79
	for nfs@lists.sourceforge.net; Fri, 07 May 2004 14:41:55 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.10/8.12.10) with ESMTP id i47LcClv031401
	for <nfs@lists.sourceforge.net>; Fri, 7 May 2004 14:38:12 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.10/8.12.10/Submit) id i47LcCSK031399
	for nfs@lists.sourceforge.net; Fri, 7 May 2004 14:38:12 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20040507182543.GA27341@fieldses.org>
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


--PpocKf6TCvdC9BKE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, May 07, 2004 at 02:25:43PM -0400, J. Bruce Fields alleged:
> On Thu, May 06, 2004 at 04:00:55PM -0700, Garrick Staples wrote:
> > No effect.  All I did was kill mountd, run the patched mountd, and try =
to 'ls'
> > on the client.
>=20
> I think that's not enough....
>=20
> > Watching an strace of mountd, it doesn't seem that mountd is ever conta=
cted.
> > The client reports stale filehandle pretty much immediately, and mountd=
 doesn't
> > do anything.
>=20
> The upcall was made earlier, and the kernel has cached it (even if it's
> a negative result).  So, just to make sure, could you try:
>=20
> killall rpc.mountd
> exportfs -f	#flush the kernel's caches
> rpc.mountd	#(the patched version)

Hey!  That did, in fact, revive a long-standing stale filehandle!  Cheers f=
or
Mr. Fields!

But now I've just noticed something else that is odd.  Something that I'm
surprised I haven't come across before...  I have to unexport filesystems
twice before I can unmount them.

Good and normal...

[root@hpc-fs3 root]# mount /dev/vgtest/lvtest /mnt/test
[root@hpc-fs3 root]# exportfs -o rw,no_subtree_check,no_root_squash,async 1=
0.125.0.0/16:/mnt/test
[root@hpc-fs3 root]# exportfs -u 10.125.0.0/16:/mnt/test
[root@hpc-fs3 root]# umount /mnt/test        =20


Same thing, but I did an 'ls' on the client after it was exported...

[root@hpc-fs3 root]# mount /dev/vgtest/lvtest /mnt/test
[root@hpc-fs3 root]# exportfs -o rw,no_subtree_check,no_root_squash,async 1=
0.125.0.0/16:/mnt/test
[root@hpc-fs3 root]# exportfs -u 10.125.0.0/16:/mnt/test
[root@hpc-fs3 root]# umount /mnt/test        =20
umount: /mnt/test: device is busy
[root@hpc-fs3 root]# exportfs -u 10.125.0.0/16:/mnt/test
[root@hpc-fs3 root]# umount /mnt/test        =20

'exportfs -f' does as well as a second umount.

--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--PpocKf6TCvdC9BKE
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFAnAHD0SBUxJbm9HMRAgaKAJ4r2Gr0VZ0rEFIT4/L4T278qrP8aACfTY6X
dH/hc/t7LD/pY0SXX0SVg/g=
=U/xP
-----END PGP SIGNATURE-----

--PpocKf6TCvdC9BKE--


-------------------------------------------------------
This SF.Net email is sponsored by Sleepycat Software
Learn developer strategies Cisco, Motorola, Ericsson & Lucent use to deliver
higher performing products faster, at low TCO.
http://www.sleepycat.com/telcomwpreg.php?From=osdnemail3
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
