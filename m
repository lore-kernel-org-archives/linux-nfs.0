Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:35643 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932188AbaHZHEU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Aug 2014 03:04:20 -0400
Date: Tue, 26 Aug 2014 17:04:10 +1000
From: NeilBrown <neilb@suse.de>
To: Junxiao Bi <junxiao.bi@oracle.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Mel Gorman <mgorman@suse.com>
Subject: Re: [PATCH v2 1/2] SUNRPC: Fix memory reclaim deadlocks in rpciod
Message-ID: <20140826170410.20560764@notabene.brown>
In-Reply-To: <53FC2DDD.9050705@oracle.com>
References: <53F6F772.6020708@oracle.com>
	<1408747772-37938-1-git-send-email-trond.myklebust@primarydata.com>
	<20140825164852.50723141@notabene.brown>
	<53FC1E93.2060800@oracle.com>
	<20140826162138.5df2f8a3@notabene.brown>
	<53FC2DDD.9050705@oracle.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/OIo=5sOznNgoZriOWXCgYKZ"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/OIo=5sOznNgoZriOWXCgYKZ
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 26 Aug 2014 14:49:01 +0800 Junxiao Bi <junxiao.bi@oracle.com> wrote:

> On 08/26/2014 02:21 PM, NeilBrown wrote:
> > On Tue, 26 Aug 2014 13:43:47 +0800 Junxiao Bi <junxiao.bi@oracle.com> w=
rote:
> >=20
> >> On 08/25/2014 02:48 PM, NeilBrown wrote:
> >>> On Fri, 22 Aug 2014 18:49:31 -0400 Trond Myklebust
> >>> <trond.myklebust@primarydata.com> wrote:
> >>>
> >>>> Junxiao Bi reports seeing the following deadlock:
> >>>>
> >>>> @ crash> bt 1539
> >>>> @ PID: 1539   TASK: ffff88178f64a040  CPU: 1   COMMAND: "rpciod/1"
> >>>> @  #0 [ffff88178f64d2c0] schedule at ffffffff8145833a
> >>>> @  #1 [ffff88178f64d348] io_schedule at ffffffff8145842c
> >>>> @  #2 [ffff88178f64d368] sync_page at ffffffff810d8161
> >>>> @  #3 [ffff88178f64d378] __wait_on_bit at ffffffff8145895b
> >>>> @  #4 [ffff88178f64d3b8] wait_on_page_bit at ffffffff810d82fe
> >>>> @  #5 [ffff88178f64d418] wait_on_page_writeback at ffffffff810e2a1a
> >>>> @  #6 [ffff88178f64d438] shrink_page_list at ffffffff810e34e1
> >>>> @  #7 [ffff88178f64d588] shrink_list at ffffffff810e3dbe
> >>>> @  #8 [ffff88178f64d6f8] shrink_zone at ffffffff810e425e
> >>>> @  #9 [ffff88178f64d7b8] do_try_to_free_pages at ffffffff810e4978
> >>>> @ #10 [ffff88178f64d828] try_to_free_pages at ffffffff810e4c31
> >>>> @ #11 [ffff88178f64d8c8] __alloc_pages_nodemask at ffffffff810de370
> >>>
> >>> This stack trace (from 2.6.32) cannot happen in mainline, though it t=
ook me a
> >>> while to remember/discover exactly why.
> >>>
> >>> try_to_free_pages() creates a 'struct scan_control' with ->target_mem=
_cgroup
> >>> set to NULL.
> >>> shrink_page_list() checks ->target_mem_cgroup using global_reclaim() =
and if
> >>> it is NULL, wait_on_page_writeback is *not* called.
> >>>
> >>> So we can only hit this deadlock if mem-cgroup limits are imposed on a
> >>> process which is using NFS - which is quite possible but probably not=
 common.
