From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: client apps not surviving nfsd restart
Date: Fri, 20 Aug 2004 15:25:31 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200408201525.36681.bernd-schubert@web.de>
References: <4125EA9F.3040304@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  protocol="application/pgp-signature";
  micalg=pgp-sha1;
  boundary="Boundary-02=_QvfJBlNVl513u2k";
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1By9Os-0007u3-7M
	for nfs@lists.sourceforge.net; Fri, 20 Aug 2004 06:25:46 -0700
Received: from relay.uni-heidelberg.de ([129.206.100.212])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1By9Or-0002eu-7x
	for nfs@lists.sourceforge.net; Fri, 20 Aug 2004 06:25:45 -0700
Received: from euklid.pci.uni-heidelberg.de (euklid.pci.uni-heidelberg.de [129.206.21.104])
	by relay.uni-heidelberg.de (8.12.10/8.12.10) with ESMTP id i7KDPbIY002589
	for <nfs@lists.sourceforge.net>; Fri, 20 Aug 2004 15:25:37 +0200 (MET DST)
Received: from bernd by euklid.pci.uni-heidelberg.de with local (Exim 3.35 #1 (Debian))
	id 1By9Oj-00055H-00
	for <nfs@lists.sourceforge.net>; Fri, 20 Aug 2004 15:25:37 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <4125EA9F.3040304@bio.ifi.lmu.de>
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


--Boundary-02=_QvfJBlNVl513u2k
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hello Frank,


> 1) After installing SusE 9.0, the default was set to nfs-over-tcp. I didn=
't
>     know that, but suddenly after every server reboot I had at least 4-5
>     of the work station users complaining about stale NFS handles, e.g.,
>     /usr was stale and so java didn't start anymore etc. It's not really
>     reproducable by some certain sequence of starting apps and rebooting
>     the server etc., but it happens every time the server has to reboot
>     with a few clients.

can you confirm this with vanilla client/server kernel version? We have 45=
=20
diskless clients here and each of them has no problem on a server reboot.=20
This works for more than two years with vanilla 2.4.X kernel versions. Sinc=
e=20
about 4-5 month we also use nfs-over-tcp and this also has no negative=20
effect.
We also tried using 2.6.7 on our server, but it always crashed every mornin=
g=20
with page allocation errors, so we had to give up with this version and=20
switched back to 2.4.X. However, although the server was rebooted every=20
morning (and/or the failover server took over), this caused no problems for=
=20
the clients (except for the directories mounted from ClusterNFS, but thats =
a=20
different more complicated CNFSD related story).

>
>     In the NFS howto I read that the disadvantage of nfs-over-tcp is that
>     "If your server crashes in the middle of a packet transmission, the
>      client will hang and any shares will need to be unmounted and
> remounted."

This howto seems to be slightly outdated.

>
>     But I thought a clean reboot with a clean stop and later start of the
>     nfsserver shouldn't make a problem.

It doesn't make a problems with vanilla kernel version.

[snip]

>
> 2) We are currently testing kernel 2.6.8.1. The nfs behaviour seems
>     to have changed in some ways. Running e.g. "find /" on a diskless
>     client with kernel 2.4 would just hang when the server rebootet
>     and later go on when the server was back.
>     With 2.6.8.1, the find command will immediately abort and report
>     some stale nfs handles.

We only tested 2.6.7 and it caused no such problems, as we have failover, I=
=20
tested failover during file transfers and this worked like a charm.


Cheers,
	Bernd

PS: About 1.5 years ago we were forced to use a Suse kernel on our server (=
due=20
to a closed-sources binary only kernel module) and this kernel caused a lot=
=20
of nfs related trouble for us. As the module also didn't work properly we=20
finally decided not to buy this software ;)


=2D-=20
Bernd Schubert
Physikalisch Chemisches Institut / Theoretische Chemie
Universit=E4t Heidelberg
INF 229
69120 Heidelberg
e-mail: bernd.schubert@pci.uni-heidelberg.de

--Boundary-02=_QvfJBlNVl513u2k
Content-Type: application/pgp-signature
Content-Description: signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBBJfvQC8BUnAF+ydYRAgYSAJ9FDuBUuKQBvI5XE1ZQ0UKHvHDNcACfRn+E
mDQRl3qqtb1K29MPrpj0IQA=
=rgBQ
-----END PGP SIGNATURE-----

--Boundary-02=_QvfJBlNVl513u2k--


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
