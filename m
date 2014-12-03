Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f169.google.com ([209.85.216.169]:32929 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751141AbaLCBaK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Dec 2014 20:30:10 -0500
Received: by mail-qc0-f169.google.com with SMTP id w7so10331187qcr.0
        for <linux-nfs@vger.kernel.org>; Tue, 02 Dec 2014 17:30:09 -0800 (PST)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 2 Dec 2014 20:29:46 -0500
To: NeilBrown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Tejun Heo <tj@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [RFC PATCH 00/14] nfsd/sunrpc: add support for a
 workqueue-based nfsd
Message-ID: <20141202202946.1e0f399b@tlielax.poochiereds.net>
In-Reply-To: <20141203121118.21a32fe1@notabene.brown>
References: <1417544663-13299-1-git-send-email-jlayton@primarydata.com>
	<20141203121118.21a32fe1@notabene.brown>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/qcs07EqwRnzZJw3h_o_dnIh"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/qcs07EqwRnzZJw3h_o_dnIh
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 3 Dec 2014 12:11:18 +1100
NeilBrown <neilb@suse.de> wrote:

> On Tue,  2 Dec 2014 13:24:09 -0500 Jeff Layton <jlayton@primarydata.com>
> wrote:
>=20
> > tl;dr: this code works and is much simpler than the dedicated thread
> >        pool, but there are some latencies in the workqueue code that
> >        seem to keep it from being as fast as it could be.
> >=20
> > This patchset is a little skunkworks project that I've been poking at
> > for the last few weeks. Currently nfsd uses a dedicated thread pool to
> > handle RPCs, but that requires maintaining a rather large swath of
> > "fiddly" code to handle the threads and transports.
> >=20
> > This patchset represents an alternative approach, which makes nfsd use
> > workqueues to do its bidding rather than a dedicated thread pool. When a
> > transport needs to do work, we simply queue it to the workqueue in
> > softirq context and let it service the transport.
> >=20
> > The current draft is runtime-switchable via a new sunrpc pool_mode
> > module parameter setting. When that's set to "workqueue", nfsd will use
> > a workqueue-based service. One of the goals of this patchset was to
> > *not* need to change any userland code, so starting it up using rpc.nfsd
> > still works as expected. The only real difference is that the nfsdfs
> > "threads" file is reinterpreted as the "max_active" value for the
> > workqueue.
>=20
> Hi Jeff,
>  I haven't looked very closely at the code, but in principal I think this=
 is
>  an excellent idea.  Having to set a number of threads manually was never
>  nice as it is impossible to give sensible guidance on what an appropriate
>  number is.

Yes, this should be a lot more "dynamic" in principle. A lightly-used
nfs server using workqueues should really not consume much at all in
the way of resources.

>  Tying max_active to "threads" doesn't really make sense I think.
>  "max_active" is a per-cpu number and I think the only meaningful numbers=
 are
>  "1" (meaning concurrent works might mutually deadlock) or infinity (whic=
h is
>  approximated as 512).  I would just ignore the "threads" number when
>  workqueues are used.... or maybe enable workqueues when "auto" is writte=
n to
>  "threads"??
>=20

That's a good point. I had originally thought that max_active on an
unbound workqueue would be the number of concurrent jobs that could run
across all the CPUs, but now that I look I'm not sure that's really
the case.

Certainly, not bounding this at all has some appeal, but having some
limit here does help put an upper bound on the size of the svc_rqst
cache.

I'll definitely give that some thought.

>  Using a shrinker to manage the allocation and freeing of svc_rqst is a
>  really good idea.  It will put pressure on the effective number of threa=
ds
>  when needed, but will not artificially constrain things.
>=20

That's my hope. We might also consider reaping idle rqsts ourselves
as needed somehow, but for now I decided not to worry about it until we
see whether this is really viable or not.

>  The combination of workqueue and shrinker seems like a perfect match for
>  nfsd.
>=20
>  I hope you can work out the latency issues!
>=20
> Thanks,
> NeilBrown

I've heard random grumblings from various people in the past that
workqueues have significant latency, but this is the first time I've
really hit it in practice. If we can get this fixed, then that may be a
significant perf win for all workqueue users. For instance, rpciod in
the NFS client is all workqueue-based. Getting that latency down could
really help things.

I'm currently trying to roll up a kernel module for benchmarking the
workqueue dispatching code in the hopes that we can use that to help
nail it down.

Thanks for having a look!
--=20
Jeff Layton <jlayton@primarydata.com>

--Sig_/qcs07EqwRnzZJw3h_o_dnIh
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUfmeKAAoJEAAOaEEZVoIVjYoQAJnTRdXHEmaeppeYf8YB1rYi
P4w/hWCUmKCUkHtRg6wkn9R8tXLaXogbbNpUCz477zxB3J36nbPiS84gpHLWv99n
iE4AoA+eWkL4q6enMDaKSSF72rhLPyxDi5DNOXKGEEMkej7ZSCLPxG85CnHO6w2E
yVwijSKhCyTqYU9IpQhGzRHSUkJB6a1OpUCm7aZrRZ23aPl+o4nqnHHurYeN+hDL
yX0Q17PaEMfUZI0pTaSVt+SbZtJCP7bjsfE5zQyQofjp5MnApKZqAkpdlumyo31o
PUltFasRUleU1OffqrlC3e5tl8lKDtNvQSo5vmNN9JEFKryntSDPLnNzxPbIDMtu
GXTKQ0fcCN5qMeMmlBFFKw8ILTV9iYMAR5TLFJFF2bsdPKj9C7ULzLbK6aQ63PuR
jtfXg/ldJBt4VC+V4uq3yWNYU25/Wsea31OtcLgcwOwVWNaj37vkS7IqnELGBX2H
MOOnNjlfyw+zxjSYB7fpElA/5jPzY6a0IGcGLgXW0FT91T/RUntnQmU8kynVkspc
8P54aPGVBFgQeoGGBOo64SM7dTLz4lLWI4tzxFKVyzf4+Mw3X75Z8StPea57CyZe
JTli4/3Ihk4nPZImBlFd1hhRGHU3ofQ0zbnGqux/hZ1V9ju4AwpnIWmBFM7R1WAx
rL3arkC+P45N0gzShSxq
=f5Mw
-----END PGP SIGNATURE-----

--Sig_/qcs07EqwRnzZJw3h_o_dnIh--
