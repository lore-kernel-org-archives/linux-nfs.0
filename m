Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:55307 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752705AbdLVDRo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Dec 2017 22:17:44 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: "neilb@suse.com" <neilb@suse.com>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC: "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH/RFC] NFS: add nostatflush mount option.
Date: Fri, 22 Dec 2017 03:17:39 +0000
Message-ID: <1513912651.24909.5.camel@primarydata.com>
References: <87k1xgkct1.fsf@notabene.neil.brown.name>
         <4B4DA4D4-8068-4C10-92BE-F03632522C75@oracle.com>
         <1513871689.11836.3.camel@primarydata.com>
         <87efnnkda2.fsf@notabene.neil.brown.name>
         <1513892346.20034.18.camel@primarydata.com>
         <878tdvk8ud.fsf@notabene.neil.brown.name>
In-Reply-To: <878tdvk8ud.fsf@notabene.neil.brown.name>
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="=-+daW7vOwWHXZr8YKLLFw"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-+daW7vOwWHXZr8YKLLFw
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2017-12-22 at 09:35 +1100, NeilBrown wrote:
> On Thu, Dec 21 2017, Trond Myklebust wrote:
>=20
> > On Fri, 2017-12-22 at 07:59 +1100, NeilBrown wrote:
> > > On Thu, Dec 21 2017, Trond Myklebust wrote:
> > >=20
> > > > On Thu, 2017-12-21 at 10:39 -0500, Chuck Lever wrote:
> > > > > Hi Neil-
> > > > >=20
> > > > >=20
> > > > > > On Dec 20, 2017, at 9:57 PM, NeilBrown <neilb@suse.com>
> > > > > > wrote:
> > > > > >=20
> > > > > >=20
> > > > > > When an i_op->getattr() call is made on an NFS file
> > > > > > (typically from a 'stat' family system call), NFS
> > > > > > will first flush any dirty data to the server.
> > > > > >=20
> > > > > > This ensures that the mtime reported is correct and stable,
> > > > > > but has a performance penalty.  'stat' is normally thought
> > > > > > to be a quick operation, and imposing this cost can be
> > > > > > surprising.
> > > > >=20
> > > > > To be clear, this behavior is a POSIX requirement.
> > > > >=20
> > > > >=20
> > > > > > I have seen problems when one process is writing a large
> > > > > > file and another process performs "ls -l" on the containing
> > > > > > directory and is blocked for as long as it take to flush
> > > > > > all the dirty data to the server, which can be minutes.
> > > > >=20
> > > > > Yes, a well-known annoyance that cannot be addressed
> > > > > even with a write delegation.
> > > > >=20
> > > > >=20
> > > > > > I have also seen a legacy application which frequently
> > > > > > calls
> > > > > > "fstat" on a file that it is writing to.  On a local
> > > > > > filesystem (and in the Solaris implementation of NFS) this
> > > > > > fstat call is cheap.  On Linux/NFS, the causes a noticeable
> > > > > > decrease in throughput.
> > > > >=20
> > > > > If the preceding write is small, Linux could be using
> > > > > a FILE_SYNC write, but Solaris could be using UNSTABLE.
> > > > >=20
> > > > >=20
> > > > > > The only circumstances where an application calling
> > > > > > 'stat()'
> > > > > > might get an mtime which is not stable are times when some
> > > > > > other process is writing to the file and the two processes
> > > > > > are not using locking to ensure consistency, or when the
> > > > > > one
> > > > > > process is both writing and stating.  In neither of these
> > > > > > cases is it reasonable to expect the mtime to be stable.
> > > > >=20
> > > > > I'm not convinced this is a strong enough rationale
> > > > > for claiming it is safe to disable the existing
> > > > > behavior.
> > > > >=20
> > > > > You've explained cases where the new behavior is
> > > > > reasonable, but do you have any examples where the
> > > > > new behavior would be a problem? There must be a
> > > > > reason why POSIX explicitly requires an up-to-date
> > > > > mtime.
> > > > >=20
> > > > > What guidance would nfs(5) give on when it is safe
> > > > > to specify the new mount option?
> > > > >=20
> > > > >=20
> > > > > > In the most common cases where mtime is important
> > > > > > (e.g. make), no other process has the file open, so there
> > > > > > will be no dirty data and the mtime will be stable.
> > > > >=20
> > > > > Isn't it also the case that make is a multi-process
> > > > > workload where one process modifies a file, then
> > > > > closes it (which triggers a flush), and then another
> > > > > process stats the file? The new mount option does
> > > > > not change the behavior of close(2), does it?
> > > > >=20
> > > > >=20
> > > > > > Rather than unilaterally changing this behavior of 'stat',
> > > > > > this patch adds a "nosyncflush" mount option to allow
> > > > > > sysadmins to have applications which are hurt by the
> > > > > > current
> > > > > > behavior to disable it.
> > > > >=20
> > > > > IMO a mount option is at the wrong granularity. A
> > > > > mount point will be shared between applications that
> > > > > can tolerate the non-POSIX behavior and those that
> > > > > cannot, for instance.
> > > >=20
> > > > Agreed.=20
> > > >=20
> > > > The other thing to note here is that we now have an embryonic
> > > > statx()
> > > > system call, which allows the application itself to decide
> > > > whether
> > > > or
> > > > not it needs up to date values for the atime/ctime/mtime. While
> > > > we
> > > > haven't yet plumbed in the NFS side, the intention was always
> > > > to
> > > > use
> > > > that information to turn off the writeback flushing when
> > > > possible.
> > >=20
> > > Yes, if statx() were actually working, we could change the
> > > application
> > > to avoid the flush.  But then if changing the application were an
> > > option, I suspect that - for my current customer issue - we could
> > > just
> > > remove the fstat() calls.  I doubt they are really necessary.
> > > I think programmers often think of stat() (and particularly
> > > fstat())
> > > as
> > > fairly cheap and so they use it whenever convenient.  Only NFS
> > > violates
> > > this expectation.
> > >=20
> > > Also statx() is only a real solution if/when it gets widely
> > > used.  Will
> > > "ls -l" default to AT_STATX_DONT_SYNC ??
> > >=20
> > > Apart from the Posix requirement (which only requires that the
> > > timestamps be updated, not that the data be flushed), do you know
> > > of
> > > any
> > > value gained from flushing data before stat()?
> > >=20
> >=20
> > POSIX requires that timestamps change as part of the read() or
> > write()
> > system call.
>=20
> Does it require that they don't change at other times?

