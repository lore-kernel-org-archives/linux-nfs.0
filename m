Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:47530 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757218AbaD2JZK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Apr 2014 05:25:10 -0400
Date: Tue, 29 Apr 2014 19:24:58 +1000
From: NeilBrown <neilb@suse.de>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
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
Message-ID: <20140429192458.641ebf1d@notabene.brown>
In-Reply-To: <535F6BC4.2090601@gmail.com>
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
	<20140428072845.67f48d8e@notabene.brown>
	<535F6BC4.2090601@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/V8T6ZgBeK+aX41RSFvafovr"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/V8T6ZgBeK+aX41RSFvafovr
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Tue, 29 Apr 2014 11:07:16 +0200 "Michael Kerrisk (man-pages)"
<mtk.manpages@gmail.com> wrote:

> On 04/27/2014 11:28 PM, NeilBrown wrote:
> > On Sun, 27 Apr 2014 13:11:33 +0200 "Michael Kerrisk (man-pages)"
> > <mtk.manpages@gmail.com> wrote:
> >=20
> >> On Sun, Apr 27, 2014 at 12:04 PM, NeilBrown <neilb@suse.de> wrote:
> >>> On Sun, 27 Apr 2014 11:16:02 +0200 "Michael Kerrisk (man-pages)"
> >>> <mtk.manpages@gmail.com> wrote:
> >>>
> >>>> [Trimming some folk from CC, and adding various NFS people]
> >>>>
> >>>> On 04/27/2014 06:51 AM, NeilBrown wrote:
> >>>>
> >>>> [...]
> >>>>
> >>>>> Note to Michael: The text
> >>>>>    flock() does not lock files over NFS.
> >>>>> in flock(2) is no longer accurate.  The reality is ... complex.
> >>>>> See nfs(5), and search for "local_lock".
> >>>>
> >>>> Ahhh -- I see:
> >>>> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commi=
t/?id=3D5eebde23223aeb0ad2d9e3be6590ff8bbfab0fc2
> >>>>
> >>>> Thanks for the heads up.
> >>>>
> >>>> Just in general, it would be great if the flock(2) and fcntl(2) man =
pages
> >>>> contained correct details for NFS, of course. So, for example, if th=
ere
> >>>> are any current gotchas for NFS and fcntl() byte-range locking, I'd =
like
> >>>> to add those to the fcntl(2) man page.
> >>>
> >>> The only peculiarities I can think of are:
> >>>  - With NFS, locking or unlocking a region forces a flush of any cach=
ed data
> >>>    for that file (or maybe for the region of the file).  I'm not sure=
 if this
> >>>    is worth mentioning.
> >>
> >> I agree that it's probably not necessary to mention.
> >>
> >>>  - With NFSv4 the client can lose a lock if it is out of contact with=
 the
> >>>    server for a period of time.  When this happens, any IO to the fil=
e by a
> >>>    process which "thinks" it holds a lock will fail until that proces=
s closes
> >>>    and re-opens the file.
> >>>    This behaviour is since 3.12.  Prior to that the client might lose=
 and
> >>>    regain the lock without ever knowing thus potentially risking corr=
uption
> >>>    (but only if client and server lost contact for an extended period=
).
> >>
> >> Do you have a pointer for that commit to 3.12?
> >>
> >=20
> > http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?=
id=3Def1820f9be27b6ad158f433ab38002ab8131db4d
> >=20
> > did most of the work while  the subsequent commit
> >=20
> > http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?=
id=3Df6de7a39c181dfb8a2c534661a53c73afb3081cd
> >=20
> > changed some details, added some documentation, and inverted the default
> > behaviour.
>=20
> Thanks for that detail. What do you think of the following text for the=20
> fcntl(2) man page:
>=20
>        Before  Linux 3.12, if an NFS client is out of contact with the
>        server for a period of time, it might lose and  regain  a  lock
>        without  ever  being  aware  of the fact.  This scenario poten=E2=
=80=90
>        tially risks  data  corruption,  since  another  process  might
>        acquire  a lock in the intervening period and perform file I/O.
>        Since Linux 3.12, if the client loses contact with the  server,
>        any I/O to the file by a process which "thinks" it holds a lock
>        will fail until that process closes and reopens  the  file.   A
>        kernel  parameter,  nfs.recover_lost_locks,  can be set to 1 to
>        obtain the pre-3.12 behavior, whereby the client  will  attempt
>        to  recover  lost  locks when contact is reestablished with the
>        server.  Because of the attendant risk of data corruption, this
>        parameter defaults to 0 (disabled).
>=20

Mostly good.

I'm just a little concerned about "if the client loses contact with the
server" in the middle there.  It is no longer qualified and it isn't clear
that the "for a period of time" qualification still applied.  And we should
probably quantify the period of time - which defaults to 90 seconds.
I don't remember just now the difference between
   /proc/fs/nfsd/nfsv4{lease,grace}time
but this 90 seconds is one of those.

Also this is NFSv4 specific.  With NFSv3 the failure mode is the reverse.  =
If
the server loses contact with a client then any lock stays in place
indefinitely ("why can't I read my mail"... I remember it well).

  Before Linux 3.12, if an NFSv4 client loses contact with the server
  (defined as more than 90 seconds with no communication), it might lose
  and regain ....

Just changing that bit should cover it I think.

NeilBrown

--Sig_/V8T6ZgBeK+aX41RSFvafovr
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU19v6jnsnt1WYoG5AQL8PA/9F69316JnwQsxLh77KdSBeGTjgVtPtYHw
9CX13E/Aj3zcRXpA1mz3vsoKxkNSDfmgzgxJV1Id+BnJP02IfhbR4AyOUt0MXNRs
8GXdTTlRMHOMjTKRvc01IxEs/8GtQUhqtANUNvLVR5nt6XvRaobMDYXjvklpWMV8
Hv+ZrNJuwPjag9hgWyfs29uscL9MI1y+Gov3mwygKS+zXJ3QD5x/9ZhHm8R8tvvs
dJ8ZYYoIyr3273E7xy6F8m7aOPDIwyKePz3XGFZyOLU6KsA6WSrDd0qVQFQiUyV2
FLszs0+VcfOoBYoCikKw2bKsqI0vvFyTvJEwTRSu13EMSAkHehj1cJnLaSM/BBG8
hxKIsFo87qnTlPJIuyLoxJd+nJLbJPYro0On4JGdOKAUHuKLU2ga5CWkbU3PLBpR
dQuio8OgJso1hvZLYAZ4yverE9RoQ2gjWKPrODgzxLzuioXQKZeQkTQuXiFN+x7r
Onadl3cDOMqDMudvAHl9CELSsd9ocN9QfUV0dOHag3pImwxb12rQcHv2XOncOtjj
OvurBTcYsykJeYsKAEC4tuBMDSd3iHtyCEkqLkQ6JUftKJ4FcH4pBR1nwZGp3kP6
vnOzFh765ppx10vg8Ts+Z+j2kaLBaX8xJ7DyO487lUSN+k7wmKl/MJZjemkVk1aP
pdY11zXLZAU=
=iYq2
-----END PGP SIGNATURE-----

--Sig_/V8T6ZgBeK+aX41RSFvafovr--
