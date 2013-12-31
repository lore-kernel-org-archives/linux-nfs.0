Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:55542 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756481Ab3LaW4d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Dec 2013 17:56:33 -0500
Date: Wed, 1 Jan 2014 09:56:20 +1100
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@redhat.com>, Simo Sorce <simo@redhat.com>,
        linux-nfs@vger.kernel.org
Subject: Re: should we change how the kernel detects whether gssproxy is
 running?
Message-ID: <20140101095620.0ab48051@notabene.brown>
In-Reply-To: <20131231180123.GA12875@fieldses.org>
References: <20131231073300.0e0f220a@tlielax.poochiereds.net>
	<20131231180123.GA12875@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/EQjHn8O5KxP55Ab6SeVIVE9"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/EQjHn8O5KxP55Ab6SeVIVE9
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 31 Dec 2013 13:01:23 -0500 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Tue, Dec 31, 2013 at 07:33:00AM -0500, Jeff Layton wrote:
> > I'm a bit concerned with how /proc/net/rpc/use-gss-proxy works...
> >=20
> > For one thing, when the kernel first boots any read against that file
> > hangs. That's going to be extremely problematic for certain tools that
> > scrape info out of /proc for troubleshooting purposes (e.g. Red Hat's
> > sosreport tool).
>=20
> Is that the only file under /proc for which that's true?  (E.g. the rpc
> cache channel files probably do the same, don't they?)  I was assuming
> tools like sosreport need to work from lists of specific paths.

The rpc cache channel files do not block on reads, so 'cat' works well on
them.
A process (like mountd) that wasn't to see new additions will use select (or
poll) for an 'exception' condition, and then read.

I think that it is best of all files in /proc (or /sys) would support 'cat'.
If I "tar" up "/proc" on my notebook it doesn't block ... though it does ta=
ke
quite a while on /proc/kcore :-)

NeilBrown

--Sig_/EQjHn8O5KxP55Ab6SeVIVE9
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUsNLlDnsnt1WYoG5AQJPHg//QAuhrfHNm1XWGHh+zbQEKxqmnH/vS9ho
xowTQH/0+clGBgCfnPV8gZkVKyRrcMbrJGEjPP4E6qn78mkBHqHkaCTqOVpt4IyS
QFHWkc/2iXjf13JT1PbiH4rhphcoxAjjqCgFE0TD6PrhfZc6C1RuH7t1jhlCZXE9
wsrVZkWcpnu1VcK2h4QSD2O95Pq9hxrnve3ppZF+fBa3/pUJWjXUE6ofNXplf7we
qs9VtiYjvG1mR5y3iDHpe6VcS4adqZE0XOhAXoY/+VF8fHlUCQWnCzOGVLXLiYe6
Q7NWu7CucD0I4P4IKcr9C78TwTNPQCakgFWb7C7NkQIaBEi9BgVeNyz4sX2V8opx
tqvsi05JoU0+i4+IdbFnPRMWxJTCimsje4/l+IGLBvloTnqf4m+XS+pdWzccpnAs
5YozkKjSQw28AvvL0gJ3Cz7jXmvfSjb4gEwlOYvnk8TnybH2RikaVh5OxOHYmvem
5uRigGZp6BIxl76yqSP+bvCTr+Kg+gFVeYXshWEgAie0steqZP878z0LyxWQJBnV
/aW5Quy1J9gfVWThV39OgjxtUQQHtTNdj5/w4QvMW9jF/ogLSsXkuWheSjyP5/B/
5judB1MvPTk1r09NoGIJtfkyaO7iqRuaE0CtLux9rYoOS/rV4kj2RIM58oocmj3V
5GrCqUc/poU=
=gt89
-----END PGP SIGNATURE-----

--Sig_/EQjHn8O5KxP55Ab6SeVIVE9--
