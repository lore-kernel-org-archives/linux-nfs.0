Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:51310 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751846AbaCJAPr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 9 Mar 2014 20:15:47 -0400
Date: Mon, 10 Mar 2014 11:15:39 +1100
From: NeilBrown <neilb@suse.de>
To: David Heidelberger <david.heidelberger@ixit.cz>
Cc: linux-nfs@vger.kernel.org
Subject: Re: DNOTIFY to INOTIFY migration
Message-ID: <20140310111539.7ae29497@notabene.brown>
In-Reply-To: <c90a00fb90b35b2ac904056383a3d532@ixit.cz>
References: <b59b1e4ede0b1d0a476c85465d480c8a@ixit.cz>
	<20140310102102.3c886726@notabene.brown>
	<c90a00fb90b35b2ac904056383a3d532@ixit.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/wA2HrN2IJpr7VVOwKhqmtk5"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/wA2HrN2IJpr7VVOwKhqmtk5
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 10 Mar 2014 01:55:15 +0100 David Heidelberger
<david.heidelberger@ixit.cz> wrote:

> Dne 2014-03-10 00:21, NeilBrown napsal:
> > On Fri, 07 Mar 2014 21:30:34 +0100 David Heidelberger
> > <david.heidelberger@ixit.cz> wrote:
> >=20
> >> Hello,
> >>=20
> >> in linux kernel is DNOTIFY actually marked as deprecated, with=20
> >> superior
> >> replacement INOTIFY.
> >=20
> > Where is it marked as deprecated?  I would be very surprised if dnotify
> > wasn't supported indefinitely.
>=20
>=20
> Dnotify is a directory-based per-fd file change notification system
> 	  that uses signals to communicate events to user-space.  There exist
> 	  superior alternatives, but some applications may still rely on
> 	  dnotify.
>=20
> (fs/notify/dnotify/Kconfig)

The fact that the new alternatives are (supposedly) superior doesn't mean t=
he
old are deprecated.


>=20
> In this moment, for modern systems I'm no aware of software actually=20
> using DNOTIFY.

I tend to use DNOTIFY because, much as I hate signals, it actually works wi=
th
python while python doesn't know about the new inotify systemcall (though I
know there is now some plug-in thing).
I suspect there is a lot of software that uses DNOTIFY that you don't know
about.


>=20
> Actually there is choice between INOTIFY and FSNOTIFY.
> >=20
> > (I have no opinion on whether rpc.idmapd should be changed to use=20
> > inotify,
> > except based on the "if it ain't broke, don't fix it" principle).
>=20
> Well, I'd like to propose build option which notify system include. It=20
> seems like *notify support reside only in rpc.idmapd, so it shouldn't be=
=20
> hard.

Feel free to post a patch.  You should make it clear how the change actually
benefits nfs-utils.  Make sure you don't use the word "deprecated" because
dnotify is *not* deprecated.

Thanks,
NeilBrown


>=20
> David
> >=20
> > NeilBrown
> >=20
> >>=20
> >> Is any plan to migrate rpc.idmapd to INOTIFY? As I looked, it's just=20
> >> one
> >> file.
> >>=20
> >> If there is some on-going porting, I'd like to test/report bugs/send
> >> patches, otherwise I'd like to try port it.
> >>=20
> >> Thank you for answer
> >> David Heidelberger (okias)
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-nfs"=20
> >> in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--Sig_/wA2HrN2IJpr7VVOwKhqmtk5
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUx0EKznsnt1WYoG5AQJv6BAAuPv4P4ESHT1Tle1wqM8DRPFmtMqL65La
vjubRsk+DoSRSkk+aqTitSudq/BKdGm7HrDWfjCF7eLTz0RVUBxZ2S8/7RIu60u6
WzUlmQpGayr06b0ZzydkX86of3q6T16Tlq6oznT56wGn7RW4tVxUSe8VXiJrNCzd
ny10btvl5gccVFjtGdSAEhGYSFa9dDew9j0WI6vrfdrwrlHORvBWQSe8TfmAbcy6
LF6IPYc2RUC7jJl2eZ9vTW5kA3Rzd/xGplyYl3PejMvOjluLgl85I6cWkaaDr/86
heC9cUZC9OQGcjmTkaRbETbxJtw7oWRhT2ZB1eMncsO7FqCLmn8Kc7SAOdK51f16
ZgaCSpIA7Y6Xo0Sz2TdtlzvlfoRBjrcmOE5JxkDd/M0kuNEa/XwHETv3GlUHFIeJ
kPYl6RaOCCSgV9tldDfKZWR3YaH/YmbsrOH2r9IgEsnEmnttw7XJ95AQNgBnzpQM
3kZXpAeVzmQtu7xVO5lu5+fCJlLKxHXJbS9kN9KEgRE4DItz8S+ksE/5nEro42mZ
7DsDSzKBrWASU1kR0JY4ZIV4o3i1gOtT5RMLsusBs2IfAth5vGZV2fVfER2qtfYo
OO1yfvK36lsKJsC76mKAKP5Yq066x1Wasn0XmHbloKV0pjg8PEA85oNvt04dy/o3
rHxsqfYri44=
=jQ+k
-----END PGP SIGNATURE-----

--Sig_/wA2HrN2IJpr7VVOwKhqmtk5--
