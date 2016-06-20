Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:55396 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751961AbcFTHCD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Jun 2016 03:02:03 -0400
Date: Mon, 20 Jun 2016 10:01:41 +0300
From: Leon Romanovsky <leon@kernel.org>
To: Sagi Grimberg <sagi@grimberg.me>
Cc: Chuck Lever <chuck.lever@oracle.com>, Or Gerlitz <gerlitz.or@gmail.com>,
        Yishai Hadas <yishaih@mellanox.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 01/24] mlx4-ib: Use coherent memory for priv pages
Message-ID: <20160620070141.GD1172@leon.nu>
Reply-To: leon@kernel.org
References: <652EBA09-2978-414C-8606-38A96C63365A@oracle.com>
 <20160617092018.GZ5408@leon.nu>
 <4D23496A-FE01-4693-B125-82CD03B8F2D4@oracle.com>
 <20160618105650.GD5408@leon.nu>
 <5D0A6B47-CB71-42DA-AE76-164B6A660ECC@oracle.com>
 <57666E14.2070802@gmail.com>
 <CAJ3xEMha=i5SaM+fV5XP15Fx6pymrYnvk=a8w+3h1cbBeuVX0A@mail.gmail.com>
 <B62EEE84-454D-4D55-9C7E-653F564DF381@oracle.com>
 <20160620054453.GA1172@leon.nu>
 <57678E74.1070308@grimberg.me>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LTeJQqWS0MN7I/qa"
In-Reply-To: <57678E74.1070308@grimberg.me>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--LTeJQqWS0MN7I/qa
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jun 20, 2016 at 09:34:28AM +0300, Sagi Grimberg wrote:
>=20
> >Yishai and me follow this thread closely and we work on finding the
> >root cause of this issue.
>=20
> Thanks Leon and Yishai, let me know if you need any help with this.
>=20
> Do you agree we should move forward with the original patch until
> we get this resolved?

We will do our best to meet our fixes submission target, which is
planned to be this week.

And for sure we will submit one of two: your's proposed patch
or Yishai's fix if any.

Right now, your's patch is running in our verification.

Thanks

--LTeJQqWS0MN7I/qa
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXZ5TVAAoJEORje4g2clinIKAP/2NsRbQ9TVYkGzO2O+0clpgE
Cu+lBYJ7uO+FrF0w5tEwkjdk3hiG0ttEnjuu4oDvP/KpyBjy3esMb70EheT8V6XU
e80c6DVtYX51JjzoiPE+eSOI712WOg8IHP3HaPYNiO9J5Pmloqkxx4XSbRmTpop1
dLq5UOkkJmBEd4Y9ij1/CcHKeLW7AJUifc/v1KljveiOnu+9yJAJQ66T8trqD97u
4Bzi67M4nWNF6coH43s38W410R/w9nyKXb9x2hpIdA15cb85p/Nit3moxa60UCWH
rViD9jlE11lTPaaFciSsVp+mvV0NT5B4qgaxeaRk4R+59XJZ4SKMsjKbMSGmq9lm
9v8ppcCV1Y/LQ82uvOhI1J85WP5oQu+aBY2W8cpS3czOW+TMGzx3PVnLXmeA15pw
ODBZRD0rvlh6L5/0CCLbvhXT9U5cFR2V8smcqFSXqKG8ONfWDDP+NhJG5nwW1Tun
6RQaobIGz10WM0qEnAuUr6d1Hj3ny+MdQp+IaHjQo1H9TC7g+XOGS4Ezd3p5lu1K
L8OVq0Sx0aqi4YNj09T+WHKM3eMVyfut3iSYtuUNuS+eptq4KWXK/M9VTQ+mqTGW
j3ew7EL850lJbb31hwIlvB1OzDIdeuh0QxQ7WBad6ARMy2tTu9RLxkDQTORZe7LN
QQdmKzDWPP74J1zDO6ZO
=769h
-----END PGP SIGNATURE-----

--LTeJQqWS0MN7I/qa--
