Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:37546 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755543AbaIICd5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Sep 2014 22:33:57 -0400
Date: Tue, 9 Sep 2014 12:33:46 +1000
From: NeilBrown <neilb@suse.de>
To: Michal Hocko <mhocko@suse.cz>
Cc: Mel Gorman <mgorman@suse.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Junxiao Bi <junxiao.bi@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH v2 1/2] SUNRPC: Fix memory reclaim deadlocks in rpciod
Message-ID: <20140909123346.434f0443@notabene.brown>
In-Reply-To: <20140904135427.GA14548@dhcp22.suse.cz>
References: <53F6F772.6020708@oracle.com>
	<1408747772-37938-1-git-send-email-trond.myklebust@primarydata.com>
	<20140825164852.50723141@notabene.brown>
	<20140826105304.GT17696@novell.com>
	<CAHQdGtRMFuH9MsJBj5YsOrJW+qFLFp_-X=b_gZPVmgVQ22swqQ@mail.gmail.com>
	<20140826132624.GU17696@novell.com>
	<20140826231938.GA13889@cmpxchg.org>
	<CAHQdGtRPsVFVfph5OcsZk_+WYPPJ-MpE2myZfXAb3jq6fuM4zw@mail.gmail.com>
	<CAHQdGtQPMJNzSM5Wt4RnNqEawBLqmYHycXTmBHhmAt26dz5wCw@mail.gmail.com>
	<20140827153644.GF12374@novell.com>
	<20140904135427.GA14548@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/.sO2KSGFiEp3BTVtcaGw/b2"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/.sO2KSGFiEp3BTVtcaGw/b2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 4 Sep 2014 15:54:27 +0200 Michal Hocko <mhocko@suse.cz> wrote:

> [Sorry for jumping in so late - I've been busy last days]
>=20
> On Wed 27-08-14 16:36:44, Mel Gorman wrote:
> > On Tue, Aug 26, 2014 at 08:00:20PM -0400, Trond Myklebust wrote:
> > > On Tue, Aug 26, 2014 at 7:51 PM, Trond Myklebust
> > > <trond.myklebust@primarydata.com> wrote:
> > > > On Tue, Aug 26, 2014 at 7:19 PM, Johannes Weiner <hannes@cmpxchg.or=
g> wrote:
> [...]
> > > >> wait_on_page_writeback() is a hammer, and we need to be better abo=
ut
> > > >> this once we have per-memcg dirty writeback and throttling, but I
> > > >> think that really misses the point.  Even if memcg writeback waiti=
ng
> > > >> were smarter, any length of time spent waiting for yourself to make
> > > >> progress is absurd.  We just shouldn't be solving deadlock scenari=
os
> > > >> through arbitrary timeouts on one side.  If you can't wait for IO =
to
> > > >> finish, you shouldn't be passing __GFP_IO.
>=20
> Exactly!

This is overly simplistic.
The code that cannot wait may be further up the call chain and not in a
position to avoid passing __GFP_IO.
In many case it isn't that "you can't wait for IO" in general, but that you
cannot wait for one specific IO request.

wait_on_page_writeback() waits for a specific IO and so is dangerous.
congestion_wait() or similar waits for IO in general and so is much safer.

NeilBrown


--Sig_/.sO2KSGFiEp3BTVtcaGw/b2
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBVA5nCjnsnt1WYoG5AQK2LxAAhEOQ0qJ/46vRP7o949RUbC1fhdUJQ3Tf
CzYlTWLp9z86XTrUjP4i1Th/nAK+QWqHP8kJ9AlnVkqIH4ZJkVw1MKNZLmE42Tay
vHfiAKgvovBboSoX9i5qh2htqp3p2XI3GI7L1uKoB0Jacfbbr91/GEuDDDZGEOv3
BF57pDepYGDGCIn4dtyzWvkvXOkt8svYmHd6Z5xoFbsYKBLQXkN/oIPKvljrWVj/
58uBpgoHJmPlrhtqR6+VBzjm4bZIWBKQ6ffDngdaSts1g9hJz38+M1/7IvBp4gna
oB08eyzhch04HFFIKcQjcu/9MbutT5bbVpQq7vsLrGOp4yn41mlPH6dXVh3rmQxG
mpcqzVMUgI2QwKjy0yp9jpjwJbH2ZwZ1RhGqO1mOBiwME5Z6iQOgVB80rR1t5SB9
iW/17jeU4Lwv+swe4warJEyCIpzeWNq35KRz8elZ7aw8KynF3keFacLhkLCKw16x
S74xzzuShgVqnrd9Lu0hpnnE6SH6UHHKVNDa/MvLrB9XJUhIOmcLbeNXXsP/H2Hq
lHK3H+E74nbcOnFbHhOm+GXKSdWn1AWuMN5AlZQYoOGv++YJD7iiUWNu4Ynx46IG
jBACYod1h1lCPAzsoxJn+wPR9jU7H+etYtjv8B3+Z/aBsg1bthXBp8395QHmeCZo
POW52N+hdyM=
=JbuS
-----END PGP SIGNATURE-----

--Sig_/.sO2KSGFiEp3BTVtcaGw/b2--
