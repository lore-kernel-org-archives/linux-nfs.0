Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:47451 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751252AbaLCBL1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Dec 2014 20:11:27 -0500
Date: Wed, 3 Dec 2014 12:11:18 +1100
From: NeilBrown <neilb@suse.de>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Tejun Heo <tj@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [RFC PATCH 00/14] nfsd/sunrpc: add support for a
 workqueue-based nfsd
Message-ID: <20141203121118.21a32fe1@notabene.brown>
In-Reply-To: <1417544663-13299-1-git-send-email-jlayton@primarydata.com>
References: <1417544663-13299-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/68YI9_iRKG0BcnmjvbSfeDg"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/68YI9_iRKG0BcnmjvbSfeDg
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue,  2 Dec 2014 13:24:09 -0500 Jeff Layton <jlayton@primarydata.com>
wrote:

> tl;dr: this code works and is much simpler than the dedicated thread
>        pool, but there are some latencies in the workqueue code that
>        seem to keep it from being as fast as it could be.
>=20
> This patchset is a little skunkworks project that I've been poking at
> for the last few weeks. Currently nfsd uses a dedicated thread pool to
> handle RPCs, but that requires maintaining a rather large swath of
> "fiddly" code to handle the threads and transports.
>=20
> This patchset represents an alternative approach, which makes nfsd use
> workqueues to do its bidding rather than a dedicated thread pool. When a
> transport needs to do work, we simply queue it to the workqueue in
> softirq context and let it service the transport.
>=20
> The current draft is runtime-switchable via a new sunrpc pool_mode
> module parameter setting. When that's set to "workqueue", nfsd will use
> a workqueue-based service. One of the goals of this patchset was to
> *not* need to change any userland code, so starting it up using rpc.nfsd
> still works as expected. The only real difference is that the nfsdfs
> "threads" file is reinterpreted as the "max_active" value for the
> workqueue.

Hi Jeff,
 I haven't looked very closely at the code, but in principal I think this is
 an excellent idea.  Having to set a number of threads manually was never
 nice as it is impossible to give sensible guidance on what an appropriate
 number is.
 Tying max_active to "threads" doesn't really make sense I think.
 "max_active" is a per-cpu number and I think the only meaningful numbers a=
re
 "1" (meaning concurrent works might mutually deadlock) or infinity (which =
is
 approximated as 512).  I would just ignore the "threads" number when
 workqueues are used.... or maybe enable workqueues when "auto" is written =
to
 "threads"??

 Using a shrinker to manage the allocation and freeing of svc_rqst is a
 really good idea.  It will put pressure on the effective number of threads
 when needed, but will not artificially constrain things.

 The combination of workqueue and shrinker seems like a perfect match for
 nfsd.

 I hope you can work out the latency issues!

Thanks,
NeilBrown

--Sig_/68YI9_iRKG0BcnmjvbSfeDg
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVH5jNjnsnt1WYoG5AQLFVRAAh5V0coqjUJzz1DfEMuz/coI8H4Srf6Ia
hH51IWQ/5AYNlTcFqxVCs3LnUr09FzQ70nuw18a0Wt7K4VOmF+ZMwmB5Gx+i0++K
3nhvDIKFbIOQoqoKw7VVfO/RV2a9NugZpzjD6VYcV8W2h4bk8rciaUTmdghnAEl/
R+SDLV6tLJVnReEynIA2rztqWkNpoay2uIaLTFLS2MuOkh3pFEITaQ4a8+hIWt3X
mjQbb+Q4SGa56tFP0e2Of0D5vzWb/DUFMHnfsbjmtUgfsK5gafs6qVDRbThwmWaX
ciTOpxHzm9XqoWov8p8fPfn5/AY5QWeNxOUTP1HfWzR3vNbESfPLtIZuCeKioOlv
RZ2SSY+zQiCdj2hc1Xydts0aGIGg5C/g2QAnTPO6GO1ho/0PFxKFKlLq7xpV9oGj
1jxmxvJIHg9NsVPw83oqQiIKjBUECZbGmBTSZQTJB7GhjSLJGyA2/wOtv9CZ2wjn
7NLdCinsAlWZ6p06yR1MTYthMAe5a/Rzxf5jtwGur6bMgPt5Dint+td2Efxi6nDE
xGklrDTx1MluDZzdjP08VajUSrc0+88w6Cj1D00eNxTsg3M5XEPyym9Es7uHIBg3
5Y+lo0ytK1vt2uwfnG1wW69AShG8bQOsmYIfWkMkVirlYNIDTinlq4YKKg8GXwuY
URb138Y9Cjg=
=7feE
-----END PGP SIGNATURE-----

--Sig_/68YI9_iRKG0BcnmjvbSfeDg--
