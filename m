Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:40986 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751023Ab2AZLky (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Jan 2012 06:40:54 -0500
Date: Thu, 26 Jan 2012 22:40:42 +1100
From: NeilBrown <neilb@suse.de>
To: "Vlasov, Vladimir" <vvlasov@mera.ru>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Re-init lockd and kstatd in runtime.
Message-ID: <20120126224042.63cdd70e@notabene.brown>
In-Reply-To: <06EFEBD57610DE4FBCA0449DDF4E102B08765D@tecas.te.mera.ru>
References: <06EFEBD57610DE4FBCA0449DDF4E102B08765D@tecas.te.mera.ru>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/3x6xopo/Mr=KURvFtd2dHzb"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/3x6xopo/Mr=KURvFtd2dHzb
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 26 Jan 2012 11:15:02 +0000 "Vlasov, Vladimir" <vvlasov@mera.ru> wro=
te:

> Hi.
>=20
> I'm wondering if there is any way to re-init lockd and kstatd after start=
up?
>=20
> Look, in svc.c static variable nsm_use_kstatd is set to 1.
> Then, if nsm_kernel_statd_init() returns error, nsm_use_kstatd is set to =
0.
> And we end up without kstatd.
>=20
> Lockd will exit as soon as last NFS mount is unmounted and on next mount =
attempt lockd() in svc.c will be called again, but nsm_use_kstatd is 0 alre=
ady and kstatd init will be skipped.
>=20
> So, looks like if /var/lib/nfs/state is missed on host startup, there is =
no way to recover and tell kernel init kstatd later on demand. Or?

This would be SLES10 - correct?

I suggest you simply make sure /var/lib/nfs/state is not missing at startup.

The issue sounds vaguely familiar ... maybe it is fixed in SLES10-SP4...

What release are you running?  Are you a SLES customer?  If you are, you
would be better off logging a support request on the SUSE bugzilla
(bugzilla.novell.com).

NeilBrown


--Sig_/3x6xopo/Mr=KURvFtd2dHzb
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBTyE7ujnsnt1WYoG5AQIjHw//f2t+br56+so1iHe2nsgop6k4SB7Wy0Iq
Kpw/5F1t9xmgaZn5iZ3UYStrXJyRkd6KRy9tmLDFo51YVzFWp7ogf5zvYspK+68Y
Hg8lFaASpgAGs/omrl4NIJudJoo7bG7Jy9gzEJzz1yuE9Abh/68n0QJrGk6xlJ8F
t+UXxwLAoLAs9UGDlkc4InEGwzXbNSDhHAUEmNuqrG6jUG9zKbRQsICAYpl4Qyb+
uSk0ykFffVqeJP8diGvQlv6R9GP66EP0H1Q345lwcV5+oijZYMYCt9OJLd6JUqmQ
7ChIOMJBxRXgRZOcarrVSEkcZO5IQ0FEm20youjocfbF6vmi48vwQmRm0sSy7nLw
dBzBnviMsrsFR8bzNjzdDrawX0TQxvTEo4hXqQshQDZYQbOGlYgj4zVk6m9jQ/YQ
uppG7agPTaYfJs1YZwdgK/kbJ6mHv23ywaxGNscy5VRZUcHrtIeE1J1xa4517Yq9
yF6HkJohM6xQp3xluW1RK4wV8cP1+yKhL/1Ab9YCdlIAElNgdpKKytTPxZztex0p
9lnRmkXtZKfVVlZWW7QRQQwx6XM+l4UFUzyibm3sguILYarmHhVDLojJYI7++zYK
Xqrwke9VDj48NTnL+chrwdiJ9IYxESE8o+gYB3noZTZeA7+eQCT9j75APbOz9i+U
QoCQvm2lrkk=
=UW4M
-----END PGP SIGNATURE-----

--Sig_/3x6xopo/Mr=KURvFtd2dHzb--
