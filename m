From: Alex Samad <alex-SGFoFqf0RKf0CCvOHzKKcA@public.gmane.org>
Subject: Re: mount issue with Mac OSX and --manage-gids, client hangs
Date: Fri, 1 Aug 2008 11:47:01 +1000
Message-ID: <20080801014701.GA2410@samad.com.au>
References: <20080731204701.GE26609@samad.com.au> <76bd70e30807311611o327339dakd2de3577608897a4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="BXVAT5kNtrzKuDFl"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail5.tpgi.com.au ([203.12.160.101]:56150 "EHLO
	mail5.tpgi.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751258AbYHABrI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Jul 2008 21:47:08 -0400
Received: from sydrt01.samad.com.au (adsl.samad.com.au [60.241.248.86])
	by mail5.tpgi.com.au (envelope-from alex-SGFoFqf0RKf0CCvOHzKKcA@public.gmane.org) (8.14.3/8.14.3) with ESMTP id m711l1b2010749
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Fri, 1 Aug 2008 11:47:04 +1000
Received: from alex by smtp.samad.com.au with local  (Exim 4.69 #1 (Debian))
	id 1KOjjR-0000dC-Ej
	for <linux-nfs@vger.kernel.org>; Fri, 01 Aug 2008 11:47:01 +1000
In-Reply-To: <76bd70e30807311611o327339dakd2de3577608897a4-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--BXVAT5kNtrzKuDFl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jul 31, 2008 at 07:11:31PM -0400, Chuck Lever wrote:
> On Thu, Jul 31, 2008 at 4:47 PM, Alex Samad <alex-SGFoFqf0RKf0CCvOHzKKcA@public.gmane.org> wrote:
> > Hi
> >
> > I have a nfs debian amd64 server, with a few linux clients that is
> > working well. I recently tried to attach a mac osx (10.5 Leopard)
> > client.
> >
> > Everytime I attached it would hang when i attempted to use the mount
> >
> > on the nas box I have this line in /etc/exports
> > /exports/shared
> > -async,no_subtree_check,no_root_squash,insecure,mp=3D/exports/shared
> > 192.168.8.0/22(rw)
>=20
> One comment: you shouldn't need "insecure" if you are mounting on the
> command line and not from the Finder's "Go" menu.  The Finder will try
> to mount an NFS share using a non-privleged port, but Darwin's mount
> command (and automounter, AFAIK) works like other Unices -- it should
> try to use a privileged port for communicating with the server.
yes agreed, but I had tried different variations, this was the last one.
In all instances when I removed the manage-gids it failed

>=20
> > I mounted with this command
> >
> > mount -t nfs -o rw,async,rsize=3D32768,wsize=3D32768
> > nas.hme1.samad.com.au:/exports/shared /mounts/shared
> >
> >
> > I then tried
> >
> > df -h &
> > ls -l /mounts/shared &
> > umount -f /mounts/shared &
> >
> > all the commands failed to return, I could not kill them with -9, I had
> > to reboot
>=20
> I find looking at the Mac's dmesg via Console.app to be helpful in such c=
ases.

The commands did not return, kill -9 failed, I had to reboot, noting in
dmesg, console or syslog (sorry I lie, there were server timeouts
messages)

>=20
> > I have attached a tcpdump (tcpdump -pni eth0 ether host
> > xx:xx:xx:xx:xx:xx -s 9100 -w
> > nas.capture.dmp) on the nas box
> >
> > a copy of the dumo is at www.samad.com.au/~alex/nas.capture.dmp
> >
> > I tracked it down to --manage-gids - when I remove this from
> > /etc/defaults/nfs-kernel-server everything works fine.
> >
> > Note though, the UID's, GIDs are not synced between the linux box and
> > the mac box. so the 2 users I have on the mac box uid 501 & 502, do not
> > exist on the nas box
> >
> >
> > I read that manage-gids was a means of handle a uid with more than 16
> > gids and it was protocol compliant, so I have opened a bug report with
> > Apple, and opened a bug report with debian
> >
> >
> > I have had a quick look at the source code, but it looks more like
> > something that is in the kernel.
> >
> > Is there another place I can log a bugreport for this ?
> >
> > Thanks
> > Alex
> >
> >
> > -----BEGIN PGP SIGNATURE-----
> > Version: GnuPG v1.4.9 (GNU/Linux)
> >
> > iEYEARECAAYFAkiSJMUACgkQkZz88chpJ2MHXgCgtfGAogy3RbEkqvacDNwvzYqf
> > nikAn3P0J3bB+/Kx6TSmJiK35mAF7+Xh
> > =3DT+Kq
> > -----END PGP SIGNATURE-----
> >
> >
>=20
>=20
>=20
> --=20
>  "Alright guard, begin the unnecessarily slow-moving dipping mechanism."
> --Dr. Evil
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20

--=20
Never play pool with anyone named "Fats".

--BXVAT5kNtrzKuDFl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkiSaxIACgkQkZz88chpJ2No7wCfRujiJDFWJmj28LDmVoGHBC/A
3GkAn3qFiqDfr/S0VFJVXyLhoR2tpURS
=ktNf
-----END PGP SIGNATURE-----

--BXVAT5kNtrzKuDFl--