> >>>
> >>> The fact that a dead-lock can happen only when memcg limits are impos=
ed seems
> >>> very fragile.  People aren't going to test that case much so there co=
uld well
> >>> be other deadlock possibilities lurking.
> >>>
> >>> Mel: might there be some other way we could get out of this deadlock?
> >>> Could the wait_on_page_writeback() in shrink_page_list() be made a ti=
med-out
> >>> wait or something?  Any other wait out of this deadlock other than se=
tting
> >>> PF_MEMALLOC_NOIO everywhere?
> >>
> >> Not only the wait_on_page_writeback() cause the deadlock but also the
> >> next pageout()-> (mapping->a_ops->writepage), Trond's second patch fix
> >> this. So fix the wait_on_page_writeback is not enough to fix deadlock.
> >=20
> > Shortly before the only place that pageout() is called there is this co=
de:
> >=20
> > 			if (page_is_file_cache(page) &&
> > 					(!current_is_kswapd() ||
> > 					 !zone_is_reclaim_dirty(zone))) {
> >                                 .....
> > 				goto keep_locked;
> >=20
> >=20
> > So pageout() only gets called by kswapd() .... or for swap. swap-over-N=
FS is
> > already very cautious about memory allocations, and uses nfs_direct_IO,=
 not
> > nfs_writepage.
> >=20
> > So nfs_writepage will never get called during direct reclaim.  There is=
 no
> > memory-allocate deadlock risk there.
> Yes, thanks for explaining this.
> But is it possible rpciod blocked somewhere by memory allocation using
> GFP_KERNEL and kswapd is trying to pageout nfs dirty pages and blocked
> by rpciod?

I don't think so, no.

Only 40% of memory (/proc/sys/vm/dirty_ratio) can be dirty.  The direct
reclaim procedure will eventually find some non-dirty memory it can use.
If it cannot, and cannot write anything out to swap either, it will
eventually trigger the OOM killer.

Direct reclaim shouldn't ever block indefinitely.  It will sometimes wait f=
or
a short while (e.g. congestion_wait()) but it should then push on until it
finds something it can do: free a clean page, write something to swap, or
kill a memory-hog with the OOM killer.

NeilBrown

--Sig_/OIo=5sOznNgoZriOWXCgYKZ
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU/wxajnsnt1WYoG5AQJvrw//f1NLwpu1czOkurAXYc/mo2GD9VvHlGZY
JRWwBC7UcVT76vbx/ij0+UMG7Wsl8wrZobPz2bQrUttqo4htwiwMojNqHgITabOl
gS0mhQWoUfz8vqkZ3+KTSu/4fho+zIndrDY2l6miJ8V/LWH/ywTgG53+EkqdQMEL
C0XxUkLM133u1nNRfRuIEEFeSJGUXd5ysGUjHAN8i6l6SJw+rpMBJLBRqbbpL/l2
KEgoK2kuyl3bs5jk6oBBzTtkGO6/S/2Xq4drslvtxp4yuGlkasu7sO/gWv1hXKIh
PW337jwNAbKD5C41czArPbIMKYpgIqcvINyoCvA76Jk7kGlfSau3newyjWnDeWEU
+/YnMC1kWhdh4drdNCF0th4J12NF1pxnv5wINOcaH9+UhmO53+DED0rDBEUldeb4
fHHjry87wm5qwGUpe7cri1i39Ef3fSjYGRA0+xsQejDiEUbcHMq7wd7JwEKYc6IL
4Pw6Pg/C+EhRgRyir2bJCd0qIhs9xMA4JFbFbxyNfEM/TRYRnk3okzMzh+gT/AuM
XuzXtozvoqCxgITkrKnR5XNLZX8B16LWSvtD9fK5PVvEW27ct8xVvFjWsAjtwEOD
52diJhUBtH3m0Zoa3FqMpAiY36+jwFP4i/yg0+5H3lPJflM9cGoKS5ce+iSl+pze
H7GyA0DAsTA=
=Ozk3
-----END PGP SIGNATURE-----

--Sig_/OIo=5sOznNgoZriOWXCgYKZ--
