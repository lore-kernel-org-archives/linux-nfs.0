Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:35306 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754455AbaEVJvM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 May 2014 05:51:12 -0400
Date: Thu, 22 May 2014 19:50:56 +1000
From: NeilBrown <neilb@suse.de>
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Oleg Nesterov <oleg@redhat.com>,
        David Howells <dhowells@redhat.com>,
        Steven Whitehouse <swhiteho@redhat.com>, dm-devel@redhat.com,
        Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>,
        Steve French <sfrench@samba.org>, "Theodore Ts'o" <tytso@mit.edu>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Ingo Molnar <mingo@redhat.com>, Roland McGrath <roland@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org
Subject: Re: [PATCH] SCHED: remove proliferation of wait_on_bit action
 functions.
Message-ID: <20140522195056.445f2dcb@notabene.brown>
In-Reply-To: <20140522090502.GB30094@gmail.com>
References: <20140501123738.3e64b2d2@notabene.brown>
	<20140522090502.GB30094@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/SLj=Ra/Rg+8ROWmpsMdvvlW"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/SLj=Ra/Rg+8ROWmpsMdvvlW
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 22 May 2014 11:05:02 +0200 Ingo Molnar <mingo@kernel.org> wrote:

>=20
> * NeilBrown <neilb@suse.de> wrote:
>=20
> > [[ get_maintainer.pl suggested 61 email address for this patch.
> >    I've trimmed that list somewhat.  Hope I didn't miss anyone
> >    important...
> >    I'm hoping it will go in through the scheduler tree, but would
> >    particularly like an Acked-by for the fscache parts.  Other acks
> >    welcome.
> > ]]
> >=20
> > The current "wait_on_bit" interface requires an 'action' function
> > to be provided which does the actual waiting.
> > There are over 20 such functions, many of them identical.
> > Most cases can be satisfied by one of just two functions, one
> > which uses io_schedule() and one which just uses schedule().
> >=20
> > So:
> >  Rename wait_on_bit and        wait_on_bit_lock to
> >         wait_on_bit_action and wait_on_bit_lock_action
> >  to make it explicit that they need an action function.
> >=20
> >  Introduce new wait_on_bit{,_lock} and wait_on_bit{,_lock}_io
> >  which are *not* given an action function but implicitly use
> >  a standard one.
> >  The decision to error-out if a signal is pending is now made
> >  based on the 'mode' argument rather than being encoded in the action
> >  function.
>=20
> this patch fails to build on x86-32 allyesconfigs.

Could you share the build errors?

>=20
> Could we keep the old names for a while, and remove them in the next=20
> cycle or so?

I don't see how changing the names later rather than now will reduce the
chance of errors... maybe I'm missing something.

Thanks,
NeilBrown



>=20
> Thanks,
>=20
> 	Ingo


--Sig_/SLj=Ra/Rg+8ROWmpsMdvvlW
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU33IgDnsnt1WYoG5AQL4zg/9EwXq3ga0dXQf8DsKuJ5gg0PFSywVLg53
ov/ah4ODfC2IL9Cjq/vrfQ9hoV5XwIhpvr9Ooz1dvuHkJn2OKJU/C9+hD+vJmRlN
0iJQBNkkdBj7XwEon+QXYgeeKIQNI6ErxHHIXN/FEtSZa4eWElBiUplTMcFY/TeJ
erB7cJDQxk3jm7q3em4F1Scg1cc6q+rJb98WIXdSpfQCzZhC3xbke2dlAetjNgzY
ea6yAhGIy0LcBevl8IGucX7FC9C6uOlxw4KhJ+i1LyaMMzwyZZ2zsipKEwSkdCug
aN2b4MYE/6/1C0gME8FjpfxGFlw6/2a/KCmKQaxWowPtJa69xozl62ZVNZ1JrTV6
0T8R+C4xsVzTn03KjgMdN5tUbQYT9RbF67ld0rGSfKowmtS+mP7SZnNRKib4PhAn
0ZEayg4T4uq9z5SuJEhUKpyj7GEyeehW+luYJTVt8LTuH79qEi1GBTdCSZ2YkS/F
zK5lRIUhzmlDd1RkvOrQaPzSjY6hxR2QEJZtY6r9i6W1QWYWJAMAxTTbYc8UYiGt
qAmhwKe8neKmznogq85iNg5A+88v4JUiVwz1/jWP3PTwOGOo+F8d5Y+youB+TotD
ZvZVSUwSfJfc8rn3cUCotypxfbkbsrP7fGIDkrD8/EfvY9YWtVdbGFWZzW8shFOA
ief4BXTLFCg=
=qy8/
-----END PGP SIGNATURE-----

--Sig_/SLj=Ra/Rg+8ROWmpsMdvvlW--
