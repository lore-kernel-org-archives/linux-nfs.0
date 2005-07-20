From: "Brian J. Murrell" <brian@interlinx.bc.ca>
Subject: rpc.mountd /home exported to both
Date: Wed, 20 Jul 2005 12:47:02 -0400
Message-ID: <1121878024.13990.52.camel@pc.ilinx>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-TYrAFLfkCepwMXRtgv9T"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DvHix-0004sd-KU
	for nfs@lists.sourceforge.net; Wed, 20 Jul 2005 09:47:11 -0700
Received: from linux.interlinx.bc.ca ([66.11.173.224])
	by sc8-sf-mx1.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1DvHiw-0002oJ-EK
	for nfs@lists.sourceforge.net; Wed, 20 Jul 2005 09:47:11 -0700
Received: from pc.ilinx (pc.ilinx [10.75.22.1])
	(using TLSv1 with cipher RC4-MD5 (128/128 bits))
	(No client certificate requested)
	by linux.interlinx.bc.ca (Postfix) with ESMTP id DBB08AB495
	for <nfs@lists.sourceforge.net>; Wed, 20 Jul 2005 12:47:08 -0400 (EDT)
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


--=-TYrAFLfkCepwMXRtgv9T
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

I am running nfs-utils-1.0.7 on Mandrake (er, I mean Mandriva) LE 2005
successfully.

I am getting messages in my syslog however of the format:

08:04:49 rpc.mountd /home exported to both 10.75.22.0/24 and pc.ilinx in *,=
10.75.22.0/24,pc.ilinx

Which is not entirely inaccurate seeing as I have the following
in /etc/exports:

/home           pc(rw,no_root_squash,sync) pvr(rw,no_root_squash,sync) bria=
n-vmware(rw,no_root_squash,sync) 10.75.22.0/24(rw,sync)

Where essentially, I want the 10.75.22.0/24 subnet to have one set of
options (rw,sync) but want a few selected hosts to have different
options.  This is the syntax AFAICS.  Is there something wrong in the
above specification?

Everything seems to work well.  It's just an annoying message I would
like to get rid of.

Any ideas?

Thanx,
b.


--=-TYrAFLfkCepwMXRtgv9T
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.0 (GNU/Linux)

iD8DBQBC3oAGl3EQlGLyuXARAn/HAKC50TOGZldLfYy/MPab8g5WAURHLgCgpB1o
NexnYSZht1/Tfnc/v7fWeNk=
=h6Ry
-----END PGP SIGNATURE-----

--=-TYrAFLfkCepwMXRtgv9T--



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
