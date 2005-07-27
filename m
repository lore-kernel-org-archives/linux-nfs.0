From: "Brian J. Murrell" <brian@interlinx.bc.ca>
Subject: funniness going on with exports
Date: Wed, 27 Jul 2005 07:59:51 -0400
Message-ID: <1122465593.7532.12.camel@pc.ilinx>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-P6nb3XLO1VoWxCYFJh9k"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dxka0-0007e9-G1
	for nfs@lists.sourceforge.net; Wed, 27 Jul 2005 05:00:08 -0700
Received: from linux.interlinx.bc.ca ([66.11.173.224])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1DxkZz-00034e-7w
	for nfs@lists.sourceforge.net; Wed, 27 Jul 2005 05:00:08 -0700
Received: from pc.ilinx (pc.ilinx [10.75.22.1])
	(using TLSv1 with cipher RC4-MD5 (128/128 bits))
	(No client certificate requested)
	by linux.interlinx.bc.ca (Postfix) with ESMTP id D8169ABE8C
	for <nfs@lists.sourceforge.net>; Wed, 27 Jul 2005 07:59:58 -0400 (EDT)
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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


--=-P6nb3XLO1VoWxCYFJh9k
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi have some funniness going on with doing exports with nfs-utils-1.0.7.
Here is my current exports list:

# cat /proc/fs/nfsd/exports=20
# Version 1.1
# Path Client(Flags) # IPs
/mnt/data       10.75.22.0/24,pc.ilinx(rw,root_squash,sync,wdelay)
/mnt/mandrake   10.75.22.0/24,pc.ilinx(rw,no_root_squash,sync,wdelay)
/usr/local      10.75.22.0/24,pc.ilinx(rw,no_root_squash,sync,wdelay)
/usr/src        10.75.22.0/24,pc.ilinx(rw,no_root_squash,sync,wdelay)
/mnt/data/mp3   10.75.22.0/24,pc.ilinx(rw,root_squash,sync,wdelay)
/home   10.75.22.0/24,pc.ilinx(rw,no_root_squash,sync,wdelay)

If I add this line to /etc/exports

/mnt/data/photos 10.75.22.0/24(ro,sync)

and then exportfs -r, my exports list looks like this:

# cat /proc/fs/nfsd/exports=20
# Version 1.1
# Path Client(Flags) # IPs
/mnt/data/photos        10.75.22.0/24,pc.ilinx(ro,root_squash,sync,wdelay)
/mnt/data       10.75.22.0/24,pc.ilinx(rw,root_squash,sync,wdelay)
/mnt/mandrake   10.75.22.0/24,pc.ilinx(rw,no_root_squash,sync,wdelay)
/usr/local      10.75.22.0/24,pc.ilinx(rw,no_root_squash,sync,wdelay)
/usr/src        10.75.22.0/24,pc.ilinx(rw,no_root_squash,sync,wdelay)
/mnt/data/mp3   10.75.22.0/24,pc.ilinx(rw,root_squash,sync,wdelay)
/home   10.75.22.0/24,pc.ilinx(rw,no_root_squash,sync,wdelay)

The new export is taking effect, but even though I only added it with
one IP list/option set, it's being exported with an additional ip/option
set (pc.ilinx(ro,root_squash,sync,wdelay)) to the one I specified in
the /etc/exports list.

Any idea why?

b.


--=-P6nb3XLO1VoWxCYFJh9k
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.0 (GNU/Linux)

iD8DBQBC53c3l3EQlGLyuXARAmkFAKCZrS1oAvNnLqi32SbpeSBomx/+YACfWN03
Kp1pG9fFSjbR3PUTbOziqH8=
=qfCd
-----END PGP SIGNATURE-----

--=-P6nb3XLO1VoWxCYFJh9k--



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
