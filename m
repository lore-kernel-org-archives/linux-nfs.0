Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:55622 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754582Ab2IRGaC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Sep 2012 02:30:02 -0400
Date: Tue, 18 Sep 2012 16:29:48 +1000
From: NeilBrown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: Should "mount -o proto=udp" be usable against an IPv6 only
 server?
Message-ID: <20120918162948.47840d42@notabene.brown>
In-Reply-To: <F8762BC2-F211-482E-8B5A-A2E991E3F937@oracle.com>
References: <20120918115450.5c65973f@notabene.brown>
	<F8762BC2-F211-482E-8B5A-A2E991E3F937@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/agoeU58Sb6WsQhEkPIIfe0j"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/agoeU58Sb6WsQhEkPIIfe0j
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 18 Sep 2012 01:28:09 -0400 Chuck Lever <chuck.lever@oracle.com> wro=
te:

> Hi Neil-
>=20
> On Sep 17, 2012, at 9:54 PM, NeilBrown wrote:
>=20
> > It seems that with current nfs-utils, "proto=3Dudp" (either
> > in /etc/nfsmount.conf or on the command line) restricts the mount to us=
ing
> > IPv4, not IPv6.
> > For IPv6 you need "udp6".
> >=20
> > This isn't made crystal clear by the documentation.  I could fix the
> > documentation, but first I wanted to check if this really is appropriat=
e.
> > Is there a good reason for this, or should we make "udp" mean "udp4 or =
udp6"
> > and require either "udp4" or "udp6" if we want a particular IP version.
> >=20
> > i.e. instead of treating the "proto=3D" value as a "netid", should we t=
reat it
> > as a "protoname" and match any "netid" in /etc/netconfig with that
> > "protoname"??
>=20
> This is working as designed.
>=20
> The meaning of each netid is defined in RFC 5665.  "udp" means UDP over I=
Pv4.  This matches precisely what "proto=3Dudp" meant before TI-RPC.  These=
 netids force a particular protocol family when the server is specified by =
hostname and not IP address.
>=20
> What's more, we mean this to match the behavior of the Solaris mount comm=
and, where "proto=3Dudp" also has this meaning.
>=20
> Which part of the documentation do you think is unclear?
>=20

Hi Chuck,
 Thanks for the reply.

It is unfortunate that the tag "proto" is used to choose the "netid".
In common parlance, "udp" and "tcp" are protocols independent of the
underlying transport (IPv4 or IPv6)  much as "nfsv3" or "nfsv4" are
independent of the underlying transport (tcp, udp6, rdma etc).

Give this obvious opportunity for confusion it would be good if the
documentation took significant steps to minimise it.

I note that nfs(5) does mention /etc/netconfig and the "netid"s that it
contains.  However "udp6" and "tcp6" are never given as examples - doing so
would help the reader see the import of the distinction.

       proto=3Dnetid    The transport protocol name and protocol family the=
  NFS
                      client  uses  to transmit requests to the NFS server =
for
                      this mount point.  If an NFS server has both an IPv4 =
and
                      an  IPv6  address, using a specific netid will force =
the
                      use of IPv4 or IPv6 networking to communicate with  t=
hat
                      server.

I don't think the second sentence would be very helpful to someone who didn=
't
already understand the subtleties.=20
Something like:

    A particular netid completely specifies the protocol, so for example
    "tcp" is TCP over IPv4, and "udp6" is UDP over IPv6.  It is not possible
    to request "UDP" without also specifying which version of IP should be
    used.

man nfsmount.conf gives the example:

       [ NFSMount_Global_Options ]
           Proto=3DTcp

              The TCP protocol will be used on every NFS mount.

which is incomplete.  Not just TCP, but TCP/IPv4 will be used on every NFS
mount.  And again, not IPv6 examples.

(and nfsmount.conf doesn't mention the "default$OPTION=3Dvalue" syntax...)


For a usability perspective, I think that treating "udp" as meaning
"udp/ipv4" is a serious mistake and I'm not at all convinced that "Solaris
compatibility" is sufficient justification, but as I have no interest in
offering patches, I won't pursue that line of argument further :-)

Thanks,
NeilBrown

--Sig_/agoeU58Sb6WsQhEkPIIfe0j
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBUFgU3Dnsnt1WYoG5AQKhFg/+LMfTo6LnMKe1tqEtkT+fJzIPXZOt3N+v
e24iogG3APGJDUgZWQS3VTwleXshIxv9VZDn4W6b35breX3+4skJLd+5XgDJZdkQ
KE8KoxccBEk5r5RD5CvhzOLRnkVlTGNf3ZMN5i4GvhynBF21D7T+9V+YYNF/jCAH
EE1dOUe2XJZ1MP0fQ7sOEeBl1zCjtNd1ihCalpFMkcestbD0VCGVGv1/Q0KtmkdA
aHCSan92aJWtqELQ/Jv3Mpk/XYw565weL8W8Z0lXxT49weTKcKRkf5fCPFsQ86lZ
BTPyWWC81ybZCdXupqlu0g/liV/vbSI19K2NqDut6EpLeEJjv4fBXD0LtS9UPDLy
kKpbjBgs0b0hcuroXnbFibZDwxLDJH/6znZ3QyGdrTUvk1zhsunXD19g/qoj7Rmo
t5eFd/xr0y1apNthXJAJNPk7CQljdmFuZoSces5NbmB6APGjBuIAb2ABWdNkQ87L
ywBPxZeSIoLQ1ckxMc4EmopfslrIhRdHa0iW9LW7uMZYDBXb0T41qCZcNzrF6aOL
8slpghnLe8y+69hq/qm3FwHJH9fCAj4HB8pcnnZiik6cKSNrFdaAHNvVNF05LoBo
Pm3jlU95w+Rta5XaiPW6Bm8r1i5r+r9lLzPOm1a1OZcIa12Mwj/po5EUyHeDQv1q
idM2924gYGA=
=mK7l
-----END PGP SIGNATURE-----

--Sig_/agoeU58Sb6WsQhEkPIIfe0j--
