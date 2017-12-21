Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:51755 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755161AbdLUVjT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Dec 2017 16:39:19 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: "neilb@suse.com" <neilb@suse.com>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC: "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH/RFC] NFS: add nostatflush mount option.
Date: Thu, 21 Dec 2017 21:39:13 +0000
Message-ID: <1513892346.20034.18.camel@primarydata.com>
References: <87k1xgkct1.fsf@notabene.neil.brown.name>
         <4B4DA4D4-8068-4C10-92BE-F03632522C75@oracle.com>
         <1513871689.11836.3.camel@primarydata.com>
         <87efnnkda2.fsf@notabene.neil.brown.name>
In-Reply-To: <87efnnkda2.fsf@notabene.neil.brown.name>
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="=-uCcSUqU/j3mn7FS3Do9J"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-uCcSUqU/j3mn7FS3Do9J
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2017-12-22 at 07:59 +1100, NeilBrown wrote:
> On Thu, Dec 21 2017, Trond Myklebust wrote:
>=20
> > On Thu, 2017-12-21 at 10:39 -0500, Chuck Lever wrote:
> > > Hi Neil-
> > >=20
> > >=20
> > > > On Dec 20, 2017, at 9:57 PM, NeilBrown <neilb@suse.com> wrote:
> > > >=20
> > > >=20
> > > > When an i_op->getattr() call is made on an NFS file
> > > > (typically from a 'stat' family system call), NFS
> > > > will first flush any dirty data to the server.
> > > >=20
> > > > This ensures that the mtime reported is correct and stable,
> > > > but has a performance penalty.  'stat' is normally thought
> > > > to be a quick operation, and imposing this cost can be
> > > > surprising.
> > >=20
> > > To be clear, this behavior is a POSIX requirement.
> > >=20
> > >=20
> > > > I have seen problems when one process is writing a large
> > > > file and another process performs "ls -l" on the containing
> > > > directory and is blocked for as long as it take to flush
> > > > all the dirty data to the server, which can be minutes.
> > >=20
> > > Yes, a well-known annoyance that cannot be addressed
> > > even with a write delegation.
> > >=20
> > >=20
> > > > I have also seen a legacy application which frequently calls
> > > > "fstat" on a file that it is writing to.  On a local
> > > > filesystem (and in the Solaris implementation of NFS) this
> > > > fstat call is cheap.  On Linux/NFS, the causes a noticeable
> > > > decrease in throughput.
> > >=20
> > > If the preceding write is small, Linux could be using
> > > a FILE_SYNC write, but Solaris could be using UNSTABLE.
> > >=20
> > >=20
> > > > The only circumstances where an application calling 'stat()'
> > > > might get an mtime which is not stable are times when some
> > > > other process is writing to the file and the two processes
> > > > are not using locking to ensure consistency, or when the one
> > > > process is both writing and stating.  In neither of these
> > > > cases is it reasonable to expect the mtime to be stable.
> > >=20
> > > I'm not convinced this is a strong enough rationale
> > > for claiming it is safe to disable the existing
> > > behavior.
> > >=20
> > > You've explained cases where the new behavior is
> > > reasonable, but do you have any examples where the
> > > new behavior would be a problem? There must be a
> > > reason why POSIX explicitly requires an up-to-date
> > > mtime.
> > >=20
> > > What guidance would nfs(5) give on when it is safe
> > > to specify the new mount option?
> > >=20
> > >=20
> > > > In the most common cases where mtime is important
> > > > (e.g. make), no other process has the file open, so there
> > > > will be no dirty data and the mtime will be stable.
> > >=20
> > > Isn't it also the case that make is a multi-process
> > > workload where one process modifies a file, then
> > > closes it (which triggers a flush), and then another
> > > process stats the file? The new mount option does
> > > not change the behavior of close(2), does it?
> > >=20
> > >=20
> > > > Rather than unilaterally changing this behavior of 'stat',
> > > > this patch adds a "nosyncflush" mount option to allow
> > > > sysadmins to have applications which are hurt by the current
> > > > behavior to disable it.
> > >=20
> > > IMO a mount option is at the wrong granularity. A
> > > mount point will be shared between applications that
> > > can tolerate the non-POSIX behavior and those that
> > > cannot, for instance.
> >=20
> > Agreed.=20
> >=20
> > The other thing to note here is that we now have an embryonic
> > statx()
> > system call, which allows the application itself to decide whether
> > or
> > not it needs up to date values for the atime/ctime/mtime. While we
> > haven't yet plumbed in the NFS side, the intention was always to
> > use
> > that information to turn off the writeback flushing when possible.
>=20
> Yes, if statx() were actually working, we could change the
> application
> to avoid the flush.  But then if changing the application were an
> option, I suspect that - for my current customer issue - we could
> just
> remove the fstat() calls.  I doubt they are really necessary.
> I think programmers often think of stat() (and particularly fstat())
> as
> fairly cheap and so they use it whenever convenient.  Only NFS
> violates
> this expectation.
>=20
> Also statx() is only a real solution if/when it gets widely
> used.  Will
> "ls -l" default to AT_STATX_DONT_SYNC ??
>=20
> Apart from the Posix requirement (which only requires that the
> timestamps be updated, not that the data be flushed), do you know of
> any
> value gained from flushing data before stat()?
>=20

