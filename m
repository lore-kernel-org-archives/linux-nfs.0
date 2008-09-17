From: Michael Trimarchi <trimarchimichael@yahoo.it>
Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
Date: Wed, 17 Sep 2008 13:19:25 +0000 (GMT)
Message-ID: <525424.91603.qm@web26201.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: linux-kernel@vger.kernel.org
To: Martin Knoblauch <knobi@knobisoft.de>,
	linux-nfs list <linux-nfs@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754022AbYIQNTh@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi



----- Messaggio originale -----
> Da: Martin Knoblauch <knobi@knobisoft.de>
> A: linux-nfs list <linux-nfs@vger.kernel.org>
> Cc: linux-kernel@vger.kernel.org
> Inviato: Mercoled=EC 17 settembre 2008, 15:06:40
> Oggetto: [RFC][Resend] Make NFS-Client readahead tunable
>=20
=2E...

> diff -urp linux-2.6.27-rc6-git4/Makefile linux-2.6.27-rc6-git4-nfs_ra=
/Makefile
> --- linux-2.6.27-rc6-git4/Makefile      2008-09-17 11:35:56.000000000=
 +0200
> +++ linux-2.6.27-rc6-git4-nfs_ra/Makefile       2008-09-17 11:45:09.0=
00000000=20
> +0200
> @@ -1,7 +1,7 @@
> VERSION =3D 2
> PATCHLEVEL =3D 6
> SUBLEVEL =3D 27
> -EXTRAVERSION =3D -rc6-git4
> +EXTRAVERSION =3D -rc6-git4-nfs_ra
> NAME =3D Rotary Wombat
>=20
> # *DOCUMENTATION*

I'm not an expert but maybe this is not necessary :)=20

>=20
>=20
> Cheers
> Martin
>=20
> ------------------------------------------------------

Michael

__________________________________________________
Do You Yahoo!?
Poco spazio e tanto spam? Yahoo! Mail ti protegge dallo spam e ti da ta=
nto spazio gratuito per i tuoi file e i messaggi=20
http://mail.yahoo.it=20
