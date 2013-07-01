Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:48022 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754808Ab3GAVff (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Jul 2013 17:35:35 -0400
Date: Tue, 2 Jul 2013 07:35:21 +1000
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 3/3] gssd: add -N option to use root credentials as
 machine credentials.
Message-ID: <20130702073521.70cf33ea@notabene.brown>
In-Reply-To: <51D1ACFA.2010203@RedHat.com>
References: <20130603005219.20080.1927.stgit@notabene.brown>
	<20130603010022.20080.88360.stgit@notabene.brown>
	<51D1ACFA.2010203@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/t=dfoxlfm1Ukl4kBrTbaepg"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/t=dfoxlfm1Ukl4kBrTbaepg
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 01 Jul 2013 12:23:22 -0400 Steve Dickson <SteveD@redhat.com> wrote:

> Neil,
>=20
> On 02/06/13 21:00, Neil Brown wrote:
> > Since linux-3.7, the kernel asks explicitly for machine credentials
> > rather than root credentials to authenticate state management requests.
> >=20
> > This causes a regression for people who do not have machine
> > credentials configured and were using "gssd -n" to instruct gssd to
> > disable the default mapping of using machine credentials to authorise
> > accesses by 'root'.
> >=20
> > This patch adds '-N' flag which instruct gssd explicitly to use 'root'
> > credentials whenever 'machine' credentials are requested.  Thus
> >   gssd -n -N
> > provides the same service that
> >   gssd -n
> > used to.
> >=20
> > In summary:
> >=20
> > Credentials used for different request types and different gssd flags:
> >=20
> >    Request type: |     "gssd"      "gssd -n"   "gssd -N"    "gssd -nN"
> >                  |
> >      machine     |     machine      machine     root         root
> >                  |
> >      root        |     machine      root        machine      root
> >=20
> > Signed-off-by: NeilBrown <neilb@suse.de>
> So is this no longer needed do the kernel change you and Chuck came up wi=
th?
>=20
> steved.

That is correct.  This patch is no longer needed.

Thanks,
NeilBrown

--Sig_/t=dfoxlfm1Ukl4kBrTbaepg
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUdH2GTnsnt1WYoG5AQKQ+g/8C8ZRbDq1vL/ZG3VjVhW50ovtNXMEAJ/W
BZd5d5A/nA4wr7cm1XfNxgRcbZK3SJS2rWDlmYnpOU/DEl+geWPETuO0o1H68pL4
XUG4cw6taepzKBDXOViQslGvEYPKR63uM4hsAjPomyfE0PqZsbfuait7UFTWbC1G
A9IJMW3l6hoLZLQ30w9/5p6ACwx/Bo+Y7eb8DPvt+jBKOACMKzWg9ZTsf0RI3BnP
8WsY9T9Ns4X/6G9bmJMTcKjPs3rjz9EwlcKG3vnmH6lQi+DMC4M2MhzxqLj3xQW5
e8P920fzL+cUwEh+7l203A9WAnjqbliWE5Q+ljv+1K4Tdzuq4N43KlFbf3+3Bu0o
JzW15Ws/Dkm2ba6v1yqnWOU9Oba/+1nRzSuNHhGrp4sNOhy1wve/rf0pSsNgitSe
dQo1EfQo3MrFYNzceJKSZYKr+gIoB+EyvtIvRUvXjtu4fBiiUjpNy2sGYsZwKGcc
2dmWCiLFuAUwTTNeV5/qzPn6rPXV5Bm8dIhEiU9WfQ1j4s8bopl/kHJ860oU02eg
yay/PKSfTGP/nvllnrB/XLYpfQgeYSu++3TCpWcJ8oV/U7Ty+JhES56AsnTyAdJd
0i4rtr1zhDsgQsuUsVs/BVqo/s0TSLTbouX6WKM9mkY4Gt/PuZMa5CCu7T+50w0H
kUkJ0C1MymA=
=PCSq
-----END PGP SIGNATURE-----

--Sig_/t=dfoxlfm1Ukl4kBrTbaepg--
