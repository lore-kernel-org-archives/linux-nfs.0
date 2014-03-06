Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:45937 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751457AbaCFDuv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Mar 2014 22:50:51 -0500
Date: Thu, 6 Mar 2014 14:50:42 +1100
From: NeilBrown <neilb@suse.de>
To: Andrew Martin <amartin@xes-inc.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Optimal NFS mount options to safely allow interrupts and
 timeouts on newer kernels
Message-ID: <20140306145042.6db53f60@notabene.brown>
In-Reply-To: <260588931.122771.1394041524167.JavaMail.zimbra@xes-inc.com>
References: <1696396609.119284.1394040541217.JavaMail.zimbra@xes-inc.com>
	<260588931.122771.1394041524167.JavaMail.zimbra@xes-inc.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/bo7zZ1JwwQhkynpIBHI1Czj"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/bo7zZ1JwwQhkynpIBHI1Czj
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 5 Mar 2014 11:45:24 -0600 (CST) Andrew Martin <amartin@xes-inc.com>
wrote:

> Hello,
>=20
> Is it safe to use the "soft" mount option with proto=3Dtcp on newer kerne=
ls (e.g
> 3.2 and newer)? Currently using the "defaults" nfs mount options on Ubuntu
> 12.04 results in processes blocking forever in uninterruptable sleep if t=
hey
> attempt to access a mountpoint while the NFS server is offline. I would p=
refer
> that NFS simply return an error to the clients after retrying a few times=
,=20
> however I also cannot have data loss. From the man page, I think these op=
tions
> will give that effect?
> soft,proto=3Dtcp,timeo=3D10,retrans=3D3
>=20
> >From my understanding, this will cause NFS to retry the connection 3 tim=
es (once
> per second), and then if all 3 are unsuccessful return an error to the
> application. Is this correct? Is there a risk of data loss or corruption =
by
> using "soft" in this way? Or is there a better way to approach this?

I think your best bet is to use an auto-mounter so that the filesystem gets
unmounted if the server isn't available.
"soft" always implies the risk of data loss.  "Nulls Frequently Substituted"
as it was described to very many years ago.

Possibly it would be good to have something between 'hard' and 'soft' for
cases like yours (you aren't the first to ask).

 From http://docstore.mik.ua/orelly/networking/puis/ch20_01.htm

   BSDI and OSF /1 also have a spongy option that is similar to hard , exce=
pt
   that the stat, lookup, fsstat, readlink, and readdir operations behave l=
ike a soft MOUNT .=20

Linux doesn't have 'spongy'.  Maybe it could.  Or maybe it was a failed
experiment and there are good reasons not to want it.

NeilBrown

--Sig_/bo7zZ1JwwQhkynpIBHI1Czj
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUxfwkjnsnt1WYoG5AQLQthAAiiaNthLXrn8XNlgk5jYv2td5BIuvU4iK
rMuBqKl+It/E4o37DYkmNnwSJVyE3uXdAtiU5+i+u9yiy+Ib0iAWV168ATU8uZIB
MiSEpUMud8Ot+QGnyVST/qKEFLanckWdmjT7dbeU2Uz0XuNbcUCy2bZZxWS8wreZ
B/CkEVt78yC01FWqHsW4QKI9awpnJF/3lP+vTb45vKgbmqmhYJ/PCLOGFikr9S6J
juT6j3w/M9z/943YKhj1rvTDCbTN/esgGs5b1eta7PyRbAc6jXJZM+calg7DpcAV
RF7H84vstJE9Dn+fOO4hctfqTmrrqiNR4J9aT05quvEJ+6cTlG7kcqL8FMDdc3iY
XgruFrczLcAC3DlMBLzRPge5Kad/OgVS9RJHcSUMmSPP+kc4uymnvXJ2WY3QG4Mg
00ho2ZARGubC6qXlPbCkQ8qZZdeeK8o5duU3pagZ8qU3h9dDgDvn6ornxnnTyKI+
Ul8evPW/KPN65JJPc4f1TLpJlNHQGeou14vnEtIZAP2qg8MVFXMll21Iwz6e1If9
J3bVQ9qL81YLFDgtRg9WQO10P6TJjsI9iy4PAfDPcZpxSxAq5XOPHYMBmgJvRGf4
Kc/FRzaslSvqKR15Ih2LKT4bfJMN0tw7PaqKc2MHYyiLtbaipb2kRoDGXd/VnxLJ
dbSsQuIuXao=
=PL4w
-----END PGP SIGNATURE-----

--Sig_/bo7zZ1JwwQhkynpIBHI1Czj--
