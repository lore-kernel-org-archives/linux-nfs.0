From: Garrick Staples <garrick@usc.edu>
Subject: Re: nfsd, rmtab, failover, and stale filehandles
Date: Thu, 6 May 2004 15:42:56 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040506224256.GB26968@polop.usc.edu>
References: <20040506185603.GM23287@polop.usc.edu> <20040506191351.GP23287@polop.usc.edu> <20040506215311.GA26968@polop.usc.edu> <20040506222455.GP18964@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Y7xTucakfITjPcLV"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BLrbK-0003v1-I7
	for nfs@lists.sourceforge.net; Thu, 06 May 2004 15:44:22 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BLrbK-0002Wa-7k
	for nfs@lists.sourceforge.net; Thu, 06 May 2004 15:44:22 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.10/8.12.10) with ESMTP id i46Mgvlv027038
	for <nfs@lists.sourceforge.net>; Thu, 6 May 2004 15:42:57 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.10/8.12.10/Submit) id i46MguCb027036
	for nfs@lists.sourceforge.net; Thu, 6 May 2004 15:42:56 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20040506222455.GP18964@fieldses.org>
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


--Y7xTucakfITjPcLV
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, May 06, 2004 at 06:24:55PM -0400, J. Bruce Fields alleged:
> On Thu, May 06, 2004 at 02:53:11PM -0700, Garrick Staples wrote:
> > I'm at a total loss.  Everything I'm reading tells me that all I need t=
o ensure
> > is that fs device names are the same on both servers so that the genera=
ted
> > filehandles are the same, and that I need to move all lines matching
> > ":$mountpoint:" in rmtab to the new server.  The former is done since I=
'm using
> > persistant device numbers with lvm.  The latter shouldn't be needed bec=
ause I'm
> > using the "new" proc interface with 2.6.5.
> >=20
> > rmtab definitly doesn't do any noticable difference.  I can add random =
text
> > and blank it out with no noticable difference on the clients.
> >=20
> > Is this a client problem?  The clients are all 2.4.24 and 2.4.26.
> >=20
> > All clients and servers are using vanilla kernels.
>=20
> I'm assuming /etc/exports is the same, and that the nfsd filesystem is
> mounted (probably on /proc/fs/nfs/) and mountd is running without
> complaint on the server that you're failing over to?

/etc/exports is basicly empty, so that the machines boot without exporting =
the
shared disk space.  The failover scripts export the filesystems directly wi=
th
'exportfs'.

The nfsd fs is mounted.  I'm definitely using the "new" upcall interface.
=20
> The kernel uses upcalls to mountd in part to construct the filehandles,
> and nfserr_stale could be returned if those upcalls weren't working.
> You can see the contents of the caches that hold the result of those
> upcalls with something like

Yes, this seems to be the process that isn't working.

=20
> for i in `find /proc/net/rpc -name "content"`; do echo -e "\n$i:"; cat $i=
; done
>=20
> Maybe the output from that (after a failed failover) would be
> enlightening.

$ for i in `find /proc/net/rpc -name "content"`; do echo -e "\n$i:"; cat $i;
done=20

/proc/net/rpc/nfsd.fh/content:
#domain fsidtype fsid [path]

/proc/net/rpc/nfsd.export/content:
#path domain(flags)

/proc/net/rpc/auth.unix.ip/content:
#class IP domain
[root@hpc-fs3 root]# for i in `find /proc/net/rpc -name "content"`; do echo=
 -e
"\n$i:"; cat $i; done=20

/proc/net/rpc/nfsd.fh/content:
#domain fsidtype fsid [path]
# hpc*,hpc*.usc.edu 0 0x0200fe0000000002
# hpc*,hpc*.usc.edu 0 0x0600fe0000000002

/proc/net/rpc/nfsd.export/content:
#path domain(flags)

/proc/net/rpc/auth.unix.ip/content:
#class IP domain
nfsd 10.125.0.200 hpc*,hpc*.usc.edu

$ showmount -e localhost | grep hpc-25
/export/home/hpc-25 hpc*.usc.edu,rcf*.usc.edu,almaak.usc.edu


On the client (10.125.0.200),
$ df | grep hpc-25
hpc-nfs2:/export/home/hpc-25
                             0         1         0   0% /auto/hpc-25

hpc-nfs2 is the virtual IP that is currently rebound to the second NFS serv=
er.


>=20
> Hmm, also, could you try recompiling mountd with the following patch
> applied?
>=20
> --Bruce Fields

Trying it now...

--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--Y7xTucakfITjPcLV
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFAmr9w0SBUxJbm9HMRAmyzAJ4/UdjhOOhlsistC4Jg9zaR2r8rcgCdFir1
HUGODj7Mx5/PbtQ6PouZaGE=
=o0ex
-----END PGP SIGNATURE-----

--Y7xTucakfITjPcLV--


-------------------------------------------------------
This SF.Net email is sponsored by Sleepycat Software
Learn developer strategies Cisco, Motorola, Ericsson & Lucent use to deliver
higher performing products faster, at low TCO.
http://www.sleepycat.com/telcomwpreg.php?From=osdnemail3
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
