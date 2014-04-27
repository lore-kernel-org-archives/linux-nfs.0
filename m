Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:38915 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753160AbaD0KEp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 27 Apr 2014 06:04:45 -0400
Date: Sun, 27 Apr 2014 20:04:31 +1000
From: NeilBrown <neilb@suse.de>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: "Stefan (metze) Metzmacher" <metze@samba.org>,
        Jeff Layton <jlayton@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Ganesha NFS List <nfs-ganesha-devel@lists.sourceforge.net>,
        Suresh Jayaraman <sjayaraman@suse.de>,
        Trond Myklebust <trond.myklebust@fys.uio.no>,
        Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: flock() and NFS [Was: Re: [PATCH] locks: rename file-private
 locks to file-description locks]
Message-ID: <20140427200431.426c98d1@notabene.brown>
In-Reply-To: <535CCAD2.4060304@gmail.com>
References: <1398087935-14001-1-git-send-email-jlayton@redhat.com>
	<20140421140246.GB26358@brightrain.aerifal.cx>
	<535529FA.8070709@gmail.com>
	<20140421161004.GC26358@brightrain.aerifal.cx>
	<5355644C.7000801@gmail.com>
	<20140421184640.GD26358@brightrain.aerifal.cx>
	<535573E0.9080106@gmail.com>
	<20140421155520.3b33fbef@ipyr.poochiereds.net>
	<53558A73.3010602@samba.org>
	<5355F60C.8010004@gmail.com>
	<20140427145125.21e7e6c6@notabene.brown>
	<535CCAD2.4060304@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/b_Cw9pVrnZdG+ROhM72w9ER"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/b_Cw9pVrnZdG+ROhM72w9ER
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun, 27 Apr 2014 11:16:02 +0200 "Michael Kerrisk (man-pages)"
<mtk.manpages@gmail.com> wrote:

> [Trimming some folk from CC, and adding various NFS people]
>=20
> On 04/27/2014 06:51 AM, NeilBrown wrote:
>=20
> [...]
>=20
> > Note to Michael: The text
> >    flock() does not lock files over NFS.
> > in flock(2) is no longer accurate.  The reality is ... complex.
> > See nfs(5), and search for "local_lock".
>=20
> Ahhh -- I see:=20
> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=
=3D5eebde23223aeb0ad2d9e3be6590ff8bbfab0fc2
>=20
> Thanks for the heads up.
>=20
> Just in general, it would be great if the flock(2) and fcntl(2) man pages
> contained correct details for NFS, of course. So, for example, if there=20
> are any current gotchas for NFS and fcntl() byte-range locking, I'd like=
=20
> to add those to the fcntl(2) man page.

The only peculiarities I can think of are:
 - With NFS, locking or unlocking a region forces a flush of any cached dat=
a=20
   for that file (or maybe for the region of the file).  I'm not sure if th=
is
   is worth mentioning.

 - With NFSv4 the client can lose a lock if it is out of contact with the
   server for a period of time.  When this happens, any IO to the file by a
   process which "thinks" it holds a lock will fail until that process clos=
es
   and re-opens the file.
   This behaviour is since 3.12.  Prior to that the client might lose and
   regain the lock without ever knowing thus potentially risking corruption
   (but only if client and server lost contact for an extended period).

>=20
> Anyway, returning to your point about flock(), how would this text
> look for the flock(2) manual page:
>=20
>     NOTES
>        Since  kernel  2.0,  flock() is implemented as a system call in
>        its own right rather than being emulated in the GNU  C  library
>        as  a  call  to fcntl(2).  This yields classical BSD semantics:
>        there is no interaction between the types  of  lock  placed  by
>        flock()  and  fcntl(2),  and  flock() does not detect deadlock.
>        (Note, however, that on some modern BSDs, flock() and  fcntl(2)
>        locks do interact with one another.)
>=20
>        In Linux kernels up to 2.6.11, flock() does not lock files over
>        NFS (i.e., the scope of locks was limited to the local system).
>        Instead,  one could use fcntl(2) byte-range locking, which does
>        work over NFS, given a sufficiently recent version of Linux and
>        a  server  which  supports  locking.   Since  Linux 2.6.12, NFS
>        clients support flock() locks by emulating them  as  byte-range
>        locks on the entire file.  This means that fcntl(2) and flock()
>        locks do interact with  one  another  over  NFS.   Since  Linux
>        2.6.37,  the  kernel  supports a compatibility mode that allows
>        flock() locks (and also  fcntl(2)  byte  region  locks)  to  be
>        treated  as  local; see the discussion of the local_lock option
>        in nfs(5).
> ?

That seems to cover it quite well - thanks.

NeilBrown

>=20
> Thanks,
>=20
> Michael
>=20
>=20


--Sig_/b_Cw9pVrnZdG+ROhM72w9ER
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU1zWLznsnt1WYoG5AQIQ1xAAvhAxQJlDBiviYnwNPdtQGyNrsoYskQYw
LuGtp/ZetrLoQd8UVXqsToMbrkadmua2Adi8e8WGaAPenA6ApW4jxATqnraLIpSQ
toROSemWPYQJQ16RWcwYWspmtOc07qIyy271OU/bHulQPGNlkrAfemmMRIhIhMb/
kM38QJT+Tew9pvquvbMvBKOuwE6LsrfXpNMYOhr8WzHdCS8eWbljPr1DwTDcV2OZ
i9p/liLE65NXEZepK5sCHTv48kNQsgnnAVRXWUX6+je4/4eSbvpRo/UN92fTStby
jDnsNQKp0xEtaPYXjvjDb3A6+f19MelNlZ1Dk2KBO9ro3ZdWoXPsfx+UX412QfoU
uGPjhuNUBULoeQDbgn9gpzW1rr2RQCiBQQ5Jwoe6//N5ucUPfbVMpPU/A+YKi0jb
9M+ex89w8d1foWSwqFrB8w0B+g/XKTo72+nckQUJVgQILXmlhYtucm9SazrXnSYe
i7gpjNCdBF7uN2EfPYMcx/osU7yD++LsMXgV7u4xvVphfwD+P0C0IDUeXY9t7Itp
lEQpcIXEHWuRsez4sEGBD2ZcEe565mAG9udqoJO/NfHGyDceFlSkAoZsMKPlBw5T
dq9aOsMfYf7omkRnGfK41rKthNMJFZRCHDqXgBUe0VrZUlL8K24htbHltd8l0+d5
I5jhP0p3c98=
=VmRa
-----END PGP SIGNATURE-----

--Sig_/b_Cw9pVrnZdG+ROhM72w9ER--
