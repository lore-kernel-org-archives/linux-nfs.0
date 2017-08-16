Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:50500 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752848AbdHPCoL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 15 Aug 2017 22:44:11 -0400
From: NeilBrown <neilb@suse.com>
To: Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        "viro\@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>
Date: Wed, 16 Aug 2017 12:43:58 +1000
Cc: "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "mkoutny\@suse.com" <mkoutny@suse.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel\@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: Do we really need d_weak_revalidate???
In-Reply-To: <1502705432.4978.1.camel@redhat.com>
References: <87bmnmrai9.fsf@notabene.neil.brown.name> <1502430944.3822.1.camel@primarydata.com> <1502449309.4950.2.camel@redhat.com> <87zib3niqn.fsf@notabene.neil.brown.name> <1502705432.4978.1.camel@redhat.com>
Message-ID: <877ey4nsep.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, Aug 14 2017, Jeff Layton wrote:

> On Mon, 2017-08-14 at 09:36 +1000, NeilBrown wrote:
>> On Fri, Aug 11 2017, Jeff Layton wrote:
>>=20
>> > On Fri, 2017-08-11 at 05:55 +0000, Trond Myklebust wrote:
>> > > On Fri, 2017-08-11 at 14:31 +1000, NeilBrown wrote:
>> > > > Funny story.  4.5 years ago we discarded the FS_REVAL_DOT superblo=
ck
>> > > > flag and introduced the d_weak_revalidate dentry operation instead.
>> > > > We duly removed the flag from NFS superblocks and NFSv4 superblock=
s,
>> > > > and added the new dentry operation to NFS dentries .... but not to
>> > > > NFSv4
>> > > > dentries.
>> > > >=20
>> > > > And nobody noticed.
>> > > >=20
>> > > > Until today.
>> > > >=20
>> > > > A customer reports a situation where mount(....,MS_REMOUNT,..) on =
an
>> > > > NFS
>> > > > filesystem hangs because the network has been deconfigured.  This
>> > > > makes
>> > > > perfect sense and I suggested a code change to fix the problem.
>> > > > However when a colleague was trying to reproduce the problem to
>> > > > validate
>> > > > the fix, he couldn't.  Then nor could I.
>> > > >=20
>> > > > The problem is trivially reproducible with NFSv3, and not at all w=
ith
>> > > > NFSv4.  The reason is the missing d_weak_revalidate.
>> > > >=20
>> > > > We could simply add d_weak_revalidate for NFSv4, but given that it
>> > > > has been missing for 4.5 years, and the only time anyone noticed w=
as
>> > > > when the ommission resulted in a better user experience, I do wond=
er
>> > > > if
>> > > > we need to.  Can we just discard d_weak_revalidate?  What purpose
>> > > > does
>> > > > it serve?  I couldn't find one.
>> > > >=20
>> > > > Thanks,
>> > > > NeilBrown
>> > > >=20
>> > > > For reference, see
>> > > > Commit: ecf3d1f1aa74 ("vfs: kill FS_REVAL_DOT by adding a
>> > > > d_weak_revalidate dentry op")
>> > > >=20
>> > > >=20
>> > > >=20
>> > > > To reproduce the problem at home, on a system that uses systemd:
>> > > > 1/ place (or find) a filesystem image in a file on an NFS filesyst=
em.
>> > > > 2/ mount the nfs filesystem with "noac" - choose v3 or v4
>> > > > 3/ loop-mount the filesystem image read-only somewhere
>> > > > 4/ reboot
>> > > >=20
>> > > > If you choose v4, the reboot will succeed, possibly after a 90seco=
nd
>> > > > timeout.
>> > > > If you choose v3, the reboot will hang indefinitely in systemd-
>> > > > shutdown while
>> > > > remounting the nfs filesystem read-only.
>> > > >=20
>> > > > If you don't use "noac" it can still hang, but only if something
>> > > > slows
>> > > > down the reboot enough that attributes have timed out by the time
>> > > > that
>> > > > systemd-shutdown runs.  This happens for our customer.
>> > > >=20
>> > > > If the loop-mounted filesystem is not read-only, you get other
>> > > > problems.
>> > > >=20
>> > > > We really want systemd to figure out that the loop-mount needs to =
be
>> > > > unmounted first.  I have ideas concerning that, but it is messy.  =
But
>> > > > that isn't the only bug here.
>> > >=20
>> > > The main purpose of d_weak_revalidate() was to catch the issues that
>> > > arise when someone changes the contents of the current working
>> > > directory or its parent on the server. Since '.' and '..' are treated
>> > > specially in the lookup code, they would not be revalidated without
>> > > special treatment. That leads to issues when looking up files as
>> > > ./<filename> or ../<filename>, since the client won't detect that its
>> > > dcache is stale until it tries to use the cached dentry+inode.
>> > >=20
>> > > The one thing that has changed since its introduction is, I believe,
>> > > the ESTALE handling in the VFS layer. That might fix a lot of the
>> > > dcache lookup bugs that were previously handled by d_weak_revalidate=
().
>> > > I haven't done an audit to figure out if it actually can handle all =
of
>> > > them.
>> > >=20
>> >=20
>> > It may also be related to 8033426e6bdb2690d302872ac1e1fadaec1a5581:
>> >=20
>> >     vfs: allow umount to handle mountpoints without revalidating them
>>=20
>> You say in the comment for that commit:
>>=20
>>      but there
>>     are cases where we do want to revalidate the root of the fs.
>>=20
>> Do you happen to remember what those cases are?
>>=20
>
> Not exactly, but I _think_ I might have been assuming that we needed to
> ensure that the inode attrs on the root were up to date after the
> pathwalk.
>
> I think that was probably wrong. d_revalidate is really intended to
> ensure that the dentry in question still points to the same inode. In
> the case of the root of the mount though, we don't really care about the
> dentry on the server at all. We're attaching the root of the mount to an
> inode and don't care of the dentry name changes. If we do need to ensure
> the inode attrs are updated, we'll just revalidate them at that point.
>
>> >=20
>> > Possibly the fact that we no longer try to revalidate during unmount
>> > means that this is no longer necessary?
>> >=20
>> > The original patch that added d_weak_revalidate had a reproducer in the
>> > patch description. Have you verified that that problem is still not
>> > reproducible when you remove d_weak_revalidate?
>>=20
>> I did try the reproducer and it works as expected both with and without
>> d_weak_revalidate.
>> On reflection, the problem it displayed was caused by d_revalidate()
>> being called when the dentry name was irrelevant.  We remove that
>> (fixing the problem) and introduce d_weak_revalidate because we thought
>> that minimum functionality was still useful.  I'm currently not
>> convinced that even that is needed.
>>=20
>> If we discarded d_weak_revalidate(), we could get rid of the special
>> handling of umount....
>
> I like idea. I say go for it and we can see what (if anything) breaks?

Getting rid of d_weak_revalidate is easy enough - hardly any users.

Getting rid of filename_mountpoint() isn't so easy unfortunately.
autofs4 uses kern_path_mountpoint() - presumably to avoid getting stuck
in autofs4_d_manage()?  It would be a shame to keep this infrastructure
around just so that one part of autofs4 can talk to another part of
autofs4.

Do you know if the fact that filename_mountpoint() skips ->d_manage is
important for sys_umount ??

Thanks,
NeilBrown


> --=20
> Jeff Layton <jlayton@redhat.com>

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlmTsXAACgkQOeye3VZi
gbl3tRAAu2HWFMSVnykYixyqptZDIJhhpg5HyEPjc9VUwvRFxSDqgLJD/A3EMEkG
ZFnvIhBSkpokpw9c4FvIMZyz/40+oUuJRyil8QcDhdlH9j7M3z9XCOQM+mPHSp8i
B30yMqvSXX0ryfvihWQv5WtiOSQouhL8hdUHDULxlsRVSjW+SKG7lPfbIWkwiKdU
vyW0jJVWFloBZQQ/dawhwwz+d9mtqqQvc1Lzy57ZRqyc1fiD74B2qWrUwwYonOpb
HBsulCtohGZQHRpvfg89eggSc5N/CYUTfDMSaYD4Z0bRDayREVRhWkOOwZUhlfYf
Bf+KXxCYMaQMHndAllfnjn4pfoZWvHAAZBEJmFsiAIroL4R5/09jmcvI3PuExrI5
WfPpY67rT38uYnaJ0fv8nYpiapuRR211F/5nzzWn2s0LbH5KPjK/VwYnvpcnAyDy
2uR42fN71x44YwOFGG++vi3GKD6JfF1eW6MlTXFN0cigNVxacvULaWLc2xzbhxXP
OS5vWG7s4c52RTRx0IyV356XithNpQp3+UDXEFMl+YLsDZjlMnKXcABL/HBr0H3W
SqbUVuUWk8Wx7GGPhU1JpQP67/HfB0jespxdITTGjZgsv417mB1FdO8FlwGhGMXa
KxbCON6kWxixfddWwCFFc8tYK1LrFFYemXUTWb1b18CPWZzNHq8=
=JeT1
-----END PGP SIGNATURE-----
--=-=-=--
