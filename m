Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:34875 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754287AbaHZGV4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Aug 2014 02:21:56 -0400
Date: Tue, 26 Aug 2014 16:21:38 +1000
From: NeilBrown <neilb@suse.de>
To: Junxiao Bi <junxiao.bi@oracle.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Mel Gorman <mgorman@suse.com>
Subject: Re: [PATCH v2 1/2] SUNRPC: Fix memory reclaim deadlocks in rpciod
Message-ID: <20140826162138.5df2f8a3@notabene.brown>
In-Reply-To: <53FC1E93.2060800@oracle.com>
References: <53F6F772.6020708@oracle.com>
	<1408747772-37938-1-git-send-email-trond.myklebust@primarydata.com>
	<20140825164852.50723141@notabene.brown>
	<53FC1E93.2060800@oracle.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/ioh5G0sbw/l36kjHgl5dAel"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/ioh5G0sbw/l36kjHgl5dAel
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 26 Aug 2014 13:43:47 +0800 Junxiao Bi <junxiao.bi@oracle.com> wrote:

> On 08/25/2014 02:48 PM, NeilBrown wrote:
> > On Fri, 22 Aug 2014 18:49:31 -0400 Trond Myklebust
> > <trond.myklebust@primarydata.com> wrote:
> >=20
> >> Junxiao Bi reports seeing the following deadlock:
> >>
> >> @ crash> bt 1539
> >> @ PID: 1539   TASK: ffff88178f64a040  CPU: 1   COMMAND: "rpciod/1"
> >> @  #0 [ffff88178f64d2c0] schedule at ffffffff8145833a
> >> @  #1 [ffff88178f64d348] io_schedule at ffffffff8145842c
> >> @  #2 [ffff88178f64d368] sync_page at ffffffff810d8161
> >> @  #3 [ffff88178f64d378] __wait_on_bit at ffffffff8145895b
> >> @  #4 [ffff88178f64d3b8] wait_on_page_bit at ffffffff810d82fe
> >> @  #5 [ffff88178f64d418] wait_on_page_writeback at ffffffff810e2a1a
> >> @  #6 [ffff88178f64d438] shrink_page_list at ffffffff810e34e1
> >> @  #7 [ffff88178f64d588] shrink_list at ffffffff810e3dbe
> >> @  #8 [ffff88178f64d6f8] shrink_zone at ffffffff810e425e
> >> @  #9 [ffff88178f64d7b8] do_try_to_free_pages at ffffffff810e4978
> >> @ #10 [ffff88178f64d828] try_to_free_pages at ffffffff810e4c31
> >> @ #11 [ffff88178f64d8c8] __alloc_pages_nodemask at ffffffff810de370
> >=20
> > This stack trace (from 2.6.32) cannot happen in mainline, though it too=
k me a
> > while to remember/discover exactly why.
> >=20
> > try_to_free_pages() creates a 'struct scan_control' with ->target_mem_c=
group
> > set to NULL.
> > shrink_page_list() checks ->target_mem_cgroup using global_reclaim() an=
d if
> > it is NULL, wait_on_page_writeback is *not* called.
> >=20
> > So we can only hit this deadlock if mem-cgroup limits are imposed on a
> > process which is using NFS - which is quite possible but probably not c=
ommon.
> >=20
> > The fact that a dead-lock can happen only when memcg limits are imposed=
 seems
> > very fragile.  People aren't going to test that case much so there coul=
d well
> > be other deadlock possibilities lurking.
> >=20
> > Mel: might there be some other way we could get out of this deadlock?
> > Could the wait_on_page_writeback() in shrink_page_list() be made a time=
d-out
> > wait or something?  Any other wait out of this deadlock other than sett=
ing
> > PF_MEMALLOC_NOIO everywhere?
>=20
> Not only the wait_on_page_writeback() cause the deadlock but also the
> next pageout()-> (mapping->a_ops->writepage), Trond's second patch fix
> this. So fix the wait_on_page_writeback is not enough to fix deadlock.

Shortly before the only place that pageout() is called there is this code:

			if (page_is_file_cache(page) &&
					(!current_is_kswapd() ||
					 !zone_is_reclaim_dirty(zone))) {
                                .....
				goto keep_locked;


So pageout() only gets called by kswapd() .... or for swap. swap-over-NFS is
already very cautious about memory allocations, and uses nfs_direct_IO, not
nfs_writepage.

So nfs_writepage will never get called during direct reclaim.  There is no
memory-allocate deadlock risk there.

NeilBrown

--Sig_/ioh5G0sbw/l36kjHgl5dAel
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU/wneTnsnt1WYoG5AQJNRg/+NFJuPBdxCpPWpMM3YNZr9qTGFs+Pb1Ml
NFZ/lj4VzQh0wq8A8pNQWRy/U2k1lX8hrc/oumwuT/3Woghowx5SOj9G3osraElo
6ID9erLeoXFGxL8MLrUbBdu6OZOgxGlqLz/YOmzEvwZYYYDUj0Zy+mNo63LDDZmR
YnbOVeegAZ0/Ilw/gIFGiPt0du6wUeJGJozW5zxhLCs0kMUCwW1t/MKSbWbXl/WY
o4bLPXxr6gJrwvZK/CET/aIi2Q6Q4tdBzEWwbItH92rr3Z6Go2/4KfZjz2/gZCZz
pQma1GsapGDYkCWlmYTZGFqqcesVueN6xHntwfjFXaxvUhuoqx/huiwumYdz41M0
OSVVCXM/YHvqeFaHAIsMQuhY4qAZGhHEPqYiA9EeDRsTU7QlM4rBJznZ6h5rel5Y
uyYqExQvlz3yfpobDgKrJ7BbakxS1NLCmlbXIXFJ5Rz0h5ZlXU04A5+AUv/M+g4r
c8jA8daNVMklRRirFTYlXXUwt/WrPAXaUxLcEEMPkjPlsrTTqmPdHXbrmkRXJIPD
8jMAsunMo18FX6qcyJ+ixxjuxIjyI3puDsq3ToNkTzl+mVc/9xsaivBOJXDm8jAi
QC6NeXpmg2D8lmVEcVP+zcg/f0zIryIC54OTrtFJRUVdDTIWz8CL/FtLS7m7ROxi
f6K/ASizO/U=
=2Oak
-----END PGP SIGNATURE-----

--Sig_/ioh5G0sbw/l36kjHgl5dAel--
