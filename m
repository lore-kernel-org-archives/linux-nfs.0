Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:33774 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752496AbaHYGFM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Aug 2014 02:05:12 -0400
Date: Mon, 25 Aug 2014 16:05:01 +1000
From: NeilBrown <neilb@suse.de>
To: Junxiao Bi <junxiao.bi@oracle.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: rpciod deadlock issue
Message-ID: <20140825160501.433b3e9e@notabene.brown>
In-Reply-To: <53F6F772.6020708@oracle.com>
References: <53F6F772.6020708@oracle.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/89.fRU7nTq_jxw8HjpPTaRv"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/89.fRU7nTq_jxw8HjpPTaRv
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 22 Aug 2014 15:55:30 +0800 Junxiao Bi <junxiao.bi@oracle.com> wrote:

> Hi All,
>=20
> I got an nfs hung issue, looks like "rpciod" run into deadlock. Bug is
> reported on 2.6.32, but seems mainline also suffers this bug from the
> source code.
>=20
> See the following rpciod trace. rpciod allocated memory using GFP_KERNEL
> in xs_setup_xprt(). That triggered direct reclaim when available memory
> was not enough, where it waited an write-back page done, but that page
> was a nfs page, and it depended on rpciod to write back. So this caused
> a deadlock.
>=20
> I am not sure how to fix this issue. Replace GFP_KERNEL with GFP_NOFS in
> xs_setup_xprt() can fix this trace, but there are other place allocating
> memory with GFP_KERNEL in rpciod, like
> xs_tcp_setup_socket()->xs_create_sock()->__sock_create()->sock_alloc(),
> there is no way to pass GFP_NOFS to network command code. Also mainline
> has changed to not care ___GFP_FS before waiting page write back done.
> Upstream commit 5cf02d0 (nfs: skip commit in releasepage if we're
> freeing memory for fs-related reasons) uses PF_FSTRANS to avoid another
> deadlock when direct reclaim, i am thinking whether we can check
> PF_FSTRANS flag in shrink_page_list(), if this flag is set, it will not
> wait any page write back done? I saw this flag is also used by xfs, not
> sure whether this will affect xfs.
>=20
> Any advices is appreciated.

This problem shouldn't affect mainline.

Since Linux 3.2, "direct reclaim" never wait for writeback - that is left f=
or
kswapd to do. (See "A pivotal patch" in https://lwn.net/Articles/595652/)
So this deadlock cannot happen.

Probably the simplest fix for your deadlock would be:
- in shrink_page_list, clear may_enter_fs if PF_FSTRANS is set.
- in rpc_async_schedule, set PF_FSTRANS before calling __rpc_execute, and
  clear it again afterwards.

NeilBrown

>=20
> @ crash> bt 1539
> @ PID: 1539   TASK: ffff88178f64a040  CPU: 1   COMMAND: "rpciod/1"
> @  #0 [ffff88178f64d2c0] schedule at ffffffff8145833a
> @  #1 [ffff88178f64d348] io_schedule at ffffffff8145842c
> @  #2 [ffff88178f64d368] sync_page at ffffffff810d8161
> @  #3 [ffff88178f64d378] __wait_on_bit at ffffffff8145895b
> @  #4 [ffff88178f64d3b8] wait_on_page_bit at ffffffff810d82fe
> @  #5 [ffff88178f64d418] wait_on_page_writeback at ffffffff810e2a1a
> @  #6 [ffff88178f64d438] shrink_page_list at ffffffff810e34e1
> @  #7 [ffff88178f64d588] shrink_list at ffffffff810e3dbe
> @  #8 [ffff88178f64d6f8] shrink_zone at ffffffff810e425e
> @  #9 [ffff88178f64d7b8] do_try_to_free_pages at ffffffff810e4978
> @ #10 [ffff88178f64d828] try_to_free_pages at ffffffff810e4c31
> @ #11 [ffff88178f64d8c8] __alloc_pages_nodemask at ffffffff810de370
> @ #12 [ffff88178f64d978] kmem_getpages at ffffffff8110e18b
> @ #13 [ffff88178f64d9a8] fallback_alloc at ffffffff8110e35e
> @ #14 [ffff88178f64da08] ____cache_alloc_node at ffffffff8110e51f
> @ #15 [ffff88178f64da48] __kmalloc at ffffffff8110efba
> @ #16 [ffff88178f64da98] xs_setup_xprt at ffffffffa00a563f [sunrpc]
> @ #17 [ffff88178f64dad8] xs_setup_tcp at ffffffffa00a7648 [sunrpc]
> @ #18 [ffff88178f64daf8] xprt_create_transport at ffffffffa00a478f [sunrp=
c]
> @ #19 [ffff88178f64db18] rpc_create at ffffffffa00a2d7a [sunrpc]
> @ #20 [ffff88178f64dbf8] rpcb_create at ffffffffa00b026b [sunrpc]
> @ #21 [ffff88178f64dc98] rpcb_getport_async at ffffffffa00b0c94 [sunrpc]
> @ #22 [ffff88178f64ddf8] call_bind at ffffffffa00a11f8 [sunrpc]
> @ #23 [ffff88178f64de18] __rpc_execute at ffffffffa00a88ef [sunrpc]
> @ #24 [ffff88178f64de58] rpc_async_schedule at ffffffffa00a9187 [sunrpc]
> @ #25 [ffff88178f64de78] worker_thread at ffffffff81072ed2
> @ #26 [ffff88178f64dee8] kthread at ffffffff81076df3
> @ #27 [ffff88178f64df48] kernel_thread at ffffffff81012e2a
> @ crash>
>=20
> Thanks,
> Junxiao.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--Sig_/89.fRU7nTq_jxw8HjpPTaRv
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU/rSDTnsnt1WYoG5AQJvexAAof1x6HdHEkbHRLLiy5fDt3UpLrlmLQSy
7OEVR/qAZRz/2fdD5lkOw/4dAxUU/Xb5q22EnqZCG982BGOj3e0+MzUAW1Ywmj4S
klM5oEQgrEc11LknsI2YFSkC0pM/HBMUnT4HhDUmxl//doj3llSOlbHkYouMj4EK
CN+PFMTbSy7/7EuK1VdyYlmUurXw9FStJ5mg3vhKhjGmXQadVEV5m8dddDWM418H
yGNkbvpI9txSwhmFWZt7Jl2mBsm7ZaL3Q0KIlWhfp2G7/v3vPiziVnNblMiDk3Bn
fY/p3wY/HzK1ykNKYLqgF9U0VVvwpSfHPhRHYhaSQ8ugzTOMZHrCMIoIDxGv3Heq
CrG0lZmZZsKGuEtfUeluBFERGPUxRWoGVX/uhsEF7jFqPlE51qGuyo78lxprbYJm
QCACOIxEeZRHjrpkn8x7z7fL3VxwYJmXEJ0HZoDsFAXaP8aRs8zerUAeID+8+qzl
o6TUfgsPhmB6LPMIVwEOfzqxOMF3rIj3DxjO8KowSbmuBWruHiQZVYN/+TAGfIOV
UhBZW80KGq7wuYeJQoscTBRLmdPrMjqA2SpcETxXzysPzWI4HsFdhugVDr5OKQuc
S9oJmAbBQEdyYfm8C70c/nM3Zb6K8GeE1sYEaa7xz/VTZLL+URtdIMzt+sST0XU5
Do4fiRNQLB0=
=Pjuh
-----END PGP SIGNATURE-----

--Sig_/89.fRU7nTq_jxw8HjpPTaRv--
