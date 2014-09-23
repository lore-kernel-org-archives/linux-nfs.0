Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:53354 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754019AbaIWCz2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Sep 2014 22:55:28 -0400
Date: Tue, 23 Sep 2014 12:55:17 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Simo Sorce <simo@redhat.com>, Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfs-service: Added the starting of gssproxy
Message-ID: <20140923125517.7a20b09a@notabene.brown>
In-Reply-To: <20140923020928.GA1409@fieldses.org>
References: <1411413608-16462-1-git-send-email-steved@redhat.com>
	<1411413608-16462-2-git-send-email-steved@redhat.com>
	<20140922194057.GE26763@fieldses.org>
	<20140922154642.779189c8@willson.usersys.redhat.com>
	<54207E4A.7010300@RedHat.com>
	<20140922160050.0b85f044@willson.usersys.redhat.com>
	<20140923114229.0a9e294f@notabene.brown>
	<20140923020928.GA1409@fieldses.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/BdvSZuqnx+nzfEVZrnPSzXj"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/BdvSZuqnx+nzfEVZrnPSzXj
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 22 Sep 2014 22:09:28 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Tue, Sep 23, 2014 at 11:42:29AM +1000, NeilBrown wrote:
> > Surely gssproxy is only serving nfsd requests if both /run/gssproxy.pid
> > exists and /proc/net/rpc/use-gss-proxy exists.
> > If either of those files is missing, then rpc.svcgssd needs to run.
> > In one case, the gssproxy daemon isn't available for some reason.  In t=
he
> > other case the kernel cannot make use of it.
> >=20
> > Is that not correct?
> >=20
> > That is exactly the rule that I (tried to) encode in the service file w=
ith
> > these two conditions.
>=20
> Eh, I see your point, but the gssproxy.pid one still seems a little odd
> to me.
>=20
> I guess it's friendlier to people that don't have gss-proxy installed at
> all, or want to turn it off for some reason--but then they or their
> distro can fix up the unit files too.

Having to fix up unit files is something I would much rather avoid.  I think
of them as code and just because they can be edited it doesn't mean they
should be.

I'm quite open to having rpc.svcgssd test to see if gssproxy is installed
rather than if it is running.  In that case we would have a 'Want=3D' somew=
here
in nfs-utils for gssproxy.service (which I previously said I didn't like but
I'm beginning to see the wisdom of).

But if gssproxy isn't installed, then I think rpc.svcgssd should run whether
use-gss-proxy is present or not.

>=20
> Otherwise if we've got gss-proxy and the kernel supports it then it
> should work, and if it's failing to come up in that case I'd kind of
> like to know why and get a bug report like "gssproxy failed to start" or
> "krb5 exports stopped working" rather than "krb5 exports are working in
> some subtly different way than they did last week."

This is quite a strong argument.

Thanks,
NeilBrown

>=20
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--Sig_/BdvSZuqnx+nzfEVZrnPSzXj
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBVCDhFjnsnt1WYoG5AQLd2BAArXnA8vwtlq00WIm5r4NYAcg7VSc75Sgq
ZFbe8CutUGmrX6XHcQHRkg7h3EP8NGbAG3yv8pnzJpxSIM9UvWxE0yYWssGgw/3m
Z6Sio0LardrhoGOxMw8W6fUiaqdgH8LtfLEey1o7JZF5DGB/vDF74Po2bl6m2NGU
sMfy3MZQ9GEcuXBOBp4wkbH29y0GUWLgrKdZEq51xePN89oXST3So4NJ7s9A5GJF
pIGeapU1d5xHtizEzT5w3tCc/cREb/WOR9CAvIYKhjYq5wR1c3T6TyiEWOYtFNrO
ZR6nVgvI+8oUtrcU0gS/1Ryh1v4LduEsAC8AqSODdWK3BtRDCYaQ71coe5KimKvE
7YU8w/fogEZZy9YmogNDFFMOj3FIJDpveQaQgicJAnMwIRHoBiQAK/4NPS2fw7xK
HKmSEWNuAn72ya2LTvMb0F0PJUP67Fic3vZvMK/iuKxT++YXR0nIc5Ss01M2E+iV
rHImCjVzsIoCpuPdiWg5JXumNLQq4+cBciiAXSLVVft0Jrov53zHSIWdz6sGznjK
o9HQYL/jbdtymFj1om8M3taVr2X7ED0CekOIjgtG/6MKBvGuRvPhvR1oXIaKsSel
KwOIDCvopUmNT1CDb4vMw5/A5v9I/xA54aIcA4UI+BDvJ7dzwkd9PgN8DhMC8uun
zUhvHSqwjjY=
=gORw
-----END PGP SIGNATURE-----

--Sig_/BdvSZuqnx+nzfEVZrnPSzXj--
