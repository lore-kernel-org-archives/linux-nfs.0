Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:56829 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751810AbbBRBnA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Feb 2015 20:43:00 -0500
Date: Wed, 18 Feb 2015 12:42:51 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Steve Dickson <SteveD@redhat.com>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH/RFC nfs-utils] exports.man: improve documentation of
 'nohide' and 'crossmnt'
Message-ID: <20150218124251.37844b36@notabene.brown>
In-Reply-To: <CAHQdGtT+xq4uFfjxvDXgG+Oe4NvNCjj0ngmGftTVfherqwJxXQ@mail.gmail.com>
References: <20150216122107.4bfd4225@notabene.brown>
	<20150216201751.GB22154@fieldses.org>
	<CAHQdGtT+xq4uFfjxvDXgG+Oe4NvNCjj0ngmGftTVfherqwJxXQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/HFVrVHa=krRKpWh5DsxsFR5"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/HFVrVHa=krRKpWh5DsxsFR5
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 16 Feb 2015 18:06:06 -0500 Trond Myklebust
<trond.myklebust@primarydata.com> wrote:

> On Mon, Feb 16, 2015 at 3:17 PM, J. Bruce Fields <bfields@fieldses.org> w=
rote:
> > On Mon, Feb 16, 2015 at 12:21:07PM +1100, NeilBrown wrote:
> >>
> >>
> >> - note that 'nohide' is irrelevant for NFSv4
> >> - note that children on a 'crossmnt' filesystem cannot be unexported
> >> - note that 'nocrossmnt' is a valid option, but probably not useful.
> >>
> >> Signed-off-by: NeilBrown <neilb@suse.de>
> >>
> >> ---
> >>
> >> I wonder if we should add a new option, e.g. "noaccess" so that childr=
en
> >> of a "crossmnt" filesystem can be hidden.  The  kernel wouldn't need to
> >> know about this.  It would just tell mountd to refuse to export that
> >> filesystem even if the parent was "crossmnt".
> >> ??
> >
> > Seems logical enough, but I can't recall seeing requests for it, and
> > the options here already seem complicated enough.
> >
> > In theory something like that could also be done with namespaces.  (So,
> > run mountd in a separate mount namespace that lacks those children.)
>=20
> Agreed. It seems unnecessarily complicated to add yet another option
> to the crossmnt/nohide saga. If the "nohide" documentation is too
> complex, then we should rather aim to improve that documentation.
>=20

Yes - improving the documentation was my first step, hence this patch.

Writing that documentation lead me to see that a particular configuration w=
as
impossible - hence the question.

I have no strong desire for a change, and that seems to be common among
others, so let's just drop it.

Thanks,
NeilBrown

--Sig_/HFVrVHa=krRKpWh5DsxsFR5
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVOPuGznsnt1WYoG5AQKujhAArw9GeK0LGdqe21LA+nZcqn9md+AbZtlw
K8z5W1mRFhqI7AZ+FImBW53682CnY9eGkT1dF+mF+2IKW0Cfk/qSYhBTUAcZJDg8
YLDOjaOIQhWu6rhaTtB91TzYfCSaTChl025UngtCXNtdnsr++55SpBWyhPBQNyYg
JBj/7eUerxt17sW1tw9X02XdyxICLSXW+JPGUYBPl2zfUHIWpFy7oS1/epGJVsQh
wMoRUv7X8sx/HKksSdpgk8Ix+0kLWS8x81IQW5OdohKcc1T56LZ0Pnl/xnzQ55QH
QwOmzosoQ701aRbfFgcEP9ZtIdkk3pGrsykdd/61E0AgXxd+/BawjreyEM5OgygW
h/FEr9gp3VPJecpj/9qxwjHI1xh2lzruWhyqMLlQRUYtwh7e5YZwtx/gicySQcRr
o0ydkmz4iIDljJiRmqGxN3zn58DAVGCnzwF/Q7Q5qHn3RkAx2bc4a+T8OL9R0qeo
boFUbqjcWUnzZv6vtPR1qR3Cpxe8i5jwCqW3C9HCBL3bmMzHCkpdORSwV0VsXkLm
QUuFQyJR1Cp4vMuMOO4czVlCL7Bmko5Sf21se9S2GldqorMpyvmRbCcKynFdZ/fR
Z/7XlP4a4HrlfJlK/4r456TEXtDdTFk0tctz/M4vIqVQbo+JbY6SnV712XM7uAHv
15FSg/Q6Qfk=
=o+t2
-----END PGP SIGNATURE-----

--Sig_/HFVrVHa=krRKpWh5DsxsFR5--
