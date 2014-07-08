Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:44294 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751852AbaGHFVG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jul 2014 01:21:06 -0400
Date: Tue, 8 Jul 2014 15:21:00 +1000
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Chuck Lever <chuck.lever@oracle.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Is there a good reason that nfs4_state_manager should use a
 work_queue?
Message-ID: <20140708152100.67cd93c7@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/tvEz=9YlWOvQP0/p=Q4cSjb"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/tvEz=9YlWOvQP0/p=Q4cSjb
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


Hi,
 I came a across a machine recently which has multiple threads blocked in
 nfs_writedata_alloc().  They were waiting for mempool_alloc to provide an
 allocation but it never did.
 Memory was tight and all the pre-allocations were in use by pending reques=
ts.
 These requests were queued on "NFS client" which means they were waiting f=
or
 the state manager to do something.
 But there was no state manager.  Presumably kthread_run failed when it tri=
ed
 to allocate some memory.
 I cannot see anything that would retry the attempt to start the thread, and
 even if there was, we probably need to complete some NFS writes before more
 memory comes available.

 In this particular case the main problem was quite separate.  Too many lar=
ge
 processes and not enough swap space, and the OOM killer missed its target.
 So even if NFS had worked perfectly the machine would still have locked up.
 But it does suggest that there is a weakness here.

 As kthread_create used GFP_KERNEL to allocate a thread, and as writes can
 block waiting for the thread to be created, there appears to be room for a
 deadlock.

 My thought is that this could be fixed by using a WQ_MEM_RECLAIM work queu=
e.
 The WQ_MEM_RECLAIM flag ensures there is always at least one thread running
 so no allocation is needed.  Before diving in and trying to implement this=
 I
 thought it would be safest to ask as there are two issues that I'm not
 certain of.

 1/ nfs4_run_state_manager() explicitly allows SIGKILL.  Why is this?
    Is there some situation where it might be appropriate to kill the manag=
er
    thread?

 2/ would it be reasonable to have a single work queue for all nfs clients?
    In the worst case this could serialise reclaim across all clients so we
    wouldn't want any reclaim attempt to block indefinitely.  Is that likely
    to be a big problem do you think?

Thanks for any hints or suggestions,

NeilBrown

--Sig_/tvEz=9YlWOvQP0/p=Q4cSjb
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU7t/vDnsnt1WYoG5AQJpgRAAu1YkhynsjxztYuMNJmPdS81uo5AKyLsP
HFY/ldoSvAhqIu17lUYEdybWehAVjeDvAQw1IlaRrwVqM23GdLi1oHmDp4UYTfZ+
KFQWPmo7aLFA+lBbIUQfT7tBwQNoyL40Vx8nJ6p1sXihq8GAlWgU4mGWohVOdz0Z
GeAtM6Km+DTQzE4A0nqHbMxeBuHzHaRyzKQh0171BwV074oaaXaES8zq3ncQ932A
AOI/O34J+emuVZyuZRBvujZnAeTSwT9l3l3hz7v1wnxqZyXgxviUfz1MCzcZiDBW
Rali8Sn/Wo3ZreCPS27QDrcNdroLIx0LjZc4dpiVKyLLcePbfEWfvevlfH3soX+R
BWN3mFVyviwSQtmZ1+Q2bvQrgsrp0Rfs73Zcx7L3pO8uVTejOYioQuNYQAEL955r
+9/2eyiJ3bW4Lt7o60PZmWeeaHDPhQ2pt4AJoIT/K/FHIcIbdmkP1UuoMyUpgI9c
fWvJojqD5k+Ck3JDrg8fpYBYkA/K5JI9vh2cfkWC+YmPRX01j2Ie9qUn4qsf2xvN
QPHb/6vclgttKFEms6gAHiOX94qsX/ZCuWUg6CwFALseoA+cOYs/bHvwiUAfmQQM
OM036Z6JXRswfkFM4HrzyIZl4W6Lo58S8DXp35o/qy+GcXYM26SGx9QY0I5vY6cQ
FZXr4TgnnPs=
=ohDq
-----END PGP SIGNATURE-----

--Sig_/tvEz=9YlWOvQP0/p=Q4cSjb--
