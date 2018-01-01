Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:35829 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751497AbeAAX3Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 1 Jan 2018 18:29:24 -0500
From: NeilBrown <neilb@suse.com>
To: Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trondmy@primarydata.com>,
        "chuck.lever\@oracle.com" <chuck.lever@oracle.com>
Date: Tue, 02 Jan 2018 10:29:14 +1100
Cc: "Anna.Schumaker\@netapp.com" <Anna.Schumaker@netapp.com>,
        "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel\@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH/RFC] NFS: add nostatflush mount option.
In-Reply-To: <1514035013.3425.8.camel@kernel.org>
References: <87k1xgkct1.fsf@notabene.neil.brown.name> <4B4DA4D4-8068-4C10-92BE-F03632522C75@oracle.com> <1513871689.11836.3.camel@primarydata.com> <87efnnkda2.fsf@notabene.neil.brown.name> <1514035013.3425.8.camel@kernel.org>
Message-ID: <87d12tf99x.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, Dec 23 2017, Jeff Layton wrote:

> On Fri, 2017-12-22 at 07:59 +1100, NeilBrown wrote:
>> On Thu, Dec 21 2017, Trond Myklebust wrote:
>>=20
>> > On Thu, 2017-12-21 at 10:39 -0500, Chuck Lever wrote:
>> > > Hi Neil-
>> > >=20
>> > >=20
>> > > > On Dec 20, 2017, at 9:57 PM, NeilBrown <neilb@suse.com> wrote:
>> > > >=20
>> > > >=20
>> > > > When an i_op->getattr() call is made on an NFS file
>> > > > (typically from a 'stat' family system call), NFS
>> > > > will first flush any dirty data to the server.
>> > > >=20
>> > > > This ensures that the mtime reported is correct and stable,
>> > > > but has a performance penalty.  'stat' is normally thought
>> > > > to be a quick operation, and imposing this cost can be
>> > > > surprising.
>> > >=20
>> > > To be clear, this behavior is a POSIX requirement.
>> > >=20
>> > >=20
>> > > > I have seen problems when one process is writing a large
>> > > > file and another process performs "ls -l" on the containing
>> > > > directory and is blocked for as long as it take to flush
>> > > > all the dirty data to the server, which can be minutes.
>> > >=20
>> > > Yes, a well-known annoyance that cannot be addressed
>> > > even with a write delegation.
>> > >=20
>> > >=20
>> > > > I have also seen a legacy application which frequently calls
>> > > > "fstat" on a file that it is writing to.  On a local
>> > > > filesystem (and in the Solaris implementation of NFS) this
>> > > > fstat call is cheap.  On Linux/NFS, the causes a noticeable
>> > > > decrease in throughput.
>> > >=20
>> > > If the preceding write is small, Linux could be using
>> > > a FILE_SYNC write, but Solaris could be using UNSTABLE.
>> > >=20
>> > >=20
>> > > > The only circumstances where an application calling 'stat()'
>> > > > might get an mtime which is not stable are times when some
>> > > > other process is writing to the file and the two processes
>> > > > are not using locking to ensure consistency, or when the one
>> > > > process is both writing and stating.  In neither of these
>> > > > cases is it reasonable to expect the mtime to be stable.
>> > >=20
>> > > I'm not convinced this is a strong enough rationale
>> > > for claiming it is safe to disable the existing
>> > > behavior.
>> > >=20
>> > > You've explained cases where the new behavior is
>> > > reasonable, but do you have any examples where the
>> > > new behavior would be a problem? There must be a
>> > > reason why POSIX explicitly requires an up-to-date
>> > > mtime.
>> > >=20
>> > > What guidance would nfs(5) give on when it is safe
>> > > to specify the new mount option?
>> > >=20
>> > >=20
>> > > > In the most common cases where mtime is important
>> > > > (e.g. make), no other process has the file open, so there
>> > > > will be no dirty data and the mtime will be stable.
>> > >=20
>> > > Isn't it also the case that make is a multi-process
>> > > workload where one process modifies a file, then
>> > > closes it (which triggers a flush), and then another
>> > > process stats the file? The new mount option does
>> > > not change the behavior of close(2), does it?
>> > >=20
>> > >=20
>> > > > Rather than unilaterally changing this behavior of 'stat',
>> > > > this patch adds a "nosyncflush" mount option to allow
>> > > > sysadmins to have applications which are hurt by the current
>> > > > behavior to disable it.
>> > >=20
>> > > IMO a mount option is at the wrong granularity. A
>> > > mount point will be shared between applications that
>> > > can tolerate the non-POSIX behavior and those that
>> > > cannot, for instance.
>> >=20
>> > Agreed.=20
>> >=20
>> > The other thing to note here is that we now have an embryonic statx()
>> > system call, which allows the application itself to decide whether or
>> > not it needs up to date values for the atime/ctime/mtime. While we
>> > haven't yet plumbed in the NFS side, the intention was always to use
>> > that information to turn off the writeback flushing when possible.
>>=20
>> Yes, if statx() were actually working, we could change the application
>> to avoid the flush.  But then if changing the application were an
>> option, I suspect that - for my current customer issue - we could just
>> remove the fstat() calls.  I doubt they are really necessary.
>> I think programmers often think of stat() (and particularly fstat()) as
>> fairly cheap and so they use it whenever convenient.  Only NFS violates
>> this expectation.
>>=20
>> Also statx() is only a real solution if/when it gets widely used.  Will
>> "ls -l" default to AT_STATX_DONT_SYNC ??
>>=20
>
> Maybe. Eventually, I could see glibc converting normal stat/fstat/etc.
> to use a statx() syscall under the hood (similar to how stat syscalls on
> 32-bit arches will use stat64 in most cases).
>
> With that, we could look at any number of ways to sneak a "don't flush"
> flag into the call. Maybe an environment variable that causes the stat
> syscall wrapper to add it? I think there are possibilities there that
> don't necessarily require recompiling applications.

