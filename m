Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:54530 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753593AbdLNVwx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Dec 2017 16:52:53 -0500
From: NeilBrown <neilb@suse.com>
To: Joshua Watt <jpewhacker@gmail.com>,
        Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J . Bruce Fields" <bfields@fieldses.org>
Date: Fri, 15 Dec 2017 08:52:39 +1100
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        David Howells <dhowells@redhat.com>, linux-api@vger.kernel.org
Subject: Re: [RFC v4 0/9] NFS Force Unmounting
In-Reply-To: <1513275773.3888.20.camel@gmail.com>
References: <20171117174552.18722-1-JPEWhacker@gmail.com> <1512398194.7031.56.camel@gmail.com> <87indksq9q.fsf@notabene.neil.brown.name> <1512565420.4048.21.camel@redhat.com> <87bmjaq89r.fsf@notabene.neil.brown.name> <1513275773.3888.20.camel@gmail.com>
Message-ID: <876099nfiw.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Dec 14 2017, Joshua Watt wrote:

> On Fri, 2017-12-08 at 13:10 +1100, NeilBrown wrote:
>> On Wed, Dec 06 2017, Jeff Layton wrote:
>>=20
>> > On Wed, 2017-12-06 at 10:34 +1100, NeilBrown wrote:
>> > >=20
>> > > The new semantic for MNT_DETACH|MNT_FORCE is interesting.
>> > > As it was never possible before (from /bin/umount), it should be
>> > > safe to
>> > > add a new meaning.
>> > > The meaning is effectively "detach the filesystem from the
>> > > namespace and
>> > > detach the transport from the filesystem", which sounds like it
>> > > is
>> > > useful.
>> > > It is worth highlighting this, and maybe even cc:ing
>> > > linux-api@vger.kernel.org ... done that.
>> > >=20
>> >=20
>> > I'm not thrilled with the new flag combo, personally. Given that
>> > we're
>> > introducing new behavior here, I think it wouldn't hurt to add a
>> > new
>> > UMOUNT_* flag for this (UMOUNT_NUKE_FROM_ORBIT?).
>>=20
>> Suppose we did... MNT_FORCE_PONIES. What would be the semantics of
>> this
>> flag?  Once we had it, would anyone ever want to use MNT_FORCE again?
>>=20
>> MNT_FORCE is already fairly heavy handled.  It abort an arbitrary
>> collections of RPC requests being sent for the given filesystem, no
>> matter where else that filesystem might be mounted.
>> Is it ever safe to use this flag unless you have good reason to
>> believe
>> that the server is not available and there is no point pretending any
>> more?
>> And if that is the case, why not use the new MNT_FORCE_PONIES which
>> is
>> at least predictable and reliable.
>>=20
>> We've talking a lot about the one NFS filesystem being mounted in
>> multiple containers.  MNT_FORCE is already a problem for such mounts
>> as
>> one contains can kill requests generated from another
>> container.  Maybe
>> MNT_FORCE needs to be restricted to "real" root.
>> Once we restrict it, do we need to keep it from being too harsh?
>>=20
>> What would be really nice is a timeout for umount, and for sync.
>> The timeout only starts when the filesystem stops making progress for
>> writeback.  If it eventually does timeout, then the caller can fall
>> back
>> to MNT_DETACH if they are in a container, or MNT_FORCE if not.
>> (Maybe MNT_FORCE should map to MNT_DETACH in a container??? or maybe
>> not).
>>=20
>> There is a lot here that still isn't clear to me, but one this does
>> seem
>> to be becoming clear:  MNT_FORCE as it stands is nearly useless and
>> it
>> would serve is well to find a semantic that it actually useful, and
>> impose that.
>
> Trying to keep the discussion going... does anyone else have thoughts
> on this?

It's a challenge, isn't it ... keeping people on-task to make forward
progress.
If only we could all meet in the canteen at 4pm every Friday and discuss
these things over drinks.  I don't suppose any of the video conference
tools support timeshifting, so we can each do 4pm in our own time
zone....

