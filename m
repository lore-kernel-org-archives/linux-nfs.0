Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:53066 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752498Ab3KZCLj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Nov 2013 21:11:39 -0500
Date: Tue, 26 Nov 2013 13:11:24 +1100
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: The return of the hanging "ls"...
Message-ID: <20131126131124.0cab6b4a@notabene.brown>
In-Reply-To: <1385422860.9247.15.camel@leira.trondhjem.org>
References: <20131125155942.0a3e4ca1@notabene.brown>
	<A7CF3941-980F-4B96-B473-ECB46375CFCF@oracle.com>
	<20131126102301.6cbbdb94@notabene.brown>
	<1385422860.9247.15.camel@leira.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/n=99.YtZNskF4n3klo9LpG4"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/n=99.YtZNskF4n3klo9LpG4
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 25 Nov 2013 23:41:02 +0000 "Myklebust, Trond"
<Trond.Myklebust@netapp.com> wrote:

> On Tue, 2013-11-26 at 10:23 +1100, NeilBrown wrote:
> > On Mon, 25 Nov 2013 09:59:39 -0500 Chuck Lever <chuck.lever@oracle.com>=
 wrote:
> >=20
> > > Hi Neil-
> > >=20
> > > On Nov 24, 2013, at 11:59 PM, NeilBrown <neilb@suse.de> wrote:
> > >=20
> > > >=20
> > > > Hi Trond,
> > > > I just noticed commit acdc53b2146c7ee67feb1f02f7bc3020126514b8 from=
 2010
> > > > reverts the effect commit 28c494c5c8d425e15b7b82571e4df6d6bc34594d =
from Chunk
> > > > in 2007.
> > >=20
> > > I'm wondering if a subsequent commit changed filemap_write_and_wait().
> >=20
> > I hadn't thought of that possibility.  I've just had a look at the
> > differences between  acdc53b2146c7ee6  and now and cannot find anything=
 that
> > could be related.
>=20
> To clarify a little: my understanding is that the current 2-pass code in
> write_cache_pages() is supposed to prevent livelock. Instead of chasing
> PAGECACHE_TAG_DIRTY tags (which are constantly being set if an
> application is actively writing), we call tag_pages_for_writeback() once
> in order to convert the current set of PAGECACHE_TAG_DIRTY tags into
> PAGECACHE_TAG_TOWRITE tags, and then we have a second pass write those
> pages back (and wait for completion).
> IOW: the inode->i_mutex should be unnecessary here...

Thanks for that pointer.  You are right, write_cache_pages shouldn't loop
indefinitely any more.
And I also just noticed commit 72cb77f4a5ace37b12dcb47a0e8637a2c28ad881 and
NFS_INO_FLUSHING which is an extra reason that the i_mutex isn't needed.
Don't know how I missed that last night.  Less haste, more speed I guess.

So it looks like I jumped the gun and there must be some other explanation.
Sorry 'bout that.

Thanks,
NeilBrown

>=20
>=20
> Now that said, we recently added in the call to nfs_inode_dio_wait(). If
> applications are using O_DIRECT, then _that_ could livelock. There is
> nothing currently preventing the applications from continuing to bump
> the inode->i_dio_count while we're waiting. Christoph has proposed some
> locking changes that should fix that problem. I'm still evaluating his
> patchset...
>=20
> Cheers
>   Trond
>=20
> Cheers
>   Trond


--Sig_/n=99.YtZNskF4n3klo9LpG4
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUpQDTTnsnt1WYoG5AQKzuRAAgkWrc6tRqdK/FAwyl3dOKBO5pE4KlIuq
c8nVJvOu8fvo+Cb/hODpUkYuYgFfdsbJNUAQj7kjVymme/C7iHdnTmtWWQGbQ1uN
VrZl/8Gout3zurHefSwrUo3499OhG1SCvt63bXPH8+Rqv6WnK3zXCs42+BLHnRyc
ekDN/WdHccY3lvMX2Peod21Afb62I6UqLy7wuE3wjA2hdTxhU2msgOv+FejcC5SQ
fQzVjocjMwMlc1P7IC5m2jSHtE2HyhTVNoMNoMGins/O3EUPtin+oTbc/OXizJlC
Ib/3aAMyZvVLsM7Mw2x+9h+VB8xwmzykv2JmagW7QzeKlivEreqy/VPEhrU9IIfU
Ow39wC9q3TvdoXk/vq/dISwjqvVo1kmwLdZUzq5jJUdg+8MFM0AMsjrT1RQg7hef
A97O/T9tAf/jYXeCifEafubXYA4f2CM3I+kgfei+TKTVfaKDuJieBpDmB5ihFf3b
bnMNYyJ7wE2LFQpFI6tUdzk8z6ydVmE6x04UF1cBiiaghWf8oV9YLK6kuUzhMHT8
Mr5PWY+ehoLdzHh43ChVRUDQ7uIc1i2cLLSI7BkX3G6DaSQv+lCBZnlt0oEhLuCs
zqmvFF5oBlFos+yfKObWJZRz5aXtYfpUym9rlWeVPfigg/FMF9uhWVsoq2uFdvpZ
tcZU6wuLWQQ=
=jvbW
-----END PGP SIGNATURE-----

--Sig_/n=99.YtZNskF4n3klo9LpG4--