Thanks - interesting ideas.

One possibility would be an LD_PRELOAD which implements fstat() using
statx().
That doesn't address the "ls -l is needlessly slow" problem, but it
would address the "legacy application calls fstat too often" problem.

This isn't an option for the "enterprise kernel" the customer is using
(statx?  what is statx?), but having a clear view of a credible
upstream solution is very helpful.

So thanks - and thanks a lot to Trond and Chuck for your input.  It
helped clarify my thoughts a lot.

Is anyone working on proper statx support for NFS, or is it a case of
"that shouldn't be hard and we should do that, but it isn't a high
priority for anyone" ??

Thanks,
NeilBrown


>
>> Apart from the Posix requirement (which only requires that the
>> timestamps be updated, not that the data be flushed), do you know of any
>> value gained from flushing data before stat()?
>>=20
> --=20
> Jeff Layton <jlayton@kernel.org>

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlpKxEoACgkQOeye3VZi
gblczQ//V/no+gSJBlLi3khR6RBIYtq8t5I1aPMkUhwMSRcMAhp491mc56lrlAD0
zQbMSCGY2B3MtB0V7zNnKNhVzM0hMARTgGRXBY7QwhIDUNU33EFCNjwSKVpcY0Oh
Ib13aHAnxDhWEBTYxR+p4oRSZVvJnhiW5gks9KIfxoVTgxfoSFNbM7ZfypTj+Wyb
3tijI/KBUaVvHESrSjKeUh9VOe3eBtM1VM7cWBbRTwt0pHKhhh9XNyM0PP6nL1/2
NQViGfflkslWtxE1GpV66kZYUsdaawJ4P25nOpvHq25t6fdF4NWb5pAy2x8VlNei
MOwldqUJjSN4iBjfBn7itjOhZS78Z1upr9VaVK+E2fa9COiL1L6piCn4gFIEUo3N
GhETogIYSvQgZu4bvTOB8uID5M1X6nKQ9dKvNT/wPPcIzTmub4pEjJeGKfDE84gy
l1YhaJtUpdSvYFvcXEmN24kTr9m5z6RUNn8qxikWKsoDZzt74MU2vq+ZDpDujjqP
TZOrGVrep5xEjabLUwq1eKBY6d9TYud+gMFEen9E3sM3KUkWfA7hBWnMWhDOQ+po
ZhTlUGBOdiO4xpJDpjmmDjzTeiklMT1jHpanI8AuhOgoqtcb4MgSBd+a+JhwuQX6
d96Hc7uomsMnoouMoCHgiuQaUhRGPYqSzXEwHdtR6lCiEB4IzC0=
=OTIi
-----END PGP SIGNATURE-----
--=-=-=--
