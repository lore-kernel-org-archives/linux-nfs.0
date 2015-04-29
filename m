Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:34030 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751437AbbD2Vwf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Apr 2015 17:52:35 -0400
Date: Thu, 30 Apr 2015 07:52:25 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC] NFSD: fix cannot umounting mount points under
 pseudo root
Message-ID: <20150430075225.21a71056@notabene.brown>
In-Reply-To: <20150429191934.GA23980@fieldses.org>
References: <553663B7.7030506@gmail.com>
	<20150421215417.GE13782@fieldses.org>
	<553781E2.1000900@gmail.com>
	<20150422150703.GA1247@fieldses.org>
	<20150423094431.1a8aa68b@notabene.brown>
	<5538EB18.7080802@gmail.com>
	<20150424130045.6bbdb2f9@notabene.brown>
	<553E2784.6020906@gmail.com>
	<20150429125728.69ddfc6c@notabene.brown>
	<20150429191934.GA23980@fieldses.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/RTUxFYpsKCXVMqa9SAuS+=X"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/RTUxFYpsKCXVMqa9SAuS+=X
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 29 Apr 2015 15:19:34 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Wed, Apr 29, 2015 at 12:57:28PM +1000, NeilBrown wrote:
> > In any case, holding a mutex while waiting for an upcall is probably a =
bad
> > idea.  We should try to find a way to work around that...
>=20
> Yeah, it sounds fragile even if we could fix this particular issue in
> mountd.
>=20
> > Any ideas Bruce ?-)
>=20
> Looking at nfsd_buffered_readdir():
>=20
> 	/*
> 	 * Various filldir functions may end up calling back into
> 	 * lookup_one_len() and the file system's ->lookup() method.
> 	 * These expect i_mutex to be held, as it would within readdir.
> 	 */
>         host_err =3D mutex_lock_killable(&dir_inode->i_mutex);
>=20
> and as far as I can tell Kinglong's approach (adding an unlock and lock
> around nfsd_cross_mnt() calls might actually be OK.

Yes, I think now that it would work.  It would look odd though, as you
suggest.
There would need to be very clear comments explaining why the lock is being
managed that way.

>=20
> Though in general I expect
>=20
> 	lock()
> 	...code...
> 	unlock()
>=20
> to mark a critical section and would be unpleasantly surprised to
> discover that a function somewhere in the middle had a buried
> unlock/lock pair.
>=20
> Maybe drop the locking from nfsd_buffered_readdir and *just* take the
> i_mutex around lookup_one_len(), if that's the only place we need it?

I think it is the only place needed.  Certainly normal path lookup only tak=
es
i_mutex very briefly around __lookup_hash().

One cost would be that we would take the mutex for every name instead of on=
ce
for a whole set of names.  That is generally frowned upon for performance
reasons.

An alternative might be to stop using lookup_one_len, and use kern_path()
instead.  Or kern_path_mountpoint if we don't want to cross a mountpoint.

They would only take the i_mutex if absolutely necessary.

The draw back is that they don't take a 'len' argument, so we would need to
make sure the name  is nul terminated (and maybe double-check that there is
no '/'??).  It would be fairly easy to nul-terminate names from readdir -
just use a bit more space  in the buffer in nfsd_buffered_filldir().

I'm less sure about the locking needed in nfsd_lookup_dentry().
The comments suggests that there is good reason to keep the lock for an
extended period.  But that reasoning might only apply to files, and
nfsd_mountpoint should  only be true for directories... I hope.

A different approach would be to pass NULL for the rqstp to nfsd_cross_mnt(=
).
This will ensure it doesn't block, but it might fail incorrectly.
If it does fail, we drop the lock, retry with the real rqstp, retake the lo=
ck
and .... no, I think that gets a bit too messy.

I think I'm in favour of:
 - not taking the lock in readdir
 - maybe not taking it in lookup
 - using kern_path_mountpoint or kern_path
 - nul terminating then names, copying the nfsd_lookup name to
   __getname() if necessary.

Sound reasonable?

NeilBrown


--Sig_/RTUxFYpsKCXVMqa9SAuS+=X
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVUFSmjnsnt1WYoG5AQKSbRAAiJ1zHTQnSMJvY7HFNAieXPgoPHO9jTZn
+El0j2X9ihr5H+WWUzTs5CRjNMlZ4kxraFyw1WYh41OhkqKxj17CuKfXuIc0eR3x
HXe8a9blZJiVBvACU8DQYXBosz4pnpz7/Aaeq8WI0GPWpQUz3fGVlzbB/ErRTnfb
roC21OPlTcRpirzBPFC845YILSgp48dqQ+p5fpogCDbBrZApaj1gYqONpKMQfZBv
VyAGHaju9o+Wl+zskd2GrY3vs60VEDkKEdMfX2jUydK87l5gHNR5D1jFdVrKqey8
grlhlZJRte8q0bWdaC3dWsICAPVXTMXjhuScY0tK9k2rJrMKcVl8zfAhSOlfKAlr
ZK8vs3jSN5Kg4SpB7ZZqn9LOfFm9NSpbLfVlsCsMz4A+h7MI/3uwZhHxuw23i912
cQGJv3DQinjLPyIeKPckSxo/h7ghMbpH3Tee5WSSw4NFSHFKl/4gyWq41vfbIGNo
5rY2Khj15E++O0US/JTL8c/EbOxjIIyY1kBpmvBs3JFiGpUJQusJhRey8IK1/USD
HRK1uz02mmgz/Ctym5peBfbca5KN2RscFIeW/gMPfzO2yoDdv8cPCGZtk43gXYCt
96fGoU/FswddHUMNuJYYWM0D5O3xFLS6A+kvykXWw0wiXFPBRY37n5Kr01p1kAOl
1e3nt/HXa4g=
=bkLM
-----END PGP SIGNATURE-----

--Sig_/RTUxFYpsKCXVMqa9SAuS+=X--
