Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:56288 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752165AbaE3Do5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 May 2014 23:44:57 -0400
Date: Fri, 30 May 2014 13:44:42 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: Live lock in silly-rename.
Message-ID: <20140530134442.5a8e5983@notabene.brown>
In-Reply-To: <20140530004423.GA13746@fieldses.org>
References: <20140529164521.02324559@notabene.brown>
	<CAHQdGtTtU9_zBcfzRb_wmEf7XaX9rNg-_Q85ZLX9BYax14D2Gg@mail.gmail.com>
	<20140530075135.753fb7ed@notabene.brown>
	<20140530004423.GA13746@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/TTjdCYQGx=XM5m6xaQ8/em7"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/TTjdCYQGx=XM5m6xaQ8/em7
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 29 May 2014 20:44:23 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Fri, May 30, 2014 at 07:51:35AM +1000, NeilBrown wrote:
> > On Thu, 29 May 2014 12:38:19 -0400 Trond Myklebust
> > <trond.myklebust@primarydata.com> wrote:
> >=20
> > > Apologies Neil. Resending due to gmail defaulting to html formatting
> > > which gets rejected by vger.kernel.org...
> > >=20
> > > On Thu, May 29, 2014 at 2:45 AM, NeilBrown <neilb@suse.de> wrote:
> > > >
> > > > The program below (provided by a customer) demonstrates a livelock =
that can
> > > > trigger in NFS.
> > > >
> > > > "/mnt" should be an NFSv4 mount from a server which will hand out R=
EAD
> > > > delegations (e.g. the Linux NFS server) and should contain a subdir=
ectory
> > > > "/mnt/data".
> > > >
> > > > The program forks off some worker threads which poll a particular f=
ile in
> > > > that directory until it disappears.  Then each worker will exit.
> > > > The main program waits a few seconds and then unlinks the file.
> > > >
> > > > The number of threads can be set with the first arg (4 is good). Th=
e number of
> > > > seconds with the second.  Both have useful defaults.
> > > >
> > > > The unlink should happen promptly and then all the workers should  =
exit.  But
> > > > they don't.
> > > >
> > > > What happens is that between when the "unlink" returns the delegati=
on that it
> > > > will inevitably have due to all those "open"s, and when it performs=
 the
> > > > required silly-rename (because some thread will have the file open)=
, some
> > > > other thread opens the file and gets a delegation.
> > > > So the NFSv4 RENAME returns NFS4ERR_DELAY while it tries to reclaim=
 the
> > > > delegation.  15 seconds later the rename will be retried, but there=
 will still
> > > > (or again) be an active delegation.  So the pattern repeats indefin=
itely.
> > > > All this time the i_mutex on the directory and file are held so "ls=
" on the
> > > > directory will also hang.
> > >=20
> > > Why would the server hand out another delegation just moments after it
> > > recalled the last one? That sounds like a nasty server bug.
> >=20
> > Exactly how long should it wait?
> > Bruce: do you have any thoughts on whether the server should hold off g=
iving
> > out new delegations after trying to recall one (e.g. due to a lease-bre=
ak
> > caused by rename)??
> > I don't suppose the RFC addresses this?
>=20
> Yes, it's a known server bug.
>=20
> As a first attempt I was thinking of just sticking a timestamp in struct
> inode to record the time of the most recent conflicting access and deny
> delegations if the timestamp is too recent, for some definition of too
> recent.
>=20

Hmmm... I'll have a look next week and see what I can come up with.

Thanks,
NeilBrown

--Sig_/TTjdCYQGx=XM5m6xaQ8/em7
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU4f+qjnsnt1WYoG5AQJuWw/9Es9ScKaOtH2RVSzGqUTatJcmqCDyvkJp
Z/YmGm/5WT5bMshhvAJLGYV2WIggbKwJl8+qqDonR/EWk7CwQaRqVXMFfEuTRaMk
xz2Lg0qoBxlt8nxKr9JauM88wuqjz1y18T4whNIO92R4jnUAvOwuh/PpyAZHtBir
Ib+LH48+la3WFEyGxD+u9PRFpPAJZ/PbGnSRWUCBYpBGAgeAJDLpcKzJOJVsJqot
hwZeVzd44ds7ig4XvakL5DM2nN6hodHkOc0yKxlieCQtDQBjPzId/F9auUlDQm6Z
R5w3Nt1w+FuIdHkMsAecDMHo1Z+AYqPLItLP+OqyaOlgHl3g9nOnPuAdDx9JFd6d
msbGmiHnuFo5EGtfDmfgZ8aApnfPyzAkMZEafXgLieNVOKHbXYVuOmDF/Cl6W+Gx
nAvVxClhJ6zrtP+iFWhQtbA7MIkENdnAjOGHfrskcyrjMljAMmtR3d9rAGNR+8hL
HD2RxEeYCRd4HKalK9zZpLYvAD11KMQQn8gZFwonTHSbCLiS7Rsi1rz0iHXp6QzF
DmmfpZqgTCv/hssnF4Gk2xDzofyAApBD72WF/1oGkW65OSQIfrtzM3X0zddR+mWJ
5hZmAZfGCXdL8YClrBJOltmZNHrNWUM4QnE1G2LjwJXwMnY6cNDqclH0byRn0Vm+
4QizWiLeGnk=
=j8Ii
-----END PGP SIGNATURE-----

--Sig_/TTjdCYQGx=XM5m6xaQ8/em7--
