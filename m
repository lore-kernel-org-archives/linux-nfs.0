Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:50075 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754333AbaIQDFX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Sep 2014 23:05:23 -0400
Date: Wed, 17 Sep 2014 13:05:12 +1000
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: NFS <linux-nfs@vger.kernel.org>, Tejun Heo <tj@kernel.org>,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] NFS: state manager thread must stay running.
Message-ID: <20140917130512.744593fd@notabene.brown>
In-Reply-To: <CAHQdGtTrWhX=iE9y1nWH13M=kt1dbu=_dwdNVSQGBh1BeZ9aTA@mail.gmail.com>
References: <20140813140831.22f3e9c7@notabene.brown>
	<CAHQdGtTrWhX=iE9y1nWH13M=kt1dbu=_dwdNVSQGBh1BeZ9aTA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/mHuF1ocO1j6EYrWdo3VtPCs"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/mHuF1ocO1j6EYrWdo3VtPCs
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 16 Sep 2014 21:43:07 -0400 Trond Myklebust
<trond.myklebust@primarydata.com> wrote:

> On Wed, Aug 13, 2014 at 12:08 AM, NeilBrown <neilb@suse.de> wrote:
> >
> >
> > If the server restarts at an awkward time it is possible for write
> > requests to block waiting for the state manager to run.
> > If the state manager isn't already running a new thread will
> > need to be started which requires a GFP_KERNEL allocation
> > (for do_fork).
> >
> > If memory is short, that GFP_KERNEL allocation could block on the
> > writes going out via NFS, resulting in a deadlock.
> >
> > The easiest solution is to keep the manager thread running
> > always.
>=20
> I'm still trying to figure out what to do about this patch. There are
> 2 concerns:
>=20
> 1) If we're so low on memory that we can't even start a state manager
> thread, then how do we guarantee that the recovery can be completed?
> We rely on that state manager thread being able to allocate memory to
> perform the lease, session, open and lock recoveries.

All the allocations performed by the state manager are (I assume) GFP_NOFS.
Creating a new thread requires GFP_KERNEL allocations, particularly in
dup_task_struct, which is called by kthreadd, which is well out of reach for
NFS to try to change the GFP flags.

Having said that, it occurs to me that my other dead-lock avoidance patch
might fix this problem as well.

The one case where I have seen a problem with starting the state manager, t=
he
machine in question had several memory-shortage issues.  I think we finally
decided that a problem with too_many_isolated handling was the main cause.
So I cannot get very much reliable information from the stack trace there. =
 I
presume that in the current kernel, thread creation could deadlock against
nfs_release_page() (it was actually stuck in a congestion_wait()).

So I can't be certain, but I think this proactive thread creation won't be
needed once nfs_release_page() doesn't block indefinitely.

So you can drop this patch.

Thanks.

Though on the topic of patches that you don't know what to do with ....
Could you have a look at
   http://permalink.gmane.org/gmane.linux.nfs/56154
it appears that it slipped under your radar, and it fell of mine until just
recently.

NeilBrown


--Sig_/mHuF1ocO1j6EYrWdo3VtPCs
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBVBj6aDnsnt1WYoG5AQJBHBAAjdiEytmmqoqeGvwfZp2EdMeDrrjD7y1y
lWEDly+9092ck+SQlKCNWw0D9P+nK6K/vJchSblyBfBhFlyGAaXAdAmxAvr5LEkl
3RBlzOzRppEdjpYbtW/vJxCAw61DMySnIV6P7AN/Z9YePzpF8yzb7cVE6zYOmhuZ
nldjwdpkQraXGAhG02x4ELXyJRKWpgA8S5RyhwSgeMJ5iUkRrepSpMU7DBB3VftX
6S3PEQ4thCiJ2jG1Hu5pIoKneivmn3ZM81Wrg4CWy++2PdIBFrEc7RxWFN63bcgJ
D/3PYcgYy+4L3458EtAlJZHp7o6GBJ3DoZFv5Epu0/7ytrNNs9plttW5pgeg3g4V
v1t3AvDUlbl88Xn7GmhQmyj9M/5jeOuKNlOQN8GkVPt5U7prS6vK1InbeDJH1Kol
FObZ8abFnGb17wcDMLn1pVx+XfCUqVPxNiXO0z3SutKAPmKkclS3um7fNNanFtMI
lzGHJTxC9FGneDkdawmDILEQdytHL4om925ROLuEt7tKoBQeDsU1Uj6tNV+S1YYu
W9dGjIrIGizRgJo+PTuzMP9Cg36TNrlOOFEmhe3lIEaA/zSfpn3gBjNCBWiq1+If
vSp/lP1JohdYlebaR1kNq7RW8IOCob7bwqgxoZDu/Q0evlHclDL2kFcbmvqE5cXg
k2CMqJvxMzE=
=FxiC
-----END PGP SIGNATURE-----

--Sig_/mHuF1ocO1j6EYrWdo3VtPCs--
