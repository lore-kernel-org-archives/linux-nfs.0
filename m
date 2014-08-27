Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:54195 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756006AbaH0Bnf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Aug 2014 21:43:35 -0400
Date: Wed, 27 Aug 2014 11:43:23 +1000
From: NeilBrown <neilb@suse.de>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@suse.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Junxiao Bi <junxiao.bi@oracle.com>, Michal Hocko <mhocko@suse.cz>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH v2 1/2] SUNRPC: Fix memory reclaim deadlocks in rpciod
Message-ID: <20140827114323.2c3e9e41@notabene.brown>
In-Reply-To: <20140826231938.GA13889@cmpxchg.org>
References: <53F6F772.6020708@oracle.com>
	<1408747772-37938-1-git-send-email-trond.myklebust@primarydata.com>
	<20140825164852.50723141@notabene.brown>
	<20140826105304.GT17696@novell.com>
	<CAHQdGtRMFuH9MsJBj5YsOrJW+qFLFp_-X=b_gZPVmgVQ22swqQ@mail.gmail.com>
	<20140826132624.GU17696@novell.com>
	<20140826231938.GA13889@cmpxchg.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/dKFHZHdCmuIAx8w5_G94/mM"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/dKFHZHdCmuIAx8w5_G94/mM
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 26 Aug 2014 19:19:38 -0400 Johannes Weiner <hannes@cmpxchg.org> wro=
te:

> On Tue, Aug 26, 2014 at 02:26:24PM +0100, Mel Gorman wrote:

> > It'd be nice of the memcg people could comment on whether they plan to
> > handle the fact that memcg is the only called of wait_on_page_writeback
> > in direct reclaim paths.
>=20
> wait_on_page_writeback() is a hammer, and we need to be better about
> this once we have per-memcg dirty writeback and throttling, but I
> think that really misses the point.  Even if memcg writeback waiting
> were smarter, any length of time spent waiting for yourself to make
> progress is absurd.  We just shouldn't be solving deadlock scenarios
> through arbitrary timeouts on one side.  If you can't wait for IO to
> finish, you shouldn't be passing __GFP_IO.

I think that is overly simplistic.  Certainly "waiting for yourself" is
absurd, but it can be hard to know if that is what you are doing.
Refusing to wait at all just because you might be waiting for yourself is
also absurd.
Direct reclaim already has "congestion_wait()" calls which wait a little
while, just in case.  Doing that you find a page in writeback might not be
such a bad thing.

When this becomes an issue, writeout is already slowing everything down, and
maybe slowing down a bit more isn't much cost.


>=20
> Can't you use mempools like the other IO paths?

mempools and other pre-allocation strategies are appropriate for block
devices and critical for any "swap out" path.
Filesystems have traditionally got by without them, using GFP_NOFS when
necessary.

GFP_NOFS was originally meant to be set when holding filesystem-internal
locks.  Setting it everywhere that memory might be allocated while handing
write-out is a very different use-case.

Setting GFP_NOFS in more and more places doesn't really scale very well and
is particularly awkward for NFS as lots of network interfaces don't allow
setting GFP flags, and the network maintainers really don't want them to.

The recent direct-reclaim changes to get kswapd and the flush- threads to do
most of the work made it much easier to avoid deadlocks.  Direct reclaim no
longer calls ->writepage and doesn't wait_on_page_writeback().  Except when
handling memory pressure for a memcg.

It's not an easy problem, but I don't think that "use mempools" is a valid
answer.  A simple rule like "direct reclaim never blocks indefinitely" is, I
think, quite achievable and would resolve a whole class of deadlocks.

Thanks,
NeilBrown


--Sig_/dKFHZHdCmuIAx8w5_G94/mM
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU/03uznsnt1WYoG5AQJ6cw/+Pi26eA4dgpo/malX0ba+0tgsK37N4ax6
Iipmfiye4bQ7YJLTsVS98bCHSvhirBq0h/tACiWqV/gOpfh4PEaTd7RXB7PJmhtL
bkRXm72W12Vqa6lBOmdmRXOx4LaHzEJObcbAJP4Hkdh1j0KLWP3gAUYf0Uz/nzLt
OztdOpQgFeEmIoXiQMeyTtHOpzxfvZn8IGw+lyqU7klPCsasv4YHoe78JkfLyVWd
POkFvcSDGrXYOZvXgcKTZgSG8qDhFZPdeW72WBRpEhEIqhNAwNAJxBwgS2Szq0MX
Mfgw0/YOk0K/F2/nyOzbrdogakONauJKnsVYWykjNRvFxuUyLmNBcUHzRhZm/NjE
pEuCjZjZWnR7eQfW+3Q93qiAril6/CsJ7alXx/ixzaDmMSjXzboZO244zUkASbXl
FsH0rLwcoaI9ZgCPvWcvo14igYhco6Jb3UTAelULl1pLDwxrnUwYgKFXxDjqN+cM
lh6SwZdT/T1nMSeLrjwGgZ3KkFdheLRKO9JXz0h6Zpb95K1x5JlmMz3mFpxBwYfA
VbCO663dU2hZA/OPlKhnLrUByrjwiistmwqdIaZTfOisL0/KvLD4PO0XWEv4rf9u
JMUJxFBU/mh2ep9xdZSc3ulPvDcqm5i2pITHs1ByciUyyY9vcL5QUoB/NWA0oR+P
/ZsCEzVhNyc=
=KQWH
-----END PGP SIGNATURE-----

--Sig_/dKFHZHdCmuIAx8w5_G94/mM--