Yes.

> I see the (arguable) deviation from POSIX that I propose to be
> completely inline with the close-to-open consistency semantics that
> NFS
> already uses, which are weaker than what POSIX might suggest.
>=20
> As you didn't exactly answer the question, would it be fair to say
> that
> you don't know of any reason to flush-before-stat except that POSIX
> seems to require it?

The reason is to emulate POSIX semantics. That is the only reason, and
that is why when we added a statx() function, I asked that we allow the
application to specify that it doesn't need these POSIX semantics.


--=20
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

--=-+daW7vOwWHXZr8YKLLFw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEESQctxSBg8JpV8KqEZwvnipYKAPIFAlo8eUsACgkQZwvnipYK
APLrLg//QIp4JDXLfXu3374Vyc0vzQvDNQVRXmtT5VkpDUzce3y7NBz697iWaODH
M0Gl8K5sfIT5tg7PnuNt7tkVEEJjh2xP5uWsrsuHxCsy+eLW2PHzER49ErQP0oH9
iN+RvlH1lvflCWtoWvJHA3Hdozzr6bGCmZVqh20XcuonNPnKnUAvvvkYbK24S3sL
qfgQ+SazE/RIVF6ZxQbF6qUJQr1eMnFFKaQw+/0JlzF5FPW5R9Zguh21fyvHQ1iw
zt7YEFxTxzhTrDAGo4txGOfLKTiDjp8zLybgwjDYiqMUNIUnDyyFcnYoQP7jantx
aEP86W5VFsr4ffXm3ZBu+avTNhmM90MWkE/i4A6fDbdlXU+Csvi/2FEJYtpVvxcm
r+vlayT5KioFn/A1Il4JJKg4utHHoAliTbKxuzbiKAljWLXxgWKId3x6dvQjhr9Z
BETPSbqllWwatzHkzGg97sdpoJFcxCncmdW6R7PfkSPxYUUme9uN5kfLaNTdRoGV
RYI3Uqb0eMvz/mDGSzKoVJh98bxWpj+5YIFg1v8mmSKxVa+GhF/nm2xwDTzvP4B0
Q2vh0fI/ne8oKdXK23J8eTjgO3EON1SRP66c8tlO3MF9pIKwrbuFKnjNzSgjk88i
kJN9rIMEXoGYGZERDABulk1MthiF72ExBWpx/Pj4fOf/uQp0O7w=
=Kg/g
-----END PGP SIGNATURE-----

--=-+daW7vOwWHXZr8YKLLFw--