I would like to arrange that nothing can block indefinitely on
=2D>s_umount.  This probably means that the various "flush data" calls
made under this lock need a timeout, or to be interruptible.
Then both umount and remount could be sure of getting ->s_umount
without undue delay.
Then I would like MNT_FORCE *not* to abort requests before trying to get
the lock, but instead to be passed down to ->kill_sb().
We probably cannot pass it explicitly, but could set a flag while
=2D>s_umount is held.
This flag might be handled by generic_shutdown_super(), causing
it to purge any unwritten data, rather than call sync_filesystems().

This way, if the filesystem is mounted elsewhere, then the MNT_FORCE has
no effect.  If it is a final mount, then it cleans up properly.

Your need to cause writes to start failing would be achieved by
performing a remount, either just setting "soft,retrans=3D0,timeo=3D1", or
by setting some special-purpose mount option.

In order for s_umount not to be held indefinite, the generic things that
need to be fixed include:
 __writeback_inodes_wb() calls writeback_sb_inodes() under the lock.
    This needs to be interruptible
 Same for try_to_writeback_inodes_sb() -> __writeback_inodes_sb_nr()
 sync_sync and do_sync_work call iterate_supers() with various handlers, an=
d these need
 to be interruptible.

and do_remount_sb needs to not block.

Finding a way to interrupt those writeback calls would be tricky,
especially as we need to trigger the interrupt without holding s_umount.

I really like the idea that an umount attempt would interrupt a sync().
Currently sync() can block indefinitely, which is occasionally
inconvenient.
If "umount" (or "umount -f" at least) on a filesystem would abort the
sync of that filesystem, take the lock and clean up more forcefully,
that would make for fairly clean shutdown processing.
1/ call sync() in a separate thread.
2/ wait until Dirty in /proc/meminfo stops changing
3/ umount -f every remaining filesystem.  Even if the
   umount fails, the sync will abort.


Part of this effort would require making sure that SIGKILL really kills
processes blocked on filesystem IO.

So:
 1/ make sure all filesystem IO waits are TASK_KILLABLE
 2/ find a way to interrupt any write-back wait when there is a pending
    remount or umount.  Possibly the write-back thing would need to
    retry after the umount/remount, I'm not sure.
 3/ Cause MNT_FORCE to set a superblock flag, and have
    generic_shutdown_super() and/or ->kill_sb() interpret this flag to
    be very forceful
 4/ Possibly introduce new NFS mount option which causes all requests
    to fail
 5/ Teach NFS to support remount of this option, and of soft, retrans,
    timeo.

How does that sound?

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAloy8qkACgkQOeye3VZi
gbldSg/+KTjub5/qvaOvMiaAUlprQtHGugaXVMZN5zzm5EUjjkz7a7b2k5EjU3uk
HSIZAjBA8oHWkrUjcXuZvAZkGDHEVYq4UED71vYb/N2dzCvtBl69NAOMr2UkT56S
AQFuQmAvxbARINTNBVujZryDHmBpoiUa8TEV5ETbG/AEYB9q7M9ZUbgHG/SaFs0+
I86AxnbpXRDlr0RuW6gBtBuUgKx1CxEsE4apkEuU15wmzW1DYcpB5cUzfAEi99VM
CDBtJV7Uz482LMPrn9HAfZQL+8pmDj8/OVzygRsHjuD0zC0IOgFsnXf6p0wKS3DK
mnOTnrJ3c84U/DZHaFpKTw9dZppCXzXjbWhneHT3lx6sY2Tkbd0hcmgobeR+Da9g
e8F7iREmn0Oce8f5Qfyy5+SbE+8JkzDXBee9Y7HYZMp5CtKkDSgo1wMGzsKir6Lf
RsNlNEkug37v1/GfKRqh6L9lLfPuOR01ck463UJJFd5z+RM4f3gyB6/C09lzPcDM
QMVH4xMlcqhJlq0og+dXG+VKsNibdG39tX0F/dyhCL7V7L8Htb2VfzysyKCm8kcs
io4i0lRfrDEZRZ0Loan/t/MvzXK3sPmov5qXZWAB1UMZ+cmdKuVw1HD8uTn2ULt8
cOnRrSDem0HLxjaVvNcltmBekRXn3oMyq4dgpHosuk9hyZKSUKU=
=xIw8
-----END PGP SIGNATURE-----
--=-=-=--
