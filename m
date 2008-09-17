From: Martin Knoblauch <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
Date: Wed, 17 Sep 2008 06:27:45 -0700 (PDT)
Message-ID: <32541.20842.qm@web32601.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: linux-kernel@vger.kernel.org
To: Michael Trimarchi <trimarchimichael-whZMOeQn8C0@public.gmane.org>,
	linux-nfs list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from web32601.mail.mud.yahoo.com ([68.142.207.228]:25828 "HELO
	web32616.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with SMTP id S1751338AbYIQN1r convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Sep 2008 09:27:47 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

----- Original Message ----

> From: Michael Trimarchi <trimarchimichael-whZMOeQn8C0@public.gmane.org>
> To: Martin Knoblauch <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>; linux-nfs list <linux-nfs@=
vger.kernel.org>
> Cc: linux-kernel@vger.kernel.org
> Sent: Wednesday, September 17, 2008 3:19:25 PM
> Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
>=20
> Hi
>=20
>=20
>=20
> ----- Messaggio originale -----
> > Da: Martin Knoblauch=20
> > A: linux-nfs list=20
> > Cc: linux-kernel@vger.kernel.org
> > Inviato: Mercoled=EC 17 settembre 2008, 15:06:40
> > Oggetto: [RFC][Resend] Make NFS-Client readahead tunable
> >=20
> ....
>=20
> > diff -urp linux-2.6.27-rc6-git4/Makefile linux-2.6.27-rc6-git4-nfs_=
ra/Makefile
> > --- linux-2.6.27-rc6-git4/Makefile      2008-09-17 11:35:56.0000000=
00 +0200
> > +++ linux-2.6.27-rc6-git4-nfs_ra/Makefile       2008-09-17 11:45:09=
=2E000000000=20
> > +0200
> > @@ -1,7 +1,7 @@
> > VERSION =3D 2
> > PATCHLEVEL =3D 6
> > SUBLEVEL =3D 27
> > -EXTRAVERSION =3D -rc6-git4
> > +EXTRAVERSION =3D -rc6-git4-nfs_ra
> > NAME =3D Rotary Wombat
> >=20
> > # *DOCUMENTATION*
>=20
> I'm not an expert but maybe this is not necessary :)=20
>=20

 Doh, yes. A final patch should not have that. Instead it should have s=
ome documentation for the module parameter and the tunable :-)

Cheers
Martin

