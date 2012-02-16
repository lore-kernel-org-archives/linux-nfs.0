Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:48697 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753112Ab2BPDGO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Feb 2012 22:06:14 -0500
Date: Thu, 16 Feb 2012 14:06:03 +1100
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Nick Piggin <npiggin@gmail.com>,
        Nick Piggin <npiggin@kernel.dk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] fs/dcache: allow __d_obtain_alias() to return unhashed
 dentries
Message-ID: <20120216140603.08cb4900@notabene.brown>
In-Reply-To: <20120215165633.GE12490@fieldses.org>
References: <20101218161609.GA22150@fieldses.org>
	<AANLkTingRv_gtRSctGzMfYrKg02M_sKj97HSQPRm_mA_@mail.gmail.com>
	<20101227234641.GA22248@fieldses.org>
	<20110118204509.GA10903@fieldses.org>
	<AANLkTikL2CDSWQJ1QH_Y4G-j70Vd=VesNMMnYTmMGHC9@mail.gmail.com>
	<20110118220817.GF10903@fieldses.org>
	<20110308181320.GA15566@fieldses.org>
	<20110310105821.GE22723@ZenIV.linux.org.uk>
	<20110311150749.2fa2be66@notabene.brown>
	<20120214170300.GA4309@fieldses.org>
	<20120215165633.GE12490@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/j2Quy02R4QWcnfMqekAnlCh"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/j2Quy02R4QWcnfMqekAnlCh
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 15 Feb 2012 11:56:33 -0500 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Tue, Feb 14, 2012 at 12:03:00PM -0500, J. Bruce Fields wrote:
> > On Fri, Mar 11, 2011 at 03:07:49PM +1100, NeilBrown wrote:
> > > On Thu, 10 Mar 2011 10:58:21 +0000 Al Viro <viro@ZenIV.linux.org.uk> =
wrote:
> > >=20
> > > > On Tue, Mar 08, 2011 at 01:13:20PM -0500, J. Bruce Fields wrote:
> > > >=20
> > > > > Al, do you have this in your queue to look at?  Need me to resend=
?  Or
> > > > > should it take some other route?
> > > >=20
> > > > It's in queue, but I'd be a lot happier if I understood what's goin=
g on
> > > > with __d_find_alias() elsewhere.  Namely, in d_splice_alias().  The=
 thing
> > > > is, unless I'm missing something we ought to use __d_find_any_alias=
()
> > > > there as well.  Directories really, _really_ should not have more t=
han
> > > > one alias.  And what we get is really weird:
> > > > 	* find (the only) alias
> > > > 	* if it doesn't exist, create one (OK, no problem)
> > > > 	* if it does exist and happens to be IS_ROOT and DCACHE_DISCONNECT=
ED,
> > > > move it (also fine, modulo rather useless BUG_ON() in there)
> > > > 	* if it does exist and either isn't IS_ROOT or not DCACHE_DISCONNE=
CTED,
> > > > add a new alias and say nothing.
> > > >=20
> > > > The last part looks very strange.  I'd been staring at the history =
of this
> > > > function and I _think_ it's a rudiment of period when we used that =
stuff for
> > > > non-directories as well.  It used to be directory-only; then Neil h=
ad
> > > > switched it to non-directories as well (in "Fix disconnected dentri=
es on NFS
> > > > exports" back in 2004), adding want_discon argument to __d_find_ali=
as() in
> > > > process and using it instead of open-coded equivalent of __d_find_a=
ny_alias().
> > > > Then, two years later, in "knfsd: close a race-opportunity in d_spl=
ice_alias"
> > > > he'd made that code directory-only again, at which point we arrived=
 to the
> > > > current situation.
> > > >=20
> > > > Neil, is there some reason I'm missing that makes __d_find_alias() =
right in
> > > > there?  And do we still need the second argument in __d_find_alias(=
)?
> > > >=20
> > > > Anyway, Bruce's patch goes in tonight's push, but I'd love to see t=
hat
> > > > mess cleaned up as well or at least explained.
> >=20
> > Nothing like seeing somebody actually run across a bug here to motivate
> > getting back to this....
> >=20
> > So, like Al I'm wondering whether the __d_find_alias in d_splice_alias
> > should be a __d_find_any_alias.
> >=20
> > Disclaimer: the bug manifested in rhel5, and I haven't looked closely at
> > upstream yet, though it seems like it would have the same problem.
> >=20
> > In the particular case I'm seeing, the directory already has an alias
> > that is UNHASHED (but not DISCONNECTED).  So d_splice_alias adds a
> > second alias.
>=20
> The reproducer I was using against rhel5 isn't going to work against
> upstream, because it depended on the dentry_unhash() call in vfs_rmdir()
> to create that UNHASHED dentry.
>=20
> Though I think there's still code that can leave UNHASHED dentries
> around still on the alias list.  I'll look some more....

I was going ask how you managed to get an 'unhashed' dentry which was not
DISCONNECTED, and belonged to a directory that could be the subject of
d_splice_alias (that implies it has a name).

The bug sounds like a race between lookup and rmdir, which should be
prevented by i_mutex.

I think that using __d_find_any_alias would just be papering over the
problem, and would trigger a BUG_ON when it returned a non-DISCONNECTED ali=
as.

NeilBrown


--Sig_/j2Quy02R4QWcnfMqekAnlCh
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBTzxymznsnt1WYoG5AQIbqA//apoBi5VaSfRAxQL7QaRl0FdMU9nBciZD
1k37BR79bE/ndMB2ervhTko57u+UfgUpMv1jd7J7mKw4eHU6ab8y9scb6ITNV0zd
RuInJkSb0apRjBVK7YtW6loMwGrEbx2T42JQrbMzgMst+2EsSu3HJQtkFZ0dzEsn
CBNY4YSSr/yfeU00NFC8jeA3/Kmrb5qYBbdGPC2v67+9d8bvD+84aP8LdhT7Gpcl
+PnbGfnEvJFv7C8DbbGNqVvTNFGQzHvLAvLHC2Hp7so0pOvpz3njnlreXAtrWOaV
TZL5qKgeyag+SVDQ1Tv/nCVN1KOflj3u6y/Qf5/xjqZWaJI34ZxWUa97/o4UMc8o
kFRoZbf0kRCCEtwr+u3ff2XVactpeBHWoureIu8mG5cgMEJWu6qb+cJzxp9JDLti
5/GuDXILNaRSrcEzNIF++zsHJM6s1ZHEnG2mwyPNF/Vhag7iIL/nDvk1Sa27sXs3
Y7TUEJ7MBfyzt3rD9mbED2paKxnmQwEDI3hmLJGGBvwJYlFq3gToVtokuWC76nLL
SJ0UNLg8DrVBWU0MTt6JuzuBtt76A9g2w4ciEbMv9TFZvL3hoasy5OWVVw7acWDq
q2Btik0k2ChLLpFW26NWxxT5czAv+09a38BLd44cO0tx8TrYsoyjm9ZkyoX4GP/a
Oipb6nMAu6c=
=qLZm
-----END PGP SIGNATURE-----

--Sig_/j2Quy02R4QWcnfMqekAnlCh--
