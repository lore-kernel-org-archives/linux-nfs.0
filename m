Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:45641 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751307AbaD0V27 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 27 Apr 2014 17:28:59 -0400
Date: Mon, 28 Apr 2014 07:28:45 +1000
From: NeilBrown <neilb@suse.de>
To: mtk.manpages@gmail.com
Cc: "Stefan (metze) Metzmacher" <metze@samba.org>,
        Jeff Layton <jlayton@redhat.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        lkml <linux-kernel@vger.kernel.org>,
        Ganesha NFS List <nfs-ganesha-devel@lists.sourceforge.net>,
        Suresh Jayaraman <sjayaraman@suse.de>,
        Trond Myklebust <trond.myklebust@fys.uio.no>,
        Christoph Hellwig <hch@infradead.org>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: flock() and NFS [Was: Re: [PATCH] locks: rename file-private
 locks to file-description locks]
Message-ID: <20140428072845.67f48d8e@notabene.brown>
In-Reply-To: <CAKgNAkgv5NqDRUNu0XtSABqmctd7=rpMMEYhhDQNzPssZuU5bA@mail.gmail.com>
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
	<20140427200431.426c98d1@notabene.brown>
	<CAKgNAkgv5NqDRUNu0XtSABqmctd7=rpMMEYhhDQNzPssZuU5bA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/ZIGdo29z7TB8ycfHs/WvBy+"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/ZIGdo29z7TB8ycfHs/WvBy+
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun, 27 Apr 2014 13:11:33 +0200 "Michael Kerrisk (man-pages)"
<mtk.manpages@gmail.com> wrote:

> On Sun, Apr 27, 2014 at 12:04 PM, NeilBrown <neilb@suse.de> wrote:
> > On Sun, 27 Apr 2014 11:16:02 +0200 "Michael Kerrisk (man-pages)"
> > <mtk.manpages@gmail.com> wrote:
> >
> >> [Trimming some folk from CC, and adding various NFS people]
> >>
> >> On 04/27/2014 06:51 AM, NeilBrown wrote:
> >>
> >> [...]
> >>
> >> > Note to Michael: The text
> >> >    flock() does not lock files over NFS.
> >> > in flock(2) is no longer accurate.  The reality is ... complex.
> >> > See nfs(5), and search for "local_lock".
> >>
> >> Ahhh -- I see:
> >> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/=
?id=3D5eebde23223aeb0ad2d9e3be6590ff8bbfab0fc2
> >>
> >> Thanks for the heads up.
> >>
> >> Just in general, it would be great if the flock(2) and fcntl(2) man pa=
ges
> >> contained correct details for NFS, of course. So, for example, if there
> >> are any current gotchas for NFS and fcntl() byte-range locking, I'd li=
ke
> >> to add those to the fcntl(2) man page.
> >
> > The only peculiarities I can think of are:
> >  - With NFS, locking or unlocking a region forces a flush of any cached=
 data
> >    for that file (or maybe for the region of the file).  I'm not sure i=
f this
> >    is worth mentioning.
>=20
> I agree that it's probably not necessary to mention.
>=20
> >  - With NFSv4 the client can lose a lock if it is out of contact with t=
he
> >    server for a period of time.  When this happens, any IO to the file =
by a
> >    process which "thinks" it holds a lock will fail until that process =
closes
> >    and re-opens the file.
> >    This behaviour is since 3.12.  Prior to that the client might lose a=
nd
> >    regain the lock without ever knowing thus potentially risking corrup=
tion
> >    (but only if client and server lost contact for an extended period).
>=20
> Do you have a pointer for that commit to 3.12?
>=20

http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=
=3Def1820f9be27b6ad158f433ab38002ab8131db4d

did most of the work while  the subsequent commit

http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=
=3Df6de7a39c181dfb8a2c534661a53c73afb3081cd

changed some details, added some documentation, and inverted the default
behaviour.

NeilBrown

--Sig_/ZIGdo29z7TB8ycfHs/WvBy+
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU112jTnsnt1WYoG5AQKCaQ/9GB7och1pfK+9ZqEweSn5+CM1AXKxwjoA
surwNnWh1+5kRtcu6JH4T2wbs4Y15z6A683N+MWX0hDc2G7Ec+xPGXjCX3HVSZc5
r6tiaI71eeSawvIeKTfpeAS1p8HBZG0LakM1TYA70CkcE5ZJ5PlR39iZM5+B1Lwt
c24BcCrZQKO1m3Xjd1VEGIYxx6OQDT/j9yo3Sds099bUvQ4qU2rOQlmABrDIrnKR
WiZo5xWVBrcU2cN/kpU0e0Rw3M2Ppzlicjoiqz1HGr4VuaYB5JXyrFVSkjfK/9Fe
r/CbCELvkUDEmOTg4w5vaVtvd0WZAD8GkCaC4K7LO99vF/yF5Mz7iwT7ohswffqJ
SOPrhdpN9rZ0C7sgWI5PR1DexU3LA1Pfrv77+/FzYB0KpMhduoA58S21vRj7agDk
YAtYE0wBfp3KzPsqVIyUBifDp/4v8vAO4r3XvqBnr3BAFvTI8jvtFKeHrS8Mn6cn
UiPdiEhL621SJOIiholf5OtllzBVx4P6aNHmC/wjMFjRwRcFHhTsk4ASfJ9bw1ws
IF5qhnOO5SYoviyLBOH93a5rhqTW7QGY7sutvi17e+Ou/P0IJebZPgSBK+WiLCtA
qwzS5mUb9mPPg9LOBfnJYmBz/VlsEKOYfW0XLjASApx/29EwKP4iwsal/oiViGSf
Cs7CSn/yaMU=
=A47O
-----END PGP SIGNATURE-----

--Sig_/ZIGdo29z7TB8ycfHs/WvBy+--