POSIX requires that timestamps change as part of the read() or write()
system call.

IOW: if I do the following

   1. fd =3D open("foo", O_WRONLY)
   2. fstat(fd, &buf1);
   3. write(fd, "bar", 3)
   4. fstat(fd, &buf2);
   5. fstat(fd, &buf3);

then the requirement translates into the following:
 * The timestamps returned in 'buf1' should differ from the timestamps
   returned in 'buf2'.
 * However 'buf2' and 'buf3' must contain the same values.

The flush performed by the NFS client in order to service the stat() in
(4) ensures that the timestamps get updated on the server (as part of
servicing the WRITE rpc call), which normally ensures that their values
won't change later on.

Note, however, that the client does cheat a little by only flushing the
WRITEs, and by not waiting for a COMMIT to be issued. That is generally
safe, but it means that the server could reboot before we have time to
persist the data+metadata. If that were to happen, then the replay of
the WRITEs might indeed cause the timestamps to change in (5) (in
contravention of POSIX rules).

Cheers
  Trond

--=20
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

--=-uCcSUqU/j3mn7FS3Do9J
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEESQctxSBg8JpV8KqEZwvnipYKAPIFAlo8KfoACgkQZwvnipYK
APIZ1RAAt15UIWwN/J/1u70rQFQKLruyZHLhgaKF5jWIJTA7V6gJqs18gzuwHqTf
V+hpM4zaEuTiBgrzLs/QtuiY6djdNj0FLkF3G4amnP/As340QWXCcGlA9rHb31Pj
cosLGHLy5qWYORt4pfbsnqFWAFPL55AAG2Io14zcpsxTNRrX3iR+rdGq91CuscfA
X/lv0L5lRXBkoqDMH1fB4ldJLVMkWysjNAUztPLOj3qia97sYLiEMJUtknJ0cN0/
SJChunfzJV+UbmAHCMeeYuOXsn1lP6uSyZC6is5g/zt8R93snn9t/Y8G5nUcBU/8
Z8CQ0CokwluvEdj5d7bKAByAlD57JjUH7W/QsdKjAazpvdjZVG+U4kcIX8/qAkFc
QQTofFOclo9ScPkcHWRsUGSuXXmSLOgERBrerh+DC/8yQt2ALB4VOPTXOZwQG8+H
Rwl45FdgrOI7KJ8qnB7ow7FE1tCkMnF6kexglTrpYFfvkU9+UNnV4Ghj/OgTwQI0
wXKQ+BfNoenyZKUZy2G0IAurdqSd45uJafrrsllQYqou4EiGtl0EffciNB8sJBFK
mET00M1hV7DY2e5OdODg3KiCT8E+bfdlysTh/e34R2WQz198XmKZXhQH9qWKJjdr
e2ZkVbE8dw1RpgAPu66qglZf/4LgrfwjLLfdcjP8Avv6awxV0rA=
=rbXS
-----END PGP SIGNATURE-----

--=-uCcSUqU/j3mn7FS3Do9J--

