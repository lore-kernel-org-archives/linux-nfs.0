Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:46749 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751202AbdHMXgL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 13 Aug 2017 19:36:11 -0400
From: NeilBrown <neilb@suse.com>
To: Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        "viro\@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>
Date: Mon, 14 Aug 2017 09:36:00 +1000
Cc: "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "mkoutny\@suse.com" <mkoutny@suse.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel\@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: Do we really need d_weak_revalidate???
In-Reply-To: <1502449309.4950.2.camel@redhat.com>
References: <87bmnmrai9.fsf@notabene.neil.brown.name> <1502430944.3822.1.camel@primarydata.com> <1502449309.4950.2.camel@redhat.com>
Message-ID: <87zib3niqn.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Aug 11 2017, Jeff Layton wrote:

> On Fri, 2017-08-11 at 05:55 +0000, Trond Myklebust wrote:
>> On Fri, 2017-08-11 at 14:31 +1000, NeilBrown wrote:
>> > Funny story.  4.5 years ago we discarded the FS_REVAL_DOT superblock
>> > flag and introduced the d_weak_revalidate dentry operation instead.
>> > We duly removed the flag from NFS superblocks and NFSv4 superblocks,
>> > and added the new dentry operation to NFS dentries .... but not to
>> > NFSv4
>> > dentries.
>> >=20
>> > And nobody noticed.
>> >=20
>> > Until today.
>> >=20
>> > A customer reports a situation where mount(....,MS_REMOUNT,..) on an
>> > NFS
>> > filesystem hangs because the network has been deconfigured.  This
>> > makes
>> > perfect sense and I suggested a code change to fix the problem.
>> > However when a colleague was trying to reproduce the problem to
>> > validate
>> > the fix, he couldn't.  Then nor could I.
>> >=20
>> > The problem is trivially reproducible with NFSv3, and not at all with
>> > NFSv4.  The reason is the missing d_weak_revalidate.
>> >=20
>> > We could simply add d_weak_revalidate for NFSv4, but given that it
>> > has been missing for 4.5 years, and the only time anyone noticed was
>> > when the ommission resulted in a better user experience, I do wonder
>> > if
>> > we need to.  Can we just discard d_weak_revalidate?  What purpose
>> > does
>> > it serve?  I couldn't find one.
>> >=20
>> > Thanks,
>> > NeilBrown
>> >=20
>> > For reference, see
>> > Commit: ecf3d1f1aa74 ("vfs: kill FS_REVAL_DOT by adding a
>> > d_weak_revalidate dentry op")
>> >=20
>> >=20
>> >=20
>> > To reproduce the problem at home, on a system that uses systemd:
>> > 1/ place (or find) a filesystem image in a file on an NFS filesystem.
>> > 2/ mount the nfs filesystem with "noac" - choose v3 or v4
>> > 3/ loop-mount the filesystem image read-only somewhere
>> > 4/ reboot
>> >=20
>> > If you choose v4, the reboot will succeed, possibly after a 90second
>> > timeout.
>> > If you choose v3, the reboot will hang indefinitely in systemd-
>> > shutdown while
>> > remounting the nfs filesystem read-only.
>> >=20
>> > If you don't use "noac" it can still hang, but only if something
>> > slows
>> > down the reboot enough that attributes have timed out by the time
>> > that
>> > systemd-shutdown runs.  This happens for our customer.
>> >=20
>> > If the loop-mounted filesystem is not read-only, you get other
>> > problems.
>> >=20
>> > We really want systemd to figure out that the loop-mount needs to be
>> > unmounted first.  I have ideas concerning that, but it is messy.  But
>> > that isn't the only bug here.
>>=20
>> The main purpose of d_weak_revalidate() was to catch the issues that
>> arise when someone changes the contents of the current working
>> directory or its parent on the server. Since '.' and '..' are treated
>> specially in the lookup code, they would not be revalidated without
>> special treatment. That leads to issues when looking up files as
>> ./<filename> or ../<filename>, since the client won't detect that its
>> dcache is stale until it tries to use the cached dentry+inode.
>>=20
>> The one thing that has changed since its introduction is, I believe,
>> the ESTALE handling in the VFS layer. That might fix a lot of the
>> dcache lookup bugs that were previously handled by d_weak_revalidate().
>> I haven't done an audit to figure out if it actually can handle all of
>> them.
>>=20
>
> It may also be related to 8033426e6bdb2690d302872ac1e1fadaec1a5581:
>
>     vfs: allow umount to handle mountpoints without revalidating them

You say in the comment for that commit:

     but there
    are cases where we do want to revalidate the root of the fs.

Do you happen to remember what those cases are?

>
> Possibly the fact that we no longer try to revalidate during unmount
> means that this is no longer necessary?
>
> The original patch that added d_weak_revalidate had a reproducer in the
> patch description. Have you verified that that problem is still not
> reproducible when you remove d_weak_revalidate?

I did try the reproducer and it works as expected both with and without
d_weak_revalidate.
On reflection, the problem it displayed was caused by d_revalidate()
being called when the dentry name was irrelevant.  We remove that
(fixing the problem) and introduce d_weak_revalidate because we thought
that minimum functionality was still useful.  I'm currently not
convinced that even that is needed.

If we discarded d_weak_revalidate(), we could get rid of the special
handling of umount....

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlmQ4mIACgkQOeye3VZi
gblwBg//av/9arcu4iELi0rQ2SeeaZ4qz88mmYMxlPK9J9pXxm9BPzfsEIwVm4EY
1/ZGEFq3O6Djjv4x3CKHcfxBqu0PjOJ1GPAzxxIAbWlJdTgkHZPD2xdOCtqiIx1G
labxcRgfn+YOyBLBqTvZF3ngCIiMIJi3xWVjqRHvF2r38DUIB+clWi775aMFuZoT
MiB6z4vfEHwTZuyEdsXzFT7dZO9tDT3FVAcn3wUNhpd2p0xJRTf9KntfWZ4XeKqy
Q3XJ0fY16JZIETwraKXeQlLGz8t1oihHu9TWpFPz7hDMHguDIC53gyPX5IdWUlQ9
3e4FoGvhVh4lYon1DbYeY2wFTD91WLkawZm2f3Nt1zOYumPtbhfN/e/QrdB+yA6i
BxeSsRjNaupFIkhQsPbZpzarSxEyNxdCPNcWbGC/PVs5CC1/Ci33aEfTKev1P245
Vh4o3+GuC8cWV88lvXBadostKBmOfLT9xL57gYIGRtCzi8VQhDGyFuZ1SCMGUmVP
Zm1kFopoyaTJXFyj+A3Gg/+sefu/2j2kh3SLghP7IbDbv9lKz3gNwPVU2cHaTI8+
MfIHapjhzZAtszHOdB/2zdb2rXPLqizRR0e70MT6T/pTMODdRFXZc67+eeLj1FP0
awZSPEmBSN75JoNicbcL+xFq85ZxsmzLntPFur9GDUjUiqDH1qw=
=n5T7
-----END PGP SIGNATURE-----
--=-=-=--
